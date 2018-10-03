class AddCreatorToAggregates < ActiveRecord::Migration
  def change
    add_column :aggregates, :creator, :string
  end
end
