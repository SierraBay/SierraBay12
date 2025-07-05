/datum/configuration/New()
	load_config()
	max_gear_cost = 30
	load_options()
	load_map()
	load_sql()
	load_hub_entry()
	motd = file2text("config/motd.txt") || ""
	event = file2text("config/event.txt") || ""