class CreatePublicationApiKeys < ActiveRecord::Migration
  def change
    create_table :publication_api_keys do |t|
      t.string :name
      t.string :token
      t.integer :publication_api_id, limit: 8
      t.timestamps null: false
    end

    add_index :publication_api_keys, :publication_api_id
  end
end
