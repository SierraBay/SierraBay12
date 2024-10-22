/obj/overmap/visitable/sector/exoplanet/ice
	name = "ice exoplanet"
	desc = "A distant, abandoned and cold world, rich in artefacts and anomalous activity."
	color = "#ebe3e3"
	rock_colors = list(COLOR_WHITE)
	can_spawn_anomalies = TRUE
	monitor_effect_type = /obj/monitor_effect_triger/snow
	anomalies_type = list(
		/obj/anomaly/electra/three_and_three = 2,
		/obj/anomaly/electra/three_and_three/tesla = 7,
		/obj/anomaly/electra/three_and_three/tesla_second = 6,
		/obj/anomaly/cooler/two_and_two = 3,
		/obj/anomaly/cooler/three_and_three = 3
		)
	min_anomaly_size = 4
	max_anomaly_size = 9
	min_anomalies_ammout = 400
	max_anomalies_ammout = 600
	planetary_area = /area/exoplanet/ice
	map_generators = list(/datum/random_map/automata/cave_system/mountains/ice, /datum/random_map/noise/exoplanet/ice)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES
	surface_color = "#ffffff"
	water_color = "#0700c7"
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 0


/obj/overmap/visitable/sector/exoplanet/ice/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)

/datum/random_map/automata/cave_system/mountains/ice
	iterations = 2
	descriptor = "space ice rocks"
	wall_type =  /turf/simulated/mineral/ice
	mineral_turf =  /turf/simulated/mineral/ice
	rock_color = COLOR_WHITE

/turf/simulated/mineral/ice
	name = "Ice wall"
	icon_state = "ice_wall"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE
	blocks_air = FALSE
	initial_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)

/turf/simulated/mineral/random/ice
	name = "Ice wall"
	icon_state = "ice_wall"
	icon = 'mods/anomaly/icons/planets.dmi'
	color = COLOR_WHITE

/obj/overmap/visitable/sector/exoplanet/ice/generate_atmosphere()
	..()
	var/datum/species/H = all_species[SPECIES_HUMAN]
	var/generator/new_temp = generator("num", H.cold_level_1 - 50, H.cold_level_3, NORMAL_RAND)
	atmosphere.temperature = new_temp.Rand()
	atmosphere.update_values()


/datum/random_map/noise/exoplanet/ice
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/ice
	water_type = /turf/simulated/floor/exoplanet/ice
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/ice
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/ice



//ICE ROCK


/turf/simulated/mineral/ice/on_update_icon(update_neighbors)
	if(!istype(mineral))
		SetName(initial(name))
		icon_state = "ice_wall"
	else
		SetName("[mineral.ore_name] deposit")

	ClearOverlays()

	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(update_neighbors && istype(turf_to_check,/turf/simulated/floor/asteroid))
			var/turf/simulated/floor/asteroid/T = turf_to_check
			T.updateMineralOverlays()
		else if(istype(turf_to_check,/turf/space) || istype(turf_to_check,/turf/simulated/floor))
			var/image/rock_side = image(icon, "ice_side", dir = turn(direction, 180))
			rock_side.turf_decal_layerise()
			switch(direction)
				if(NORTH)
					rock_side.pixel_y += world.icon_size
				if(SOUTH)
					rock_side.pixel_y -= world.icon_size
				if(EAST)
					rock_side.pixel_x += world.icon_size
				if(WEST)
					rock_side.pixel_x -= world.icon_size
			AddOverlays(rock_side)

	if(ore_overlay)
		AddOverlays(ore_overlay)

	if(excav_overlay)
		AddOverlays(excav_overlay)

	if(archaeo_overlay)
		AddOverlays(archaeo_overlay)


//СКАЛОЛАЗАНЬЕ
/turf/simulated/mineral/ice/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, SPAN_GOOD("Шагните на скалу, чтоб попытаться взабраться на неё."))

/turf/simulated/mineral/ice/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(istype(mover, /mob/living/carbon/human)) //Если пытается шагнуть человек - он может взабраться на скалу
		if(!istype(mover.loc, /turf/simulated/mineral/ice))
			var/mob/living/carbon/human/user = mover
			if(user.stamina < 60)
				to_chat(mover, SPAN_BAD("Я слишком устал!"))
				return
			visible_message("[user] начинает взбираться вверх по склону.", "Вы слышите как кто-то залезает вверх по склону.", 5)
			if(do_after(user, (15 SECONDS - (2 SECONDS *user.get_skill_value(SKILL_HAULING)))))
				//Помощь друга даёт 25 процентов на успех и не даёт пораниться при падении
				//Макс бонус от навыка составит 50 процентов
				//Бонус от кирки при подьёме составит 25 процентов
				var/helper_chance = 0
				var/pickaxe_chance = 0
				for(var/mob/living/carbon/human/helper in src)
					if(helper.a_intent == I_HELP && turn(user.dir, 180) == helper.dir) //Лезущий и помощник должны смотреть друг другу в лицо
						helper_chance = 25
						to_chat(user, SPAN_GOOD("[helper] помогает вам взобраться на скалу."))
						to_chat(helper, SPAN_GOOD("Вы помогаете [user] взобраться на скалу."))
						break //Помощник найден
				if(user.IsHolding(/obj/item/pickaxe))
					to_chat(user, SPAN_NOTICE("Вам куда легче взбираться вверх с киркой."))
					pickaxe_chance = 25
				var/success_chance = (10 * user.get_skill_value(SKILL_HAULING)) + helper_chance + pickaxe_chance //Максимально - 100 процентов
				if(prob(success_chance))
					user.forceMove(get_turf(src))
					to_chat(user, SPAN_GOOD("Вы успешно взбираетесь на гору."))
				else
					var/list/result_effects = calculate_artefact_reaction(user, "Падение с высоты")
					if(result_effects)
						if(result_effects.Find("Защищает от падения"))
							to_chat(user, SPAN_GOOD("Вы срываетесь вниз, но что-то ловит вас прямо у земли, оберегая от повреждений."))
							return
					if(!helper_chance) //Нам никто не помог
						for(var/picked_organ in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
							user.apply_damage(2.5, DAMAGE_BRUTE, picked_organ, used_weapon="Gravitation")
						user.adjust_stamina(-50)
						to_chat(user, SPAN_BAD("Вы срываетесь вниз, ударяясь в процессе."))
					else
						user.adjust_stamina(-50)
						to_chat(user, SPAN_COLOR("#ffa500","Вы срываетесь вниз, но стоящий сверху удерживает вас, предотвращая ранения."))

		else
			mover.forceMove(get_turf(src))
	. = ..()

/turf/simulated/mineral/ice/Exit(O, newloc)
	if(istype(O, /mob/living/carbon/human) && !istype(newloc,/turf/simulated/mineral/ice)) //Человек пытается слезть с скалы
		var/mob/living/carbon/human/user = O
		if(do_after(user, (15 SECONDS - (2 SECONDS * user.get_skill_value(SKILL_HAULING))))) //Чем лучше атлетика, тем быстрее спуск
			//Помощь друга даёт 25 процентов на успех и не даёт пораниться при падении
			//Макс бонус от навыка составит 50 процентов
			//Бонус от кирки при подьёме составит 25 процентов
			var/helper_chance = 0
			var/pickaxe_chance = 0
			for(var/mob/living/carbon/human/helper in newloc)
				if(helper.a_intent == I_HELP && turn(user.dir, 180) == helper.dir) //Лезущий и помощник должны смотреть друг другу в лицо
					helper_chance = 25
				to_chat(user, SPAN_GOOD("[helper] помогает вам взобраться на скалу."))
				to_chat(helper, SPAN_GOOD("Вы помогаете [user] взобраться на скалу."))
				break //Помощник найден
			if(user.IsHolding(/obj/item/pickaxe))
				to_chat(user, SPAN_NOTICE("Вам куда легче взбираться вверх с киркой."))
				pickaxe_chance = 25
			var/success_chance = (10 * user.get_skill_value(SKILL_HAULING)) + helper_chance + pickaxe_chance //Максимально - 100 процентов
			if(prob(success_chance))
				to_chat(user, SPAN_GOOD("Вы аккуратно слезаете со скалы."))
				user.forceMove(newloc)
			else
				var/list/result_effects = calculate_artefact_reaction(user, "Падение с высоты")
				if(result_effects)
					if(result_effects.Find("Защищает от падения"))
						to_chat(user, SPAN_GOOD("Вы срываетесь вниз, но что-то ловит вас прямо у земли, оберегая от повреждений."))
						return
				if(!helper_chance)
					to_chat(user, SPAN_BAD("Вы срываетесь вниз со скалы."))
					for(var/picked_organ in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
						user.apply_damage(5, DAMAGE_BRUTE, picked_organ, used_weapon="Gravitation")
					user.adjust_stamina(-100)
					user.forceMove(newloc)
				else
					to_chat(user, SPAN_COLOR("#ffa500", "Вы срываетесь вниз со скалы, но вас ловят предотвращая ранения."))
					user.adjust_stamina(-100)
					user.forceMove(newloc)
		else
			return FALSE
	. = ..()

/turf/simulated/mineral/ice/Bumped(AM)
	return
