class ItemsController < ApplicationController

	def index
		@items = Item.order("item_name")
	end

end