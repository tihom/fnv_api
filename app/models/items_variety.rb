class ItemsVariety < ActiveRecord::Base
	default_scope { where(is_hidden: 0) } 
	self.primary_key = 'item_variety_id'

	belongs_to :item, foreign_key: "item_id"
end