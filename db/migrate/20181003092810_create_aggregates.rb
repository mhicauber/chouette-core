class CreateAggregates < ActiveRecord::Migration
  def change
    create_table :aggregates do |t|
      t.integer :workgroup_id, limit: 8
      t.string :status
      t.string :name
      t.integer  "referential_ids", limit: 8, array: true
      t.integer :new_id, limit: 8

      t.timestamps null: false
    end
    add_index :aggregates, :workgroup_id
  end
end
