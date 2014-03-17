class CreateItemMappings < ActiveRecord::Migration
  def change
    create_table :item_mappings do |t|
      t.integer :item_id
      t.integer :item_variety_id
      t.integer :unit_id
      t.integer :supplier_id
      t.decimal :unit_conversion, precision: 20, scale: 10
      t.string  :identifier
      t.string :remark

      t.timestamps
    end
  end
end
