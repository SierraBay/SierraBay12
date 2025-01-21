/datum/trading_station/example
	// A simple example of how to create a trading station.
	// The name_pool is a list of possible names and descriptions
	// The first element of the pair is the name that will show up in the UI
	// The second element is the description that will show up in the UI
	name_pool = list(
		"FTB \"Example\"" = "Free Trade Beacon \"Example\": Just a simple example of how to create a trading station!",
		)
	// The uid is a unique identifier for the trading station
	// It must be unique among all trading stations.
	uid = "example"
	// The unlock_favor is the amount of favor required to unlock the hidden inventory
	// The hidden inventory is a list of items that will be available after the favor requirement has been met
	unlock_favor = 1000
	// The faction is the parent faction of the trading station
	// Factions have relations with other factions, but it is usually outside of player's control
	faction = FACTION_INDEPENDENT
	// If spawn_always is TRUE, the trading station will spawn every round
	// If spawn_always is FALSE, the trading station will spawn at a random time with a probability set by spawn_probability
	spawn_always = TRUE
	// The markup is the multiplier for the prices of all items in the trading station
	// A markup of 1.2 will make the prices 20% higher than the default price
	markup = 1.2
	// The inventory is a big list of items that the trading station will sell
	inventory = list(
		TRADE_CAT_FOOD = list(
			/obj/item/reagent_containers/food/snacks/cheesecake = CUSTOM_GOODS_NAME("cheesecake"),
			/obj/item/reagent_containers/food/snacks/pizza = CUSTOM_GOODS_NAME("pizza"),
			/obj/item/reagent_containers/food/drinks/coffee = CUSTOM_GOODS_NAME("coffee"),
			),
		)
