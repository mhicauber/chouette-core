class AddNotificationsOptionsToOperations < ActiveRecord::Migration
  def change
    [Import::Base, Export::Base, Merge, Aggregate, ComplianceCheckSet].each do |klass|
      add_column klass.table_name, :notification_target, :string
      add_column klass.table_name, :notified_recipients_at, :datetime
      unless klass.column_names.include?("user_id")
        add_column klass.table_name, :user_id, :integer, limit: 8
      end
    end
  end
end
