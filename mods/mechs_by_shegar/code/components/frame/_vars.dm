/obj/structure/heavy_vehicle_frame
	name = "exosuit frame"
	desc = "The frame for an exosuit, apparently."
	icon = 'mods/mechs_by_shegar/icons/mech_parts.dmi'
	icon_state = "backbone"
	density = TRUE
	pixel_x = -8
	atom_flags = ATOM_FLAG_CAN_BE_PAINTED

	// Holders for the final product.
	var/obj/item/mech_component/sensors/head
	var/obj/item/mech_component/chassis/body
	var/obj/item/mech_component/manipulators/L_arm
	var/obj/item/mech_component/manipulators/R_arm
	var/obj/item/mech_component/propulsion/L_leg
	var/obj/item/mech_component/propulsion/R_leg
	var/is_wired = 0
	var/is_reinforced = 0
	var/set_name
	dir = SOUTH
