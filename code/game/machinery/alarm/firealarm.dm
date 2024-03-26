/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/machines/firealarm.dmi'
	icon_state = "casing"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = TRUE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/wiresexposed = FALSE
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone
	var/seclevel
	var/static/list/overlays_cache

/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	if(loc.z in GLOB.using_map.contact_levels)
		var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
		to_chat(user, "The current alert level is [security_state.current_security_level.name].")

/obj/machinery/firealarm/Initialize()
	. = ..()
	queue_icon_update()

/obj/machinery/firealarm/proc/get_cached_overlay(state)
	if(!LAZYACCESS(overlays_cache, state))
		LAZYSET(overlays_cache, state, image(icon, state))
	return overlays_cache[state]

/obj/machinery/firealarm/on_update_icon()
	ClearOverlays()

	pixel_x = 0
	pixel_y = 0
	var/walldir = (dir & (NORTH|SOUTH)) ? GLOB.reverse_dir[dir] : dir
	var/turf/T = get_step(get_turf(src), walldir)
	if(istype(T) && T.density)
		if(dir == SOUTH)
			pixel_y = 21
		else if(dir == NORTH)
			pixel_y = -21
		else if(dir == EAST)
			pixel_x = 21
		else if(dir == WEST)
			pixel_x = -21

	icon_state = "casing"
	if(wiresexposed)
		AddOverlays(get_cached_overlay("b[buildstage]"))
		set_light(0)
		return

	if(MACHINE_IS_BROKEN(src))
		AddOverlays(get_cached_overlay("broken"))
		set_light(0)
	else if(!is_powered())
		AddOverlays(get_cached_overlay("unpowered"))
		set_light(0)
	else
		if(!detecting)
			AddOverlays(get_cached_overlay("fire1"))
			set_light(2, 0.25, COLOR_RED)
		else if(z in GLOB.using_map.contact_levels)
			var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
			var/singleton/security_level/sl = security_state.current_security_level

			set_light(sl.light_power, sl.light_range, sl.light_color_alarm)
			AddOverlays(image(sl.icon, sl.overlay_alarm))
		else
			AddOverlays(get_cached_overlay("fire0"))

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(src.detecting)
		if(exposed_temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/bullet_act()
	return src.alarm()

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm(rand(30/severity, 60/severity))
	..()

/obj/machinery/firealarm/use_tool(obj/item/W, mob/living/user, list/click_params)
	if ((. = ..()))
		return

	if(isScrewdriver(W) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return TRUE

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if(isMultitool(W))
					detecting = !detecting
					user.visible_message(
						SPAN_NOTICE("\The [user] has [detecting? "re" : "dis"]connected \the [src]'s detecting unit!"),
						SPAN_NOTICE("You have [detecting? "re" : "dis"]connected \the [src]'s detecting unit.")
					)
					return TRUE

				if (isWirecutter(W))
					user.visible_message(
						SPAN_NOTICE("\The [user] has cut the wires inside \the [src]!"),
						SPAN_NOTICE("You have cut the wires inside \the [src].")
					)
					new/obj/item/stack/cable_coil(get_turf(src), 5)
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					buildstage = 1
					update_icon()
					return TRUE

			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = W
					if (C.use(5))
						to_chat(user, SPAN_NOTICE("You wire \the [src]."))
						buildstage = 2
						update_icon()
						return TRUE
					else
						to_chat(user, SPAN_WARNING("You need 5 pieces of cable to wire \the [src]."))
						return TRUE
				if(isCrowbar(W))
					to_chat(user, "You start prying out the circuit.")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					if (!do_after(user, (W.toolspeed * 2) SECONDS, src, DO_REPAIR_CONSTRUCT))
						return TRUE

					to_chat(user, "You pry out the circuit!")
					var/obj/item/firealarm_electronics/circuit = new /obj/item/firealarm_electronics()
					circuit.dropInto(user.loc)
					buildstage = 0
					update_icon()
					return TRUE
			if(0)
				if(istype(W, /obj/item/firealarm_electronics))
					to_chat(user, "You insert the circuit!")
					qdel(W)
					buildstage = 1
					update_icon()
					return TRUE

				if (isWrench(W))
					to_chat(user, "You remove the fire alarm assembly from the wall!")
					new /obj/item/frame/fire_alarm(get_turf(user))
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
					return TRUE

	to_chat(user, SPAN_WARNING("You fumble with \the [W] and trigger the alarm!"))
	alarm()
	return TRUE

/obj/machinery/firealarm/Process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(inoperable())
		return

	if(timing)
		if(time > 0)
			time -= (world.timeofday - last_process)/10

		else
			alarm()
			time = 0
			timing = 0
			STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		updateDialog()
	last_process = world.timeofday

	if(locate(/obj/hotspot) in loc)
		alarm()

/obj/machinery/firealarm/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/firealarm/interact(mob/user)
	user.set_machine(src)
	var/area/A = src.loc
	var/d1
	var/d2

	var/datum/browser/popup = new(user, "firealarm", "Fire alarm")
	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon))
		A = A.loc

		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		popup.set_content("[d1]\n<HR>The current alert level is <b>[security_state.current_security_level.name]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		popup.set_content("[d1]\n<HR>The current security level is <b>[security_state.current_security_level.name]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n")
	popup.open()
	return

/obj/machinery/firealarm/CanUseTopic(user)
	if(buildstage != 2)
		return STATUS_CLOSE
	return ..()

/obj/machinery/firealarm/OnTopic(user, href_list)
	if (href_list["reset"])
		src.reset()
		. = TOPIC_REFRESH
	else if (href_list["alarm"])
		src.alarm()
		. = TOPIC_REFRESH
	else if (href_list["time"])
		src.timing = text2num(href_list["time"])
		last_process = world.timeofday
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		. = TOPIC_REFRESH
	else if (href_list["tp"])
		var/tp = text2num(href_list["tp"])
		src.time += tp
		src.time = min(max(round(src.time), 0), 120)
		. = TOPIC_REFRESH

	if(. == TOPIC_REFRESH)
		interact(user)

/obj/machinery/firealarm/proc/reset()
	if (!( src.working ))
		return

	var/area/area = get_area(src)
	for(var/obj/machinery/firealarm/FA in area.machinery_list)
		GLOB.fire_alarm.clearAlarm(loc, FA)

	update_icon()
	return

/obj/machinery/firealarm/proc/alarm(duration = 0)
	if (!(src.working))
		return

	var/area/area = get_area(src)
	for(var/obj/machinery/firealarm/FA in area.machinery_list)
		GLOB.fire_alarm.triggerAlarm(loc, FA, duration)

	update_icon()
	playsound(src, 'sound/machines/fire_alarm.ogg', 75, 0)
	return

/obj/machinery/firealarm/New(loc, dir, atom/frame)
	..(loc)

	if(dir)
		src.set_dir((dir & (NORTH|SOUTH)) ? dir : GLOB.reverse_dir[dir])

	if(istype(frame))
		buildstage = 0
		wiresexposed = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -21 : 21)
		pixel_y = (dir & 3)? (dir ==1 ? -21 : 21) : 0
		update_icon()
		frame.transfer_fingerprints_to(src)

/obj/machinery/firealarm/Initialize()
	. = ..()
	if(z in GLOB.using_map.contact_levels)
		update_icon()

/obj/item/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\"."
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
