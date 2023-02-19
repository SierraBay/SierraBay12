GLOBAL_VAR(planet_repopulation_disabled)

/obj/effect/overmap/visitable/sector/exoplanet
	name = "exoplanet"
	icon_state = "globe"
	in_space = FALSE
	var/area/planetary_area
	var/list/seeds = list()
	var/list/fauna_types = list()		// possible types of mobs to spawn
	var/list/megafauna_types = list() 	// possibble types of megafauna to spawn
	var/list/animals = list()
	var/max_animal_count
	var/datum/gas_mixture/atmosphere
	var/list/breathgas = list()	//list of gases animals/plants require to survive
	var/badgas					//id of gas that is toxic to life here


	//DAY/NIGHT CYCLE
	var/daycycle //How often do we change day and night
	//var/current_time // Holds the current time for sun positioning.  Note that we assume day and night is the same length because simplicity.
	var/sun_process_interval = 5 MINUTES //How often we update planetary sunlight -> This has a performance impact, though consider lengthening days if you increase this else you may skip over phases
	var/sun_last_process = null // world.time

	/// 0 means midnight, 1 means noon.
	var/sun_position = 0
	/// This a multiplier used to apply to the brightness of ambient lighting.  0.3 means 30% of the brightness of the sun.
	var/sun_brightness_modifier = 0.5

	/// The color currently applied to the sun.
	var/sun_apparent_color
	var/sun_apparent_brightness
	var/sun_updating = FALSE //Once a color/brightness value has been set, we must finish setting turfs before changing values again
	var/sun_next_color
	var/sun_next_brightness
	var/sun_needs_update = FALSE

	var/maxx
	var/maxy
	var/landmark_type = /obj/effect/shuttle_landmark/automatic

	var/list/rock_colors = list(COLOR_ASTEROID_ROCK)
	var/list/plant_colors = list("RANDOM")
	var/grass_color
	var/surface_color = COLOR_ASTEROID_ROCK
	var/water_color = "#436499"
	var/image/skybox_image

	var/list/actors = list() //things that appear in engravings on xenoarch finds.
	var/list/species = list() //list of names to use for simple animals

	var/flora_diversity = 4				// max number of different seeds growing here
	var/has_trees = TRUE				// if large flora should be generated
	var/list/small_flora_types = list()	// seeds of 'small' flora
	var/list/big_flora_types = list()	// seeds of tree-tier flora

	var/repopulating = FALSE
	var/repopulate_types = list() // animals which have died that may come back

	var/list/possible_themes = list(
		/datum/exoplanet_theme = 45,
		/datum/exoplanet_theme/mountains = 65,
		/datum/exoplanet_theme/radiation_bombing = 10,
		/datum/exoplanet_theme/ruined_city = 5,
		/datum/exoplanet_theme/robotic_guardians = 10
		)
	var/list/themes = list()

	var/list/map_generators = list()

	//Flags deciding what features to pick
	var/ruin_tags_whitelist
	var/ruin_tags_blacklist
	var/features_budget = 5
	var/list/possible_features = list()
	var/list/spawned_features

	//Either a type or a list of types and weights. You must include all types if it's a list
	var/list/habitability_distribution = list(
		HABITABILITY_IDEAL = 10,
		HABITABILITY_OKAY = 40,
		HABITABILITY_BAD = 50
	)
	var/habitability_class

/obj/effect/overmap/visitable/sector/exoplanet/proc/generate_habitability()
	if (isnum(habitability_distribution))
		habitability_class = habitability_distribution
	else
		habitability_class = pickweight_index(habitability_distribution)

/obj/effect/overmap/visitable/sector/exoplanet/New(nloc, max_x, max_y)
	if (!GLOB.using_map.use_overmap)
		return

	maxx = max_x ? max_x : world.maxx
	maxy = max_y ? max_y : world.maxy

	var/planet_name = generate_planet_name()
	name = "[planet_name], \a [name]"

	planetary_area = new planetary_area()
	GLOB.using_map.area_purity_test_exempt_areas += planetary_area.type
	planetary_area.name = "Surface of [planet_name]"

	INCREMENT_WORLD_Z_SIZE
	forceMove(locate(1,1,world.maxz))

	if (LAZYLEN(possible_themes))
		var/datum/exoplanet_theme/T = pick(possible_themes)
		themes += new T
		possible_themes -= T

	for (var/datum/exoplanet_theme/T in themes)
		if (T.ruin_tags_whitelist)
			ruin_tags_whitelist |= T.ruin_tags_whitelist
		if (T.ruin_tags_blacklist)
			ruin_tags_blacklist |= T.ruin_tags_blacklist

	for (var/T in subtypesof(/datum/map_template/ruin/exoplanet))
		var/datum/map_template/ruin/exoplanet/ruin = T
		if (initial(ruin.template_flags) & TEMPLATE_FLAG_RUIN_STARTS_DISALLOWED)
			continue
		if (ruin_tags_whitelist && !(ruin_tags_whitelist & initial(ruin.ruin_tags)))
			continue
		if (ruin_tags_blacklist & initial(ruin.ruin_tags))
			continue
		possible_features += new ruin
	..()

/obj/effect/overmap/visitable/sector/exoplanet/proc/build_level()
	generate_habitability()
	generate_atmosphere()
	for (var/datum/exoplanet_theme/T in themes)
		T.adjust_atmosphere(src)
	if (atmosphere)
		//Set up gases for living things
		if (!length(breathgas))
			var/list/goodgases = gas_data.gases.Copy()
			var/gasnum = min(rand(1,3), length(goodgases))
			for (var/i = 1 to gasnum)
				var/gas = pick(goodgases)
				breathgas[gas] = round(0.4*goodgases[gas], 0.1)
				goodgases -= gas
		if (!badgas)
			var/list/badgases = gas_data.gases.Copy()
			badgases -= atmosphere.gas
			badgas = pick(badgases)
	generate_flora()
	generate_map()
	generate_features()
	for (var/datum/exoplanet_theme/T in themes)
		T.after_map_generation(src)
	generate_landing(2)
	update_biome()
	generate_daycycle()
	generate_planet_image()
	START_PROCESSING(SSobj, src)

//attempt at more consistent history generation for xenoarch finds.
/obj/effect/overmap/visitable/sector/exoplanet/proc/get_engravings()
	if (!length(actors))
		actors += pick("alien humanoid","an amorphic blob","a short, hairy being","a rodent-like creature","a robot","a primate","a reptilian alien","an unidentifiable object","a statue","a starship","unusual devices","a structure")
		actors += pick("alien humanoids","amorphic blobs","short, hairy beings","rodent-like creatures","robots","primates","reptilian aliens")

	var/engravings = "[actors[1]] \
	[pick("surrounded by","being held aloft by","being struck by","being examined by","communicating with")] \
	[actors[2]]"
	if (prob(50))
		engravings += ", [pick("they seem to be enjoying themselves","they seem extremely angry","they look pensive","they are making gestures of supplication","the scene is one of subtle horror","the scene conveys a sense of desperation","the scene is completely bizarre")]"
	engravings += "."
	return engravings

/obj/effect/overmap/visitable/sector/exoplanet/Process(wait, tick)
	if (length(animals) < 0.5*max_animal_count && !repopulating)
		repopulating = TRUE
		max_animal_count = round(max_animal_count * 0.5)

	for (var/zlevel in map_z)
		if (repopulating && !GLOB.planet_repopulation_disabled)
			handle_repopulation()

		if (!atmosphere)
			continue

		var/zone/Z
		for (var/i = 1 to maxx)
			var/turf/simulated/T = locate(i, 2, zlevel)
			if (istype(T) && T.zone && length(T.zone.contents) > (maxx*maxy*0.25)) //if it's a zone quarter of zlevel, good enough odds it's planetary main one
				Z = T.zone
				break
		if (Z && !length(Z.fire_tiles) && !atmosphere.compare(Z.air)) //let fire die out first if there is one
			var/datum/gas_mixture/daddy = new() //make a fake 'planet' zone gas
			daddy.copy_from(atmosphere)
			daddy.group_multiplier = Z.air.group_multiplier
			Z.air.equalize(daddy)

	if(sun_last_process <= world.time - sun_process_interval)
		update_sun()
	if(sun_needs_update)
		update_sunlight()

/obj/effect/overmap/visitable/sector/exoplanet/proc/generate_daycycle()
	daycycle = rand(20 MINUTES, 40 MINUTES)

	update_sun()


// This changes the position of the sun on the planet.
/obj/effect/overmap/visitable/sector/exoplanet/proc/update_sun()
	if(sun_last_process == world.time) //For now, calling it several times in same frame is not valid. Add a parameter to ignore this if weather is added
		return
	sun_last_process = world.time

	var/time_of_day = (world.time % daycycle) / daycycle //0 to 1 range.

	var/distance_from_noon = abs(time_of_day - 0.5)
	sun_position = distance_from_noon / 0.5 // -1 to 1 range
	sun_position = abs(sun_position - 1)

	var/low_brightness = null
	var/high_brightness = null

	var/low_color = null
	var/high_color = null
	var/min = 0
	var/max = 0

	//Now, each planet type may want to do its own thing for light, if so move most of this code into its own function and override it.
	switch(sun_position)
		if(0 to 0.40) // Night
			low_brightness = 0.01
			low_color = "#000066"

			high_brightness = 0.2
			high_color = "#66004D"
			min = 0
			max = 0.4

		if(0.40 to 0.50) // Twilight
			low_brightness = 0.2
			low_color = "#66004D"

			high_brightness = 0.5
			high_color = "#CC3300"
			min = 0.40
			max = 0.50

		if(0.50 to 0.70) // Sunrise/set
			low_brightness = 0.5
			low_color = "#CC3300"

			high_brightness = 0.8
			high_color = "#FF9933"
			min = 0.50
			max = 0.70

		if(0.70 to 1.00) // Noon
			low_brightness = 0.8
			low_color = "#DDDDDD"

			high_brightness = 1.0
			high_color = "#FFFFFF"
			min = 0.70
			max = 1.0

	//var/interpolate_weight = (abs(min - sun_position)) * 4 Cit interpolation, not sure
	var/interpolate_weight = (sun_position - min) / (max - min)

	var/new_brightness = (Interpolate(low_brightness, high_brightness, interpolate_weight) ) * sun_brightness_modifier

	//We do a gradient instead of linear interpolation because linear interpolations of colours are unintuitive
	var/new_color = UNLINT(gradient(low_color, high_color, space = COLORSPACE_HSV, index=interpolate_weight))

	finish_updating_sun(new_brightness, new_color)

/obj/effect/overmap/visitable/sector/exoplanet/proc/finish_updating_sun(new_brightness, new_color)
	set waitfor = FALSE
	ASSERT(length(args) < 3)
	// Delta updates: changing the sun while it's still updating will permanently corrupt ambient lights (short of resetting them globally)
	while(sun_updating)
		stoplag()

	sun_updating = TRUE //Block any further changes

	sun_next_brightness = new_brightness
	sun_next_color = new_color

	sun_needs_update = TRUE


/obj/effect/overmap/visitable/sector/exoplanet/proc/update_sunlight()
	sun_needs_update = FALSE
	if (sun_next_brightness == sun_apparent_brightness && sun_next_color == sun_apparent_color)
		sun_updating = FALSE
		log_debug("update_sunlight(): apparent == next, not bothering")
		return

	//Replace implies we already set colour before. Else we're going to run into an assert
	var/replace = (sun_apparent_color != null) && (sun_apparent_brightness != null)

	var/list/surface = block(locate(1, 1, min(map_z)),locate(maxx,maxy, max(map_z)))
	for (var/turf/simulated/floor/T in surface)
		if(istype(T))
			if(T.is_outside() && TURF_IS_DYNAMICALLY_LIT_UNSAFE(T)) //Probably more accurate to base it on z stack
				if(replace)
					T.replace_ambient_light(sun_apparent_color, sun_next_color, sun_apparent_brightness, sun_next_brightness)
				else
					T.add_ambient_light(sun_next_color, sun_next_brightness)

			CHECK_TICK

	sun_apparent_color = sun_next_color
	sun_apparent_brightness = sun_next_brightness
	sun_updating = FALSE

/obj/effect/overmap/visitable/sector/exoplanet/proc/generate_map()
	var/list/grasscolors = plant_colors.Copy()
	grasscolors -= "RANDOM"
	if (length(grasscolors))
		grass_color = pick(grasscolors)

	for (var/datum/exoplanet_theme/T in themes)
		T.before_map_generation(src)
	for (var/zlevel in map_z)
		var/list/edges
		edges += block(locate(1, 1, zlevel), locate(TRANSITIONEDGE, maxy, zlevel))
		edges |= block(locate(maxx-TRANSITIONEDGE, 1, zlevel),locate(maxx, maxy, zlevel))
		edges |= block(locate(1, 1, zlevel), locate(maxx, TRANSITIONEDGE, zlevel))
		edges |= block(locate(1, maxy-TRANSITIONEDGE, zlevel),locate(maxx, maxy, zlevel))
		for (var/turf/T in edges)
			T.ChangeTurf(/turf/simulated/planet_edge)
		var/padding = TRANSITIONEDGE
		for (var/map_type in map_generators)
			if (ispath(map_type, /datum/random_map/noise/exoplanet))
				new map_type(null,padding,padding,zlevel,maxx-padding,maxy-padding,0,1,1,planetary_area, plant_colors)
			else
				new map_type(null,1,1,zlevel,maxx,maxy,0,1,1,planetary_area)

/obj/effect/overmap/visitable/sector/exoplanet/proc/generate_features()
	spawned_features = seedRuins(map_z, features_budget, possible_features, /area/exoplanet, maxx, maxy)

/obj/effect/overmap/visitable/sector/exoplanet/proc/update_biome()
	for (var/datum/seed/S in seeds)
		adapt_seed(S)

	for (var/mob/living/simple_animal/A in animals)
		adapt_animal(A)

/obj/effect/landmark/exoplanet_spawn/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/exoplanet_spawn/LateInitialize()
	. = ..()
	var/obj/effect/overmap/visitable/sector/exoplanet/E = map_sectors["[z]"]
	if (istype(E))
		do_spawn(E)

//Tries to generate num landmarks, but avoids repeats.
/obj/effect/overmap/visitable/sector/exoplanet/proc/generate_landing(num = 1)
	var/places = list()
	var/attempts = 30*num
	var/new_type = landmark_type
	while(num)
		attempts--
		var/turf/T = locate(rand(TRANSITIONEDGE + LANDING_ZONE_RADIUS, maxx - TRANSITIONEDGE - LANDING_ZONE_RADIUS), rand(TRANSITIONEDGE + LANDING_ZONE_RADIUS, maxy - TRANSITIONEDGE - LANDING_ZONE_RADIUS),map_z[length(map_z)])
		if (!T || (T in places) || T.density) // Don't allow two landmarks on one turf, and don't use a dense turf.
			continue
		if (attempts >= 0) // While we have the patience, try to find better spawn points. If out of patience, put them down wherever, so long as there are no repeats.
			var/valid = TRUE
			var/list/block_to_check = block(locate(T.x - LANDING_ZONE_RADIUS, T.y - LANDING_ZONE_RADIUS, T.z), locate(T.x + LANDING_ZONE_RADIUS, T.y + LANDING_ZONE_RADIUS, T.z))
			for (var/turf/check in block_to_check)
				if (!istype(get_area(check), /area/exoplanet) || check.turf_flags & TURF_FLAG_NORUINS)
					valid = FALSE
					break
			if (attempts >= 10)
				if (check_collision(T.loc, block_to_check)) //While we have lots of patience, ensure landability
					valid = FALSE
			else //Running out of patience, but would rather not clear ruins, so switch to clearing landmarks and bypass landability check
				new_type = /obj/effect/shuttle_landmark/automatic/clearing

			if (!valid)
				continue

		num--
		places += T
		new new_type(T)

/obj/effect/overmap/visitable/sector/exoplanet/get_scan_data(mob/user)
	. = ..()
	var/list/extra_data = list("<br>")
	if (atmosphere)
		if (user.skill_check(SKILL_SCIENCE, SKILL_ADEPT))
			var/list/gases = list()
			for (var/g in atmosphere.gas)
				if (atmosphere.gas[g] > atmosphere.total_moles * 0.05)
					gases += gas_data.name[g]
			extra_data += "Atmosphere composition: [english_list(gases)]"
			var/inaccuracy = rand(8,12)/10
			extra_data += "Atmosphere pressure [atmosphere.return_pressure()*inaccuracy] kPa, temperature [atmosphere.temperature*inaccuracy] K"
		else if (user.skill_check(SKILL_SCIENCE, SKILL_BASIC))
			extra_data += "Atmosphere present"
		extra_data += "<br>"

	if (length(seeds) && user.skill_check(SKILL_SCIENCE, SKILL_BASIC))
		extra_data += "Xenoflora detected"

	if (length(animals) && user.skill_check(SKILL_SCIENCE, SKILL_BASIC))
		extra_data += "Life traces detected"

	if (LAZYLEN(spawned_features) && user.skill_check(SKILL_SCIENCE, SKILL_ADEPT))
		var/ruin_num = 0
		for (var/datum/map_template/ruin/exoplanet/R in spawned_features)
			if (!(R.ruin_tags & RUIN_NATURAL))
				ruin_num++
		if (ruin_num)
			extra_data += "<br>[ruin_num] possible artificial structure\s detected."

	for (var/datum/exoplanet_theme/T in themes)
		if (T.get_sensor_data())
			extra_data += T.get_sensor_data()
	. += jointext(extra_data, "<br>")

/obj/effect/overmap/visitable/sector/exoplanet/proc/get_surface_color()
	return surface_color

/area/exoplanet
	name = "\improper Planetary surface"
	ambience = list(
		'sound/effects/wind/wind_2_1.ogg',
		'sound/effects/wind/wind_2_2.ogg',
		'sound/effects/wind/wind_3_1.ogg',
		'sound/effects/wind/wind_4_1.ogg',
		'sound/effects/wind/wind_4_2.ogg',
		'sound/effects/wind/wind_5_1.ogg'
	)
	always_unpowered = TRUE
	area_flags = AREA_FLAG_EXTERNAL
	planetary_surface = TRUE
