/proc/get_supply_department_account()
	return department_accounts["Supply"] || department_accounts["Cargo"] || department_accounts["Снабжения"]

/proc/recursive_list_len(list/input)
	. = 0
	if(!islist(input))
		return
	. += length(input)
	for(var/entry in input)
		if(islist(entry))
			. += recursive_list_len(entry)
		else if(islist(input[entry]))
			. += recursive_list_len(input[entry])

/obj/structure/closet/secure_closet/personal/trade
	name = "trade locker"
	desc = "A secure locker used to deliver trade network orders."
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/personal/trade/WillContain()
	return

/obj/structure/closet/secure_closet/personal/trade/CanToggleLock(mob/user, obj/item/card/id/id_card)
	if(istype(id_card))
		if((access_cargo in id_card.access) || (access_qm in id_card.access) || (access_captain in id_card.access))
			return TRUE
		if(id_card.registered_name && (!registered_name || registered_name == id_card.registered_name))
			return TRUE
	return FALSE

/obj/structure/closet/secure_closet/personal/trade/togglelock(mob/user, obj/item/card/id/id_card)
	locked = !locked
	if(locked)
		id_card = istype(id_card) ? id_card : user?.GetIdCard()
		if(id_card)
			set_owner(id_card.registered_name)
		if(user)
			to_chat(user, SPAN_NOTICE("You lock the locker."))
	else
		set_owner(null)
		if(user)
			to_chat(user, SPAN_NOTICE("You unlock the locker."))
	update_icon()
	return TRUE

