class CreateDestinations < ActiveRecord::Migration
  def change
    create_table :destinations do |t|
      t.belongs_to :publication_setup, index: true, limit: 8
      t.string :name
      t.string :type
      t.hstore :options
      t.string :secret_file

      t.timestamps null: false
    end
  end
end
