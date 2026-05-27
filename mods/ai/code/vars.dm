/obj/machinery/law_rack
	var/rack_network = "default"
	var/allow_roundstart_fallback = TRUE

/mob/living/silicon

/mob/living/silicon/ai
	var/obj/machinery/computer/modular/internal_computer = new /obj/machinery/computer/modular/preset/engineering
	var/obj/machinery/law_rack/law_rack = null
	var/law_rack_network = "default"

/obj/machinery/computer/modular/preset/sensors
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
