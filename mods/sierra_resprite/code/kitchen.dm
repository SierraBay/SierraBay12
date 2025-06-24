
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
