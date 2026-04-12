/proc/get_supply_department_account()
	return department_accounts["Снабжения"] || department_accounts["Supply"]

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
	return istype(id_card) && id_card.registered_name && (!registered_name || registered_name == id_card.registered_name)

/obj/structure/closet/secure_closet/personal/trade/togglelock(mob/user, obj/item/card/id/id_card)
	if(locked)
		id_card = istype(id_card) ? id_card : user?.GetIdCard()
		if(id_card)
			set_owner(id_card.registered_name)
	else
		set_owner(null)
	locked = !locked
	update_icon()
