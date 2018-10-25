class AddSentinalParamsToWorkgroups < ActiveRecord::Migration
  def change
    add_column :workgroups, :sentinel_min_hole_size, :int, default: 3
    add_column :workgroups, :sentinel_delay, :int, default: 7
  end
end
