class ReferentialCopy
  extend Enumerize
  include ReferentialCopyHelpers

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
end
