class AddOutputToWorkgroups < ActiveRecord::Migration
  def change
    add_column :workgroups, :output_id, :integer, limit: 8
    Workgroup.find_each &:save
  end
end
