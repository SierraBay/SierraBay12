// TGUI
/obj/machinery/vending/tgui_state(mob/user)
	return GLOB.tgui_default_state


/obj/machinery/vending/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vending", name)
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/vending/tgui_data(mob/user)
	var/list/data = list()

	if(currently_vending)
		data["mode"] = TRUE
		data["product"] = currently_vending.item_name
		data["price"] = currently_vending.price
		data["image"] = tgui_product_image(currently_vending)
	else
		data["mode"] = FALSE

	data["message"] = status_message
	data["message_err"] = status_error
	data["vend_ready"] = vend_ready
	data["coin"] = coin?.name
	data["panel"] = panel_open
	data["speaker"] = !shut_up

	var/list/listed_products = list()

	for(var/product_position in 1 to length(product_records))
		var/datum/stored_items/vending_products/product = product_records[product_position]
		if(!(product.category & vendor_flags))
			continue

		listed_products += list(list(
			"key" = product_position,
			"name" = product.item_name,
			"price" = product.price,
			"category" = product.category,
			"ammount" = product.get_amount(),
			"image" = tgui_product_image(product)
		))
	data["products"] = listed_products

	return data


/obj/machinery/vending/tgui_static_data(mob/user)
	var/list/data = list()
	data["isSilicon"] = istype(user, /mob/living/silicon)
	return data


/obj/machinery/vending/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	user.set_machine(src)
	return tgui_interact(user)

/obj/machinery/vending/proc/tgui_product_image(datum/stored_items/vending_products/product)
	var/static/list/product_image_cache = list()
	if(!product_image_cache[product.item_path])
		var/atom/item_type = product.item_path
		product_image_cache[product.item_path] = icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), SOUTH))
	return product_image_cache[product.item_path]

/obj/machinery/vending/tgui_act(action, list/params)
	if(..())
		return
	var/list/href_list = list()
	switch(action)
		if("vend")
			href_list["vend"] = "[params["vend"]]"
		if("remove_coin", "cancelpurchase", "togglevoice")
			href_list[action] = "1"
		else
			return FALSE
	// Preserve Sierra stock, access, coin, payment and panel rules.
	Topic("", href_list)
	return TRUE
