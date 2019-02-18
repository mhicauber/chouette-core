class AddNetexFullToWorkgroups < ActiveRecord::Migration
  def change
    Workgroup.where.not("export_types::text[] @> ARRAY['Export::NetexFull']").find_each do |w|
      w.export_types << "Export::NetexFull"
      w.save!
    end
  end
end
