class CreatePublicationApis < ActiveRecord::Migration
  def change
    create_table :publication_apis do |t|
      t.string :name
      t.string :slug
      t.integer :workgroup_id, limit: 8

      t.timestamps null: false
    end

    add_index :publication_apis, :workgroup_id
  end
end
