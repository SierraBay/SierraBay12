// Because telecoms code is dumb and hardcoded to require an origin mob and radio. This will just exist inside things that are broadcasting legion messages across a radio net.
/mob/legion_broadcaster
	name = "legion"

	/// Broadcaster radio this mob uses. Created during init.
	var/obj/item/device/radio/broadcaster

	/// List of frequencies this device will broadcast on.
	var/list/frequencies = list()

	/// List of default frequencies the device will use if no tcomms servers are found.
	var/static/list/default_frequencies = list(
		PUB_FREQ,
		HAIL_FREQ
	)


/mob/legion_broadcaster/Initialize()
	. = ..()
	broadcaster = new(src)
	broadcaster.SetName("legion broadcaster")
	broadcaster.power_usage = FALSE
	broadcaster.listening = FALSE
	broadcaster.on = TRUE
	resync_frequencies()


/mob/legion_broadcaster/Destroy()
	QDEL_NULL(broadcaster)
	frequencies.Cut()
	return ..()


/mob/legion_broadcaster/SetName(new_name)
	name = new_name
	real_name = new_name


/mob/legion_broadcaster/proc/resync_frequencies()
	frequencies.Cut()

	for (var/obj/machinery/telecomms/server in telecomms_list)
		if (!AreConnectedZLevels(get_z(src), get_z(server)))
			continue
		frequencies |= server.freq_listening

	if (!length(frequencies))
		frequencies = default_frequencies


/mob/legion_broadcaster/proc/legion_broadcast(origin, message)
	SetName(origin)
	for (var/frequency in frequencies)
		broadcaster.set_frequency(frequency)
		do_message(message)
	SetName("")


/mob/legion_broadcaster/proc/do_message(message)
	set waitfor = FALSE
	broadcaster.talk_into(src, message, null, null, all_languages["Noise"])
