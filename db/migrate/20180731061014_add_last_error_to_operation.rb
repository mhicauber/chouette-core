class AddLastErrorToOperation < ActiveRecord::Migration
  def change
    add_column :referential_copies, :last_error, :text
  end
end
