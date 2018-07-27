class RenameStopAreaProvidersStopAreasJoinTable < ActiveRecord::Migration
  def change
    rename_table :stop_areas_stop_area_providers, :stop_area_providers_areas
  end
end
