/proc/get_supply_department_account()
	return department_accounts["Supply"] || department_accounts["Cargo"]

/obj/structure/closet/secure_closet/personal/trade
	parent_type = /obj/structure/closet/crate/trade

/obj/structure/closet/crate/trade
	parent_type = /obj/structure/closet/crate/secure
	name = "trade crate"
	desc = "A secure crate used to deliver trade network orders."
	closet_appearance = /singleton/closet_appearance/crate/secure
	req_access = null
	locked = FALSE
	var/registered_name

/obj/structure/closet/crate/trade/WillContain()
	return

/obj/structure/closet/crate/trade/CanToggleLock(mob/user, obj/item/card/id/id_card)
	if(!id_card && user)
		id_card = user.GetIdCard()
	if(istype(id_card))
		if((access_cargo in id_card.access) || (access_qm in id_card.access) || (access_captain in id_card.access))
			return TRUE
		if(id_card.registered_name && (!registered_name || registered_name == id_card.registered_name))
			return TRUE
	return FALSE

