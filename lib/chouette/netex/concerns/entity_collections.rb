module Chouette::Netex::Concerns::EntityCollections
  def netex_operators
    Chouette::Company.within_workgroup(workgroup) do
      companies.find_each do |company|
        Chouette::Netex::Operator.new(company).to_xml(@builder)
      end
    end
  end

  def netex_stop_places
    Chouette::StopArea.within_workgroup(workgroup) do
      stop_areas.where('stop_areas.area_type != ? OR stop_areas.parent_id IS NULL', :zdep).includes(:parent).find_each do |stop_area|
        Chouette::Netex::StopPlace.new(stop_area, stop_areas).to_xml(@builder)
      end
    end
  end

  def netex_lines
    lines.includes(:network, :company_light).find_each do |line|
      Chouette::Netex::Line.new(line).to_xml(@builder)
    end
  end

  def netex_groups_of_lines
    networks.find_each do |network|
      Chouette::Netex::GroupOfLines.new(network).to_xml(@builder)
    end
  end

  def netex_routes
    routes.find_each do |route|
      Chouette::Netex::Route.new(route).to_xml(@builder)
    end
  end

  def netex_scheduled_stop_points
    stop_points.select(:id, :objectid).find_each do |stop_point|
      Chouette::Netex::ScheduledStopPoint.new(stop_point).to_xml(@builder)
    end
  end

  def netex_stop_assignments
    stop_points.includes(:stop_area_light).find_each do |stop_point|
      Chouette::Netex::PassengerStopAssignment.new(stop_point).to_xml(@builder)
    end
  end

  def netex_route_points
    stop_points.includes(:stop_area_light).find_each do |stop_point|
      Chouette::Netex::RoutePoint.new(stop_point).to_xml(@builder)
    end
  end

  def netex_service_journey_patterns
    Chouette::JourneyPattern.within_workgroup(workgroup) do
      journey_patterns.includes(:route).find_each do |journey_pattern|
        Chouette::Netex::ServiceJourneyPattern.new(journey_pattern).to_xml(@builder)
      end
    end
  end

  def netex_service_links
    Chouette::JourneyPattern.within_workgroup(workgroup) do
      journey_patterns.find_each do |journey_pattern|
        Chouette::Netex::ServiceLink.new(journey_pattern).to_xml(@builder)
      end
    end
  end

  def netex_day_types
    time_tables.includes(:tags).find_each do |time_table|
      Chouette::Netex::DayType.new(time_table).to_xml(@builder)
    end
  end

  def netex_operating_periods
    time_tables.includes(:periods).find_each do |time_table|
      Chouette::Netex::OperatingPeriod.new(time_table).to_xml(@builder)
    end
  end

  def netex_day_type_assignments
    time_tables.includes(:periods, :dates).find_each do |time_table|
      Chouette::Netex::DayTypeAssignment.new(time_table).to_xml(@builder)
    end
  end

  def netex_service_journeys
    Chouette::VehicleJourney.within_workgroup(workgroup) do
      vehicle_journeys\
      .includes(:journey_pattern_only_objectid, :company_light, :purchase_windows, :time_tables, vehicle_journey_at_stops: { stop_point: :stop_area_light })\
      .find_each do |vehicle_journey|
        Chouette::Netex::ServiceJourney.new(vehicle_journey).to_xml(@builder)
      end
    end
  end
end
