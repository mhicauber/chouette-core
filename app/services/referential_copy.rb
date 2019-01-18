class ReferentialCopy
  extend Enumerize

  attr_accessor :source, :target, :status, :last_error

  enumerize :status, in: %w[new pending successful failed running], default: :new

  def initialize(opts={})
    @source = opts[:source]
    @target = opts[:target]
    @opts = opts
    @lines = opts[:lines]
  end

  def logger
    @logger ||= Rails.logger
  end

  def skip_metadatas?
    @opts[:skip_metadatas]
  end

  def copy(raise_error: false)
    ActiveRecord::Base.cache do
      copy_metadatas unless skip_metadatas?
      copy_time_tables
      copy_purchase_windows
      source.switch do
        lines.includes(:footnotes, :routes).find_each do |line|
          copy_footnotes line
          copy_routes line
        end
      end
      @status = :successful
    end
  rescue SaveError => e
    logger.error e.message
    failed! e.message
    raise if raise_error
  end

  def copy!
    copy raise_error: true
  end

  private

  def lines
    @lines ||= begin
      source.lines
    end
  end

  # METADATAS

  def copy_metadatas
    ReferentialMetadata.bulk_insert do |worker|
      source.metadatas.find_each do |metadata|
        candidate = target.metadatas.with_lines(metadata.line_ids).find { |m| m.periodes == metadata.periodes }
        candidate ||= target.metadatas.build(line_ids: metadata.line_ids, periodes: metadata.periodes)
        controlled_save! candidate, worker
      end
    end
  end

  # TIMETABLES

  def copy_time_tables
    Chouette::TimeTable.transaction do
      source.switch do
        Chouette::TimeTable.linked_to_lines(lines).uniq.find_each do |tt|
          attributes = clean_attributes_for_copy tt
          target.switch do
            new_tt = Chouette::TimeTable.new attributes
            controlled_save! new_tt
            record_match(tt, new_tt)
            copy_bulk_collection tt.dates do |new_date_attributes|
              new_date_attributes[:time_table_id] = new_tt.id
            end
            copy_bulk_collection tt.periods do |new_period_attributes|
              new_period_attributes[:time_table_id] = new_tt.id
            end
          end
        end
        target.switch do
          Chouette::TimeTable.select(:id, :checksum, :checksum_source, :int_day_types).includes(:dates, :periods).find_each do |new_tt|
            # We could store the checksum and update the col manually,
            # but this way we ensure we copied all the relevant data correctly
            new_tt.update_checksum_without_callbacks!
          end
        end
      end
    end
  end

  # PURCHASE WINDOWS

  def copy_purchase_windows
    Chouette::PurchaseWindow.transaction do
      source.switch do
        Chouette::PurchaseWindow.linked_to_lines(lines).uniq.find_each do |pw|
          attributes = clean_attributes_for_copy pw
          target.switch do
            new_pw = Chouette::PurchaseWindow.new attributes
            controlled_save! new_pw
            record_match(pw, new_pw)
          end
        end
      end
    end
  end

  # FOOTNOTES

  def copy_footnotes line
    line.footnotes.find_each do |footnote|
      copy_item_to_target_collection footnote, line.footnotes
    end
  end

  # ROUTES

  def copy_routes line
    line.routes.find_each &method(:copy_route)
  end

  def copy_route route
    line = route.line
    attributes = clean_attributes_for_copy route
    opposite_route = route.opposite_route

    target.switch do
      new_route = line.routes.build attributes
      copy_collection route, new_route, :stop_points

      new_route.opposite_route_id = matching_id(opposite_route)

      controlled_save! new_route
      record_match(route, new_route)

      # we copy the journey_patterns
      copy_collection route, new_route, :journey_patterns do |journey_pattern, new_journey_pattern|
        retrieve_collection_with_mapping journey_pattern, new_journey_pattern, new_route.stop_points, :stop_points

        copy_bulk_collection journey_pattern.courses_stats do |new_stat_attributes|
          new_stat_attributes[:journey_pattern_id] = new_journey_pattern.id
          new_stat_attributes[:route_id] = new_route.id
        end

        copy_collection journey_pattern, new_journey_pattern, :vehicle_journeys do |vj, new_vj|
          new_vj.route = new_route
          retrieve_collection_with_mapping vj, new_vj, Chouette::TimeTable, :time_tables
          retrieve_collection_with_mapping vj, new_vj, Chouette::PurchaseWindow, :purchase_windows
        end

        source.switch do
          journey_pattern.vehicle_journeys.find_each do |vj|
            copy_bulk_collection vj.vehicle_journey_at_stops.includes(:stop_point) do |new_vjas_attributes, vjas|
              new_vjas_attributes[:vehicle_journey_id] = matching_id(vj)
              new_vjas_attributes[:stop_point_id] = matching_id(vjas.stop_point)
            end
          end
        end
        new_journey_pattern.vehicle_journeys.reload.each &:update_checksum!
      end

      # we copy the routing_constraint_zones
      copy_collection route, new_route, :routing_constraint_zones do |rcz, new_rcz|
        new_rcz.stop_point_ids = []
        retrieve_collection_with_mapping rcz, new_rcz, new_route.stop_points, :stop_points
      end
    end
    clean_matches Chouette::StopPoint, Chouette::JourneyPattern, Chouette::VehicleJourney, Chouette::RoutingConstraintZone
  end

  #  _  _ ___ _    ___ ___ ___  ___
  # | || | __| |  | _ \ __| _ \/ __|
  # | __ | _|| |__|  _/ _||   /\__ \
  # |_||_|___|____|_| |___|_|_\|___/
  #
  def copy_bulk_collection collection, &block
    target.switch do
      collection.klass.bulk_insert do |worker|
        each_item_in_source_collection(collection) do |item|
          attributes = clean_attributes_for_copy item, strict: false
          block.call(attributes, item) if block_given?
          target.switch(verbose: false) do
            worker.add attributes
          end
        end
      end
    end
  end

  def copy_collection source_item, target_item, collection_name, &block
    each_item_in_source_collection(source_item.send(collection_name)) do |item|
      copy_item_to_target_collection item, target_item.send(collection_name), &block
    end
  end

  # from: the object you read the collection from
  # to: the object owning the collection you want to fill
  # find_collection: the collection used to find the objects in the source referential
  # collection_name: the name of the collection
  # keys: the keys used to identify the objects across both referentials
  # select (optional): the fields to query on the source collection

  def retrieve_collection_with_mapping from, to, find_collection, collection_name
    queries = []
    if from.is_a? Chouette::RoutingConstraintZone
      # we need the dirty switch because of the has_many_in_array stuff
      from_collection = source.switch(verbose: false) { from.send(collection_name).to_a }
    else
      from_collection = from.send(collection_name).select(:id)
    end

    to_collection = to.send(collection_name)
    each_item_in_source_collection(from_collection) do |item|
      target.switch(verbose: false) do
        to_collection << find_collection.find(matching_id(item))
      end
    end
  end

  def each_item_in_source_collection collection
    source.switch do
      meth = collection.respond_to?(:find_each) ? :find_each : :each
      collection.send(meth) do |item|
        yield item
      end
    end
  end

  def copy_item_to_target_collection source_item, target_collection, &block
    attributes = clean_attributes_for_copy source_item
    owner = target_collection.instance_variable_get("@association").owner
    target.switch do
      new_item = target_collection.build attributes
      block.call(source_item, new_item) if block.present?
      if owner.persisted?
        controlled_save! new_item
        record_match source_item, new_item
      else
        waiting_for_save_to_record_match(source_item, new_item)
      end
    end
  end

  def clean_attributes_for_copy model, strict: true
    removed_attrs = %w(id created_at updated_at opposite_route_id)
    removed_attrs += %w(position) if strict

    model.attributes.dup.except(*removed_attrs)
  end

  def controlled_save! model, worker=nil
    begin
      if worker && model.new_record?
        model.validate!
        worker.add clean_attributes_for_copy model
      else
        model.save!
      end
    rescue => e
      error = []
      error << e.message
      error << model.class.name
      error << model.attributes
      error << model.errors.messages
      error = error.join("\n")

      raise SaveError.new(error)
    end
    process_wait_queue
  end

  def clean_matches *models
    models.each do |model|
      @matches[model.name] = {}
    end
  end

  def matches
    @matches ||= Hash.new { |hash, key| hash[key] = {} }
  end

  def record_match(source_item, copied_item)
    matches[source_item.class.name][source_item.id] = copied_item.id
  end

  def matching_id(item)
    return unless item
    matches[item.class.name][item.id]
  end

  def waiting_for_save_to_record_match(source_item, copied_item)
    @wait_queue ||= []
    @wait_queue.push [source_item, copied_item]
  end

  def process_wait_queue
    @wait_queue ||= []
    new_queue = []
    @wait_queue.each do |source_item, copied_item|
      if copied_item.persisted?
        record_match source_item, copied_item
      else
        new_queue.push [source_item, copied_item]
      end
    end
    @wait_queue = new_queue
  end

  def failed! error
    @status = :failed
    @last_error = error
  end

  class SaveError < RuntimeError
  end
end
