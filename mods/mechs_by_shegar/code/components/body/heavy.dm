/obj/item/mech_component/chassis/heavy
	name = "reinforced exosuit chassis"
	desc = "The HI-Koloss chassis is a veritable juggernaut, capable of protecting a pilot even in the most hostile of environments. It handles like a battlecruiser, however."
	hatch_descriptor = "hatch"
	pilot_coverage = 100
	exosuit_desc_string = "a heavily armoured chassis"
	icon_state = "heavy_body"
	power_use = 50
	has_hardpoints = list(HARDPOINT_BACK)
	max_hp = 500
	mech_health = 500
	max_repair = 150
	min_damage = 300
	repair_damage = 30
	hide_pilot = TRUE
	req_material = MATERIAL_PLASTEEL
	have_fast_power_up = TRUE
	back_modificator_damage = 4
	front_modificator_damage = 0.5
	max_heat = 300
	heat_cooling = 4
	emp_heat_generation = 100
	weight = 800

/obj/item/mech_component/chassis/heavy/prebuild()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = 8),
			"[SOUTH]" = list("x" = 9,  "y" = 2),
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

/obj/item/mech_component/chassis/heavy/prebuild()
	. = ..()
	m_armour = new /obj/item/robot_parts/robot_component/armour/exosuit/combat(src)
