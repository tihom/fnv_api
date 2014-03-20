class ItemMapping < ActiveRecord::Base

	belongs_to :supplier
	belongs_to :item
	belongs_to :items_variety, foreign_key: :item_variety_id
	belongs_to :unit
	belongs_to :suppliers_item, foreign_key: [:item_id, :unit_id, :item_variety_id, :supplier_id]

	validates_uniqueness_of :item_id, scope: [:unit_id, :item_variety_id, :supplier_id]
	validates_numericality_of :unit_conversion


	class << self

		def update_prices(crawler_id=nil)
			puts "Updating prices for crawler #{crawler_id}"
			collection = ItemMapping.includes(:supplier).find_by_crawler_id(crawler_id)
			collection.find_each do |im|
				puts "id: #{im.id}"
				unless im.update_price
					# catch known errors here
					# unknown errors would be caught by rakify
					# log im.errors to crawler error log
					Supplier.crawler_errors_log.error "Following error encountered in updating price for mapping #{im.id} for item #{im.item_name} at crawler #{crawler_id}"
					Supplier.crawler_errors_log.error im.errors
				end
			end
			puts "Updated prices for crawler #{crawler_id}"
		end

		def find_by_crawler_id(crawler_id)
			 supplier = Supplier.find_by_crawler_id(crawler_id)
    		 self.where(supplier_id: supplier.try(:id)) 
		end

	end

	def crawler
		supplier.try(:crawler)
	end

	def crawler_api
		crawler[:api].constantize
	end

	def item_name
		item.try(:item_name)
	end

	def item_price
		suppliers_item.try(:item_price)
	end

	def price_last_updated_at
		ti = suppliers_item.try(:updated_at)
		return unless item_price && ti
		Time.zone.at ti
	end

	# def suppliers_item(reload=false)
	# 	@suppliers_item = nil if reload
	# 	@suppliers_item ||= SuppliersItem.where(suppliers_item_attributes).order("updated_at DESC").first
	# end


	def find_or_build_suppliers_item
		suppliers_item(true) || build_suppliers_item(suppliers_item_attributes)
	end

	def update_price(force=false)
		begin 
			raw_price, time = crawler_api.get_latest_price(self,force: force)
			raise Exceptions::CrawlerError.new("Price #{raw_price} not valid") unless price_valid?(raw_price)
			price = raw_price*unit_conversion
			hsh = {item_price: price, updated_at: time}
			create_suppliers_items_price_history(hsh)
			update_suppliers_item(hsh)
			return hsh
		rescue Exceptions::CrawlerError => e
			self.errors.add(:price,  e.message )
			# can add errors to a error log or error table db
			return false
		end
	end

	def price_valid?(p)
		p.to_i > 0.0
	end

	def create_suppliers_items_price_history(hsh)
		#might to add logic to prevent duplicate history creation
		SuppliersItemsPriceHistory.create suppliers_item_attributes.merge(hsh).except(:is_hidden)
	end

	def update_suppliers_item(hsh)
		# Add the item to supplier if not already present
		si = find_or_build_suppliers_item
		# Update the price if last updated time is older
		si.update_attributes(hsh) unless si.item_price && si.updated_at && (si.updated_at > hsh[:updated_at])
	end

	def suppliers_item_attributes
		{item_id: item_id, item_variety_id: item_variety_id, 
		 unit_id: unit_id, supplier_id: supplier_id, is_hidden: 0}
	end

	# Validations to make sure that the entry is not missing data
	validate do |im|

		# presence of supplier, item , unit and variety
		im.errors.add(:base, "Item not found") if im.item.blank?
		im.errors.add(:base, "Unit not found") if im.unit.blank?
		im.errors.add(:base, "Item Variety not found") if im.items_variety.blank?
		im.errors.add(:base, "Item Variety does not belong to item") if im.items_variety.try(:item) != im.item
		im.errors.add(:base, "Supplier not found") if im.supplier.blank?

		# check for duplicity
		#im.errors.add(:base, "Mapping already exists") if im.new_record? && ItemMapping.where(item_id: im.item_id, unit_id: im.unit_id, item_variety_id: im.item_variety_id, supplier_id: im.supplier_id).count > 0

		identifier_name = im.crawler.try(:identifier_name) || "external identifier"
		im.errors.add(:base, "#{identifier_name} cannot be blank") if im.identifier.blank?

		# rails converts the unit conversion to integer even if it is a string so need to use the inbuilt validation
		#im.errors.add(:base, "Unit conversion should be a number") if im.unit_conversion.blank? || !im.unit_conversion.to_s[/\A[-+]?[0-9]*\.?[0-9]+\Z/]
	end
end
