class AddTypeToAggregates < ActiveRecord::Migration
  def change
    add_column :aggregates, :type, :string
  end
end
