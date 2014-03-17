require "rubygems"
#require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"

Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://www.hopcoms.kar.nic.in/" #http://krishimaratavahini.kar.nic.in/"

module Test
  class Google
    include Capybara::DSL
   
    def get_results
    	visit('AnalysisReport.aspx')
     	select("January", :from => "ctl00_LC_drop1")
     	select("2014", :from => "ctl00_LC_drop2")
     	select("Amla", :from => "ctl00_LC_drop3")
    	click_button "ctl00_LC_but1"

    	all(:xpath, "//div[@id='ctl00_LC_report']//td").map{ |a| a.text }
    end
  end
end

spider = Test::Google.new
p spider.get_results


# Supplier mapping to crawlers

supplier_name:string
supplier_id:integer
crawler_module:string
mapping_method: #for a given item returns the relevant item identifier in supplier

#given item_name, item_variety and unit  return the item identifier on external api

# where to place the logic of updating the prices of suppliers using crawlers

# does it have a state?
# need to log the progess, check when last run..like an update status or delayed job?
# can call it crawl job