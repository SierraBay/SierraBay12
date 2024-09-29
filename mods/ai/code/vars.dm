/mob/living/silicon
	var/list/datum/alarm/queued_alarms = new()
	var/next_alarm_notice = 0

/mob/living/silicon/ai
	var/obj/machinery/computer/modular/ai/internal_computer = new /obj/machinery/computer/modular/preset/engineering

/obj/machinery/computer/ship/sensors
	//Синтетики могут смотреть на сенсоры
	silicon_restriction = STATUS_INTERACTIVE

/datum/turret_checks
	var/attack_robots
	var/hold_deployed


/obj/machinery/porta_turret
	///Туррель будет атаковать и роботов
	var/attack_robots = 0
	var/hold_deployed = 0

/obj/machinery/turretid
	///Туррель будет атаковать и роботов
	var/attack_robots = 0
	var/hold_deployed = 0
