require "rubygems"
#require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "headless"

Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://www.hopcoms.kar.nic.in/"

module HopcomApi
	extend self

	# def get_latest_prices(opts={})
	# 	data = []
	# 	rate_list = get_latest_price
	# 	ItemMapping.where("hopcom_name IS NOT NULL OR hopcom_name != ?", "").each do |im|
	# 		page = rate_list.find{|x| x.downcase == im.hopcom_name.downcase}
	# 		# add error reporting here if price is not valid or missing
	# 		# might need conversion of units
	# 		next unless page[:price] > 0.0
	# 		conv = im.hopcom_unit_conv || 1.0
	# 		data << {item_mapping_id: im.id, supplier_id: supplier_id, price: page[:price]*conv, time: page[:time].to_i}
	# 	end
	# 	data
	# end

	def get_latest_price(item_mapping,opts={})
		im = item_mapping
		page = get_rate_list(opts).find{|x| x[:name].downcase == im.identifier.downcase}	
		raise Exceptions::CrawlerError.new("Item not found for #{item_mapping.item_name} in #{self.name}") unless page.present?	
		[page[:price], page[:time].to_i]
	end

	def supplier_id
		# id of supplier that belongs to this crawler
		@@supplier_id ||= Supplier.find_by_crawler_api(self.name).try(:id)
	end


	def get_price_history(item_name, sd, ed,opts={})
		data = []
		month_groups(sd,ed).each do |mon, yr|
      		puts "getting price for #{item_name} in #{mon} #{yr}"
      		data += get_date_wise_report(item_name, mon, yr,opts)
      	end
      	data.sort_by{|x| x["date"]}
	end

	# return an array of month and year duplets between the given dates
	def month_groups(sd,ed)
	    (sd..ed).map{|d| [Date::MONTHNAMES[d.month], d.year]}.uniq
	end

	def get_all_items
		report = DateWiseReport.new 
		report.all_items
	end

	def get_date_wise_report(item_name,mon,yr,opts={})
		Rails.cache.fetch("#{item_name}_#{mon}_#{yr}", expires_in: 1.hour, force: opts[:force]) do 
			puts "in date wise report cache"
			report = DateWiseReport.new item_name, mon, yr
			report.data
		end
    	# resuce following error
    	# Capybara::ElementNotFound: Unable to find option "POTATAA"
	end

	def get_rate_list(opts={})
		url = CustomUri.build_url(:host => "www.hopcoms.kar.nic.in", :path => "/RateList.aspx")
		Rails.cache.fetch(url, expires_in: 1.hour, force: opts[:force]) do
			puts "in rate list cache"
			rl = RateList.new url
			rl.data
		end
	end


	
	class RateList < NokogiriNode

		def time
			txt = get("//span[@id='ctl00_LC_DateText']")[/\d{2}\/\d{2}\/\d{4}/]
			# adding current time of day to the date to capture price variation during a day
			strpdate_with_current_time(txt, "%d/%m/%Y")
		end

		def rows
			node.xpath("//table[@id='ctl00_LC_grid1']/tr")			
		end

		def data
			data = []
			return data unless time
			rows.each do |row|
				[[2,3],[5,6]].each do |n,p|
					name = row.xpath("td[#{n}]").text.strip
					price  = row.xpath("td[#{p}]").text.strip
					data << {name: name, price: price.to_i} if valid_entry(name,price)
				end
			end
			data.map{|i| i[:time] = time}
			data
		end

		def valid_entry(name,price)
			name && name[/[A-Z]+/i] && price && price[/\d+/]
		end

	end

	class DateWiseReport < CapybaraNode
		include Capybara::DSL

		def visit_page(item_name=nil, month=nil, year=nil)
			visit('AnalysisReport.aspx')
			@item_name = item_name
		    select(month.capitalize, :from => "ctl00_LC_drop1") if month
		    select(year.to_s, :from => "ctl00_LC_drop2") if year
		    select(item_name, :from => "ctl00_LC_drop3") if item_name
		    click_button "ctl00_LC_but1" if  item_name || month || year
		    @doc = Nokogiri::HTML html
		end

	    def all_items
      		all(:xpath, "//select[@id='ctl00_LC_drop3']//option").map { |a| a.text}
    	end

    	def data_table
    		doc.xpath("//table[@id='ctl00_LC_grid1']/tbody")
    	end

    	def rows
    		data_table.xpath("tr")
    	end

    	def data
    		data = []
    		rows.each do |row|
    			date = row.xpath("td[2]").text.strip
    			price = row.xpath("td[3]").text.strip
    			date_parsed, price_int = valid_entry(date, price)
    			data << {name: @item_name, price: price_int, time: date_parsed} if date_parsed && price_int
    		end
    		data
    	end

    	def valid_entry(date,price)
    		return unless date && price && date[/\d{2}\/\d{2}\/\d{4}/]
    		date_parsed = NokogiriNode.strpdate_with_current_time(txt, "%d/%m/%Y")
    		price_int = price.strip.to_i
    		return unless (date_parsed && (price_int > 0) )
    		[date_parsed, price_int]
    	end

	end
end




