/obj/item/mech_component/sensors
	name = "head"
	icon_state = "loader_head"
	gender = NEUTER

	var/vision_flags = 0
	var/see_invisible = 0
	var/obj/item/robot_parts/robot_component/radio/radio
	var/obj/item/robot_parts/robot_component/camera/camera
	var/obj/item/robot_parts/robot_component/control_module/computer
	/// Takes /obj/item/circuitboard/exosystem type paths for what boards get put in for prefabs
	var/list/prebuilt_software = list()
	has_hardpoints = list(HARDPOINT_HEAD)
	var/active_sensors = 0
	power_use = 15
	w_class = ITEM_SIZE_NORMAL

/obj/item/mech_component/sensors/Destroy()
	QDEL_NULL(camera)
	QDEL_NULL(radio)
	QDEL_NULL(computer)
	. = ..()

/obj/item/mech_component/sensors/show_missing_parts(mob/user)
	if(!radio)
		to_chat(user, SPAN_WARNING("It is missing a radio."))
	if(!camera)
		to_chat(user, SPAN_WARNING("It is missing a camera."))
	if(!computer)
		to_chat(user, SPAN_WARNING("It is missing a software control module."))

/obj/item/mech_component/sensors/prebuild()
	radio = new(src)
	camera = new(src)
	computer = new(src)
	for(var/board in prebuilt_software)
		computer.install_software(new board)
	update_parts_images()

/obj/item/mech_component/sensors/update_components()
	radio = locate() in src
	camera = locate() in src
	computer = locate() in src
	if(owner)
		owner.need_update_sensor_effects = TRUE
	update_parts_images()

/obj/item/mech_component/sensors/ready_to_install()
	return (radio && camera)

/obj/item/mech_component/sensors/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(istype(thing, /obj/item/robot_parts/robot_component/control_module))
		if(computer)
			to_chat(user, SPAN_WARNING("\The [src] already has a control modules installed."))
			return TRUE
		if(install_component(thing, user))
			computer = thing
			update_parts_images()
			return TRUE

	else if(istype(thing,/obj/item/robot_parts/robot_component/radio))
		if(radio)
			to_chat(user, SPAN_WARNING("\The [src] already has a radio installed."))
			return TRUE
		if(install_component(thing, user))
			radio = thing
			update_parts_images()
			return TRUE

	else if(istype(thing,/obj/item/robot_parts/robot_component/camera))
		if(camera)
			to_chat(user, SPAN_WARNING("\The [src] already has a camera installed."))
			return TRUE
		if(install_component(thing, user))
			camera = thing
			update_parts_images()
			return TRUE
	else
		return ..()

/obj/item/mech_component/sensors/return_diagnostics(mob/user)
	..()
	if(computer)
		to_chat(user, SPAN_NOTICE(" Installed Software"))
		for(var/exosystem_software in computer.installed_software)
			to_chat(user, SPAN_NOTICE(" - <b>[capitalize(exosystem_software)]</b>"))
	else
		to_chat(user, SPAN_WARNING(" Control Module Missing or Non-functional."))
	if(radio)
		to_chat(user, SPAN_NOTICE(" Radio Integrity: <b>[round((((radio.max_dam - radio.total_dam) / radio.max_dam)) * 100)]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Radio Missing or Non-functional."))
	if(camera)
		to_chat(user, SPAN_NOTICE(" Camera Integrity: <b>[round((((camera.max_dam - camera.total_dam) / camera.max_dam)) * 100)]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Camera Missing or Non-functional."))
