class CreateTablePublicationApiSources < ActiveRecord::Migration
  def change
    create_table :publication_api_sources do |t|
      t.integer :publication_id, limit: 8
      t.integer :publication_api_id, limit: 8
      t.string :file
      t.string :key
      
      t.timestamps
    end

    add_index :publication_api_sources, :publication_id
    add_index :publication_api_sources, :publication_api_id
    add_index :publication_api_sources, [:publication_id, :key]
  end
end
