class Import::Neptune < Import::Base
  include LocalImportSupport

  def self.accepts_file?(file)
    Zip::File.open(file) do |zip_file|
      zip_file.glob('*.xml').size == zip_file.glob('*').size
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
  end

  def prepare_referential
    import_resources :lines

    create_referential
    referential.switch
  end

  def referential_metadata
    # TODO #10177
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

  def import_lines
    each_source do |source|
      source.css('ChouettePTNetwork ChouetteLineDescription Line')\
            .map(&method(:build_object_from_nokogiri_element))\
            .each do |source_line|

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

  def build_object_from_nokogiri_element(element)
    out = {}
    element.children.each do |child|
      key = child.name.underscore.to_sym
      next if key == :text
      if child.children.count == 1 && child.children.last.node_type == Nokogiri::XML::Node::TEXT_NODE
        content = child.children.last.content
        out[key] = content
      else
        out[key] = build_object_from_nokogiri_element(child)
      end
    end
    out
  end
end
