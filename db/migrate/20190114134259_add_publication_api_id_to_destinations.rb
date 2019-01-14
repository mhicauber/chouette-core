class AddPublicationApiIdToDestinations < ActiveRecord::Migration
  def change
    add_column :destinations, :publication_api_id, :integer, limit: 8
    add_index :destinations, :publication_api_id
  end
end
