/obj/machinery/porta_turret/
	var/neuron_activation = FALSE

/obj/machinery/porta_turret/Initialize()
	. = ..()
	update_watch_area()

/obj/machinery/porta_turret/Destroy()
	unregister_turret_view(src)
	. = ..()

/obj/machinery/porta_turret/update_watch_area()
	if(!enabled || MACHINE_IS_BROKEN(src))
		unregister_turret_view(src)
		return

	var/list/view_turfs = view(world.view, src)
	register_turret_view(src, TURRET_WATCH_MOBS, view_turfs)

	. = ..()

/obj/machinery/porta_turret/wake_up()
	if(!neuron_activation)
		neuron_activation = TRUE
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

	. = ..()

/obj/machinery/porta_turret/proc/hibernate()
	if(neuron_activation)
		neuron_activation = FALSE
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/porta_turret/Process()
	if(!neuron_activation)
		return PROCESS_KILL

	. = ..()

	// last_target is set when the turret finds a target and starts deploying/shooting.
	// It is cleared in popDown() when it decides to stop.
	// We check it to avoid hibernating while the turret is in the middle of a spawned popUp() call.
	if(!raised && !raising && !last_target)
		hibernate()

/obj/machinery/porta_turret/Topic(href, href_list)
	. = ..()
	if(. && href_list["command"] == "enable")
		update_watch_area()
