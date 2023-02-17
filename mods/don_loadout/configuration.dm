/datum/configuration
	/// Set to 1 to enable loadout donations system
	var/static/donations_enabled = FALSE

	/// The number of extra points donators would have
	var/static/extra_loadout_points = 5


/datum/configuration/New()
 . = ..()
 load_donations()

/datum/configuration/proc/load_donations()
	var/list/file = read_config("config/donations.txt")
	for (var/name in file)
		var/value = file[name]
		switch (name)
			if ("enable_donations")
				donations_enabled = TRUE
			if ("extra_loadout_points")
				extra_loadout_points = text2num(value)
