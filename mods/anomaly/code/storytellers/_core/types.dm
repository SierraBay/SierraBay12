/datum/planet_storyteller/electra_home
	scam_abilities = list(
		/datum/storyteller_ability/spawn_fake_anomaly/electra_ice)
	anomaly_activities = list(
		/datum/storyteller_ability/spawn_anomaly/electra)
	mob_abilities = list(
		/datum/storyteller_ability/spawn_mobs/ice)

/datum/planet_storyteller/gravi_home
	scam_abilities = list(
		/datum/storyteller_ability/spawn_fake_anomaly/gravi)
	anomaly_activities = list(
		/datum/storyteller_ability/spawn_anomaly/gravi)
	mob_abilities = list(
		/datum/storyteller_ability/spawn_mobs/gravi)

/datum/planet_storyteller/water_home
	scam_abilities = list(
		/datum/storyteller_ability/spawn_fake_anomaly/water)
	anomaly_activities = list(
		/datum/storyteller_ability/spawn_anomaly/water)
	mob_abilities = list(
		/datum/storyteller_ability/spawn_mobs/water)

/datum/planet_storyteller/electra_home/mob_test
		activity_levels = list(
		list(
			name = "impotent",
			scam_chance = 0,
			anomaly_chance = 0,
			mob_chance = 100,
		),
		list(
			name = "active",
			scam_chance = 0,
			anomaly_chance = 0,
			mob_chance = 100,
		),
		list(
			name = "angry",
			scam_chance = 0,
			anomaly_chance = 0,
			mob_chance = 100,
		)
	)

/obj/deploy_storyteller_here
	var/storyteller_path = /datum/planet_storyteller/electra_home/mob_test
	var/datum/planet_storyteller/storyteller

/obj/deploy_storyteller_here/New(loc, ...)
	.=..()
	storyteller = new storyteller_path(null, get_area(src))

/obj/deploy_storyteller_here/anomaly_test
	storyteller_path = /datum/planet_storyteller/electra_home/anomaly_test

/datum/planet_storyteller/electra_home/anomaly_test
	activity_levels = list(
		list(
			name = "impotent",
			scam_chance = 0,
			anomaly_chance = 100,
			mob_chance = 0,
		),
		list(
			name = "active",
			scam_chance = 0,
			anomaly_chance = 100,
			mob_chance = 0,
		),
		list(
			name = "angry",
			scam_chance = 0,
			anomaly_chance = 100,
			mob_chance = 0,
		)
	)

/obj/deploy_storyteller_here/anomaly_test/New(loc, ...)
	. = ..()
	storyteller.current_evolution_points = 500
	storyteller.check_level_up()
	storyteller.next_possible_action = 1
	storyteller.current_anomaly_points = 500
	storyteller.check_action()

/obj/deploy_storyteller_here/scam_test
	storyteller_path = /datum/planet_storyteller/electra_home/scam_test

/datum/planet_storyteller/electra_home/scam_test
	activity_levels = list(
		list(
			name = "impotent",
			scam_chance = 100,
			anomaly_chance = 0,
			mob_chance = 0,
		),
		list(
			name = "active",
			scam_chance = 100,
			anomaly_chance = 0,
			mob_chance = 0,
		),
		list(
			name = "angry",
			scam_chance = 100,
			anomaly_chance = 0,
			mob_chance = 0,
		)
	)

/obj/deploy_storyteller_here/scam_test/New(loc, ...)
	. = ..()
	storyteller.current_evolution_points = 500
	storyteller.check_level_up()
	storyteller.next_possible_action = 1
	storyteller.current_scam_points = 500
	storyteller.check_action()


/obj/deploy_storyteller_here/anomaly_test_titan
	storyteller_path = /datum/planet_storyteller/water_home/anoms

/datum/planet_storyteller/water_home/anoms
	activity_levels = list(
		list(
			name = "impotent",
			scam_chance = 0,
			anomaly_chance = 100,
			mob_chance = 0,
		),
		list(
			name = "active",
			scam_chance = 0,
			anomaly_chance = 100,
			mob_chance = 0,
		),
		list(
			name = "angry",
			scam_chance = 0,
			anomaly_chance = 100,
			mob_chance = 0,
		)
	)

/obj/deploy_storyteller_here/anomaly_test_titan/New(loc, ...)
	. = ..()
	storyteller.current_evolution_points = 500
	storyteller.check_level_up()
	storyteller.next_possible_action = 1
	storyteller.current_anomaly_points = 500
	storyteller.check_action()
