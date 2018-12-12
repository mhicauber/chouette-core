class AddNightlyAggregatedAtToWorkgroups < ActiveRecord::Migration
  def change
    add_column :workgroups, :nightly_aggregated_at, :datetime
  end
end
