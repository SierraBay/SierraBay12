//SSanom
PROCESSING_SUBSYSTEM_DEF(anom)
	name = "Anomalys"
	priority = SS_PRIORITY_DEFAULT
	init_order = SS_INIT_DEFAULT
	flags = SS_BACKGROUND



	var/list/all_anomalies = list()
	var/anomalies_ammount_in_world = 0
	var/added_ammount = 0
	var/removed_ammount = 0

/datum/controller/subsystem/processing/anom/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"\
		anomalies in world:    [anomalies_ammount_in_world]  \
		added times:    [added_ammount]  \
		removed timest: [removed_ammount]  \
	"})

/datum/controller/subsystem/processing/anom/Initialize(start_uptime)
	anomalies_init()


/datum/controller/subsystem/processing/anom/proc/anomalies_init()

/datum/controller/subsystem/processing/anom/proc/add_anomaly_in_list(obj/anomaly/input)
	LAZYADD(all_anomalies, input)
	added_ammount++
	anomalies_ammount_in_world++

/datum/controller/subsystem/processing/anom/proc/remove_anomaly_from_list(obj/anomaly/input)
	LAZYREMOVE(all_anomalies, input)
	removed_ammount++
	anomalies_ammount_in_world--
