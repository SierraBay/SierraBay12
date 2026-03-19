/obj/machinery/pointdefense/
	var/neuron_activation = FALSE

/obj/machinery/pointdefense/Initialize()
	. = ..()
	update_watch_area()

/obj/machinery/pointdefense/Destroy()
	unregister_turret_view(src)
	. = ..()

/obj/machinery/pointdefense/update_watch_area()
	if(!active || MACHINE_IS_BROKEN(src))
		unregister_turret_view(src)
		return

	var/list/view_turfs = list()
	for(var/turf/T in range(kill_range, src))
		if(can_see(src, T, kill_range))
			view_turfs += T

	register_turret_view(src, TURRET_WATCH_METEORS, view_turfs)

	. = ..()

/obj/machinery/pointdefense/wake_up()
	if(!neuron_activation)
		neuron_activation = TRUE
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

	. = ..()

/obj/machinery/pointdefense/proc/hibernate()
	if(neuron_activation)
		neuron_activation = FALSE
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/pointdefense/Process()
	if(!neuron_activation)
		return PROCESS_KILL

	. = ..()

	// PD should stay awake if it's currently shooting or on cooldown waiting for the next shot.
	// We add a small buffer (5 ticks) to ensures it doesn't hibernate exactly when the cooldown ends,
	// giving it one more Process() cycle to find new targets.
	if(!engaging && (world.time - last_shot) > (charge_cooldown + 5))
		hibernate()

/obj/machinery/pointdefense/RefreshParts()
	. = ..()
	update_watch_area()

/obj/machinery/pointdefense/Activate()
	. = ..()
	if(.)
		update_watch_area()

/obj/machinery/pointdefense/Deactivate()
	. = ..()
	if(.)
		update_watch_area()

/obj/machinery/pointdefense/Topic(href, href_list)
	. = ..()
	if(. && href_list["active"])
		update_watch_area()
