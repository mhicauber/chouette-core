class AddLocalCodeToStopAreas < ActiveRecord::Migration
  def change
    add_column :stop_areas, :local_code, :string
  end
end
