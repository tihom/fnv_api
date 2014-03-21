class CapybaraNode


		def initialize(item_name=nil, month=nil, year=nil)
			
			@item_name = item_name
			
			# need headless as unbuntu does not have x server
			# does not run on mac  so need to use env 
			headlesslly = Rails.env.development? ? "false" : "true"
			
			# running the capybara crawl as a script as within rails it was running into problems
			# was showin broken pipe which could be due to forking
			html = `ruby #{Rails.root}/lib/capybara_crawl.rb #{@site} #{headlesslly} #{item_name} #{month} #{year}`
			@doc = Nokogiri::HTML html.strip

            # headless = Rails.env.development? ? nil : Headless.new 
	        # headless.try(:start)
	        # visit_page(item_name, month, year)
		    # headless.try(:destroy)

	    end


	    def doc
      		@doc
    	end

end