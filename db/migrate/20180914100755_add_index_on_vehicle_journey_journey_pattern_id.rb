class AddIndexOnVehicleJourneyJourneyPatternId < ActiveRecord::Migration
  def change
    # Avoid error in the case of issue #8255
    return if ActiveRecord::Base.connection.index_exists?(:vehicle_journeys, :journey_pattern_id)
    add_index :vehicle_journeys, :journey_pattern_id
  end
end
