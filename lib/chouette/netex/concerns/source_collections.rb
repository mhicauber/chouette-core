module Chouette::Netex::Concerns::SourceCollections
  def companies
    @companies ||= referential.line_referential.companies
  end

  def stop_areas
    @stop_areas ||= referential.stop_area_referential.stop_areas
  end

  def lines
    @lines ||= referential.lines
  end

  def networks
    @networks ||= referential.line_referential.networks
  end

  def routes
    @routes ||= referential.routes
  end

  def stop_points
    @stop_points ||= referential.stop_points
  end

  def journey_patterns
    @journey_patterns ||= referential.journey_patterns
  end

  def time_tables
    @time_tables ||= referential.time_tables
  end

  def vehicle_journeys
    @vehicle_journeys ||= referential.vehicle_journeys
  end

  def routing_constraint_zones
    @routing_constraint_zones ||= referential.routing_constraint_zones
  end
end
