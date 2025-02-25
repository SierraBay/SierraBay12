/obj/screen/exosuit/menu_button/id
	name = "ID control"
	button_desc = "Управляет ID Доступом в мехе. <br> Нажмите по кнопке ID картой чтоб задать доступ для меха. <br> После, мех будет открываться и закрываться при нажатии картой по меху."
	icon_state = "id"

/obj/screen/exosuit/menu_button/id/activated()
	var/obj/item/active = usr.get_active_hand()
	if(isMultitool(active) || ismultimeter(active))
		owner.can_hack_id()
		return
	if(!isid(active))
		to_chat(usr, "You need id card in active hand for interaction with ID control.")
		return
	if(owner.id_holder == "EMAGED")
		to_chat(usr, "Error 404, ID controlled din't respond.")
		return
	var/obj/item/card/id/pilot_card = active
	if(!owner.id_holder) //Холдер пустой?
		owner.control_id(pilot_card, usr)
	else //В холдере какой-то доступ уже есть
		//Доступ из холдера есть в нашей карте?
		if(has_access(owner.id_holder, pilot_card.access))
			owner.control_id(pilot_card, usr)
		else //Доступа нет в списке, увы
			to_chat(usr, "Acsess denied.")
			return
