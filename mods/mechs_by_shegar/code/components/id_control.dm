
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
