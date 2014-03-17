class BigBasketApiController < ApplicationController
  
  # returns the current price of the given item
  # Query Params
  #   = url: url to fetch
  # Result
  # json encoded information about the item
  #   = name:
  #   = price:
  #   = unit:
  #   = url:
  #   = error:
  def current_price
  	@item_pages =  BigBasketApi.get_item_page params[:url]
  	respond_to do |format|
	      format.html
	      format.xml  { render :xml => @item_pages.map(&:to_xml)}
	      format.json  { render :json => @item_pages.map(&:to_json)}
	end
  end


end
