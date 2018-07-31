class CreateReferentialCopies < ActiveRecord::Migration
  def change
    create_table :referential_copies do |t|
      t.integer :source_id, limit: 8
      t.integer :target_id, limit: 8
      t.string :status

      t.timestamps null: false
    end
  end
end
