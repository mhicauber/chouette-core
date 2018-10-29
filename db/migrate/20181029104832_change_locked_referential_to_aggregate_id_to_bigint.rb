class ChangeLockedReferentialToAggregateIdToBigint < ActiveRecord::Migration
  def up
    change_column :workbenches, :locked_referential_to_aggregate_id, :integer, limit: 8
  end

  def down
    change_column :workbenches, :locked_referential_to_aggregate_id, :integer
  end
end
