/obj/machinery/power/smes/batteryrack/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/cell)) // ID Card, try to insert it.
		if(!panel_open)
			to_chat(user, SPAN_WARNING("You need to open the access hatch on \the [src] first!"))
			return TRUE
		if(insert_cell(W, user))
			to_chat(user, "You insert \the [W] into \the [src].")
		else
			to_chat(user, "\The [src] has no empty slot for \the [W]")
		return TRUE

	if((. = ..()))
		return
