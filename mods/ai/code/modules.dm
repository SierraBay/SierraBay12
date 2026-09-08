/obj/item/robot_module/build_emag()
	var/list/created_toys = list()
	for (var/thing in emag_gear)
		if (ispath(thing, /obj/item))
			// Don't add a duplicate if this item type is already in equipment (e.g. flash)
			if (locate(thing) in equipment)
				continue
			created_toys |= new thing(src)
		else if (isitem(thing))
			var/obj/item/I = thing
			I.forceMove(src)
			created_toys |= I
		else
			log_debug("Invalid var type in [type] emag creation - [emag_gear[thing]]")
	equipment |= created_toys
