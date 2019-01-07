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
    copy_metadatas unless skip_metadatas?
    copy_time_tables
    copy_purchase_windows
    source.switch do
      lines.includes(:footnotes, :routes).each do |line|
        copy_footnotes line
        copy_routes line
      end
    end
    @status = :successful
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
    source.metadatas.each do |metadata|
      candidate = target.metadatas.with_lines(metadata.line_ids).find { |m| m.periodes == metadata.periodes }
      candidate ||= target.metadatas.build(line_ids: metadata.line_ids, periodes: metadata.periodes)
      controlled_save! candidate
    end
  end

  # TIMETABLES

  def copy_time_tables
    source.switch do
      Chouette::TimeTable.linked_to_lines(lines).uniq.find_each do |tt|
        attributes = clean_attributes_for_copy tt
        target.switch do
          new_tt = Chouette::TimeTable.new attributes
          copy_collection tt, new_tt, :dates
          copy_collection tt, new_tt, :periods
          controlled_save! new_tt
        end
      end
    end
  end

  # PURCHASE WINDOWS

  def copy_purchase_windows
    purchase_window_attributes = source.switch do
      Chouette::PurchaseWindow.linked_to_lines(lines).uniq.find_each.map do |purchase_window|
        clean_attributes_for_copy purchase_window
      end
    end
    target.switch do
      purchase_window_attributes.each do |attributes|
        controlled_save! Chouette::PurchaseWindow.new attributes
      end
    end
  end

  # FOOTNOTES

  def copy_footnotes line
    line.footnotes.each do |footnote|
      copy_item_to_target_collection footnote, line.footnotes
    end
  end

  # ROUTES

  def copy_routes line
    line.routes.each &method(:copy_route)
  end

  def copy_route route
    line = route.line
    attributes = clean_attributes_for_copy route
    opposite_route_checksum = route.opposite_route&.checksum
    target.switch do
      new_route = line.routes.build attributes
      copy_collection route, new_route, :stop_points

      new_route.opposite_route = line.routes.where(checksum: opposite_route_checksum).last if opposite_route_checksum

      controlled_save! new_route

      # we copy the journey_patterns
      copy_collection route, new_route, :journey_patterns do |journey_pattern, new_journey_pattern|
        retrieve_collection_with_mapping journey_pattern, new_journey_pattern, new_route.stop_points, :stop_points, [:objectid], [:objectid]
        copy_collection journey_pattern, new_journey_pattern, :courses_stats do |_, new_stat|
          new_stat.route = new_route
        end
        copy_collection journey_pattern, new_journey_pattern, :vehicle_journeys do |vj, new_vj|
          new_vj.route = new_route
          retrieve_collection_with_mapping vj, new_vj, Chouette::TimeTable, :time_tables, [:checksum], [:checksum]
          retrieve_collection_with_mapping vj, new_vj, Chouette::PurchaseWindow, :purchase_windows, [:checksum], [:checksum, :date_ranges]
          copy_collection vj, new_vj, :vehicle_journey_at_stops do |vjas, new_vjas|
            query = source.switch { vjas.stop_point.slice(:objectid) }
            new_vjas.stop_point = new_journey_pattern.stop_points.find_by(query)
          end
        end
      end

      # we copy the routing_constraint_zones
      copy_collection route, new_route, :routing_constraint_zones do |rcz, new_rcz|
        new_rcz.stop_point_ids = []
        retrieve_collection_with_mapping rcz, new_rcz, new_route.stop_points, :stop_points, [:objectid, :position]
      end
    end
  end

  #  _  _ ___ _    ___ ___ ___  ___
  # | || | __| |  | _ \ __| _ \/ __|
  # | __ | _|| |__|  _/ _||   /\__ \
  # |_||_|___|____|_| |___|_|_\|___/
  #

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

  def retrieve_collection_with_mapping from, to, find_collection, collection_name, keys, select=nil
    queries = []
    from_collection = from.send(collection_name)
    from_collection = from_collection.select(*select) if select.present?
    each_item_in_source_collection(from_collection) do |item|
      queries << item.slice(*keys)
    end

    to_collection = to.send(collection_name)
    queries.each do |q|
      to_collection << find_collection.find_by(q)
    end
  end

  def each_item_in_source_collection collection
    source.switch do
      collection.each do |item|
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
      controlled_save! new_item if owner.persisted?
    end
  end

  def clean_attributes_for_copy model
    model.attributes.dup.except(*%w(id created_at updated_at opposite_route_id position))
  end

  def controlled_save! model
    begin
      model.save!
    rescue => e
      error = []
      error << e.message
      error << model.class.name
      error << model.attributes
      error << model.errors.messages
      error = error.join("\n")

      raise SaveError.new(error)
    end
  end

  def failed! error
    @status = :failed
    @last_error = error
  end

  class SaveError < RuntimeError
  end
end
