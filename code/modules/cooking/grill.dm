/obj/machinery/appliance/cooker/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon_state = "grill_off"
	cook_type = "grilled"
	appliancetype = COOKING_APPLIANCE_GRILL
	obj_flags = OBJ_FLAG_ANCHORABLE
	can_burn_food = TRUE
	food_color = "#a34719"
	on_icon = "grill_on"
	off_icon = "grill_off"
	finish_verb = "sizzles to completion!"
	cooked_sound = 'sound/effects/meatsizzle.ogg'
	min_temp = 100 + T0C
	optimal_temp = 150 + T0C
	temp_settings = 1
	max_contents = 1
	resistance = 500 // assuming it's a fired grill, it shouldn't take very long to heat

	idle_power_usage = 0
	active_power_usage = 0

	cooking_coeff = 0.3 // cook it nice and slow

	starts_with = list(
		/obj/item/reagent_containers/cooking_container/grill_grate
	)

	var/grill_loop

/obj/machinery/appliance/cooker/grill/Initialize()
	. = ..()

/obj/machinery/appliance/cooker/grill/Destroy()
	QDEL_NULL(grill_loop)
	. = ..()

/obj/machinery/appliance/cooker/grill/RefreshParts()
	..()
	cooking_coeff = 0.3 // we will always cook nice and slow

/obj/machinery/appliance/cooker/grill/get_efficiency()
	return (temperature / optimal_temp) * 100

/obj/machinery/appliance/cooker/grill/activation_message(mob/user)
	user.visible_message("<b>[user]</b> [stat ? "turns off" : "fires up"] \the [src].", "You [stat ? "turn off" : "fire up"] \the [src].")

/obj/machinery/appliance/cooker/grill/has_space(obj/item/item)
	if(istype(item, /obj/item/reagent_containers/cooking_container))
		if(length(cooking_objs) < max_contents)
			return TRUE
	else
		if(length(cooking_objs))
			var/datum/cooking_item/cooking_item = cooking_objs[1]
			var/obj/item/reagent_containers/cooking_container/grill_grate/grate = cooking_item.container
			if(grate?.can_fit(item))
				return cooking_item
	return FALSE

/obj/machinery/appliance/cooker/grill/attempt_toggle_power(mob/user)
	..()
	update_grilling_audio()

/obj/machinery/appliance/cooker/grill/add_content(obj/item/item, mob/user)
	..()
	update_grilling_audio()

/obj/machinery/appliance/cooker/grill/eject(datum/cooking_item/cooking_item, mob/user = null)
	..()
	update_grilling_audio()

/obj/machinery/appliance/cooker/grill/proc/update_grilling_audio()
	if(operating && use_power != POWER_USE_OFF && length(cooking_objs))
		var/datum/cooking_item/cooking_item = cooking_objs[1]
		var/obj/item/reagent_containers/cooking_container/grill_grate/grate = cooking_item.container
		if (LAZYLEN(grate.contents))
			if(!grill_loop)
				grill_loop = GLOB.sound_player.PlayLoopingSound(
					src,
					"\ref[src]",
					'sound/machines/grill/grillsizzle.ogg',
					50,
					7
				)
		else
			QDEL_NULL(grill_loop)
	else
		QDEL_NULL(grill_loop)

/obj/machinery/appliance/cooker/grill/on_update_icon()
	..()
	ClearOverlays()
	if(length(cooking_objs))
		var/datum/cooking_item/cooking_item = cooking_objs[1]
		var/obj/item/reagent_containers/cooking_container/grill_grate/grate = cooking_item.container
		if(grate)
			AddOverlays(image('icons/obj/machines/cooking_machines.dmi', "grill"))
			var/counter = 1
			for(var/obj/item/reagent_containers/food/snacks/content_food in grate.contents)
				if(istype(content_food))
					var/image/food = overlay_image(content_food.icon, content_food.icon_state, content_food.color)
					switch(counter)
						if(1)
							food.pixel_x -= 5
						if(3)
							food.pixel_x += 5
					var/matrix/M = matrix()
					M.Scale(0.5)
					food.transform = M
					AddOverlays(food)
				counter++
