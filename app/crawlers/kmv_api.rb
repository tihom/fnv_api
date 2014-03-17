require "rubygems"
#require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
# Need ot use capybara for kmv as usual methods did not work due to js form validation
Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://krishimaratavahini.kar.nic.in/"

module KmvApi

  extend self

  # def get_latest_prices(opts={})
  #   data = []
  #   ItemMapping.where("kmv_name IS NOT NULL OR kmv_name != ?", "").each do |im|
  #     page = get_price_history(im.kmv_name, ["BANGALORE", "BINNY"])
  #     # add error reporting here if price is not valid or missing
  #     next unless page.present? 

  #     rate = page["BANGALORE"] || page["BINNY"]

  #     conv = im.kmv_unit_conv || 0.01 # prices on mv are in quintal typically so converting to kg
  #     data << {item_mapping_id: im.id, supplier_id: supplier_id, price: rate[:price]*conv, time: rate[:time].to_i}
  #   end
  #   data
  # end

  def get_latest_price(item_mapping,opts={})
    im = item_mapping

    page = get_price_history(im.identifier, ["BANGALORE", "BINNY", "BINNY MILL (F&V)"],nil,nil,opts)
    raise Exceptions::CrawlerError.new("Item not found for #{item_mapping.item_name} in #{self.name}") unless page.present? 
    
    rate = page["BANGALORE"] || page["BINNY"] || page["BINNY MILL (F&V)"]
    [rate[:price], rate[:time].to_i]
  end


  def supplier_id
    # id of supplier that belongs to this crawler
    @@supplier_id ||= Supplier.find_by_crawler_api(self.name).try(:id)
  end

  def get_all_items
     report = DateWiseReport.new 
     report.all_items
  end


  # returns a hash with key as each market and value as an array of prices for different dates and other meta data
  # { "BANGALORE" => [{"Date" => "10/01/2014", "Modal" => "25","Average" => "27"}, {"Date" => }...],
  #   "BINNY" => 
  # }
  def get_price_history(item_name,  markets=[], sd=nil, ed=nil,opts={})
    data = []
    latest_only = false
    # if either of sd or ed are missing
    unless sd && ed
      sd = Date.today - 2
      ed = Date.today
      latest_only = true
    end
    month_groups(sd,ed).each do |mon, yr|
      puts "getting price for #{item_name} in #{mon} #{yr}"
      data += get_date_wise_report(item_name, mon, yr,opts)
    end
    # different itmes can come up in the report e.g. chips in potato
    data = data.select{|x| x[:name].downcase == item_name.downcase}
    # select the markets given
    data = data.select{|x| markets.map(&:upcase).include? x[:market]} if markets.present?
    data = data.group_by{|x| x[:market]}
    data.map{|k,v| data[k] = v.sort_by{|x| x[:date]}}
    data.map{|k,v| data[k] = v.last} if latest_only
    data
  end

  # return an array of month and year duplets between the given dates
  def month_groups(sd,ed)
    (sd..ed).map{|d| [Date::MONTHNAMES[d.month], d.year]}.uniq
  end

  def get_date_wise_report(item_name, month=nil, year=nil,opts={})
    Rails.cache.fetch("#{item_name}_#{month}_#{year}", expires_in: 1.hour, force: opts[:force]) do
              puts "in date wise report cache"
              report =  DateWiseReport.new item_name, month, year
              report.data
    end
    # resuce following error
    # Capybara::ElementNotFound: Unable to find option "POTATAA"
  end

  class DateWiseReport
    include Capybara::DSL
    
    # fetch the report for given item name (name in caps e.g. AJWAN), month (full name e.g. JANUARY) and year (numeric e.g. 2014 )
    # if no valu is given the default value is selected 
    # item default is first option : AJWAN
    # Month default is JANUARY
    # YEAR default is current year e.g. 2014

    # Will raise error if given item_name is not present in the list
    # will return blank array if item is present but no data is returned by kmv site
    def initialize(item_name=nil, month=nil, year=nil)
      visit('reports/DateWiseReport.aspx')
      @item_name = item_name
      select(item_name.upcase, :from => "_ctl0_content5_ddlcommodity") if item_name
      select(month.upcase, :from => "_ctl0_content5_ddlmonth") if month
      select(year.to_s, :from => "_ctl0_content5_ddlyear") if year
      #select("AllMarkets", :from => "_ctl0_content5_ddlmarket") #default is all market so not needed
      click_button "_ctl0_content5_viewreport" if  item_name || month || year
      @doc = Nokogiri::HTML html
    end

    def doc
      @doc
    end

    def all_items
      all(:xpath, "//select[@id='_ctl0_content5_ddlcommodity']//option").map { |a| a.text}
    end

    def all_markets
      Hash[all(:xpath, "//select[@id='_ctl0_content5_ddlmarket']//option").map { |a| [a["value"], a.text]}]
    end

    def item_name
      @item_name
    end

    def data_table
      @data_table ||=  doc.xpath("//div[@id='divprint']//table/tbody")
    end

    def rows
     @rows ||= data_table.xpath("tr")[1..-1]
    end

    # should be equal to ["Market", "Date", "Variety", "Grade", "Arrivals", "Unit", "Min", "Max", "Modal"] 
    def headers
      @headers ||= data_table.xpath("tr[1]/th").map(&:text)
    end

    def raw_data
      @raw_data ||= rows.collect do |row|
        data = {}
        headers.map.with_index{|h,index| data[h] = row.xpath("td[#{index+1}]").text.strip} #row.all(:xpath,"td[#{index+1}]").first.try(:text)}
        data
      end
    end


    def data
      return @data  if @data
      # select rows with vaild date , name and price
      d = raw_data.select{|x| x["Date"] && x["Date"][/^\d{2}\/\d{2}\/\d{4}$/] && x["Modal"].to_i >= 0 }.
          select{|x| x["Date"] = NokogiriNode.strpdate_with_current_time(x["Date"], "%d/%m/%Y")}
      latest_market = nil 
      arr = []
      # populate the market in each row by selecting the latest row with a non blank value for market
      d.each do |x|
        h = {}
        h[:market] =  x["Market"][/[A-Z]+/i] ? x["Market"] : latest_market
        latest_market = h[:market]
        # standardize the keys containing price, unit and name information
        # x[:name] = item_name
        h[:name] = x["Variety"]
        h[:price] = x["Modal"].to_i
        h[:time] = x["Date"]
        h[:unit] = x["Unit"]
        arr << h
      end
      @data = arr
    end



  end
end
