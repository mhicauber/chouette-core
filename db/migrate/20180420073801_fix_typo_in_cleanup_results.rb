class FixTypoInCleanupResults < ActiveRecord::Migration
  def change
    rename_column :clean_up_results, :message_attributs, :message_attributes
  end
end
