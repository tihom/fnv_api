class SuppliersItem < ActiveRecord::Base
	self.primary_keys = :item_id, :unit_id, :item_variety_id, :supplier_id
	default_scope { where(is_hidden: 0) } 

	belongs_to :supplier, foreign_key: "supplier_id"
	belongs_to :item, foreign_key: "item_id"
	belongs_to :item_variety, foreign_key: "item_variety_id"
	belongs_to :unit, foreign_key: "unit_id"
end