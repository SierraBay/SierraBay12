//Point defense
/obj/machinery/pointdefense_control
	name = "fire assist mainframe"
	desc = "A specialized computer designed to synchronize a variety of weapon systems and a vessel's astronav data."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "control"
	var/ui_template = "pointdefense_control.tmpl"
	var/initial_id_tag
	density = TRUE
	anchored = TRUE
	base_type =       /obj/machinery/pointdefense_control
	construct_state = /singleton/machine_construction/default/panel_closed
	var/list/targets = list()
	atom_flags =  ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE
	machine_name = "fire assist mainframe"
	machine_desc = "A control computer used to synchronize point defense batteries."

/obj/machinery/pointdefense_control/Initialize()
	. = ..()
	set_extension(src, /datum/extension/local_network_member/multilevel)
	if(initial_id_tag)
		var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
		pointdefense.set_tag(null, initial_id_tag)
		//No more than 1 controller please.
		var/datum/local_network/lan = pointdefense.get_local_network()
		if(lan)
			var/list/pointdefense_controllers = lan.get_devices(/obj/machinery/pointdefense_control)
			if(length(pointdefense_controllers) > 1)
				lan.remove_device(src)

/obj/machinery/pointdefense_control/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(ui_template)
		var/list/data = build_ui_data()
		ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
		if (!ui)
			ui = new(user, src, ui_key, ui_template, name, 400, 600)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

/obj/machinery/pointdefense_control/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/pointdefense_control/OnTopic(mob/user, href_list, datum/topic_state/state)

	if(href_list["toggle_active"])
		var/obj/machinery/pointdefense/PD = locate(href_list["toggle_active"])
		if(!istype(PD))
			return TOPIC_NOACTION

		var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
		var/datum/local_network/lan = pointdefense.get_local_network()
		if(!lan || !lan.is_connected(PD))
			return TOPIC_NOACTION

		if(!PD.Activate()) //Startup() whilst the device is active will return null.
			PD.Deactivate()
		return TOPIC_REFRESH

/obj/machinery/pointdefense_control/proc/build_ui_data()
	var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
	var/datum/local_network/lan = pointdefense.get_local_network()
	var/list/data = list()
	data["id"] = lan ? lan.id_tag : "unset"
	data["name"] = name
	var/list/turrets = list()
	if(lan)
		var/list/pointdefense_turrets = lan.get_devices(/obj/machinery/pointdefense)
		for(var/i = 1 to LAZYLEN(pointdefense_turrets))
			var/list/turret = list()
			var/obj/machinery/pointdefense/PD = pointdefense_turrets[i]
			turret["id"] =          "#[i]"
			turret["ref"] =         "\ref[PD]"
			turret["active"] =       PD.active
			turret["effective_range"] = PD.active ? "[PD.kill_range] meter\s" : "OFFLINE."
			turret["reaction_wheel_delay"] = PD.active ? "[(PD.rotation_speed / (1 SECONDS))] second\s" : "OFFLINE."
			turret["recharge_time"] = PD.active ? "[(PD.charge_cooldown / (1 SECONDS))] second\s" : "OFFLINE."

			turrets += list(turret)

	data["turrets"] = turrets
	return data

/obj/machinery/pointdefense_control/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(isMultitool(thing))
		var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
		pointdefense.get_new_tag(user)
		//Check if there is more than 1 controller
		var/datum/local_network/lan = pointdefense.get_local_network()
		if(lan)
			var/list/pointdefense_controllers = lan.get_devices(/obj/machinery/pointdefense_control)
			if(pointdefense_controllers && length(pointdefense_controllers) > 1)
				lan.remove_device(src)
		return TRUE
	else
		return ..()

/obj/machinery/pointdefense
	name = "point defense battery"
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "pointdefense"
	desc = "A Kuiper pattern anti-meteor battery. Capable of destroying most threats in a single salvo."
	density = TRUE
	anchored = TRUE
	atom_flags =  ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE
	idle_power_usage = 0.1 KILOWATTS
	construct_state = /singleton/machine_construction/default/panel_closed
	maximum_component_parts = list(/obj/item/stock_parts = 10)         //null - no max. list(type part = number max).
	base_type = /obj/machinery/pointdefense
	stock_part_presets = list(/singleton/stock_part_preset/terminal_setup)
	uncreated_component_parts = null
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | PIXEL_SCALE
	machine_name = "point defense battery"
	machine_desc = "A mounted turret that locks onto and destroys incoming meteors. Aim away from vessel."
	var/active = TRUE
	var/charge_cooldown = 1 SECOND  //time between it can fire at different targets
	var/last_shot = 0
	var/kill_range = 18
	var/rotation_speed = 0.25 SECONDS  //How quickly we turn to face threats
	var/engaging = FALSE
	var/initial_id_tag
	var/list/pending_targets = list()
	var/last_event_wake_tick = -1
	var/event_heartbeat_interval = 1 SECONDS

/obj/machinery/pointdefense/Initialize()
	. = ..()
	set_extension(src, /datum/extension/local_network_member/multilevel)
	if(initial_id_tag)
		var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
		pointdefense.set_tag(null, initial_id_tag)
	RegisterSignal(GLOB, COMSIG_METEOR_SPAWNED, PROC_REF(on_meteor_spawned))
	RegisterSignal(GLOB, COMSIG_METEOR_DESPAWNED, PROC_REF(on_meteor_despawned))
	if(length(GLOB.meteor_list))
		pending_targets |= GLOB.meteor_list
	queue_event_processing()

/obj/machinery/pointdefense/Destroy()
	UnregisterSignal(GLOB, list(COMSIG_METEOR_SPAWNED, COMSIG_METEOR_DESPAWNED))
	return ..()

/obj/machinery/pointdefense/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(isMultitool(thing))
		var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
		pointdefense.get_new_tag(user)
		return TRUE

	return ..()

//Guns cannot shoot through hull or generally dense turfs.
/obj/machinery/pointdefense/proc/space_los(meteor)
	for(var/turf/T in getline(src,meteor))
		if(T.density)
			return FALSE
	return TRUE

/obj/machinery/pointdefense/proc/Shoot(weakref/target)
	var/obj/meteor/M = target.resolve()
	if(!istype(M))
		return
	engaging = TRUE
	addtimer(new Callback(src, PROC_REF(finish_shot), target), rotation_speed)
	var/Angle = round(Get_Angle(src, M))
	animate(
		src,
		transform = matrix().Update(rotation = Angle),
		rotation_speed,
		easing = SINE_EASING
	)

	set_dir(transform.get_angle() > 0 ? NORTH : SOUTH)

/obj/machinery/pointdefense/proc/finish_shot(weakref/target)
	//Cleanup from list
	var/obj/machinery/pointdefense_control/PC = get_controller()
	if(istype(PC))
		PC.targets -= target


	engaging = FALSE
	last_shot = world.time
	var/obj/meteor/M = target.resolve()
	if(!istype(M))
		return
	//We throw a laser but it doesnt have to hit for meteor to explode
	var/obj/item/projectile/beam/pointdefense/beam = new (get_turf(src))
	playsound(src, 'sound/effects/heavy_cannon_blast.ogg', 75, 1)
	use_power_oneoff(idle_power_usage * 10)
	beam.launch(M.loc)
	M.make_debris()
	qdel(M)

/obj/machinery/pointdefense/proc/get_controller()
	var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
	var/datum/local_network/lan = pointdefense.get_local_network()
	if(!lan)
		return null
	var/list/pointdefense_controllers = lan.get_devices(/obj/machinery/pointdefense_control)
	return LAZYACCESS(pointdefense_controllers, 1)

/obj/machinery/pointdefense/proc/queue_event_processing()
	if(world.time == last_event_wake_tick)
		return
	last_event_wake_tick = world.time
	START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/pointdefense/proc/schedule_event_heartbeat()
	if(!SSmachines.optimize_machinery_event || !event_heartbeat_interval)
		return
	addtimer(new Callback(src, PROC_REF(queue_event_processing)), event_heartbeat_interval, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/pointdefense/proc/on_meteor_spawned(datum/globals/source, obj/meteor/meteor_ref)
	SIGNAL_HANDLER
	if(source != GLOB || !istype(meteor_ref))
		return
	if(!(meteor_ref in pending_targets))
		pending_targets += meteor_ref
	queue_event_processing()

/obj/machinery/pointdefense/proc/on_meteor_despawned(datum/globals/source, obj/meteor/meteor_ref)
	SIGNAL_HANDLER
	if(source != GLOB || !istype(meteor_ref))
		return
	pending_targets -= meteor_ref

/obj/machinery/pointdefense/Process()
	..()
	if(inoperable())
		if(SSmachines.optimize_machinery_event)
			return PROCESS_KILL
		return
	if(!active)
		if(SSmachines.optimize_machinery_event)
			return PROCESS_KILL
		return
	var/desiredir = transform.get_angle() > 0 ? NORTH : SOUTH
	if(dir != desiredir)
		set_dir(desiredir)
	if(engaging || ((world.time - last_shot) < charge_cooldown))
		if(SSmachines.optimize_machinery_event)
			schedule_event_heartbeat()
			return PROCESS_KILL
		return

	if(emagged)
		if(SSmachines.optimize_machinery_event)
			return PROCESS_KILL
		return

	var/obj/machinery/pointdefense_control/PC = get_controller()
	if(!istype(PC))
		if(SSmachines.optimize_machinery_event)
			return PROCESS_KILL
		return

	var/list/already_targeted = list()
	for(var/i = length(PC.targets) to 1 step -1)
		var/weakref/WR = PC.targets[i]
		var/obj/meteor/current_target = WR.resolve()
		if(!istype(current_target))
			PC.targets.Cut(i, i + 1)
			continue
		already_targeted[current_target] = TRUE

	var/list/connected_zlevels = GetConnectedZlevels(z)
	var/list/candidates = SSmachines.optimize_machinery_event ? pending_targets.Copy() : GLOB.meteor_list

	for(var/obj/meteor/M in candidates)
		if(!istype(M))
			pending_targets -= M
			continue
		if(already_targeted[M])
			pending_targets -= M
			continue

		if(!(M.z in connected_zlevels))
			continue
		if(get_dist(M, src) > kill_range)
			continue

		if (!can_see(src, M, kill_range))
			continue

		if(space_los(M))
			var/weakref/target = weakref(M)
			PC.targets += target
			pending_targets -= M
			Shoot(target)
			return

	if(SSmachines.optimize_machinery_event)
		if(length(pending_targets))
			schedule_event_heartbeat()
		return PROCESS_KILL

/obj/machinery/pointdefense/RefreshParts()
	. = ..()
	// Calculates an average rating of components that affect shooting rate
	var/shootrate_divisor = total_component_rating_of_type(/obj/item/stock_parts/capacitor)

	charge_cooldown = 2 SECONDS / (shootrate_divisor ? shootrate_divisor : 1)

	//Calculate max shooting range
	var/killrange_multiplier = total_component_rating_of_type(/obj/item/stock_parts/capacitor)
	killrange_multiplier += 1.5 * total_component_rating_of_type(/obj/item/stock_parts/scanning_module)

	kill_range = 10 + 4 * killrange_multiplier

	var/rotation_divisor = total_component_rating_of_type(/obj/item/stock_parts/manipulator)
	rotation_speed = 0.5 SECONDS / (rotation_divisor ? rotation_divisor : 1)

/obj/machinery/pointdefense/proc/Activate()
	if(active)
		return FALSE

	active = TRUE
	queue_event_processing()
	return TRUE

/obj/machinery/pointdefense/proc/Deactivate()
	if(!active)
		return FALSE
	playsound(src, 'sound/machines/apc_nopower.ogg', 50, 0)
	active = FALSE
	queue_event_processing()
	return TRUE
