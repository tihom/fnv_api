json.array!(@item_varieties) do |item_varieties|
	#json.extract! item, :id, :name
	json.id item_varieties.item_variety_id
	json.name item_varieties.item_variety_name
	json.item_id item_varieties.item_id
	json.item_name item_varieties.item_name
end