class CapybaraNode


		def initialize(item_name=nil, month=nil, year=nil)
			# need headless as unbuntu does not have x server
			# does not run on mac  so need to use env 
      		headless = Rails.env.development? ? nil : Headless.new 
	        headless.try(:start)
	        visit_page(item_name, month, year)
		    headless.try(:destroy)
	    end


	    def doc
      		@doc
    	end

end