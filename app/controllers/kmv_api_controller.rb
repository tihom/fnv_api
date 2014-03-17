class KmvApiController < ApplicationController
  
  # returns the current price of the given item
  # Query Params
  #   = name: corresponding name of the item on kmv
  # Optional params
  #   = markets: comma separated names of market for which to return the results
  #   = sd: start date in yyyy-mm-dd format
  #   = ed: end date in yyyy-mm-dd format
  # if no dates are given the lates prices are retruned
  # Result
  # json encoded information about the item for various markets and dates
  #   = {market => [{date: , name: , price:, unit: , ..etc },{date: , name:,... }... ]... }

  def price_report
    sd = Date.strptime(params[:sd], "%Y-%m-%d") rescue nil
    ed = Date.strptime(params[:ed], "%Y-%m-%d") rescue nil
    markets = params[:markets].split(",") rescue nil
    @data = KmvApi.get_price_history(params[:name], markets,sd, ed)
  	respond_to do |format|
	      format.html
	      format.xml  { render :xml => @data.to_xml}
	      format.json  { render :json => @data.to_json}
	end
  end


end