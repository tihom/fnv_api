json.array!(@item_mappings) do |item_mapping|
	json.partial! "item_mappings/item_mapping", item_mapping: item_mapping
end
