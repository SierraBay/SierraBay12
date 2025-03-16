#define CATAPULT_SINGLE 1
#define CATAPULT_AREA   2

/obj/item/mech_equipment/catapult
	name = "gravitational catapult"
	desc = "An exosuit-mounted gravitational catapult."
	icon_state = "mech_clamp"
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	var/mode = CATAPULT_SINGLE
	var/atom/movable/locked
	equipment_delay = 2.2 SECONDS //Stunlocks are not ideal
	origin_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 4, TECH_MAGNET = 4)
	require_adjacent = FALSE

	var/activated_passive_power = 1 KILOWATTS
 	///For when targetting a single object, will create a warp beam
	var/datum/beam = null
	var/max_dist = 6
	var/obj/effect/warp/small/warpeffect = null

/obj/ebeam/warp
	plane = WARP_EFFECT_PLANE
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | TILE_BOUND | NO_CLIENT_COLOR
	z_flags = ZMM_IGNORE

/obj/effect/warp/small
	plane = WARP_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE | NO_CLIENT_COLOR
	icon = 'icons/effects/96x96.dmi'
	icon_state = "singularity_s3"
	pixel_x = -32
	pixel_y = -32
	z_flags = ZMM_IGNORE

/obj/item/mech_equipment/catapult/proc/beamdestroyed()
	if(beam)
		GLOB.destroyed_event.unregister(beam, src, .proc/beamdestroyed)
		beam = null
	if(locked)
		if(owner)
			for(var/pilot in owner.pilots)
				to_chat(pilot, SPAN_NOTICE("Lock on \the [locked] disengaged."))
		endanimation()
		locked = null
	//It's possible beam self destroyed, match active
	if(active)
		deactivate()

/obj/item/mech_equipment/catapult/proc/endanimation()
	if(locked)
		animate(locked,pixel_y= initial(locked.pixel_y), time = 0)

/obj/item/mech_equipment/catapult/get_hardpoint_maptext()
	var/string
	if(locked)
		string = locked.name + " - "
	if(mode == 1)
		string += "Pull"
	else string += "Push"
	return string

/obj/item/mech_equipment/catapult/deactivate()
	. = ..()
	if(beam)
		QDEL_NULL(beam)
	passive_power_use = 0

/obj/item/mech_equipment/catapult/attack_self(mob/user)
	. = ..()
	if(.)
		if(!locked)
			mode = mode == CATAPULT_SINGLE ? CATAPULT_AREA : CATAPULT_SINGLE
			to_chat(user, SPAN_NOTICE("You set \the [src] to [mode == CATAPULT_SINGLE ? "single" : "multi"]-target mode."))
			update_icon()
		else
			to_chat(user, SPAN_NOTICE("You cannot change the mode \the [src] while it is locked on to a target."))

/obj/item/mech_equipment/catapult/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if(.)
		switch(mode)
			if(CATAPULT_SINGLE)
				if(!locked && (get_dist(owner, target) <= max_dist))
					var/atom/movable/AM = target
					if(!istype(AM) || AM.anchored || !AM.simulated)
						to_chat(user, SPAN_NOTICE("Unable to lock on [target]."))
						return
					locked = AM
					beam = owner.Beam(BeamTarget = target, icon_state = "r_beam", maxdistance = max_dist, beam_type = /obj/ebeam/warp)
					GLOB.destroyed_event.register(beam, src, .proc/beamdestroyed)

					animate(target,pixel_y= initial(target.pixel_y) - 2,time=1 SECOND, easing = SINE_EASING, flags = ANIMATION_PARALLEL, loop = -1)
					animate(pixel_y= initial(target.pixel_y) + 2,time=1 SECOND)

					active = TRUE
					passive_power_use = activated_passive_power
					to_chat(user, SPAN_NOTICE("Locked on [AM]."))
					return
				else if(target != locked)
					if(locked in view(owner))
						log_and_message_admins("used [src] to throw [locked] at [target].", user, owner.loc)
						endanimation() //End animation without waiting for delete, so throw won't be affected
						locked.throw_at(target, 14, 1.5, owner)
						locked = null
						deactivate()

						var/obj/item/cell/C = owner.get_cell()
						if(istype(C))
							C.use(active_power_use * CELLRATE)

					else
						deactivate()
			if(CATAPULT_AREA)
				if(!warpeffect)
					warpeffect = new

				//effect and sound
				warpeffect.forceMove(get_turf(target))
				warpeffect.SetTransform(scale = 0)
				warpeffect.alpha = 255
				animate(
					warpeffect,
					transform = matrix(),
					alpha = 0,
					time = 1.25 SECONDS
				)
				addtimer(new Callback(warpeffect, /atom/movable/proc/forceMove, null), 1.25 SECONDS)
				playsound(warpeffect, 'sound/effects/heavy_cannon_blast.ogg', 50, 1)

				var/list/atoms = list()
				if(isturf(target))
					atoms = range(target,3)
				else
					atoms = orange(target,3)
				for(var/atom/movable/A in atoms)
					if(A.anchored || !A.simulated) continue
					var/dist = 5-get_dist(A,target)
					A.throw_at(get_edge_target_turf(A,get_dir(target, A)),dist,0.7)

				log_and_message_admins("used [src]'s area throw on [target].", user, owner.loc)
				var/obj/item/cell/C = owner.get_cell()
				if(istype(C))
					C.use(active_power_use * CELLRATE * 2) //bit more expensive to throw all

#undef CATAPULT_SINGLE
#undef CATAPULT_AREA
