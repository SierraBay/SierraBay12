// Seeing stuff
/datum/hallucination/mirage
	category = "evidence"
	base_weight = 7
	category_cooldown = 15 SECONDS
	duration = 30 SECONDS
	max_power = 30
	var/number = 1
	var/list/things = list()

/datum/hallucination/mirage/Destroy()
	end()
	. = ..()

/datum/hallucination/mirage/proc/generate_mirage()
	var/icon/T = new('icons/obj/trash.dmi')
	return image(T, pick(T.IconStates()), layer = BELOW_TABLE_LAYER)

/datum/hallucination/mirage/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	for(var/turf/simulated/floor/F in view(C, world.view + 1))
		return null
	return "no floor tiles nearby"

/datum/hallucination/mirage/start()
	if(!holder?.client)
		return FALSE
	var/list/possible_points = list()
	for(var/turf/simulated/floor/F in view(holder, world.view + 1))
		possible_points += F
	if(!length(possible_points))
		return FALSE
	for(var/i = 1 to number)
		var/image/thing = generate_mirage()
		things += thing
		thing.loc = pick(possible_points)
	holder.client.images += things
	return TRUE

/datum/hallucination/mirage/end()
	if(holder?.client)
		holder.client.images -= things

/datum/hallucination/mirage/money
	base_weight = 3
	min_power = 20
	max_power = 45
	number = 2

/datum/hallucination/mirage/money/generate_mirage()
	return image('icons/obj/money.dmi', "spacecash[pick(1000, 500, 200, 100, 50)]", layer = BELOW_TABLE_LAYER)

/datum/hallucination/mirage/carnage
	min_power = 50
	theme_tags = list("aftermath")
	number = 10

/datum/hallucination/mirage/carnage/generate_mirage()
	if(prob(50))
		var/image/I = image('icons/effects/blood.dmi', pick("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7"), layer = BELOW_TABLE_LAYER)
		I.color = COLOR_BLOOD_HUMAN
		return I
	var/image/I = image('icons/obj/weapons/ammo.dmi', "s-casing-spent", layer = BELOW_TABLE_LAYER)
	I.layer = BELOW_TABLE_LAYER
	I.dir = pick(GLOB.alldirs)
	I.pixel_x = rand(-10, 10)
	I.pixel_y = rand(-10, 10)
	return I

// Fake hacked APC
/datum/hallucination/malf_apc
	category = "machinery"
	base_weight = 9
	category_cooldown = 12 SECONDS
	theme_tags = list("machinery")
	min_power = 40
	max_power = 80
	allow_duplicates = FALSE
	duration = 1 SECOND
	var/apc_icon = 'icons/obj/machines/apc.dmi'
	var/apc_icon_state = "apcemag"
	var/image/hacked_image

/datum/hallucination/malf_apc/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(context?.apc_count)
		return null
	for(var/obj/machinery/power/apc/apc in view(C))
		if(MACHINE_IS_BROKEN(apc) || GET_FLAGS(apc.stat, MACHINE_STAT_MAINT))
			continue
		if(!apc.area || !apc.area.requires_power || apc.opened)
			continue
		return null
	return "no APC nearby"

/datum/hallucination/malf_apc/get_context_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	. = ..()
	if(context.apc_count)
		. *= 2
		debug_factors += "APC nearby x2"

/datum/hallucination/malf_apc/start()
	if(!holder?.client)
		return FALSE
	var/list/nearby_apcs = list()
	for(var/obj/machinery/power/apc/apc in view(holder))
		if(MACHINE_IS_BROKEN(apc) || GET_FLAGS(apc.stat, MACHINE_STAT_MAINT))
			continue
		if(!apc.area || !apc.area.requires_power || apc.opened)
			continue
		nearby_apcs += apc
	if(!length(nearby_apcs))
		return FALSE
	var/obj/machinery/power/apc/selected_apc = pick(nearby_apcs)
	hacked_image = image(apc_icon, selected_apc, apc_icon_state, FLOAT_LAYER)
	holder.client.images += hacked_image
	feedback_details = " Fake emagged APC: [selected_apc] in [get_area(selected_apc)]"
	return TRUE

/datum/hallucination/malf_apc/end()
	holder?.client?.images -= hacked_image
	hacked_image = null

// Someone is following you
/datum/hallucination/stalker
	category = "threat"
	base_weight = 7
	category_cooldown = 18 SECONDS
	theme_tags = list("predator")
	min_power = 45
	max_power = 100
	allow_duplicates = FALSE
	duration = 4 SECONDS
	var/datum/hallucination_actor/actor

/datum/hallucination/stalker/start()
	actor = new
	actor.holder = holder
	actor.icon = 'icons/mob/mob.dmi'
	actor.icon_state = "shade"
	actor.actor_name = "shadow"
	actor.lifetime = 3.5 SECONDS
	actor.step_delay = 0.5 SECONDS
	actor.max_steps = 3
	actor.behavior = new /datum/hallucination_actor_behavior/peek_and_hide
	if(!actor.start())
		QDEL_NULL(actor)
		return FALSE
	feedback_details = " Stalker actor"
	if(holder.can_hear())
		holder.playsound_local(actor.current_turf || get_turf(holder), pick('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg'), 40)
	return TRUE

/datum/hallucination/stalker/end()
	QDEL_NULL(actor)

/datum/hallucination/mirage/carnage/aftermath
	number = 6

/datum/hallucination/mirage/carnage/aftermath/generate_mirage()
	switch(rand(1, 4))
		if(1)
			var/image/I = image('icons/effects/blood.dmi', pick("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7"), layer = BELOW_TABLE_LAYER)
			I.color = COLOR_BLOOD_HUMAN
			return I
		if(2)
			return image('icons/obj/closets/bodybag.dmi', "closed", layer = BELOW_TABLE_LAYER)
		if(3)
			var/image/I = image('icons/obj/weapons/ammo.dmi', "s-casing-spent", layer = BELOW_TABLE_LAYER)
			I.dir = pick(GLOB.alldirs)
			I.pixel_x = rand(-12, 12)
			I.pixel_y = rand(-12, 12)
			return I
		else
			var/image/I = image('icons/effects/blood.dmi', "floor1", layer = BELOW_TABLE_LAYER)
			I.color = COLOR_BLOOD_HUMAN
			return I

// Brief hostile sightings
/datum/hallucination/hostile_sighting
	category = "threat"
	base_weight = 5
	category_cooldown = 18 SECONDS
	theme_tags = list("predator")
	min_power = 45
	max_power = 100
	allow_duplicates = FALSE
	duration = 3 SECONDS
	var/datum/hallucination_actor/actor

/datum/hallucination/hostile_sighting/start()
	var/list/choices = list(
		list("icon" = 'icons/mob/simple_animal/spider.dmi', "state" = "generic", "name" = "giant spider", "sound" = 'sound/hallucinations/growl2.ogg'),
		list("icon" = 'icons/mob/simple_animal/space_carp.dmi', "state" = "carp", "name" = "space carp", "sound" = 'sound/hallucinations/growl3.ogg'),
		list("icon" = 'icons/mob/mob.dmi', "state" = "shade", "name" = "shadow", "sound" = 'sound/hallucinations/im_here1.ogg'),
		list("icon" = 'icons/mob/simple_animal/animal.dmi', "state" = "mouse_gray", "name" = "mouse swarm", "sound" = 'sound/effects/screech.ogg'),
		list("icon" = 'icons/mob/simple_animal/animal.dmi', "state" = "faithless", "name" = "faithless", "sound" = 'sound/hallucinations/growl1.ogg')
	)
	var/list/choice = pick(choices)
	actor = new
	actor.holder = holder
	actor.icon = choice["icon"]
	actor.icon_state = choice["state"]
	actor.actor_name = choice["name"]
	actor.lifetime = 2.5 SECONDS
	actor.step_delay = 0.35 SECONDS
	actor.max_steps = 4
	actor.behavior = new /datum/hallucination_actor_behavior/approach_then_vanish
	if(!actor.start())
		QDEL_NULL(actor)
		return FALSE
	feedback_details = " Hostile sighting: [choice["name"]] at [actor.current_turf?.x],[actor.current_turf?.y],[actor.current_turf?.z]"
	if(holder.can_hear())
		holder.playsound_local(actor.current_turf || get_turf(holder), choice["sound"], 40)
	return TRUE

/datum/hallucination/hostile_sighting/end()
	QDEL_NULL(actor)

// False corpse in the corridor
/datum/hallucination/corpse_mirage
	category = "evidence"
	base_weight = 7
	category_cooldown = 15 SECONDS
	theme_tags = list("predator", "aftermath")
	min_power = 45
	max_power = 100
	allow_duplicates = FALSE
	duration = 8 SECONDS
	var/list/things = list()

/datum/hallucination/corpse_mirage/start()
	var/turf/T = holder.random_hallucination_turf(3, 7, TRUE)
	if(!T)
		return FALSE
	var/image/body_bag = image('icons/obj/closets/bodybag.dmi', T, "closed", BELOW_TABLE_LAYER)
	var/image/blood = image('icons/effects/blood.dmi', T, pick("mfloor1", "mfloor2", "mfloor3", "floor1"), BELOW_TABLE_LAYER)
	blood.color = COLOR_BLOOD_HUMAN
	things += body_bag
	things += blood
	holder.client.images += things
	feedback_details = " Corpse mirage at [T.x],[T.y],[T.z]"
	to_chat(holder, SPAN_WARNING("For a second, you spot what looks like a corpse crumpled in the corridor."))
	return TRUE

/datum/hallucination/corpse_mirage/end()
	holder?.client?.images -= things
	things.Cut()

// Blood on the floor
/datum/hallucination/mirage/blood
	theme_tags = list("aftermath")
	min_power = 25
	max_power = 70
	number = 5

/datum/hallucination/mirage/blood/generate_mirage()
	var/image/I = image('icons/effects/blood.dmi', pick("floor1", "floor2", "floor3", "mfloor1", "mfloor2", "mfloor3"), layer = BELOW_TABLE_LAYER)
	I.color = COLOR_BLOOD_HUMAN
	return I

/datum/hallucination/mirage/psychedelic
	category = "ambient"
	base_weight = 8
	category_cooldown = 10 SECONDS
	theme_tags = list("psychedelic")
	min_power = 20
	max_power = 80
	number = 6

/datum/hallucination/mirage/psychedelic/generate_mirage()
	if(prob(60))
		var/image/I = image('icons/effects/blood.dmi', pick("floor1", "floor2", "floor3", "mfloor1", "mfloor2", "mfloor3"), layer = BELOW_TABLE_LAYER)
		I.color = pick("#ff4fd8", "#4ffff2", "#d6ff4f", "#ff9b4f", "#8f6dff")
		I.alpha = 190
		return I
	var/icon/T = new('icons/obj/trash.dmi')
	var/image/I = image(T, pick(T.IconStates()), layer = BELOW_TABLE_LAYER)
	I.color = pick("#ff66cc", "#66ffcc", "#ffd966", "#9f87ff")
	I.alpha = 210
	return I

// The corridor ahead briefly mirrors the one behind you.
/datum/hallucination/time_loop
	category = "ambient"
	base_weight = 6
	category_cooldown = 16 SECONDS
	theme_tags = list("machinery", "psychedelic", "cosmic")
	min_power = 35
	max_power = 90
	allow_duplicates = FALSE
	duration = 5 SECONDS
	var/list/fake_images = list()

/datum/hallucination/time_loop/Destroy()
	end()
	. = ..()

/datum/hallucination/time_loop/proc/add_copied_image(atom/source, atom/location, layer_override = null)
	if(!holder?.client || !source || !location)
		return
	var/image/fake = image(source, location)
	if(!isnull(layer_override))
		fake.layer = layer_override
	fake_images += fake

/datum/hallucination/time_loop/proc/get_offset_turf(turf/start, direction, distance)
	var/turf/current = start
	for(var/i = 1 to distance)
		current = get_step(current, direction)
		if(!istype(current))
			return null
	return current

/datum/hallucination/time_loop/proc/copy_source_tile(turf/source, turf/target)
	if(!istype(source) || !istype(target))
		return
	add_copied_image(source, target, TURF_LAYER)
	for(var/obj/O in source)
		if(istype(O, /obj/effect))
			add_copied_image(O, target)
			continue
		if(istype(O, /obj/machinery) || istype(O, /obj/structure) || istype(O, /obj/item))
			add_copied_image(O, target)
			break

/datum/hallucination/time_loop/proc/is_viable_loop_direction(turf/origin, direction)
	if(!(direction in GLOB.cardinal))
		return FALSE
	var/turf/ahead_one = get_offset_turf(origin, direction, 1)
	var/turf/ahead_two = get_offset_turf(origin, direction, 2)
	var/turf/behind_one = get_offset_turf(origin, reverse_direction(direction), 1)
	var/turf/behind_two = get_offset_turf(origin, reverse_direction(direction), 2)
	return istype(ahead_one, /turf/simulated/floor) && istype(ahead_two, /turf/simulated/floor) && istype(behind_one, /turf/simulated/floor) && istype(behind_two, /turf/simulated/floor)

/datum/hallucination/time_loop/proc/find_loop_direction(mob/living/carbon/C)
	var/turf/origin = get_turf(C)
	if(!istype(origin))
		return null

	var/list/directions = list()
	if(C.dir & NORTH)
		directions += NORTH
	if(C.dir & SOUTH)
		directions += SOUTH
	if(C.dir & EAST)
		directions += EAST
	if(C.dir & WEST)
		directions += WEST
	for(var/direction in GLOB.cardinal)
		if(!(direction in directions))
			directions += direction

	for(var/direction in directions)
		if(is_viable_loop_direction(origin, direction))
			return direction
	return null

/datum/hallucination/time_loop/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	return find_loop_direction(C) ? null : "no loopable corridor nearby"

/datum/hallucination/time_loop/start()
	if(!holder?.client)
		return FALSE

	var/turf/origin = get_turf(holder)
	if(!istype(origin))
		return FALSE

	var/loop_direction = find_loop_direction(holder)
	if(!loop_direction)
		return FALSE

	var/reverse_dir = reverse_direction(loop_direction)
	var/left_dir = turn(loop_direction, 90)
	var/right_dir = turn(loop_direction, -90)
	var/copied_segments = 0

	for(var/i = 1 to 3)
		var/turf/source = get_offset_turf(origin, reverse_dir, i)
		var/turf/target = get_offset_turf(origin, loop_direction, i)
		if(!istype(source, /turf/simulated/floor) || !istype(target, /turf/simulated/floor))
			break

		copy_source_tile(source, target)
		copy_source_tile(get_step(source, left_dir), get_step(target, left_dir))
		copy_source_tile(get_step(source, right_dir), get_step(target, right_dir))
		copied_segments++

	if(copied_segments < 2 || !length(fake_images))
		fake_images.Cut()
		return FALSE

	holder.client.images += fake_images
	if(holder.can_hear())
		holder.playsound_local(origin, 'sound/machines/twobeep.ogg', 25)
		spawn(0.8 SECONDS)
			if(holder)
				holder.playsound_local(origin, 'sound/machines/twobeep.ogg', 20)

	to_chat(holder, SPAN_WARNING("The corridor ahead looks exactly like the stretch you just walked through."))
	feedback_details = " Time loop toward [dir2text(loop_direction)] from [origin.x],[origin.y],[origin.z]"
	return TRUE

/datum/hallucination/time_loop/end()
	holder?.client?.images -= fake_images
	fake_images.Cut()

// Screen-space distortions rather than world mirages.
/datum/hallucination/screen_effect
	abstract_hallucination = TRUE
	category = "ambient"
	base_weight = 8
	category_cooldown = 10 SECONDS
	min_power = 20
	max_power = 85
	allow_duplicates = FALSE
	duration = 4 SECONDS
	var/list/fullscreen_categories = list()
	var/list/client_color_types = list()
	var/datum/effect/trail/afterimage/motion_trail

/datum/hallucination/screen_effect/Destroy()
	end()
	. = ..()

/datum/hallucination/screen_effect/proc/add_fullscreen(category, screen_type)
	if(!holder?.client || !category || !ispath(screen_type, /obj/screen/fullscreen))
		return
	holder.overlay_fullscreen(category, screen_type, "")
	fullscreen_categories += category

/datum/hallucination/screen_effect/proc/add_color_shift(color_type)
	if(!holder?.client || !ispath(color_type, /datum/client_color))
		return
	holder.add_client_color(color_type)
	client_color_types += color_type

/datum/hallucination/screen_effect/end()
	if(holder?.client)
		for(var/category in fullscreen_categories)
			holder.clear_fullscreen(category)
	for(var/color_type in client_color_types)
		holder?.remove_client_color(color_type)
	if(motion_trail)
		motion_trail.stop()
		qdel(motion_trail)
		motion_trail = null
	fullscreen_categories.Cut()
	client_color_types.Cut()

/datum/hallucination/screen_effect/vignette
	base_weight = 7
	theme_tags = list("predator", "body")
	duration = 5 SECONDS

/datum/hallucination/screen_effect/vignette/start()
	add_fullscreen("hall_vignette", /obj/screen/fullscreen/impaired)
	feedback_details = " Screen effect: vignette"
	return TRUE

/datum/hallucination/screen_effect/color_shift
	base_weight = 7
	theme_tags = list("psychedelic", "cosmic")
	duration = 5 SECONDS

/datum/hallucination/screen_effect/color_shift/start()
	add_color_shift(pick(/datum/client_color/hallucination_shift_warm, /datum/client_color/hallucination_shift_cold))
	feedback_details = " Screen effect: color shift"
	return TRUE

/datum/hallucination/screen_effect/blur
	base_weight = 8
	theme_tags = list("psychedelic", "body")
	duration = 4 SECONDS

/datum/hallucination/screen_effect/blur/start()
	add_fullscreen("hall_blur", /obj/screen/fullscreen/blurry)
	feedback_details = " Screen effect: blur"
	return TRUE

/datum/hallucination/screen_effect/shake
	base_weight = 6
	theme_tags = list("body", "cosmic")
	duration = 1 SECOND

/datum/hallucination/screen_effect/shake/start()
	shake_camera(holder, rand(4, 7), rand(1, 2))
	feedback_details = " Screen effect: shake"
	return TRUE

/datum/hallucination/screen_effect/glitch
	base_weight = 6
	theme_tags = list("machinery", "cosmic", "psychedelic")
	duration = 3 SECONDS

/datum/hallucination/screen_effect/glitch/start()
	add_fullscreen("hall_noise", /obj/screen/fullscreen/noise)
	add_fullscreen("hall_scanline", /obj/screen/fullscreen/scanline)
	if(prob(60))
		add_color_shift(/datum/client_color/hallucination_shift_cold)
	if(prob(35))
		shake_camera(holder, 3, 1)
	feedback_details = " Screen effect: glitch"
	return TRUE

/datum/hallucination/screen_effect/motion_trails
	base_weight = 6
	theme_tags = list("psychedelic")
	duration = 5 SECONDS

/datum/hallucination/screen_effect/motion_trails/start()
	motion_trail = new /datum/effect/trail/afterimage
	motion_trail.set_up(holder)
	motion_trail.start()
	feedback_details = " Screen effect: motion trails"
	return TRUE

// Quick movement at the edge of your vision.
/datum/hallucination/peripheral_motion
	category = "threat"
	base_weight = 6
	category_cooldown = 14 SECONDS
	theme_tags = list("predator", "psychedelic")
	min_power = 25
	max_power = 85
	allow_duplicates = FALSE
	duration = 3 SECONDS
	var/list/things = list()

/datum/hallucination/peripheral_motion/Destroy()
	end()
	. = ..()

/datum/hallucination/peripheral_motion/start()
	if(!holder?.client)
		return FALSE

	var/base_dir = holder.dir || NORTH
	var/list/preferred_dirs = list(turn(base_dir, 90), turn(base_dir, -90), turn(base_dir, 135), turn(base_dir, -135))
	var/list/candidates = list()
	for(var/turf/simulated/floor/T in view(holder, 5))
		if(get_dist(holder, T) < 2)
			continue
		if(!(get_dir(holder, T) in preferred_dirs))
			continue
		candidates += T
	if(!length(candidates))
		return FALSE

	for(var/i = 1 to min(2, length(candidates)))
		var/turf/target = pick(candidates)
		candidates -= target
		var/image/shade = image('icons/mob/mob.dmi', target, "shade", FLOAT_LAYER)
		shade.alpha = 210
		things += shade

	holder.client.images += things
	feedback_details = " Peripheral motion"
	return TRUE

/datum/hallucination/peripheral_motion/end()
	holder?.client?.images -= things
	things.Cut()

// Repeating silhouette instead of a single pop-in
/datum/hallucination/stalker/recurring
	duration = 6 SECONDS
	var/list/stalker_actors = list()

/datum/hallucination/stalker/recurring/proc/spawn_silhouette()
	if(!holder?.client)
		return
	var/datum/hallucination_actor/actor = new
	actor.holder = holder
	actor.icon = 'icons/mob/mob.dmi'
	actor.icon_state = "shade"
	actor.actor_name = "shadow"
	actor.lifetime = 1.8 SECONDS
	actor.step_delay = 0.45 SECONDS
	actor.max_steps = 2
	actor.behavior = new /datum/hallucination_actor_behavior/peek_and_hide
	if(actor.start())
		stalker_actors += actor
	else
		qdel(actor)

/datum/hallucination/stalker/recurring/start()
	if(!holder?.client)
		return FALSE
	var/turf/first = holder.random_hallucination_turf(2, 4)
	spawn_silhouette()
	spawn(2 SECONDS)
		if(holder)
			spawn_silhouette()
	spawn(4 SECONDS)
		if(holder)
			spawn_silhouette()
	feedback_details = " Recurring stalker silhouettes"
	if(holder.can_hear())
		holder.playsound_local(first || get_turf(holder), pick('sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg'), 35)
	return TRUE

/datum/hallucination/stalker/recurring/end()
	for(var/datum/hallucination_actor/actor in stalker_actors)
		qdel(actor)
	stalker_actors.Cut()

/datum/client_color/hallucination_shift_warm
	client_color = list(
		1.15, 0.08, 0.02,
		0.04, 0.95, 0.08,
		0.02, 0.06, 0.82
	)
	order = 240
	ignore_blood = TRUE

/datum/client_color/hallucination_shift_cold
	client_color = list(
		0.82, 0.05, 0.12,
		0.06, 0.92, 0.12,
		0.12, 0.14, 1.12
	)
	order = 240
	ignore_blood = TRUE
