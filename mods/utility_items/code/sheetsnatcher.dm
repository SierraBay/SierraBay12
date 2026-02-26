/obj/item/storage/sheetsnatcher/handle_item_insertion(obj/item/stack/material/stack, silent)
	if (!can_be_inserted(stack, null, silent))
		return FALSE
	if (!usr?.unEquip(stack, src))
		return FALSE
	cur_sheets += stack.amount
	for (var/obj/item/stack/material/held as anything in contents)
		if (stack.amount < 1)
			break
		if (held == stack)
			continue
		if (held.type != stack.type)
			continue
		if (held.amount >= held.max_amount)
			continue
		var/free_space = held.max_amount - held.amount
		if (free_space >= stack.amount)
			held.amount += stack.amount
			qdel(stack)
			break
		else
			held.amount += free_space
			stack.amount -= free_space
	if (stack.amount < 1)
		qdel(stack)
	prepare_ui(usr)
	update_icon()
	return TRUE
