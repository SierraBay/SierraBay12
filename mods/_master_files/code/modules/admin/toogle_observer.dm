/datum/admins/proc/toggleobserverjoin()
	set category = "Server"
	set desc="People can't join as observers"
	set name="Toggle Observe"
	config.observer_spawn_allowed = !(config.observer_spawn_allowed)
	log_and_message_admins("toggled new player observer joining to [config.observer_spawn_allowed ? "On" : "Off"].")
