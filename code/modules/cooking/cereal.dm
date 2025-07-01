/obj/machinery/appliance/mixer/cereal
	name = "cereal maker"
	desc = "Now with Dann O's available!"
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "cereal_off"
	cook_type = "cerealized"
	on_icon = "cereal_on"
	off_icon = "cereal_off"

	output_options = list(
		"Cereal" = /obj/item/reagent_containers/food/snacks/variable/cereal
	)

/obj/machinery/appliance/mixer/cereal/combination_cook(datum/cooking_item/cooking_item)
	var/list/images = list()
	var/num = 0
	for (var/obj/item/item in cooking_item.container)
		if (istype(item, /obj/item/reagent_containers/food/snacks/variable/cereal))
			//Images of cereal boxes on cereal boxes is dumb
			continue

		var/image/food_image = image(item.icon, item.icon_state)
		food_image.color = item.color
		food_image.AddOverlays(item.overlays)
		food_image.transform *= 0.7 - (num * 0.05)
		food_image.pixel_x = rand(-2,2)
		food_image.pixel_y = rand(-3,5)


		if (!images[item.icon_state])
			images[item.icon_state] = food_image
			num++

		if (num > 3)
			continue

	var/obj/item/reagent_containers/food/snacks/result = ..()
	result.color = result.filling_color
	for (var/i in images)
		result.AddOverlays(images[i])
