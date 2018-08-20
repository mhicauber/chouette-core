class AddIndexOnRoutesLineId < ActiveRecord::Migration
  def change
    add_index :routes, :line_id
  end
end
