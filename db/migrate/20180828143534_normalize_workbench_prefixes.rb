class NormalizeWorkbenchPrefixes < ActiveRecord::Migration
  def up
    Workbench.find_each do |w|
      w.update prefix: w.prefix
    end
  end
end
