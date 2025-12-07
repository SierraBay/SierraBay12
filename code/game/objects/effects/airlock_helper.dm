/*
Note that these have to be within range of world.view (7 tiles), centered on the controller for them to function.
You still need to set the controller's `id_tag` to something unique.
In case of multiple nearby airlocks, you can set `master_tag` or `must_share_area` to prevent the helper from selecting the wrong airlock.
*/
/obj/airlock_helper
	icon = 'icons/effects/airlock_helper.dmi'
	abstract_type = /obj/airlock_helper
	layer = ABOVE_DOOR_LAYER
	/// The controller we're using. Set to a type to locate the type during Initialize().
	var/obj/machinery/embedded_controller/radio/my_controller = /obj/machinery/embedded_controller/radio/airlock
	/// The device we're setting up. Set to a type to locate the type during Initialize().
	var/my_device
	/// Adjusts the various radio tags used to configure airlock devices.
	var/tag_addon
	/// Whether the helper should share an area with the controller.
	var/must_share_area = FALSE
	/// The master tag, in case of nearby controllers that could cause conflicts.
	var/master_tag

/obj/airlock_helper/Initialize()
	..()
	my_controller = get_controller()
	if (!my_controller)
		log_error("Airlock helper '[name]' couldn't find a controller at: X:[x] Y:[y] Z:[z]")
		return INITIALIZE_HINT_QDEL

	if (!my_controller.id_tag)
		log_error("Airlock helper '[name]' found a controller without an 'id_tag' set: X:[x] Y:[y] Z:[z]")
		return INITIALIZE_HINT_QDEL

	my_device = locate(my_device) in loc
	if (!my_device)
		log_error("Airlock helper '[name]' couldn't find the device it wanted at: X:[x] Y:[y] Z:[z]")
		return INITIALIZE_HINT_QDEL

	configure_associated_device()
	return INITIALIZE_HINT_QDEL

/obj/airlock_helper/Destroy()
	my_controller = null
	my_device = null
	return ..()

/obj/airlock_helper/proc/get_controller()
	var/closest_distance = INFINITY
	for (var/obj/O in range(world.view, src))
		if (!istype(O, my_controller))
			continue
		var/obj/machinery/embedded_controller/radio/airlock/controller = O
		if (must_share_area && get_area(controller) != get_area(src))
			continue
		if (master_tag && master_tag != controller.id_tag)
			continue
		if (!.)
			. = controller
			continue
		var/check_distance = get_dist(src, controller)
		if (check_distance >= closest_distance)
			continue
		closest_distance = check_distance
		. = controller

/// Stub for subtypes to override to deal with their specific devices.
/obj/airlock_helper/proc/configure_associated_device()
	return

/*
	Doors
*/
/obj/airlock_helper/door
	abstract_type = /obj/airlock_helper/door
	my_device = /obj/machinery/door/airlock
	/// Whether the door should start bolted.
	var/should_lock_door = TRUE

/obj/airlock_helper/door/configure_associated_device()
	var/obj/machinery/door/airlock/my_airlock = my_device
	if (should_lock_door)
		my_airlock.lock()
	my_airlock.set_id_tag(my_controller.id_tag + tag_addon)
	my_airlock.set_frequency(my_controller.frequency)
	for (var/obj/item/stock_parts/radio/R in my_airlock.get_all_components_of_type(/obj/item/stock_parts/radio))
		R.set_id_tag(my_controller.id_tag + tag_addon)

/obj/airlock_helper/door/ext_door
	name = "exterior airlock door"
	icon_state = "doorout"
	tag_addon = "_outer"

/obj/airlock_helper/door/int_door
	name = "interior airlock door"
	icon_state = "doorin"
	tag_addon = "_inner"

/obj/airlock_helper/door/simple
	name = "simple docking controller hatch"
	icon_state = "doorsimple"
	tag_addon = "_hatch"
	my_controller = /obj/machinery/embedded_controller/radio/simple_docking_controller


/*
	Atmos
*/
/obj/airlock_helper/atmos
	abstract_type = /obj/airlock_helper/atmos
	my_device = /obj/machinery/atmospherics/unary/vent_pump

/obj/airlock_helper/atmos/configure_associated_device()
	var/obj/machinery/atmospherics/unary/vent_pump/my_pump = my_device
	my_pump.set_id_tag(my_controller.id_tag + tag_addon)
	for(var/obj/item/stock_parts/radio/R in my_pump.get_all_components_of_type(/obj/item/stock_parts/radio))
		R.set_id_tag(my_controller.id_tag + tag_addon)

/obj/airlock_helper/atmos/chamber_pump
	name = "chamber pump"
	icon_state = "pump"
	tag_addon = "_pump"

/obj/airlock_helper/atmos/pump_out_internal
	name = "air dump intake"
	icon_state = "pumpdin"
	tag_addon = "_pump_out_internal"

/obj/airlock_helper/atmos/pump_out_external
	name = "air dump output"
	icon_state = "pumpdout"
	tag_addon = "_pump_out_external"


/*
	Sensors
*/
/obj/airlock_helper/sensor
	my_device = /obj/machinery/airlock_sensor

/obj/airlock_helper/sensor/configure_associated_device()
	var/obj/machinery/airlock_sensor/my_sensor = my_device
	my_sensor.set_id_tag(my_controller.id_tag + tag_addon)
	my_sensor.set_frequency(my_controller.frequency)

/obj/airlock_helper/sensor/ext_sensor
	name = "exterior sensor"
	icon_state = "sensout"
	tag_addon = "_exterior_sensor"

/obj/airlock_helper/sensor/chamber_sensor
	name = "chamber sensor"
	icon_state = "sens"
	tag_addon = "_sensor"

/obj/airlock_helper/sensor/int_sensor
	name = "interior sensor"
	icon_state = "sensin"
	tag_addon = "_interior_sensor"

/*
	Buttons
*/
/obj/airlock_helper/button
	my_device = /obj/machinery/access_button
	icon_state = "button"
	var/command
	var/replace_with_name

/obj/airlock_helper/button/configure_associated_device()
	var/obj/machinery/access_button/my_button = my_device
	my_button.master_tag = my_controller.id_tag
	my_button.set_frequency(my_controller.frequency)
	my_button.command = command
	if (!my_button.name)
		my_button.name = replace_with_name

/obj/airlock_helper/button/interior
	icon_state = "button_int"
	command = "cycle_interior"
	replace_with_name = "interior access button"

/obj/airlock_helper/button/exterior
	icon_state = "button_ext"
	command = "cycle_exterior"
	replace_with_name = "exterior access button"
