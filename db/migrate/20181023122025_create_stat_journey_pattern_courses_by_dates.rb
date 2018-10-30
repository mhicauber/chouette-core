class CreateStatJourneyPatternCoursesByDates < ActiveRecord::Migration
  def change
    create_table :stat_journey_pattern_courses_by_dates do |t|
      t.integer :journey_pattern_id, index: { name: 'journey_pattern_id' }, limit: 8
      t.integer :route_id, index: { name: 'route_id' }, limit: 8
      t.integer :line_id, index: { name: 'line_id' }, limit: 8
      t.date :date
      t.integer :count, default: 0

      # t.timestamps null: false
    end
  end
end
