#define NYMPH_VINE_ROOT_COST 40
#define NYMPH_VINE_GROW_COST 25
#define NYMPH_VINE_SHIFT_COST 15
#define NYMPH_VINE_MAX 16

/mob/living/carbon/alien/diona
	var/datum/nymph_vine/guided_vine

/datum/nymph_vine
	var/mob/living/carbon/alien/diona/planter
	var/mob/living/bound
	var/obj/vine/guided/root
	var/obj/vine/guided/tip
	var/mob/living/captive
	var/moving_bound = FALSE
	var/withering = FALSE

/datum/nymph_vine/New(mob/living/carbon/alien/diona/planter, mob/living/bound)
	src.planter = planter
	src.bound = bound

/datum/nymph_vine/proc/segment_count()
	var/count = 0
	var/obj/vine/guided/segment = root
	while(segment)
		count++
		segment = segment.toward_tip
	return count

/datum/nymph_vine/proc/segment_at(atom/location)
	var/turf/tile = get_turf(location)
	if(!tile)
		return
	for(var/obj/vine/guided/segment in tile)
		if(segment.planter == planter)
			return segment

/datum/nymph_vine/proc/owns(obj/vine/guided/segment)
	return segment && segment.planter == planter

/datum/nymph_vine/proc/plant_root()
	if(root || !planter?.genome?.line)
		return FALSE
	if(!planter.spend_nutrients(NYMPH_VINE_ROOT_COST))
		return FALSE
	var/turf/origin = get_turf(bound)
	root = new(origin, planter.genome.line)
	root.attach(src, null)
	tip = root
	origin.visible_message(SPAN_NOTICE("\The [bound] roots a vine into the floor."))
	return TRUE

/datum/nymph_vine/proc/grow_to(turf/destination)
	if(!tip || !destination || !tip.Adjacent(destination))
		return FALSE
	if(istype(destination, /turf/space) || destination.density)
		notify(SPAN_WARNING("The vine can only grow onto an open floor."))
		return FALSE
	if(segment_at(destination))
		return FALSE
	if(segment_count() >= NYMPH_VINE_MAX)
		notify(SPAN_WARNING("The vine cannot grow past [NYMPH_VINE_MAX] tiles."))
		return FALSE
	if(!planter.spend_nutrients(NYMPH_VINE_GROW_COST))
		return FALSE
	var/obj/vine/guided/segment = new(destination, planter.genome.line)
	segment.attach(src, tip)
	tip.toward_tip = segment
	tip = segment
	return TRUE

/datum/nymph_vine/proc/walk_bound(turf/destination)
	var/obj/vine/guided/goal = segment_at(destination)
	var/obj/vine/guided/here = segment_at(bound)
	if(!goal || !here || !bound)
		return FALSE
	var/list/chain = chain()
	var/from = chain.Find(here)
	var/goal_index = chain.Find(goal)
	if(!from || !goal_index || from == goal_index)
		return TRUE
	var/direction = goal_index > from ? 1 : -1
	moving_bound = TRUE
	for(var/index = from + direction to goal_index step direction)
		var/obj/vine/guided/segment = chain[index]
		bound.forceMove(get_turf(segment))
	moving_bound = FALSE
	return TRUE

/datum/nymph_vine/proc/grab(mob/living/victim)
	if(!victim || victim == bound || victim == planter || captive)
		return FALSE
	var/obj/vine/guided/segment = segment_at(victim)
	if(!segment)
		for(var/obj/vine/guided/nearby in range(1, victim))
			if(owns(nearby))
				segment = nearby
				break
	if(!segment)
		notify(SPAN_WARNING("They are not close enough to the vine."))
		return FALSE
	if(!planter.spend_nutrients(NYMPH_VINE_SHIFT_COST))
		return FALSE
	victim.forceMove(get_turf(segment))
	segment.buckle_mob(victim)
	captive = victim
	if(planter.genome.stings)
		planter.genome.inflict_sting(planter, victim)
	if(planter.genome.carnivorous)
		planter.genome.inflict_thorns(planter, victim)
	victim.visible_message(SPAN_WARNING("\The vine winds around \the [victim]."))
	return TRUE

/datum/nymph_vine/proc/release()
	if(!captive)
		return FALSE
	var/mob/living/freed = captive
	captive = null
	if(freed.buckled)
		freed.buckled.unbuckle_mob()
	freed.visible_message(SPAN_NOTICE("\The vine lets \the [freed] go."))
	return TRUE

/datum/nymph_vine/proc/shift_captive_toward(turf/destination)
	if(!captive)
		notify(SPAN_WARNING("The vine is not holding anyone."))
		return FALSE
	var/obj/vine/guided/goal = segment_at(destination)
	var/obj/vine/guided/here = segment_at(captive)
	if(!goal || !here)
		return FALSE
	var/list/chain = chain()
	var/from = chain.Find(here)
	var/goal_index = chain.Find(goal)
	if(!from || !goal_index || from == goal_index)
		return FALSE
	var/obj/vine/guided/next = chain[from + (goal_index > from ? 1 : -1)]
	if(!planter.spend_nutrients(NYMPH_VINE_SHIFT_COST))
		return FALSE
	if(captive.buckled)
		captive.buckled.unbuckle_mob()
	captive.forceMove(get_turf(next))
	next.buckle_mob(captive)
	return TRUE

/datum/nymph_vine/proc/cut_at(obj/vine/guided/segment)
	if(!owns(segment))
		return FALSE
	if(segment == root)
		wither()
		return TRUE
	var/obj/vine/guided/previous = segment.toward_root
	if(previous)
		previous.toward_tip = null
	if(tip == segment || chain_contains(segment, tip))
		tip = previous
	var/obj/vine/guided/doomed = segment
	while(doomed)
		var/obj/vine/guided/next = doomed.toward_tip
		if(captive && segment_at(captive) == doomed)
			release()
		doomed.toward_tip = null
		doomed.toward_root = null
		qdel(doomed)
		doomed = next
	return TRUE

/datum/nymph_vine/proc/chain_contains(obj/vine/guided/start, obj/vine/guided/sought)
	var/obj/vine/guided/segment = start
	while(segment)
		if(segment == sought)
			return TRUE
		segment = segment.toward_tip
	return FALSE

/datum/nymph_vine/proc/chain()
	var/list/segments = list()
	var/obj/vine/guided/segment = root
	while(segment)
		segments += segment
		segment = segment.toward_tip
	return segments

/datum/nymph_vine/proc/wither()
	if(withering)
		return
	withering = TRUE
	release()
	var/obj/vine/guided/segment = root
	root = null
	tip = null
	while(segment)
		var/obj/vine/guided/next = segment.toward_tip
		segment.toward_tip = null
		segment.toward_root = null
		qdel(segment)
		segment = next
	if(planter)
		planter.guided_vine = null
	if(bound)
		bound.visible_message(SPAN_NOTICE("\The vine withers away from \the [bound]."))
	planter = null
	bound = null

/datum/nymph_vine/proc/notify(message)
	to_chat(bound, message)
	if(planter && planter != bound)
		to_chat(planter, message)

/datum/nymph_vine/proc/handle_click(mob/user, atom/target)
	var/turf/tile = get_turf(target)
	if(!tile)
		return FALSE
	switch(user.a_intent)
		if(I_HELP)
			if(segment_at(tile))
				return walk_bound(tile)
			// The tip can be several tiles ahead of her. Growth still starts only there.
			if(tip && tip.Adjacent(tile))
				return grow_to(tile)
		if(I_DISARM)
			if(target == captive)
				return release()
			if(segment_at(tile))
				return shift_captive_toward(tile)
		if(I_GRAB)
			if(isliving(target) && (segment_at(tile) || segment_beside(tile)))
				return grab(target)
		if(I_HURT)
			if(target == user || target == bound)
				wither()
				return TRUE
			if(istype(target, /obj/vine/guided) && owns(target))
				return cut_at(target)
	return FALSE

/datum/nymph_vine/proc/segment_beside(turf/tile)
	if(!tile)
		return FALSE
	for(var/obj/vine/guided/segment in range(1, tile))
		if(owns(segment))
			return TRUE
	return FALSE

/obj/vine/guided
	spread_chance = 0
	possible_children = 0
	var/mob/living/carbon/alien/diona/planter
	var/datum/nymph_vine/controller
	var/obj/vine/guided/toward_tip
	var/obj/vine/guided/toward_root

/obj/vine/guided/Initialize(mapload, datum/seed/newseed, obj/vine/newparent, start_matured = 0)
	. = ..(mapload, newseed, null, TRUE)
	name = "vine"
	spread_chance = 0
	possible_children = 0
	mature_time = 0
	set_density(0)
	set_opacity(0)
	mouse_opacity = 1
	update_icon()

/obj/vine/guided/proc/attach(datum/nymph_vine/vine, obj/vine/guided/previous)
	controller = vine
	planter = vine.planter
	toward_root = previous
	if(planter?.genome?.body_colour)
		color = planter.genome.body_colour
	update_icon()

/obj/vine/guided/Process()
	if(controller && !controller.withering && controller.bound && !controller.segment_at(controller.bound))
		controller.wither()
	return

/obj/vine/guided/HasProximity()
	return

/obj/vine/guided/Crossed()
	return

/obj/vine/guided/on_update_icon()
	ClearOverlays()
	icon = 'icons/obj/flora/hydroponics_vines.dmi'
	var/stage = 4
	if(!toward_root)
		stage = 3
	else if(!toward_tip)
		stage = 2
	icon_state = "vines-[stage]"
	set_density(0)
	set_opacity(0)

/obj/vine/guided/use_weapon(obj/item/weapon, mob/living/user, list/click_params)
	if(!weapon.force)
		return ..()
	damage_health(weapon.force)
	if(health_dead())
		controller?.cut_at(src)
	return TRUE

/obj/vine/guided/Destroy()
	toward_tip = null
	toward_root = null
	controller = null
	planter = null
	return ..()

/mob/living/carbon/proc/nymph_vine_allow_move(atom/newloc)
	return TRUE

/mob/living/carbon/proc/guided_vine_of()
	return

/mob/living/carbon/alien/diona/guided_vine_of()
	if(guided_vine && guided_vine.bound == src)
		return guided_vine

/mob/living/carbon/human/guided_vine_of()
	if(!species || species.name != SPECIES_DIONA)
		return
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.guided_vine && nymph.guided_vine.bound == src)
			return nymph.guided_vine

/mob/living/carbon/alien/diona/nymph_vine_allow_move(atom/newloc)
	return allow_guided_vine_move(newloc)

/mob/living/carbon/human/nymph_vine_allow_move(atom/newloc)
	return allow_guided_vine_move(newloc)

/mob/living/carbon/proc/allow_guided_vine_move(atom/newloc)
	var/datum/nymph_vine/vine = guided_vine_of()
	if(!vine || vine.withering)
		return TRUE
	if(!vine.segment_at(src))
		vine.wither()
		return TRUE
	if(vine.moving_bound || vine.segment_at(newloc))
		return TRUE
	if(pulledby || throwing || (LAssailant && LAssailant.now_pushing))
		vine.wither()
		return TRUE
	to_chat(src, SPAN_WARNING("The root holds you on the vine."))
	return FALSE

/mob/living/carbon/alien/diona/forceMove(atom/destination)
	. = ..()
	var/datum/nymph_vine/vine = guided_vine_of()
	if(vine && !vine.moving_bound && !vine.withering && !vine.segment_at(loc))
		vine.wither()

/mob/living/carbon/human/forceMove(atom/destination)
	. = ..()
	var/datum/nymph_vine/vine = guided_vine_of()
	if(vine && !vine.moving_bound && !vine.withering && !vine.segment_at(loc))
		vine.wither()

/mob/living/carbon/proc/handle_guided_vine_click(atom/target)
	return FALSE

/mob/living/carbon/alien/diona/handle_guided_vine_click(atom/target)
	return offer_guided_vine(target)

/mob/living/carbon/human/handle_guided_vine_click(atom/target)
	if(!species || species.name != SPECIES_DIONA)
		return FALSE
	return offer_guided_vine(target)

/mob/living/carbon/proc/vine_planter()
	return

/mob/living/carbon/alien/diona/vine_planter()
	if(genome?.spread)
		return src

/mob/living/carbon/human/vine_planter()
	return first_expressed_nymph("vine")

/mob/living/carbon/proc/offer_guided_vine(atom/target)
	var/mob/living/carbon/alien/diona/nymph = vine_planter()
	if(!nymph)
		return FALSE
	if(!nymph.guided_vine)
		return FALSE
	return nymph.guided_vine.handle_click(src, target)

/mob/living/carbon/alien/diona/proc/plant_guided_root(mob/living/body)
	if(guided_vine || !genome?.spread || !genome.line)
		return FALSE
	if(!isliving(body))
		body = expression_host()
	if(!isliving(body))
		body = src
	guided_vine = new(src, body)
	if(!guided_vine.plant_root())
		qdel(guided_vine)
		guided_vine = null
		return FALSE
	return TRUE

/mob/living/carbon/alien/diona/proc/drop_guided_vine()
	if(guided_vine)
		guided_vine.wither()

/mob/living/carbon/alien/diona/proc/rebind_guided_vine(mob/living/new_bound)
	if(!guided_vine)
		return
	if(guided_vine.segment_at(new_bound))
		guided_vine.bound = new_bound
	else
		guided_vine.wither()

/singleton/species/diona/handle_death(mob/living/carbon/human/H)
	for(var/mob/living/carbon/alien/diona/nymph in H)
		nymph.drop_guided_vine()
	return ..()

/mob/living/carbon/alien/diona/movement_delay(singleton/move_intent/using_intent = move_intent)
	. = ..()
	if(genome?.large)
		. += 3

#undef NYMPH_VINE_ROOT_COST
#undef NYMPH_VINE_GROW_COST
#undef NYMPH_VINE_SHIFT_COST
#undef NYMPH_VINE_MAX
