//SSweather
PROCESSING_SUBSYSTEM_DEF(weather)
	name = "Weather"
	priority = SS_PRIORITY_TURF
	init_order = SS_INIT_DEFAULT
	flags = SS_BACKGROUND
	//

	var/list/weather_turf_in_world = list()
	var/list/weather_managers_in_world = list()
	var/list/aurora_sctructures = list()

/datum/controller/subsystem/processing/weather/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"\
		weather turfs amount:    [LAZYLEN(weather_turf_in_world)]  \
		weather controllers amount: [LAZYLEN(weather_managers_in_world)]
	"})
