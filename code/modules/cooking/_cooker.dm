/obj/machinery/appliance/cooker
	var/min_temp = 80 + T0C	//Minimum temperature to do any cooking
	var/optimal_temp = 200 + T0C	//Temperature at which we have 100% efficiency. efficiency is lowered on either side of this
	var/optimal_power = 1.1//cooking power at 100%
	var/set_temp = 200 + T0C
	var/temp_settings = 4 // the number of temperature settings to have, including min and optimal
	var/list/temp_options = list()

	var/loss = 1	//Temp lost per proc when equalising
	var/resistance = 320000	//Resistance to heating. combines with heating power to determine how long heating takes

	var/light_x = 0
	var/light_y = 0
	mobdamagetype = DAMAGE_BURN
	cooking_coeff = 0
	cooking_power = 0
	var/starts_with = list()

/obj/machinery/appliance/cooker/examine(mob/user, distance)
	. = ..()
	if (distance <= 1)
		if (operating)
			if (temperature < min_temp)
				to_chat(user, SPAN_WARNING("[src] is still heating up and is too cold to cook anything yet."))
			else
				to_chat(user, SPAN_NOTICE("It is running at [round(get_efficiency(), 0.1)]% efficiency!"))
			to_chat(user, "Temperature: [round(temperature - T0C, 0.1)]C / [round(optimal_temp - T0C, 0.1)]C")
		else
			to_chat(user, SPAN_WARNING("It is switched off."))

/obj/machinery/appliance/cooker/MouseEntered(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && get_dist(usr, src) <= 2)
		params = replacetext(params, "shift=1;", "") // tooltip doesn't appear unless this is stripped
		var/description = ""
		if(!length(cooking_objs))
			description = "It is empty."
		else
			description = "Contains...<ul>"
			for(var/datum/cooking_item/CI in cooking_objs)
				description += "<li>\a [CI.container.label(null, CI.combine_target)], [report_progress(CI)]</li>"
			description += "</ul>"
		if(operating)
			if(temperature < min_temp)
				description += "[src] is still heating up and is too cold to cook anything yet."
			else
				description += "It is running at [round(get_efficiency(), 0.1)]% efficiency!"
			description += "<br>Temperature: [round(temperature - T0C, 0.1)]C / [round(optimal_temp - T0C, 0.1)]C"
		else
			description += "It is switched off."
		openToolTip(usr, src, params, name, description)

/obj/machinery/appliance/cooker/MouseExited(location, control, params)
	. = ..()
	closeToolTip(usr)

/obj/machinery/appliance/cooker/list_contents(mob/user)
	if (length(cooking_objs))
		var/string = "Contains...</br>"
		var/num = 0
		for (var/atom in cooking_objs)
			var/datum/cooking_item/cooking_item = atom
			num++
			if (cooking_item && cooking_item.container)
				string += "- [cooking_item.container.label(num)], [report_progress(cooking_item)]</br>"
		to_chat(usr, string)
	else
		to_chat(usr, SPAN_NOTICE("It's empty."))

/obj/machinery/appliance/cooker/proc/get_efficiency()
	. = (cooking_power / optimal_power) * 100

/obj/machinery/appliance/cooker/Initialize(mapload)
	. = ..()
	var/interval = (optimal_temp - min_temp)/temp_settings
	for(var/newtemp = min_temp - interval, newtemp<=optimal_temp, newtemp+=interval)
		var/image/disp_image = image('icons/screen/radial.dmi', "radial_temp")
		var/hue = RotateHue(hsv(0, 255, 255), 120 * (1 - (newtemp-min_temp)/(optimal_temp-min_temp)))
		disp_image.color = HSVtoRGB(hue)
		temp_options["[newtemp - T0C]"] = disp_image
	temp_options["OFF"] = image('icons/misc/mark.dmi', "x3")
	loss = (active_power_usage / resistance)*0.5
	cooking_objs = list()
	if(mapload)
		for(var/starting_container_type in starts_with)
			if (length(cooking_objs) >= max_contents)
				break
			var/obj/item/reagent_containers/cooking_container/cooking_container = new starting_container_type(src)
			var/datum/cooking_item/cooking_item = new /datum/cooking_item/(cooking_container)
			cooking_objs.Add(cooking_item)
	cooking = FALSE

	queue_icon_update()

/obj/machinery/appliance/cooker/attempt_toggle_power(mob/user)
	var/wasoff = !operating
	if (use_check_and_message(user, issilicon(user) ? USE_ALLOW_NON_ADJACENT : 0))
		return

	var/list/missing = missing_parts()
	if(missing)
		return

	var/desired_temp = show_radial_menu(user, src, temp_options - (wasoff ? "OFF" : "[set_temp-T0C]"), require_near = TRUE, tooltips = TRUE, no_repeat_close = TRUE)
	if(!desired_temp)
		return

	if(desired_temp == "OFF")
		operating = FALSE
		update_use_power(POWER_USE_OFF)
	else
		operating = TRUE
		set_temp = text2num(desired_temp) + T0C
		to_chat(user, SPAN_NOTICE("You set [src] to [round(set_temp-T0C)]C."))
		update_use_power(POWER_USE_IDLE)
	if(wasoff != operating)
		activation_message(user)
	playsound(src, 'sound/machines/click.ogg', 40, 1)
	cooking = use_power
	update_icon()

/obj/machinery/appliance/cooker/proc/activation_message(mob/user)
	user.visible_message("<b>[user]</b> turns [use_power ? "on" : "off"] [src].", "You turn [use_power ? "on" : "off"] [src].")

/obj/machinery/appliance/cooker/Process()
	if (!loc)
		return FALSE
	var/datum/gas_mixture/loc_air = loc.return_air()
	if (!operating || (use_power != POWER_USE_ACTIVE)) // if we're not actively heating
		temperature -= min(loss, temperature - loc_air.temperature)
	if (operating)
		heat_up()
		update_cooking_power() // update!
	for (var/cooking_obj in cooking_objs)
		var/datum/cooking_item/cooking_item = cooking_obj
		if ((cooking_item.container.atom_flags && ATOM_FLAG_NO_REACT) || cooking_item.container?.reagents.total_volume > 0)
			continue
		cooking_item.container.temperature = (min(temperature, cooking_item.container.temperature + 10 * SIGN(temperature - cooking_item.container.temperature))) // max of 5C per second
	return ..()

/obj/machinery/appliance/cooker/power_change()
	. = ..()
	queue_icon_update()

/obj/machinery/appliance/cooker/update_cooking_power()
	var/temp_scale = 0
	if(temperature > min_temp)
		if(temperature >= optimal_temp)
			temp_scale = clamp(1 - ((optimal_temp - temperature) / optimal_temp), 0, 1)
		else
			temp_scale = temperature / optimal_temp
		//If we're between min and optimal this will yield a value in the range 0.7 to 1
	cooking_power *= temp_scale * optimal_power
	cooking_power = optimal_power * temp_scale * cooking_coeff

/obj/machinery/appliance/cooker/proc/heat_up()
	if (temperature < set_temp)
		if (use_power == POWER_USE_IDLE && ((set_temp - temperature) > 5))
			update_use_power(POWER_USE_ACTIVE)
			update_icon()
		temperature += heating_power / resistance
		update_cooking_power()
		return TRUE
	if (use_power == POWER_USE_ACTIVE)
		update_use_power(POWER_USE_IDLE)
		update_icon()

//Cookers do differently, they use containers
/obj/machinery/appliance/cooker/has_space(obj/item/item)
	if (istype(item, /obj/item/reagent_containers/cooking_container))
		//Containers can go into an empty slot
		if (length(cooking_objs) < max_contents)
			return TRUE
	else
		//Any food items directly added need an empty container. A slot without a container cant hold food
		for (var/datum/cooking_item/cooking_item in cooking_objs)
			if (cooking_item.container.check_contents() == COOKING_CONTAINER_EMPTY)
				return cooking_item

	return FALSE

/obj/machinery/appliance/cooker/add_content(obj/item/item, mob/user)
	var/datum/cooking_item/cooking_item = ..()
	if (cooking_item && cooking_item.combine_target)
		to_chat(user, "[item] will be used to make a [selected_option]. Output selection is returned to default for future items.")
		selected_option = null
