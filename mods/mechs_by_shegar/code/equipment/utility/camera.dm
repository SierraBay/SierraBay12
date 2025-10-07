/obj/item/mech_equipment/camera
	name = "mech camera"
	desc = "A dedicated visible light spectrum camera for remote feeds. It comes with its own transmitter!"
	icon_state = "mech_camera"
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	equipment_delay = 10
	heat_generation = 10

	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 2, TECH_MAGNET = 2)
	var/obj/machinery/camera/network/helmet/camera
	var/list/additional_networks //If you want to make a subtype for mercs, ert etc... Write here the extra networks

/obj/item/mech_equipment/camera/Destroy()
	QDEL_NULL(camera)
	. = ..()

/obj/item/mech_equipment/camera/Initialize()
	. = ..()
	camera = new(src)
	camera.c_tag = "null"
	camera.set_status(FALSE)
	camera.is_helmet_cam = TRUE //Can transmit locally regardless of network
	camera.set_stat_immunity(MACHINE_STAT_NOPOWER) //Camera power comes from the mech, not the camera itself.

/obj/item/mech_equipment/camera/installed(mob/living/exosuit/_owner)
	. = ..()
	if(owner)
		camera.c_tag = "[owner.name] camera feed"
		invalidateCameraCache()

/obj/item/mech_equipment/camera/uninstalled()
	. = ..()
	camera.c_tag = "null"
	invalidateCameraCache()

/obj/item/mech_equipment/camera/examine(mob/user)
	. = ..()
	to_chat(user, "Network: [english_list(camera.network)]; Feed is currently: [camera.status ? "Online" : "Offline"].")

/obj/item/mech_equipment/camera/proc/activate()
	camera.set_status(TRUE)
	passive_power_use = 0.2 KILOWATTS
	active = TRUE

/obj/item/mech_equipment/camera/deactivate()
	camera.set_status(FALSE)
	passive_power_use = 0
	. = ..()

/obj/item/mech_equipment/camera/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isScrewdriver(W))
		var/list/all_networks = list()
		for(var/network in GLOB.using_map.station_networks)
			if(has_access(get_camera_access(network), GetIdCard(user)))
				all_networks += network

		all_networks += additional_networks

		var/network = input("Which network would you like to configure it for?") as null|anything in (all_networks)
		if(!network)
			to_chat(user, SPAN_WARNING("You cannot connect to any camera network!."))
			return TRUE
		var/delay = 2 SECONDS * user.skill_delay_mult(SKILL_DEVICES)
		if(do_after(user, delay, src, DO_DEFAULT | DO_BOTH_UNIQUE_ACT) && network)
			camera.network = list(network)
			camera.update_coverage(TRUE)
			to_chat(user, SPAN_NOTICE("You configure the camera for \the [network] network."))
		return TRUE

	return ..()

/obj/item/mech_equipment/camera/attack_self(mob/user)
	. = ..()
	if(.)
		if(active)
			deactivate()
		else
			activate()
		to_chat(user, SPAN_NOTICE("You toggle \the [src] [active ? "on" : "off"]"))

/obj/item/mech_equipment/camera/get_hardpoint_maptext()
	return "[english_list(camera.network)]: [active ? "ONLINE" : "OFFLINE"]"
