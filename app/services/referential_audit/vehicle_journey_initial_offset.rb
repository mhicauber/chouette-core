class ReferentialAudit
  class VehicleJourneyInitialOffset < Base
    def find_faulty
      Chouette::VehicleJourneyAtStop.where.not(departure_day_offset: 0).joins(:stop_point).where('stop_points.position' => 0)
    end

    def message record
      "VehicleJourney ##{record.vehicle_journey_id} has an initial offset > 0"
    end
  end
end
