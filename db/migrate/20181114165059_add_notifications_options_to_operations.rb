class AddNotificationsOptionsToOperations < ActiveRecord::Migration
  def change
    %i{imports exports merges aggregates compliance_check_sets}.each do |table|
      add_column table, :notification_target, :string
      add_column table, :notified_recipients_at, :datetime
      add_column table, :user_id, :integer, limit: 8
    end
  end
end
