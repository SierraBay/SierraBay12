
/obj/machinery/appliance/cooker/oven
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "ovenclosed"

/obj/machinery/appliance/cooker/oven/on_update_icon()
	ClearOverlays()
	if (!open)
		icon_state = "ovenclosed"
	else
		icon_state = "ovenopen"
	if (operating && !open)
		var/image/glow = image('mods/sierra_resprite/icons/kitchen.dmi', "oven_on")
		glow.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		AddOverlays(glow)

/obj/machinery/appliance/cooker/grill
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "grill_off"

/obj/machinery/appliance/cooker/grill/on_update_icon()
	..()
	ClearOverlays()
	if(length(cooking_objs))
		var/datum/cooking_item/cooking_item = cooking_objs[1]
		var/obj/item/reagent_containers/cooking_container/grill_grate/grate = cooking_item.container
		if(grate)
			AddOverlays(image('mods/sierra_resprite/icons/kitchen.dmi', "grill"))
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

/obj/machinery/appliance/cooker/fryer
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "fryer_off"

/obj/machinery/appliance/cooker/fryer/on_update_icon()
	..()
	ClearOverlays()
	var/list/pans = list()
	for(var/obj/item/reagent_containers/cooking_container/cooking_container in contents)
		var/image/pan_overlay
		if(cooking_container.appliancetype == COOKING_APPLIANCE_FRYER)
			pan_overlay = image('mods/sierra_resprite/icons/kitchen.dmi', "basket[clamp(length(pans)+1, 1, 2)]")
		pan_overlay.color = cooking_container.color
		pans += pan_overlay
	if(!length(pans))
		return
	AddOverlays(pans)

/obj/machinery/appliance/mixer/candy
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "candy_mixer"

/obj/machinery/appliance/cooker/microwave
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "mw"

/obj/machinery/appliance/mixer/cereal
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "cereal"

/obj/machinery/chem_master/condimaster
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "mixer"

/obj/structure/reagent_dispensers/water_cooler
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "water_cooler"

/obj/machinery/reagentgrinder/juicer
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "juicer"

/obj/machinery/appliance/cooker/stove
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "stove"

/obj/machinery/appliance/cooker/stove/on_update_icon()
	..()
	ClearOverlays()
	var/list/pans = list()
	var/pan_number = 0
	for(var/obj/item/reagent_containers/cooking_container/cooking_container in contents)
		var/pan_icon_state
		var/pan_position_number = clamp((pan_number)+1, 1, 4)
		var/list/positions = pan_positions[pan_position_number]
		switch(cooking_container.appliancetype)
			if(COOKING_APPLIANCE_SKILLET)
				pan_icon_state = "skillet"
				if(pan_position_number >= 3)
					pan_icon_state = "skillet_flip"
			if(COOKING_APPLIANCE_SAUCEPAN)
				pan_icon_state = "pan"
				if(pan_position_number >= 3)
					pan_icon_state = "pan_flip"
			if(COOKING_APPLIANCE_POT)
				pan_icon_state = "pot"
			else
				continue
		var/mutable_appearance/pan_overlay = mutable_appearance('mods/sierra_resprite/icons/kitchen.dmi', pan_icon_state)
		pan_overlay.pixel_x = positions[1]
		pan_overlay.pixel_y = positions[2]
		pan_overlay.color = cooking_container.color
		pans += pan_overlay
		pan_number = pan_position_number
		//filling
		if(cooking_container.reagents.total_volume)
			var/mutable_appearance/filling_overlay = mutable_appearance('mods/sierra_resprite/icons/kitchen.dmi', "filling_overlay")
			filling_overlay.pixel_x = positions[1]
			filling_overlay.pixel_y = positions[2]
			filling_overlay.color = cooking_container.reagents.get_color()
			switch(cooking_container.appliancetype)
				if(COOKING_APPLIANCE_SKILLET)
					filling_overlay.pixel_y -= 3
				if(COOKING_APPLIANCE_SAUCEPAN)
					filling_overlay.pixel_y -= 2
			pans += filling_overlay
		// flame overlay
		if(operating)
			var/mutable_appearance/flame_overlay = mutable_appearance('mods/sierra_resprite/icons/kitchen.dmi', "stove_flame")
			flame_overlay.pixel_x = positions[1]
			flame_overlay.pixel_y = positions[2]
			flame_overlay.color = "#006eff"
			pans += flame_overlay
	if(!length(pans))
		return
	AddOverlays(pans)


/obj/item/reagent_containers/food/drinks/teapot
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
	icon_state = "teapot"
	item_state = "teapot"

/obj/item/reagent_containers/food/drinks
	icon = 'mods/sierra_resprite/icons/kitchen.dmi'
