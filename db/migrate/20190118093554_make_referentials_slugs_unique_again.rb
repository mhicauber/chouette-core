class MakeReferentialsSlugsUniqueAgain < ActiveRecord::Migration
  def change
    add_index :referentials, :slug, unique: true
  end
end
