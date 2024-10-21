/obj/item/mech_component/chassis
	var/list/back_passengers_positions
	var/list/left_back_passengers_positions
	var/list/right_back_passengers_positions
	///Могут ли пассажиры занимать пассажирское место Back?
	var/allow_passengers = TRUE
	///Отвечает за состояние болтов кабины. Их можно срезать сваркой, если мех закрыт. После этого мех никогда не сможет вновь опустить болты, ибо их попросту нет.
	var/hatch_bolts_status = BOLTS_NOMITAL
	///НЕ ТРОГАТЬ. Даёт возможность меху проходить сквозь турфы
	var/phazon = FALSE
	///Холден, когда в последний раз проводили очистку атмосферы в мехе
	var/last_atmos_cleared = 0
	///КД на очистку, дабы пользователь не нагружал по приколу игру.
	var/atmos_clear_cooldown = 60 SECONDS
	///Статус очистки. TRUE - она идёт. FALSE - не идёт
	var/atmos_clear_status = FALSE
	///Отвечает за возможность меха быстро стартовать за счёт определённых штрафов
	var/have_fast_power_up = FALSE
	///Время перегрева меха
	var/overheat_time = 10 SECONDS
	///Куллдаун для обработки тепла.
	var/heat_process_speed = 2 SECONDS


/obj/item/mech_component/chassis/proc/atmos_clear_protocol(mob/living/user)
	//Проверка куллдауна
	if((world.time - last_atmos_cleared) < atmos_clear_cooldown)
		to_chat(user,"Not so often!")
		return
	to_chat(user,"Atmos clear protocol initiated.")
	last_atmos_cleared = world.time
	qdel(cockpit)
	cockpit = new
	var/good_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)
	cockpit.gas = good_gas
	cockpit.temperature = 293.152

	//air_contents

/obj/item/mech_component/chassis/powerloader
	max_damage = 100
	min_damage = 75
	max_repair = 50
	repair_damage = 25
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 15
	emp_heat_generation = 100
	weight = 300

/obj/item/mech_component/chassis/powerloader/Initialize()
	back_passengers_positions = list(
			"[NORTH]" = list("x" = 8,  "y" = 16),
			"[SOUTH]" = list("x" = 8,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	left_back_passengers_positions = list(
			"[NORTH]" = list("x" = -4,  "y" = 16),
			"[SOUTH]" = list("x" = 20,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	right_back_passengers_positions = list(
			"[NORTH]" = list("x" = 20,  "y" = 16),
			"[SOUTH]" = list("x" = -4,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	.=..()

/obj/item/mech_component/chassis/light
	max_damage = 80
	min_damage = 50
	max_repair = 40
	repair_damage = 20
	hide_pilot = TRUE
	req_material = MATERIAL_ALUMINIUM
	have_fast_power_up = TRUE
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 80
	weight = 200

/obj/item/mech_component/chassis/light/Initialize()
	back_passengers_positions = list(
			"[NORTH]" = list("x" = 8,  "y" = 16),
			"[SOUTH]" = list("x" = 8,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	left_back_passengers_positions = list(
			"[NORTH]" = list("x" = -2,  "y" = 16),
			"[SOUTH]" = list("x" = 16,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	right_back_passengers_positions = list(
			"[NORTH]" = list("x" = 16,  "y" = 16),
			"[SOUTH]" = list("x" = -2,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	.=..()

/obj/item/mech_component/chassis/pod
	max_damage = 210
	max_repair = 50
	min_damage = 110
	repair_damage = 30
	have_fast_power_up = TRUE
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 5
	emp_heat_generation = 100
	weight = 400

/obj/item/mech_component/chassis/pod/Initialize()
	back_passengers_positions = list(
			"[NORTH]" = list("x" = 8,  "y" = 16),
			"[SOUTH]" = list("x" = 8,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	left_back_passengers_positions = list(
			"[NORTH]" = list("x" = -4,  "y" = 16),
			"[SOUTH]" = list("x" = 20,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	right_back_passengers_positions = list(
			"[NORTH]" = list("x" = 20,  "y" = 16),
			"[SOUTH]" = list("x" = -4,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	.=..()

/obj/item/mech_component/chassis/heavy
	max_damage = 500
	max_repair = 150
	min_damage = 300
	repair_damage = 30
	hide_pilot = TRUE
	req_material = MATERIAL_PLASTEEL
	have_fast_power_up = TRUE
	back_modificator_damage = 1.3
	front_modificator_damage = 0.7
	max_heat = 300
	heat_cooling = 4
	emp_heat_generation = 100
	weight = 800

/obj/item/mech_component/chassis/heavy/Initialize()
	back_passengers_positions = list(
			"[NORTH]" = list("x" = 8,  "y" = 16),
			"[SOUTH]" = list("x" = 8,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	left_back_passengers_positions = list(
			"[NORTH]" = list("x" = -4,  "y" = 16),
			"[SOUTH]" = list("x" = 20,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	right_back_passengers_positions = list(
			"[NORTH]" = list("x" = 20,  "y" = 16),
			"[SOUTH]" = list("x" = -4,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	. = ..()

/obj/item/mech_component/chassis/combat
	max_damage = 180
	min_damage = 100
	max_repair = 60
	repair_damage = 30
	hide_pilot = TRUE
	have_fast_power_up = TRUE
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 100
	weight = 500

/obj/item/mech_component/chassis/combat/Initialize()
	back_passengers_positions = list(
			"[NORTH]" = list("x" = 8,  "y" = 16),
			"[SOUTH]" = list("x" = 8,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	left_back_passengers_positions = list(
			"[NORTH]" = list("x" = -4,  "y" = 16),
			"[SOUTH]" = list("x" = 20,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	right_back_passengers_positions = list(
			"[NORTH]" = list("x" = 20,  "y" = 16),
			"[SOUTH]" = list("x" = -4,  "y" = 16),
			"[EAST]"  = list("x" = -4, "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
			)
	. = ..()
