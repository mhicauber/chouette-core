class AddNetexFullToWorkgroups < ActiveRecord::Migration
  def change
    Workgroup.find_each do |w|
      w.export_types << "Export::NetexFull"
      w.save!
    end
  end
end
