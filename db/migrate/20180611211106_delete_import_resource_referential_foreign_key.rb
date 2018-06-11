class DeleteImportResourceReferentialForeignKey < ActiveRecord::Migration
  def change
    remove_foreign_key :import_resources, :referentials
  end
end
