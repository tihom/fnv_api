require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "headless"

Capybara.run_server = false
Capybara.current_driver = :webkit

class CapybaraCrawl
    include Capybara::DSL
   
    def visit_page(site, headlessly, item_name=nil, month=nil, year=nil)
        headless = headlessly == "true" ?  Headless.new : nil
        headless.start if headless

            if site == "hopcoms"
                Capybara.app_host = "http://www.hopcoms.kar.nic.in/"
                visit('AnalysisReport.aspx')
                select(month.capitalize, :from => "ctl00_LC_drop1") if month
                select(year.to_s, :from => "ctl00_LC_drop2") if year
                select(item_name, :from => "ctl00_LC_drop3") if item_name
                click_button "ctl00_LC_but1" if  item_name || month || year
                #return all(:xpath, "//div[@id='ctl00_LC_report']//td").map{ |a| a.text }
                return html

            elsif site == "kmv"
                Capybara.app_host = "http://krishimaratavahini.kar.nic.in/" 
                Capybara.save_and_open_page_path = 'capybara.html'
                visit('reports/DateWiseReport.aspx')
                select(item_name.upcase, :from => "_ctl0_content5_ddlcommodity") if item_name
                select(month.upcase, :from => "_ctl0_content5_ddlmonth") if month
                select(year.to_s, :from => "_ctl0_content5_ddlyear") if year
                #select("AllMarkets", :from => "_ctl0_content5_ddlmarket") #default is all market so not needed
                click_button "_ctl0_content5_viewreport" if  item_name || month || year
                #return all(:xpath, "//div[@id='divprint']//table/tbody").map{ |a| a.text }
                return html

            end
        
        headless.destroy if headless


    end
end

spider = CapybaraCrawl.new
puts spider.visit_page(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4])

