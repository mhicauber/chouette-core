class AddStatusToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :status, :string
    add_column :publications, :started_at, :datetime
    add_column :publications, :ended_at, :datetime
  end
end
