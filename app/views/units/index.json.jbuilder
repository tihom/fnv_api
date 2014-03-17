json.array!(@units) do |unit|
	#json.extract! item, :id, :name
	json.id unit.unit_id
	json.name unit.unit_name
	json.item_ids do
  		json.array! unit.items.map(&:item_id).uniq
	end
end