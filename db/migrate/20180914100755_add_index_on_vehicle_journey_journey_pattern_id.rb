class AddIndexOnVehicleJourneyJourneyPatternId < ActiveRecord::Migration
  def change
    add_index :vehicle_journeys, :journey_pattern_id
  end
end
