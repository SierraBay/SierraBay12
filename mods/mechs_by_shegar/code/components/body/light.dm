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
	max_hp = 80
	min_damage = 50
	max_repair = 40
	repair_damage = 20
	hide_pilot = TRUE
	req_material = MATERIAL_ALUMINIUM
	back_modificator_damage = 1.3
	front_modificator_damage = 1
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 80
	weight = 200

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

/obj/item/mech_component/chassis/light/prebuild()
	. = ..()
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/radproof(src)
