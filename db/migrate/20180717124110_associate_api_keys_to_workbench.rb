class AssociateApiKeysToWorkbench < ActiveRecord::Migration
  def change
    remove_column :api_keys, :referential_id
    add_column :api_keys, :workbench_id, :bigint

    ApiKey.where(workbench_id: nil).each do |key|
      key.update_column(:workbench_id, Organisation.find(key[:organisation_id]).workbenches.first&.id)
    end

    remove_column :api_keys, :organisation_id
  end
end
