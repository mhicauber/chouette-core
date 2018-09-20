class AddOptionsToImports < ActiveRecord::Migration
  def change
    add_column :imports, :options, :hstore
  rescue PG::DuplicateColumn
    nil
  end
end
