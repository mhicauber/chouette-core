module VehicleJourneyControl
  class PurchaseWindowDates < InternalBase
    required_features :purchase_windows

    def self.default_code; "3-VehicleJourney-7" end

    def self.collection referential, _
      referential.vehicle_journeys.joins(:time_tables, :purchase_windows)
    end

    def self.compliance_test compliance_check, vehicle_journey
      vehicle_journey.bounding_dates.empty? || vehicle_journey.selling_bounding_dates.last <= vehicle_journey.bounding_dates.last
    end
  end
end
