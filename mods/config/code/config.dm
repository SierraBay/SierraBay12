/datum/configuration/New()
	load_config()
	max_gear_cost = 30
	probabilities["extended"] = 1
	probabilities["traitor"] = 1
	probabilities["spyvspy"] = 1
	probabilities["mercenary"] = 1
	probabilities["heist"] = 1
	probabilities["cult"] = 1
	probabilities["intrigue"] = 1
	probabilities["thething"] = 1
	probabilities["traitorling"] = 1
	probabilities["operative"] = 1
	load_options()
	load_map()
	load_sql()
	load_hub_entry()
	motd = file2text("config/motd.txt") || ""
	event = file2text("config/event.txt") || ""
