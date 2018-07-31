class ReferentialCopy < ActiveRecord::Base
  extend Enumerize

  belongs_to :source, class_name: "Referential"
  belongs_to :target, class_name: "Referential"

  enumerize :status, in: %w[new pending successful failed running], default: :new

  def copy
    copy_metadatas
    source.switch do
      lines.includes(:footnotes, :routes).each do |line|
        copy_footnotes line
        copy_routes line
      end
    end
    update status: :successful
  rescue SaveError => e
    Rails.logger.error e.message
    failed! e.message
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
      candidate = target.metadatas.with_lines(metadata.line_ids).last
      if candidate
        candidate.periodes += metadata.periodes
        candidate.merge_periodes
        controlled_save! candidate
      else
        target.metadatas.create line_ids: metadata.line_ids, periodes: metadata.periodes
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
    target.switch do
      new_route = line.routes.build attributes
      copy_collection route, new_route, :stop_points

      controlled_save! new_route

      copy_collection route, new_route, :journey_patterns do |journey_pattern, new_journey_pattern|
        copy_collection_with_mapping journey_pattern, new_journey_pattern, new_route.stop_points, :stop_points, [:objectid, :position], [:objectid, :position]
      end
      copy_collection route, new_route, :routing_constraint_zones do |rcz, new_rcz|
        new_rcz.stop_point_ids = []
        copy_collection_with_mapping rcz, new_rcz, new_route.stop_points, :stop_points, [:objectid, :position]
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

  def copy_collection_with_mapping from, to, find_collection, collection_name, keys, select=nil
    queries = []
    from_collection = from.send(collection_name)
    from_collection = from_collection.select(*select) if select.present?
    each_item_in_source_collection(from_collection) do |item|
      queries << Hash[keys.map{|k| [k, item.send(k)]}]
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
    target.switch do
      new_item = target_collection.build attributes
      block.call(source_item, new_item) if block.present?
      controlled_save! new_item
    end
  end

  def clean_attributes_for_copy model
    model.attributes.dup.except(*%w(id created_at updated_at))
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
    update status: :failed, last_error: error
  end

  class SaveError < RuntimeError
  end
end
