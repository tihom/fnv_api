  json.extract! item_mapping, :id, :supplier_id, :item_id, :item_variety_id, :unit_id, :identifier, :unit_conversion,
   :remark, :item_price, :price_last_updated_at
  
  if item_mapping.price_last_updated_at
  	json.time_ago time_ago_in_words(item_mapping.price_last_updated_at).gsub("about ", "")
  else
  	json.time_ago ""
  end