class ItemVarietiesController < ApplicationController

	def index
		@item_varieties = ItemsVariety.joins(:item).select("*, items.item_id AS item_id, items.item_name AS item_name").order("items.item_id, item_variety_name")
	end

end