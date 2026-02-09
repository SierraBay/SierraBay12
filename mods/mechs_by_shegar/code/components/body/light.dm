/obj/item/mech_component/chassis/light
	name = "light exosuit chassis"
	desc = "The Veymed Odysseus series cockpits combine ultralight materials and clear aluminum laminates to provide an optimized cockpit experience."
	transparent_cabin =  TRUE
	exosuit_desc_string = "an open and light chassis"
	icon_state = "light_body"
	has_hardpoints = list(HARDPOINT_BACK, HARDPOINT_LEFT_SHOULDER)
	damage_sound = 'sound/effects/glass_crack1.ogg'
	power_use = 5
	pilot_coverage = 100
	climb_time = 15

	matter = list(MATERIAL_STEEL = 100000, MATERIAL_ALUMINIUM = 20000, MATERIAL_PLASTIC = 10000)

	max_hp = 75
	min_damage = 30
	max_repair = 50
	repair_damage = 15
	front_modificator_damage = 1

	hide_pilot = TRUE
	req_material = MATERIAL_ALUMINIUM
	//Тепло
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 110

	weight = 100

/obj/item/mech_component/chassis/light/Initialize()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = 0),
			"[SOUTH]" = list("x" = 8,  "y" = 0),
			"[EAST]"  = list("x" = 3,  "y" = 0),
			"[WEST]"  = list("x" = 13, "y" = 0)
		)
	)
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
	. = ..()
