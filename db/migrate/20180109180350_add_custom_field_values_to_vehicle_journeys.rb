class AddCustomFieldValuesToVehicleJourneys < ActiveRecord::Migration
  def change
    add_column :vehicle_journeys, :custom_field_values, :jsonb, default: {}
  end
end
