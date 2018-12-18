class CreatePublicationSetups < ActiveRecord::Migration
  def change
    create_table :publication_setups do |t|
      t.belongs_to :workgroup, index: true, limit: 8
      t.string :export_type
      t.hstore :export_options
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
