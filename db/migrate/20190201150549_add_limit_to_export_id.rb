class AddLimitToExportId < ActiveRecord::Migration
  def change
    change_column :publication_api_sources, :export_id, :integer, limit: 8
  end
end
