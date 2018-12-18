class AddInfosOnDestinationReports < ActiveRecord::Migration
  def change
    add_column :destination_reports, :error_message, :string
    add_column :destination_reports, :error_backtrace, :text
  end
end
