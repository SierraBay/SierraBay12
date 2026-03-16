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
