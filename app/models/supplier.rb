class Supplier < ActiveRecord::Base
	self.primary_key = 'supplier_id'
	default_scope { where(is_hidden: 0) } 

	has_many :item_mappings
	has_one :crawler

	class << self

		def crawlers
			@@crawlers ||= ([
				{id: "BigBasket", api: "BigBasketApi", supplier_name: "Big Basket Online", unit_conversion: 1.0, identifier_name: "Big Basket Url", items_list_url: "http://bigbasket.com/cl/fruits-vegetables"},
			 	{id: "Hopcoms", api: "HopcomApi", supplier_name: "Hopcoms Online", unit_conversion: 1.0, identifier_name: "Hopcom's Name", items_list_url: "http://www.hopcoms.kar.nic.in/CommodityList.aspx"}, 
			 	{id: "Kmv", api: "KmvApi", supplier_name: "KMV Online", unit_conversion: 0.01, identifier_name: "Kmv Name", items_list_url: "http://krishimaratavahini.kar.nic.in/reports/DateWiseReport.aspx" } #"/crawlers/Kmv/items_list"
				].each{|c| c[:supplier] = Supplier.where(supplier_name: c[:supplier_name]).first })
		end

		def find_by_crawler_id(crawler_id)
			crawlers.find{|c| c[:id] == crawler_id}.try(:[],:supplier)
		end

		def find_by_crawler_api(api)
			crawlers.find{|c| c[:api] == api}.try(:[],:supplier)
		end

		def crawler_errors_log
			@@crawler_errors_log ||= Logger.new('log/crawler_errors.log')			
		end

	end

	def crawler
		@crawler ||= Supplier.crawlers.find{|v| v[:supplier].try(:supplier_id) == supplier_id}
	end

	def crawler_api
		@crawler_api ||= crawler[:api].constantize
	end


end