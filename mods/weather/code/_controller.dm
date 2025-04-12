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
	var/list/mobs_effected_by_weather = list()
	///Очередь из погоды которая ожидает изменение своего состояния. Позволяет погоде менятся менее лагучим образом.
	var/list/changing_weather_queue = list()
	///Очередь из воды Титана которая ожидает изменение своего состояния (углубление или уменьшение глубины). Позволяет воде менятся менее лагучим образом.
	var/list/water_changing_queue = list()
	//Сколько турфов будет обработано за 1 процессинг контроллера. Чем больше тем быстрее выполняется очередь, но может сильней влиять на производительность игры.
	var/changing_tufs_per_time = 10

/datum/controller/subsystem/processing/weather/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"\
		weather turfs amount:    [LAZYLEN(weather_turf_in_world)]  \
		weather controllers amount: [LAZYLEN(weather_managers_in_world)]
	"})

/datum/controller/subsystem/processing/weather/fire(resumed)
	if(LAZYLEN(water_changing_queue))
		process_water_changes()
	for(var/datum/weather_manager/manager in weather_managers_in_world)
		manager.Process()
	if (MC_TICK_CHECK)
		return

//ВОДИЧКА
/datum/controller/subsystem/processing/weather/proc/add_to_water_queue(turf/simulated/floor/exoplanet/titan_water/water, direction)
	if(!water || !direction)
		return
	water_changing_queue[water] = direction

/datum/controller/subsystem/processing/weather/proc/process_water_changes()
	if(LAZYLEN(water_changing_queue))
		var/will_be_checked_turfs = changing_tufs_per_time
		while(will_be_checked_turfs != 0)
			//Если мы опустошили очередь но WHILE всё ещё пашет
			if(!LAZYLEN(water_changing_queue))
				return
			var/turf/simulated/floor/exoplanet/titan_water/water = pick(water_changing_queue)
			var/direction = water_changing_queue[water]
			switch(direction)
				if("up")
					water.get_better()
				if("easiest")
					water.get_easiest()
			will_be_checked_turfs--
			water_changing_queue -= water
