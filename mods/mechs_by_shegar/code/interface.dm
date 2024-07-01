#define MECH_UI_STYLE(X) "<span style=\"font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 5px;\">" + X + "</span>"

/obj/screen/movable/exosuit/toggle/menu
	name = "toggle mech menu "
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("MENU")
	maptext_x = 6
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/menu/toggled()
	owner.menu_status = !owner.menu_status
	owner.refresh_menu_hud()

/obj/screen/movable/exosuit/toggle/megaspeakers
	name = "Use megaspeakers "
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("SPEAK")
	maptext_x = 4
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/megaspeakers/toggled()
	if (usr.client)
		if(usr.client.prefs.muted & MUTE_IC)
			to_chat(usr, SPAN_WARNING("You cannot speak in IC (muted)."))
			return

	var/message = sanitize(input(usr, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = capitalize(message)
	owner.visible_message("[FONT_GIANT("\"[]\"")]",10)
	owner.visible_message("[FONT_GIANT("\"[owner] integrated megaspeaker speaks: [message]\"")]",10)
	owner.visible_message("[FONT_GIANT("\"[]\"")]",10)
	return

/obj/screen/movable/exosuit/toggle/gps
	name = "Use integrated GPS"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("GPS")
	maptext_x = 6
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/gps/toggled()
	owner.GPS.attack_self(usr)

/obj/screen/movable/exosuit/toggle/medscan
	name = "Full scan pilot"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("PLTSCN")
	maptext_x = 2
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/id
	name = "ID control"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("ID")
	maptext_x = 12
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/id/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(istype(tool, /obj/item/card/id))
		if(owner.id_holder == "EMAGED")
			to_chat(user, "Error 404, ID controlled din't respond.")
			return
		var/obj/item/card/id/card = tool
		if(!owner.id_holder) //Холдер пустой?
			owner.control_id(card,user)
		else //В холдере какой-то доступ уже есть
			//Доступ из холдера есть в нашей карте?
			if(has_access(card.access,owner.id_holder))
				owner.control_id(card,user)
			else //Доступа нет в списке, увы
				to_chat(user, "Acsess denied.")
				return
	else if (istype(tool, /obj/item/device/multitool/multimeter) || istype(tool, /obj/item/device/multitool))
		owner.can_hack_id()

	.=..()

/mob/living/exosuit/proc/can_hack_id(obj/item/device/multitool/tool, mob/living/user)
	if(!id_holder)
		to_chat(user, "Looks like [src] not locked.")
		return
	if(istype(tool, /obj/item/device/multitool/multimeter))
		if(user.skill_check(SKILL_DEVICES , SKILL_TRAINED) && user.skill_check(SKILL_ELECTRICAL , SKILL_TRAINED))
			mech_id_hack(user)
			return
	else if(istype(tool, /obj/item/device/multitool))
		if(user.skill_check(SKILL_DEVICES , SKILL_EXPERIENCED))
			mech_id_hack(user)
			return
	to_chat(user, "I dont understand")
	return

/mob/living/exosuit/proc/control_id(obj/item/card/id/card, mob/living/user)
	var/list/variants = list("Delete current ID", "Write NEW ID")
	var/choose
	var/choosed_place = input(usr, "What you want to do?.", name, choose) as null|anything in variants
	if(!choosed_place)
		return
	if(choosed_place == "Delete current ID")
		to_chat(user,"[src] ID holder cleared.")
		id_holder = null
		return
	else if (choosed_place == "Write NEW ID")
		if(!card.access) //<- карта пустая лол
			to_chat(user, "ERROR.No access detected in ID card")
			return

		var/list/access_variants = card.access
		var/choosed_access = input(usr, "Choose access from your list.", name, choose) as null|anything in access_variants
		if(!choosed_access)
			return
		id_holder = null
		to_chat(user, "New access accepted. Current: [id_holder]")
		playsound(src, 'sound/machines/twobeep.ogg', 50, 1, -6)
		id_holder = list(choosed_access)
		return

/mob/living/exosuit/proc/mech_id_hack(mob/living/user)
	var/delay = (90 - (15 * user.get_skill_value(SKILL_DEVICES))) SECONDS
	if(do_after(user, delay, src, DO_REPAIR_CONSTRUCT))
		to_chat(user, "ID data restored to NOMINAL by specific maintaint protocol.")
		id_holder = null
		selfopen_mech_hatch()
		return
	else
		to_chat(user, "ERROR. ID restore protocol canceled.")
		return

/obj/screen/movable/exosuit/toggle/medscan/toggled()
	owner.medscan.scan(usr,usr)
	roboscan(usr,usr)



/mob/living/exosuit/proc/get_main_data(mob/user)
	to_chat(user, SPAN_NOTICE("Main mech integrity: <b> [health]/[maxHealth]([((health/maxHealth)*100)]%) </b>"))
