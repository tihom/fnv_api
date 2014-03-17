class CrawlersController < ApplicationController

	def index
    	@crawlers = Supplier.crawlers.select{|c| c[:supplier] }
	end

	def items_list
		@crawler = Supplier.crawlers.find{|c| c[:id] == params[:id] }
		@items = @crawler[:api].constantize.try(:get_all_items)
	end

	private

	def crawler_params
		
	end

end