/obj/titan_fluid
	name = ""
	icon = 'icons/effects/liquids.dmi'
	icon_state = "ocean"
	anchored = TRUE
	simulated = FALSE
	opacity = 0
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	layer = FLY_LAYER
	alpha = 200
	color = COLOR_OCEAN
	var/move_delay = 0.5 SECONDS
	var/turf/my_turf
	var/move_cooldown = 0.1 SECONDS
	var/list/water_victims = list()
	///Список существ которые не замедляются и не задыхаются в воде
	var/list/whitelist_specis_move_slowdown = list(
		SPECIES_SKRELL,
		SPECIES_TRITONIAN,
		SPECIES_YEOSA
	)
	var/list/whitelist_species_oxygenization = list(
		SPECIES_SKRELL,
		SPECIES_TRITONIAN,
		SPECIES_IPC,
		SPECIES_FBP,
		SPECIES_YEOSA,
		SPECIES_ADHERENT
	)

/obj/titan_fluid/Crossed(O)
	. = ..()
	if(ishuman(O))
		var/mob/living/carbon/human/human = O
		human.water_act(FLUID_MAX_DEPTH)
		playsound(my_turf, 'mods/anomaly/sounds/water/max/water_move7.ogg', 100, 1)
		if(!(human.species.name in whitelist_specis_move_slowdown))
			var/datum/movement_handler/mob/delay/delay = human.GetMovementHandler(/datum/movement_handler/mob/delay)
			if(delay)
				delay.AddDelay(move_delay)
		if(!(human.species.name in whitelist_species_oxygenization))
			LAZYADD(water_victims, human)
			START_PROCESSING(SSanom, src)

/obj/titan_fluid/Initialize()
	. = ..()
	my_turf = get_turf(src)

/obj/titan_fluid/Uncrossed(O)
	. = ..()
	if(O in water_victims)
		LAZYREMOVE(water_victims, O)
