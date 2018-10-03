class AddComplianceControlSetIdsToWorkgroups < ActiveRecord::Migration
  def change
    add_column :workgroups, :compliance_control_set_ids, :hstore
  end
end
