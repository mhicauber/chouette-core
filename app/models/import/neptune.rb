class Import::Neptune < Import::Base
  include LocalImportSupport

  def self.accepts_file?(file)
    Zip::File.open(file) do |zip_file|
      files_count = zip_file.glob('*').size
      files_count -= zip_file.glob('metadata*.txt').size
      zip_file.glob('*.xml').size == files_count
    end
  rescue => e
    Rails.logger.debug "Error in testing Neptune file: #{e}"
    return false
  end

  def launch_worker
    NeptuneImportWorker.perform_async_or_fail(self)
  end

  def import_without_status
    prepare_referential

    import_resources :time_tables
    fix_metadatas_periodes
    import_resources :stop_areas
  end

  def prepare_referential
    import_resources :lines, :companies

    create_referential
    referential.switch
  end

  def referential_metadata
    # we use a mock periode, and will fix it once we have imported the timetables
    periode = (Time.now..1.month.from_now)
    ReferentialMetadata.new line_ids: @imported_line_ids, periodes: [periode]
  end

  protected

  def each_source
    Zip::File.open(local_file) do |zip_file|
      zip_file.glob('*.xml').each do |f|
        yield Nokogiri::XML(f.get_input_stream)
      end
    end
  end

  def each_element_matching_css(selector)
    each_source do |source|
      source.css(selector)\
            .map(&method(:build_object_from_nokogiri_element))\
            .each do |object|
          yield object
      end
    end
  end

  def import_lines
    each_element_matching_css('ChouettePTNetwork ChouetteLineDescription Line') do |source_line|
      line = line_referential.lines.find_or_initialize_by registration_number: source_line[:object_id]
      line.name = source_line[:name]
      line.number = source_line[:number]
      line.published_name = source_line[:published_name]
      line.comment = source_line[:comment]
      line.transport_mode, line.transport_submode = transport_mode_name_mapping(source_line[:transport_mode_name])

      save_model line
      @imported_line_ids ||= []
      @imported_line_ids << line.id
    end
  end

  def import_companies
    each_element_matching_css('ChouettePTNetwork Company') do |source_company|
      company = line_referential.companies.find_or_initialize_by registration_number: source_company.delete(:object_id)
      company.assign_attributes source_company.slice(:name, :short_name, :code, :phone, :email, :fax, :organizational_unit, :operating_department_name)

      save_model company
    end
  end

  def import_time_tables
    each_element_matching_css('ChouettePTNetwork Timetable') do |source_timetable|
      tt = Chouette::TimeTable.find_or_initialize_by objectid: source_timetable[:object_id]
      tt.int_day_types = int_day_types_mapping source_timetable[:day_type]
      tt.created_at = source_timetable[:creation_time]
      tt.comment = source_timetable[:comment].presence || source_timetable[:object_id]
      tt.metadata = { creator_username: source_timetable[:creator_id] }
      save_model tt
      add_time_table_dates tt, source_timetable[:calendar_day]
      add_time_table_periods tt, source_timetable[:period]
    end
  end

  def add_time_table_dates(timetable, dates)
    return unless dates

    dates = [dates] unless dates.is_a?(Array)
    dates.each do |date|
      @timetables_period_start = [@timetables_period_start, date.to_date].compact.min
      @timetables_period_end = [@timetables_period_end, date.to_date].compact.max
      next if timetable.dates.where(in_out: true, date: date).exists?

      timetable.dates.create(in_out: true, date: date)
    end
  end

  def add_time_table_periods(timetable, periods)
    return unless periods

    periods = [periods] unless periods.is_a?(Array)
    periods.each do |period|
      @timetables_period_start = [@timetables_period_start, period[:start_of_period].to_date].compact.min
      @timetables_period_end = [@timetables_period_end, period[:end_of_period].to_date].compact.max

      timetable.periods.build(period_start: period[:start_of_period], period_end: period[:end_of_period])
    end
    timetable.periods = timetable.optimize_overlapping_periods
  end

  def int_day_types_mapping day_types
    day_types = [day_types] unless day_types.is_a?(Array)

    val = 0
    day_types.each do |day_type|
      day_value = case day_type.downcase
      when 'monday'
        Chouette::TimeTable::MONDAY
      when 'tuesday'
        Chouette::TimeTable::TUESDAY
      when 'wednesday'
        Chouette::TimeTable::WEDNESDAY
      when 'thursday'
        Chouette::TimeTable::THURSDAY
      when 'friday'
        Chouette::TimeTable::FRIDAY
      when 'saturday'
        Chouette::TimeTable::SATURDAY
      when 'sunday'
        Chouette::TimeTable::SUNDAY
      when 'weekday'
        Chouette::TimeTable::MONDAY | Chouette::TimeTable::TUESDAY | Chouette::TimeTable::WEDNESDAY | Chouette::TimeTable::THURSDAY  | Chouette::TimeTable::FRIDAY
      when 'weekend'
        Chouette::TimeTable::SATURDAY | Chouette::TimeTable::SUNDAY
      end
      val = val | day_value if day_value
    end
    val
  end

  def fix_metadatas_periodes
    referential.metadatas.last.update periodes: [(@timetables_period_start..@timetables_period_end)]
  end

  def transport_mode_name_mapping(source_transport_mode)
    {
      'Air' => nil,
      'Train' => ['rail', 'regionalRail'],
      'LongDistanceTrain' => ['rail', 'interregionalRail'],
      'LocalTrain' => ['rail', 'suburbanRailway'],
      'RapidTransit' => ['rail', 'railShuttle'],
      'Metro' => ['metro', nil],
      'Tramway' => ['tram', nil],
      'Coach' => ['bus', nil],
      'Bus' => ['bus', nil],
      'Ferry' => nil,
      'Waterborne' => nil,
      'PrivateVehicle' => nil,
      'Walk' => nil,
      'Trolleybus' => ['tram', nil],
      'Bicycle' => nil,
      'Shuttle' => ['bus', 'airportLinkBus'],
      'Taxi' => nil,
      'VAL' => ['rail', 'railShuttle'],
      'Other' => nil
    }[source_transport_mode]
  end

  def import_stop_areas
    @parent_stop_areas = {}
    each_element_matching_css('ChouettePTNetwork ChouetteArea StopArea') do |source_stop_area|
      stop_area = stop_area_referential.stop_areas.find_or_initialize_by registration_number: source_stop_area[:object_id]
      stop_area.name = source_stop_area[:name]
      stop_area.comment = source_stop_area[:comment]
      stop_area.street_name = source_stop_area[:address].try(:[], :street_name)
      stop_area.nearest_topic_name = source_stop_area[:nearest_topic_name]
      stop_area.fare_code = source_stop_area[:fare_code]
      stop_area.area_type = stop_area_type_mapping(source_stop_area[:stop_area_extension][:area_type])
      stop_area.kind = :commercial
      stop_area.latitude = source_stop_area[:latitude]
      stop_area.longitude = source_stop_area[:longitude]
      stop_area.parent_id = @parent_stop_areas.delete(source_stop_area[:object_id])

      save_model stop_area

      contains = source_stop_area[:contains]
      contains = [contains] unless contains.is_a?(Array)
      contains.each do |child_registration_number|
        @parent_stop_areas[child_registration_number] = stop_area.id
      end
    end
  end

  def stop_area_type_mapping(source_stop_area_type)
    {
      'BoardingPosition' => :zdep,
      'Quay' =>  :zdep,
      'CommercialStopPoint' => 	:zdlp,
      'StopPlace' => :lda
    }[source_stop_area_type]
  end

  def convert_to_wgs84(lat, lng)
    return unless lat && lng
    geometry = GeoRuby::SimpleFeatures::Point.from_lon_lat(lat, lng)
    [geometry.lat, geometry.lng]
  end

  def build_object_from_nokogiri_element(element)
    out = {}
    element.children.each do |child|
      key = child.name.underscore.to_sym
      next if key == :text

      if child.children.count == 1 && child.children.last.node_type == Nokogiri::XML::Node::TEXT_NODE
        content = child.children.last.content
      else
        content = build_object_from_nokogiri_element(child)
      end

      if element.children.select{ |c| c.name == child.name }.count > 1
        out[key] ||= []
        out[key] << content
      else
        out[key] = content
      end
    end
    out
  end
end
