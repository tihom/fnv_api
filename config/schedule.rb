set :output, "#{path}/log/cron.log"

case @environment
when 'production'
	
	every 6.hours 
	  rake "crawler:update_prices"
	end


end


