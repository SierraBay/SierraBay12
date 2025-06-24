/obj/machinery/appliance/mixer
	max_contents = 1
	use_power = POWER_USE_OFF
	cooking_coeff = 0.75
	cooking = FALSE
	active_power_usage = 3000
	idle_power_usage = 50
	appliancetype = 0

/obj/machinery/appliance/mixer/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		to_chat(user, SPAN_NOTICE("It is currently set to make a [selected_option]"))

/obj/machinery/appliance/mixer/Initialize()
	. = ..()
	cooking_objs += new /datum/cooking_item(new /obj/item/reagent_containers/cooking_container(src))
	selected_option = pick(output_options)
	update_cooking_power()

//Mixers cannot-not do combining mode. So the default option is removed from this. A combine target must be chosen
/obj/machinery/appliance/mixer/choose_output()
	set src in oview(1)
	set name = "Choose Output"
	set category = "Object"

	if (use_check_and_message(usr))
		return

	if(!length(output_options))
		return
	var/choice = input("What specific food do you wish to make with [src]?", "Choose Output") as null|anything in output_options
	if(!choice)
		return
	selected_option = choice
	to_chat(usr, SPAN_NOTICE("You set [src] to make \a [selected_option]."))
	var/datum/cooking_item/CI = cooking_objs[1]
	CI.combine_target = selected_option

/obj/machinery/appliance/mixer/has_space(obj/item/I)
	var/datum/cooking_item/CI = cooking_objs[1]
	if (!CI || !CI.container)
		return FALSE

	if (CI.container.can_fit(I))
		return CI

	return FALSE

/obj/machinery/appliance/mixer/can_remove_items(mob/user)
	if (!operating)
		return ..()
	to_chat(user, SPAN_WARNING("You can't remove ingredients while [src] is turned on! Turn it off first or wait for it to finish."))
	return FALSE

//Container is not removable
/obj/machinery/appliance/mixer/removal_menu(mob/user)
	if (!can_remove_items(user))
		return FALSE
	var/list/menuoptions = list()
	for (var/cooking_obj in cooking_objs)
		var/datum/cooking_item/CI = cooking_obj
		if (CI.container?.check_contents() == COOKING_CONTAINER_EMPTY)
			to_chat(user, "There's nothing in [src] to remove!")
			return
		for (var/thing in CI.container)
			var/obj/item/I = thing
			menuoptions[I.name] = I

	var/selection = show_radial_menu(user, src, menuoptions, require_near = TRUE, tooltips = TRUE, no_repeat_close = TRUE)
	if (!selection)
		return FALSE
	var/obj/item/I = menuoptions[selection]
	if (!user?.put_in_hands(I))
		I.forceMove(get_turf(src))
	update_icon()
	return TRUE

/obj/machinery/appliance/mixer/attempt_toggle_power(mob/user)
	. = ..(user)
	if(!use_power)
		return
	var/list/missing = missing_parts()
	if(missing)
		return
	for(var/i in cooking_objs)
		var/datum/cooking_item/CI = i
		CI.combine_target = selected_option
	get_cooking_work(cooking_objs[1])

/obj/machinery/appliance/mixer/can_insert(obj/item/I, mob/user)
	if (operating)
		to_chat(user, SPAN_WARNING("You can't add items while [src] is running. Wait for it to finish or turn the power off to abort"))
		return FALSE
	return ..()

/obj/machinery/appliance/mixer/finish_cooking(datum/cooking_item/CI)
	..()
	playsound(src, 'sound/machines/click.ogg', 40, 1)
	update_use_power(POWER_USE_OFF)
	CI.reset()
	update_icon()

/obj/machinery/appliance/mixer/Process()
	if (operating)
		for (var/i in cooking_objs)
			do_cooking_tick(i)
