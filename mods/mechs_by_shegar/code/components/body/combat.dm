/obj/item/mech_component/chassis/combat
	name = "sealed exosuit chassis"
	pilot_coverage = 100
	exosuit_desc_string = "an armoured chassis"
	icon_state = "combat_body"
	power_use = 40

	max_hp = 150
	min_damage = 100
	max_repair = 60
	repair_damage = 30

	hide_pilot = TRUE
	front_modificator_damage = 1

	matter = list(MATERIAL_STEEL = 135000, MATERIAL_PLASTEEL = 10000, MATERIAL_ALUMINIUM = 40000)

	max_heat = 200
	heat_cooling = 8
	emp_heat_generation = 150

	weight = 200

/obj/item/mech_component/chassis/combat/Initialize()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = 8),
			"[SOUTH]" = list("x" = 8,  "y" = 8),
			"[EAST]"  = list("x" = 4,  "y" = 8),
			"[WEST]"  = list("x" = 12, "y" = 8)
		)
	)
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
