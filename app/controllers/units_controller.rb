class UnitsController < ApplicationController

	def index
		#@units = Unit.joins(:items).select("units.unit_id AS unit_id, units.unit_name AS unit_name, items.item_id AS item_id, items.item_name AS item_name").order("items.item_id, unit_name").group("item_id,unit_id")
		@units = Unit.includes(:items).order("unit_name")
	end

end