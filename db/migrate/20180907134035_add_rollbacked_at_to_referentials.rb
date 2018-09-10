class AddRollbackedAtToReferentials < ActiveRecord::Migration
  def change
    add_column :referentials, :rollbacked_at, :datetime
  end
end
