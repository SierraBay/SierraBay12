/datum/admins/proc/toggleobserverjoin()
	set category = "Server"
	set desc="People can't join as observers"
	set name="Toggle Observe"
	config.observer_spawn_allowed = !(config.observer_spawn_allowed)
	if (!(config.observer_spawn_allowed))
		to_world("New players may no longer join as observers.")
	else
		to_world("New players may now join as observers.")
	log_and_message_admins("toggled new player observer joining to [config.observer_spawn_allowed ? "On" : "Off"].")
