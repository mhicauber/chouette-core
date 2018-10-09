class AddStartedAndEndedToAggregates < ActiveRecord::Migration
  def change
    add_column :aggregates, :started_at, :datetime
    add_column :aggregates, :ended_at, :datetime
  end
end
