GLOBAL_LIST_EMPTY(all_observable_events)

// True if net rebuild will be called manually after an event.
//GLOBAL_VAR_AS(defer_powernet_rebuild, FALSE) //[SIERRA-REMOVE]

// Those networks can only be accessed by pre-existing terminals. AIs and new terminals can't use them.
GLOBAL_LIST_AS(restricted_camera_networks, list(\
	NETWORK_ERT,\
	NETWORK_MERCENARY,\
	NETWORK_CRESCENT,\
	"Secret"\
))

GLOBAL_VAR_AS(stat_flags_planted, 0)

GLOBAL_VAR_AS(stat_flora_scanned, 0)

GLOBAL_LIST_EMPTY(stat_fauna_scanned)

GLOBAL_VAR_AS(extracted_slime_cores_amount, 0)

GLOBAL_VAR_AS(crew_death_count, 0)
