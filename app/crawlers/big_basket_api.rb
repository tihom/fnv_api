# Api module for big basket website
module BigBasketApi

	extend self

	def get_latest_price(item_mapping,opts={})
		im = item_mapping
		page = get_item_page im.identifier
		# add error reporting here if page is not valid
		raise Exceptions::CrawlerError.new("Page not valid with name #{page.name} and price #{page.price}") unless page.try(:valid?)
		[page.price, Time.zone.now.to_i]
	end

	def supplier_id
		# id of supplier that belongs to this crawler
		@@supplier_id ||= Supplier.find_by_crawler_api(self.name).try(:id)
	end

	# return the item page object given the url
	def get_item_page(url)
		ItemPage.new url
	end

	def id_from_url(url)
		url[/(?<=\/pd\/).+?(?=\/|\?|\#|$)/]
	end

	def url_from_id(id)
		CustomUri.build_url(:host => "bigbasket.com", :path => "/pd/#{id}")
	end

	# class representing an item show page on the big basket website
	class ItemPage < NokogiriNode

	    def price
	    	extract_rs get("//div[@itemprop='price']")
	    end

	    def unit
	    	get("//span[@itemprop='model']/text()").gsub(/Pack\s+Size\s*\:\s+/i,"").strip
	    end

	    def name
	    	get("//div[@itemprop='name']/h1").strip
	    end

	    # item id for big basket
	    # item url can be generated from id as : http://bigbasket.com/pd/{id}/some-text
	    def id
	    	BigBasketApi.id_from_url(@url)
	    end

	    def attribs
	    	{name: name, price: price.to_i, unit: unit, time: Time.now.to_i}
	    end

	    def valid?
	    	name.present?
	    end

	    def to_json
	    	attribs.to_json
	    end

	    def to_xml
	    	attribs.to_xml
	    end


	end

end