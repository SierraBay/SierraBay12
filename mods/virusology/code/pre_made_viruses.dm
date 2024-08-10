///Premade Viruses
/datum/disease2/disease/cold
	infectionchance = 50//very aggressive
	speed = 1
	spreadtype = "Airborne"
	max_stage = 3


/datum/disease2/disease/cold/New()
	..()
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	effects += E1
	var/datum/disease2/effect/fridge/E2 = new()
	E2.stage = 2
	effects += E2
	var/datum/disease2/effect/shakey/E3 = new()
	E3.stage = 3
	effects += E3
