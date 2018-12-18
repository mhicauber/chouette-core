class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.belongs_to :publication_setup, index: true, limit: 8
      t.string :parent_type
      t.integer :parent_id, limit: 8
      t.belongs_to :export, index: true, foreign_key: true, limit: 8

      t.timestamps null: false
    end
    add_index :publications, [:parent_type, :parent_id]
  end
end
