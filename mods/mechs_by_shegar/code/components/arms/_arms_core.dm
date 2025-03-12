/obj/item/mech_component/manipulators
	name = "powerloader mech arm"
	pixel_y = -12
	//icon_state должен указываться без приписки left или right
	icon_state = "loader_arm"
	has_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)

	var/punch_sound = 'sound/mecha/mech_punch.ogg'
	var/melee_damage = 20
	var/action_delay = 15
	var/side = LEFT
	var/obj/item/robot_parts/robot_component/actuator/motivator
	power_use = 10
	w_class = ITEM_SIZE_LARGE
	///Могут ли пассажиры занимать Left back и Right back (боковые пассажирские места)?
	var/allow_passengers = TRUE

/obj/item/mech_component/manipulators/Initialize()
	. = ..()
	setup_side()

/obj/item/mech_component/manipulators/proc/setup_side()
	if(side == LEFT)
		icon_state = "[initial(icon_state)]_left"
		name = "left [initial(name)]"
	else if(side == RIGHT)
		icon_state = "[initial(icon_state)]_right"
		name = "right [initial(name)]"

/obj/item/mech_component/manipulators/Destroy()
	QDEL_NULL(motivator)
	. = ..()

/obj/item/mech_component/manipulators/show_missing_parts(mob/user)
	if(!motivator)
		to_chat(user, SPAN_WARNING("It is missing an actuator."))

/obj/item/mech_component/manipulators/ready_to_install()
	return motivator

/obj/item/mech_component/manipulators/prebuild()
	motivator = new(src)
	update_parts_images()

/obj/item/mech_component/manipulators/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if(istype(thing,/obj/item/robot_parts/robot_component/actuator))
		if(motivator)
			to_chat(user, SPAN_WARNING("\The [src] already has an actuator installed."))
			return TRUE
		if(install_component(thing, user))
			motivator = thing
			return TRUE
	else
		return ..()

/obj/item/mech_component/manipulators/update_components()
	motivator = locate() in src
	update_parts_images()

/obj/item/mech_component/manipulators/get_damage_string()
	if(!motivator || !motivator.is_functional())
		return SPAN_DANGER("disabled")
	return ..()

/obj/item/mech_component/manipulators/return_diagnostics(mob/user)
	..()
	if(motivator)
		to_chat(user, SPAN_NOTICE(" Actuator Integrity: <b>[round((((motivator.max_dam - motivator.total_dam) / motivator.max_dam)) * 100)]%</b>"))
	else
		to_chat(user, SPAN_WARNING(" Actuator Missing or Non-functional."))

/obj/item/mech_component/manipulators/update_parts_images()
	var/list/parts_to_show = list()
	if(motivator)
		parts_to_show += motivator
	internal_parts_list_images = make_item_radial_menu_choices(parts_to_show)
