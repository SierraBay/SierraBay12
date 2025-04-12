/mob/living/exosuit/Destroy()

	selected_system = null

	for (var/mob/pilot as anything in pilots)
		remove_pilot(pilot)

	hud_health = null
	hud_power = null
	hud_power_control = null
	hud_camera = null

	QDEL_NULL_LIST(hud_elements)

	for (var/hardpoint in hardpoints)
		qdel(hardpoints[hardpoint])
	// SIERRA-REMOVE hardpoints.Cut() //Это место из-за мода рантаймит, в целом бесполезный кусок кода ибо удаление всё само сделает
	hardpoints = null

	QDEL_NULL(access_card)
	QDEL_NULL(L_leg)
	QDEL_NULL(R_leg)
	QDEL_NULL(L_arm)
	QDEL_NULL(R_arm)
	QDEL_NULL(head)
	QDEL_NULL(body)

	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		H.owner = null
		H.holding = null
		qdel(H)
	// SIERRA-REMOVE hardpoint_hud_elements.Cut() //Это место из-за мода рантаймит, в целом бесполезный кусок кода ибо удаление всё само сделает
	hardpoint_hud_elements = null
	external_leaving_passenger(mode = MECH_DROP_ALL_PASSENGERS) // Перед смертью меха, сбросим всех пассажиров
	. = ..()


/mob/living/exosuit/death(gibbed)
	// Eject the pilot.
	if(LAZYLEN(pilots))
		hatch_locked = 0 // So they can get out.
		for(var/pilot in pilots)
			eject(pilot, silent=1)

	// Salvage moves into the wreck unless we're exploding violently.
	var/obj/wreck = new wreckage_path(get_turf(src), src, gibbed)
	wreck.name = "wreckage of \the [name]"

	// Handle the rest of things.
	..(gibbed, (gibbed ? "explodes!" : "grinds to a halt before collapsing!"))

	if(!gibbed)
		if(L_leg.loc != src)
			L_leg = null
		if(R_leg.loc != src)
			R_leg = null
		if(L_arm.loc != src)
			L_arm = null
		if(R_arm.loc != src)
			R_arm = null
		if(head.loc != src)
			head = null
		if(body.loc != src)
			body = null
		qdel(src)

/mob/living/exosuit/gib()
	death(1)


	// Get a turf to play with.
	var/turf/T = get_turf(src)
	if(!T)
		qdel(src)
		return

	//Подожгём людей и пилотов рядом
	for(var/mob/living/detected_living in range(1, get_turf(src)))
		detected_living.fire_stacks = max(2, detected_living.fire_stacks)
		detected_living.IgniteMob()
	// Hurl our component pieces about.
	var/list/stuff_to_throw = list()
	for(var/obj/item/thing in list(head, body, L_arm, R_arm, L_leg, R_leg))
		if(thing) stuff_to_throw += thing
	for(var/hardpoint in hardpoints)
		if(hardpoints[hardpoint])
			var/obj/item/thing = hardpoints[hardpoint]
			thing.screen_loc = null
			stuff_to_throw += thing
	for(var/obj/item/thing in stuff_to_throw)
		thing.forceMove(T)
		thing.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(3,6),40)
	explosion(T, 2, EX_ACT_LIGHT)
	qdel(src)
	return
