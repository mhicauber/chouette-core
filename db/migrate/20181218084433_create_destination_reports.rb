class CreateDestinationReports < ActiveRecord::Migration
  def change
    create_table :destination_reports do |t|
      t.belongs_to :destination, index: true, limit: 8
      t.belongs_to :publication, index: true, limit: 8
      t.string :status
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps null: false
    end
  end
end
