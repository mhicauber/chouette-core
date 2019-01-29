class AddAggregatedAtToWorkgroups < ActiveRecord::Migration
  def change
    add_column :workgroups, :aggregated_at, :datetime
    Workgroup.find_each do |w|
      w.update aggregated_at: w.output&.current&.created_at
    end
  end
end
