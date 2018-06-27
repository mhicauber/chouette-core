class ReferentialAudit
  class VehicleJourneyInitialOffset < Base
    def perform logger
      foo = Chouette::VehicleJourneyAtStop.where.not(departure_day_offset: 0).joins(:stop_point).where('stop_points.position' => 0).count
      if foo == 0
        @status = :success
      else
        logger.add_error "Found #{foo} VehicleJourney having an initial offset > 0"
        @status = :error
      end
    end
  end
end
