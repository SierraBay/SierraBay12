/obj/item/mech_component/chassis
	var/list/back_passengers_positions
	var/list/left_back_passengers_positions
	var/list/right_back_passengers_positions
	var/allow_passengers = TRUE
	var/hatch_bolts_status = BOLTS_NOMITAL

/obj/item/mech_component/chassis/powerloader
	max_damage = 150

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
	max_damage = 120

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
	max_damage = 700

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
	max_damage = 270

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
