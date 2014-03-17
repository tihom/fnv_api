json.array!(@items) do |item|
	#json.extract! item, :id, :name
	json.id item.item_id
	json.name item.item_name
end