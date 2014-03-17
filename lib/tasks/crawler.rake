namespace :crawler do 

	desc "Update prices using crawlers"
	task :update_prices => :environment do
		Rakify.rescue_task(:item_mapping, :update_prices, "BigBasket")
		Rakify.rescue_task(:item_mapping, :update_prices, "Hopcoms")
		Rakify.rescue_task(:item_mapping, :update_prices, "Kmv")
	end

end