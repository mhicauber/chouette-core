module VehicleJourneyControl
  class InternalBase < InternalControl::Base
    def self.object_path compliance_check, vehicle_journey
      referential_line_route_vehicle_journeys_path(compliance_check.referential, vehicle_journey.route.line, vehicle_journey.route)
    end

    def self.collection(lines_scope, compliance_check)
      compliance_check.referential.vehicle_journeys_in_lines(lines_scope)
    end

    def self.label_attr(compliance_check)
      :published_journey_name
    end
  end
end
