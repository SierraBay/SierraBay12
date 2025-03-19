/obj/item/mech_component/doubled_legs
	var/R_leg_type = /obj/item/mech_component/propulsion/powerloader
	var/L_leg_type = /obj/item/mech_component/propulsion/powerloader
	var/obj/item/mech_component/propulsion/R_stored_leg
	var/obj/item/mech_component/propulsion/L_stored_leg
	//Компоненты внутри сдвоенной части меха (ноги/руки)
	var/list/parts_list_images = list()

/obj/item/mech_component/doubled_legs/Initialize()
	. = ..()
	if(!R_stored_leg)
		R_stored_leg = new R_leg_type(src)
		R_stored_leg.doubled_owner = src
	if(!L_stored_leg)
		L_stored_leg = new L_leg_type(src)
		L_stored_leg.doubled_owner = src
	parts_list_images = make_item_radial_menu_choices(list(R_stored_leg, L_stored_leg))

/obj/item/mech_component/doubled_legs/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(istype(thing,/obj/item/robot_parts/robot_component/actuator))
		var/obj/item/mech_component/propulsion/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
		if(choosed_part.motivator)
			to_chat(user, SPAN_WARNING("\The [src] already has an actuator installed."))
			return TRUE
		if(choosed_part.install_component(thing, user))
			choosed_part.motivator = thing
			return TRUE
	else
		return ..()

/obj/item/mech_component/doubled_legs/material_interaction(obj/item/stack/material/input_material, mob/user)
	var/obj/item/mech_component/propulsion/choosed_leg = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	choosed_leg.material_interaction(input_material, user)

/obj/item/mech_component/doubled_legs/screwdriver_interaction(mob/living/user)
	var/obj/item/mech_component/propulsion/choosed_leg = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	choosed_leg.screwdriver_interaction(user)

/obj/item/mech_component/doubled_legs/welder_interacion(obj/item/thing, mob/user)
	var/obj/item/mech_component/propulsion/choosed_leg = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	choosed_leg.welder_interacion(thing, user)

/obj/item/mech_component/doubled_legs/spider
	name = "spiderlegs"
	desc = "Xion Industrial's arachnid series boasts more leg per leg than the leading competitor."
	icon_state = "spiderlegs_both"
	R_leg_type = /obj/item/mech_component/propulsion/spider/right
	L_leg_type = /obj/item/mech_component/propulsion/spider

/obj/item/mech_component/doubled_legs/tracks
	name = "armored tracks"
	desc = "A classic brought back. The Hephaestus' Landmaster class tracks are impervious to most damage and can maintain top speed regardless of load. Watch out for corners."
	icon_state = "tracks_both"
	R_leg_type = /obj/item/mech_component/propulsion/tracks/right
	L_leg_type = /obj/item/mech_component/propulsion/tracks
