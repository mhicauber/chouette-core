class ReferentialCopy < ActiveRecord::Base
  extend Enumerize

  belongs_to :source, class_name: "Referential"
  belongs_to :target, class_name: "Referential"

  enumerize :status, in: %w[new pending successful failed running], default: :new

  def copy
    copy_metadatas
    copy_routes
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
        candidate.save
      else
        target.metadatas.create line_ids: metadata.line_ids, periodes: metadata.periodes
      end
    end
  end

  # ROUTES

  def copy_routes
    lines.each do |line|
      source.switch do
        line.routes.each &method(:copy_route)
      end
    end
  end

  def copy_route route
    line = route.line
    attributes = clean_attributes_for_copy route
    target.switch do
      new_route = line.routes.build attributes
      copy_route_stop_points route, new_route
      copy_route_journey_patterns route, new_route
      controlled_save! new_route
    end
  end

  # STOP POINTS

  def copy_route_stop_points source_route, target_route
    each_item_in_source_collection(source_route.stop_points) do |stop_point|
      copy_route_stop_point stop_point, target_route
    end
  end

  def copy_route_stop_point stop_point, target_route
    copy_item_to_target_collection stop_point, target_route.stop_points
  end

  # JOURNEY PATTERNS

  def copy_route_journey_patterns source_route, target_route
    each_item_in_source_collection(source_route.journey_patterns) do |journey_pattern|
      copy_route_journey_pattern journey_pattern, target_route
    end
  end

  def copy_route_journey_pattern journey_pattern, target_route
    copy_item_to_target_collection journey_pattern, target_route.journey_patterns
  end

  #  _  _ ___ _    ___ ___ ___  ___
  # | || | __| |  | _ \ __| _ \/ __|
  # | __ | _|| |__|  _/ _||   /\__ \
  # |_||_|___|____|_| |___|_|_\|___/
  #

  def each_item_in_source_collection collection
    source.switch do
      collection.each do |item|
        yield item
      end
    end
  end

  def copy_item_to_target_collection source_item, target_collection
    attributes = clean_attributes_for_copy source_item
    target.switch do
      new_item = target_collection.build attributes
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
