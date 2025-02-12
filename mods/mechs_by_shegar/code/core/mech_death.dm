/mob/living/exosuit/Destroy()

	selected_system = null

	for (var/mob/pilot as anything in pilots)
		remove_pilot(pilot)

	hud_health = null
	hud_open = null
	hud_power = null
	hud_power_control = null
	hud_camera = null

	QDEL_NULL_LIST(hud_elements)

	for (var/hardpoint in hardpoints)
		qdel(hardpoints[hardpoint])
	// SIERRA-REMOVE hardpoints.Cut() //Это место из-за мода рантаймит, в целом бесполезный кусок кода ибо удаление всё само сделает
	hardpoints = null

	QDEL_NULL(access_card)
	QDEL_NULL(arms)
	QDEL_NULL(legs)
	QDEL_NULL(head)
	QDEL_NULL(body)

	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		H.owner = null
		H.holding = null
		qdel(H)
	// SIERRA-REMOVE hardpoint_hud_elements.Cut() //Это место из-за мода рантаймит, в целом бесполезный кусок кода ибо удаление всё само сделает
	hardpoint_hud_elements = null
	forced_leave_passenger(0 , MECH_DROP_ALL_PASSENGERS , "destroys of [src]") // Перед смертью меха, сбросим всех пассажиров
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
		if(arms.loc != src)
			arms = null
		if(legs.loc != src)
			legs = null
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

	// Hurl our component pieces about.
	var/list/stuff_to_throw = list()
	for(var/obj/item/thing in list(arms, legs, head, body))
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
