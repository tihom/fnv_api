class Item < ActiveRecord::Base
	default_scope { where(is_hidden: 0)	 } 

	self.primary_key = 'item_id'
	has_many :items_varieties, foreign_key: "item_id"
	has_and_belongs_to_many :units, -> {uniq}
end