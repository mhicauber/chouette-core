class AddNameToPublicationSetups < ActiveRecord::Migration
  def change
    add_column :publication_setups, :name, :string
  end
end
