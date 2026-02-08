/obj/item/mech_component/chassis/pod
	name = "spherical exosuit chassis"
	desc = "The NanoTrasen Katamari series cockpits have won a massive tender by SCG few years back. No one is sure why, but these terrible things keep popping up on every government facility."
	pilot_coverage = 100
	transparent_cabin = TRUE
	exosuit_desc_string = "a spherical chassis"
	icon_state = "pod_body"
	has_hardpoints = list(HARDPOINT_BACK)
	power_use = 5

	matter = list(MATERIAL_STEEL = 54000, MATERIAL_ALUMINIUM = 10000, MATERIAL_PLASTIC = 10000)

	max_hp = 100
	max_repair = 80
	min_damage = 30
	repair_damage = 20
	front_modificator_damage = 1

	max_heat = 200
	heat_cooling = 5
	emp_heat_generation = 100

	weight = 200

/obj/item/mech_component/chassis/pod/Initialize()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = 4),
			"[SOUTH]" = list("x" = 8,  "y" = 4),
			"[EAST]"  = list("x" = 12,  "y" = 4),
			"[WEST]"  = list("x" = 4,  "y" = 4)
		),
		list(
			"[NORTH]" = list("x" = 8,  "y" = 8),
			"[SOUTH]" = list("x" = 8,  "y" = 8),
			"[EAST]"  = list("x" = 10,  "y" = 8),
			"[WEST]"  = list("x" = 6, "y" = 8)
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
