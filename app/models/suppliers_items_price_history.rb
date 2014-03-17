class SuppliersItemsPriceHistory < ActiveRecord::Base
	self.table_name =  "suppliers_items_price_history"

	belongs_to :supplier, foreign_key: "supplier_id"
	belongs_to :item, foreign_key: "item_id"
	belongs_to :item_variety, foreign_key: "item_variety_id"
	belongs_to :unit, foreign_key: "unit_id"
end