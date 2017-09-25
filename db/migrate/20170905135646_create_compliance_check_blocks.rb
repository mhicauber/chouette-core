class CreateComplianceCheckBlocks < ActiveRecord::Migration
  def change
    create_table :compliance_check_blocks do |t|
      t.string :name
      t.hstore :condition_attributes
      t.references :compliance_check_sets, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
