class AddOptionsToImports < ActiveRecord::Migration
  def change
    return if ActiveRecord::Base.connection.column_exists?(:imports, :options)

    add_column :imports, :options, :hstore
  end
end
