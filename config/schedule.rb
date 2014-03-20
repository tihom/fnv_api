set :output, {:error => "#{path}/log/cron_errors.log", :standard => "#{path}/log/cron.log"}

case @environment
when 'production'
	
	every 6.hours do
	  rake "crawler:update_prices"
	end

end


