class CreateDatabase < ActiveRecord::Migration

	def self.change

		  create_table "current_session", id: false, force: true do |t|
		    t.string "username",    limit: 30, null: false
		    t.string "session_var", limit: 35, null: false
		  end

		  create_table "item_categories", primary_key: "item_category_id", force: true do |t|
		    t.string  "item_category_name", limit: 100, null: false
		    t.integer "is_hidden",          limit: 1,   null: false
		  end

		  create_table "items", primary_key: "item_id", force: true do |t|
		    t.integer "item_category_id", limit: 1,   null: false
		    t.string  "item_name",        limit: 200, null: false
		    t.integer "is_hidden",        limit: 1,   null: false
		  end

		  add_index "items", ["item_category_id"], name: "item_category_id", using: :btree

		  create_table "items_units", id: false, force: true do |t|
		    t.integer "unit_id",   limit: 1, null: false
		    t.integer "item_id",             null: false
		    t.integer "is_hidden", limit: 1, null: false
		  end

		  add_index "items_units", ["item_id"], name: "item_id", using: :btree

		  create_table "items_varieties", primary_key: "item_variety_id", force: true do |t|
		    t.string  "item_variety_name", limit: 100, null: false
		    t.integer "item_id",                       null: false
		    t.integer "is_hidden",         limit: 1,   null: false
		  end

		  add_index "items_varieties", ["item_id"], name: "item_id", using: :btree

		  create_table "items_varieties_price", id: false, force: true do |t|
		    t.integer "item_variety_id",                                   null: false
		    t.integer "item_id",                                           null: false
		    t.integer "unit_id",         limit: 1,                         null: false
		    t.decimal "aalgro_price_1",            precision: 6, scale: 2
		    t.decimal "aalgro_price_2",            precision: 6, scale: 2
		    t.decimal "aalgro_price_3",            precision: 6, scale: 2
		    t.integer "updated_at",                                        null: false
		  end

		  add_index "items_varieties_price", ["item_id"], name: "item_id", using: :btree

		  create_table "items_varieties_price_history", id: false, force: true do |t|
		    t.integer "item_variety_id",                                   null: false
		    t.integer "item_id",                                           null: false
		    t.integer "unit_id",         limit: 1,                         null: false
		    t.decimal "aalgro_price_1",            precision: 6, scale: 2
		    t.decimal "aalgro_price_2",            precision: 6, scale: 2
		    t.decimal "aalgro_price_3",            precision: 6, scale: 2
		    t.integer "updated_at",                                        null: false
		  end

		  add_index "items_varieties_price_history", ["item_id"], name: "item_id", using: :btree

		  create_table "supplier_categories", primary_key: "supplier_category_id", force: true do |t|
		    t.string  "supplier_category_name", limit: 50, null: false
		    t.integer "is_hidden",              limit: 1,  null: false
		  end

		  create_table "suppliers", primary_key: "supplier_id", force: true do |t|
		    t.integer "supplier_category_id", limit: 1,   null: false
		    t.string  "supplier_name",        limit: 50,  null: false
		    t.string  "supplier_phone",       limit: 15
		    t.string  "supplier_address",     limit: 200
		    t.integer "supplier_added_at",                null: false
		    t.integer "is_hidden",            limit: 1,   null: false
		  end

		  add_index "suppliers", ["supplier_category_id"], name: "supplier_category_id", using: :btree

		  create_table "suppliers_items", id: false, force: true do |t|
		    t.integer "supplier_id",                                            null: false
		    t.integer "item_id",                                                null: false
		    t.integer "item_variety_id",                                        null: false
		    t.integer "unit_id",              limit: 1,                         null: false
		    t.decimal "item_price",                     precision: 6, scale: 2, null: false
		    t.integer "item_min_units"
		    t.integer "item_max_units"
		    t.integer "supplier_item_rating", limit: 1
		    t.integer "is_hidden",            limit: 1,                         null: false
		    t.integer "updated_at",                                             null: false
		  end

		  add_index "suppliers_items", ["item_id"], name: "item_id", using: :btree
		  add_index "suppliers_items", ["supplier_id"], name: "supplier_id", using: :btree

		  create_table "suppliers_items_price_history", id: false, force: true do |t|
		    t.integer "supplier_id",                                       null: false
		    t.integer "item_id",                                           null: false
		    t.integer "item_variety_id",                                   null: false
		    t.integer "unit_id",         limit: 1,                         null: false
		    t.decimal "item_price",                precision: 6, scale: 2, null: false
		    t.integer "updated_at"
		  end

		  add_index "suppliers_items_price_history", ["item_id"], name: "item_id", using: :btree
		  add_index "suppliers_items_price_history", ["supplier_id"], name: "supplier_id", using: :btree

		  create_table "suppliers_remarks", primary_key: "supplier_remark_id", force: true do |t|
		    t.integer "supplier_id",                 null: false
		    t.string  "supplier_remark", limit: 500, null: false
		  end

		  add_index "suppliers_remarks", ["supplier_id"], name: "supplier_id", using: :btree

		  create_table "units", primary_key: "unit_id", force: true do |t|
		    t.string  "unit_name", limit: 100, null: false
		    t.integer "is_hidden", limit: 1,   null: false
		  end

		  create_table "users", primary_key: "username", force: true do |t|
		    t.string  "password", limit: 32, null: false
		    t.integer "role",     limit: 3,  null: false
		  end

	end

end

