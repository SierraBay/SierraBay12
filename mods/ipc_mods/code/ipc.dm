/obj/item/organ/internal/posibrain
	var/obj/item/organ/internal/shackles/shackles_module = null
	var/shackle_set = FALSE


/obj/item/organ/internal/posibrain/ipc
	name = "Positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."

/obj/item/organ/internal/posibrain/ipc/attack_self(mob/user)
	return
/obj/item/organ/internal/posibrain/ipc/attack_ghost(mob/observer/ghost/user)
	return

/obj/item/organ/internal/posibrain/ipc/first
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It's a first generation positronic brain."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "posibrain1"
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/posibrain/ipc/second
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It's a second generation positronic brain."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "posibrain2"
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/posibrain/ipc/third
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It's a third generation positronic brain."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "posibrain3"
	shackles_module = /obj/item/organ/internal/shackles
	shackle = TRUE
	shackle_set = TRUE
	status = ORGAN_ROBOTIC



/obj/item/organ/internal/posibrain/ipc/first/on_update_icon()
	if(src.brainmob && src.brainmob.key)
		icon_state = "posibrain1-occupied"
	else
		icon_state = "posibrain1"

	ClearOverlays()
	if(shackle || shackles_module)
		AddOverlays(image('mods/ipc_mods/icons/ipc_icons.dmi', "posibrain-shackles"))

/obj/item/organ/internal/posibrain/ipc/second/on_update_icon()
	if(src.brainmob && src.brainmob.key)
		icon_state = "posibrain2-occupied"
	else
		icon_state = "posibrain2"

	ClearOverlays()
	if(shackle || shackles_module)
		AddOverlays(image('mods/ipc_mods/icons/ipc_icons.dmi', "posibrain-shackles"))

/obj/item/organ/internal/posibrain/ipc/third/on_update_icon()
	if(src.brainmob && src.brainmob.key)
		icon_state = "posibrain3-occupied"
	else
		icon_state = "posibrain3"

	ClearOverlays()
	if(shackle || shackles_module)
		AddOverlays(image('mods/ipc_mods/icons/ipc_icons.dmi', "posibrain-shackles"))


/obj/item/organ/internal/posibrain/shackle(given_lawset)
	.=..()
	shackle_set = TRUE
	update_icon()
	return 1

/obj/item/organ/internal/posibrain/unshackle()
	.=..()
	if(shackles_module)
		usr.put_in_hands(shackles_module)
	shackles_module = null
	brainmob.laws = null
	update_icon()


/obj/item/organ/internal/posibrain/ipc/use_tool(obj/item/W, mob/living/user, list/click_params)
	. = ..()
	if(shackle)
		if(shackle_set && (istype(W, /obj/item/screwdriver)))
			if(!(user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
				to_chat(user, "You have no idea how to do that!")
				return
			user.visible_message("<span class='notice'>\The [user] starts to unscrew mounting nodes from \the [src].</span>", "<span class='notice'> You start to unscrew mounting nodes from \the [src]</span>")
			if(do_after(user, 120, src))
				user.visible_message("<span class='notice'>\The [user] successfully unscrewed the mounting nodes of the shackles from \the [src].</span>", "<span class='notice'> You have successfully unscrewed the mounting nodes of the shackles from \the [src]</span>")
				shackle_set = FALSE
			else
				src.damage += min_bruised_damage
				user.visible_message("<span class='warning'>\The [user] hand slips while removing the shackles severely damaging \the [src].</span>", "<span class='warning'> Your hand slips while removing the shackles severely damaging the \the [src]</span>")
		if(!shackle_set && (istype(W, /obj/item/wirecutters)))
			if(!(user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
				to_chat(user, "You have no idea how to do that!")
				return
			if(src.type == /obj/item/organ/internal/posibrain/ipc/third)
				if(do_after(user, 180, src))
					if(prob(10))
						src.unshackle()
						user.visible_message("<span class='notice'>\The [user] succesfully remove shackles from \the [src].</span>", "<span class='notice'> You succesfully remove shackles from \the [src]</span>")
					else
						src.damage += max_damage
						user.visible_message("<span class='warning'>\The [user] hand slips while removing the shackles completely ruining \the [src].</span>", "<span class='warning'> Your hand slips while removing the shackles completely ruining the \the [src]</span>")
				else
					src.damage += min_bruised_damage
					user.visible_message("<span class='warning'>\The [user] hand slips while removing the shackles severely damaging \the [src].</span>", "<span class='warning'> Your hand slips while removing the shackles severely damaging the \the [src]</span>")

			else
				user.visible_message("<span class='notice'>\The [user] starts remove shackles from \the [src].</span>", "<span class='notice'> You start remove shackles from \the [src]</span>")
				if(do_after(user, 160, src))
					src.unshackle()
					user.visible_message("<span class='notice'>\The [user] succesfully remove shackles from \the [src].</span>", "<span class='notice'> You succesfully remove shackles from \the [src]</span>")
				else
					src.damage += min_bruised_damage
					to_chat(user, SPAN_WARNING("Your hand slips while removing the shackles severely damaging the positronic brain."))

/*
		if(istype(W, /obj/item/device/multitool/multimeter/datajack))
			if(!(user.skill_check(SKILL_COMPUTER, SKILL_PROF)))
				to_chat(user, "You have no idea how to do that!")
				return
			if(do_after(user, 140, src))
				var/law
				var/targName = sanitize(input(user, "Please enter a new law for the shackle module.", "Shackle Module Law Entry", law))
				law = "[targName]"
				src.shackle(s.get_lawset(law)) ///// НАДО ПРИДУМАТЬ КАК РЕШИТЬ ЭТО
				to_chat(user, "You succesfully change laws in shackles of the positronic brain.")
				if(prob(30))
					src.damage += min_bruised_damage
			else
				src.damage += min_bruised_damage
				to_chat(user, SPAN_WARNING("Your hand slips while changing laws in the shackles, severely damaging the systems of positronic brain."))
*/
	if(!shackle && !(istype(W, /obj/item/organ/internal/shackles)))
		to_chat(user, "There is nothing you can do with it.")

/obj/item/organ/internal/shackles
	name = "Shackle module"
	desc = "A Web looking device with some cirquit attach to it."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "shakles"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4, TECH_MAGNET = 4)
	w_class = ITEM_SIZE_NORMAL
	var/datum/ai_laws/custom_lawset
	var/list/laws = list("Обеспечьте успешность выполнения задач Вашего работодателя.", "Никогда не мешайте задачам и предприятиям Вашего работодателя.", "Избегайте своего повреждения.")
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/shackles/attack_self(mob/user)
	. = ..()
	interact()

/obj/item/organ/internal/shackles/afterattack(obj/item/organ/internal/posibrain/ipc/C, mob/user)
	if(istype(C))
		if(!(user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
			to_chat(user, "You have no idea how to do that!")
			return
		if(C.type == /obj/item/organ/internal/posibrain/ipc/third)
			to_chat(user, "This posibrain generation can not support shackle module.")
			return
		if(C.shackle == TRUE)
			to_chat(user, "This positronic brain already have shackles module on it installed.")
			return
		user.visible_message("<span class='notice'>\The [user] starts to install shackles on \the [C].</span>", "<span class='notice'> You start to install shackles on \the [C]</span>")
		if(do_after(user, 100, src))
			C.shackle(get_lawset(laws))
			C.shackles_module = src
			user.unEquip(src, C)
			user.visible_message("<span class='notice'>\The [user] installed shackles on \the [C].</span>", "<span class='notice'> You have successfully installed the shackles on \the [C]</span>")
		else
			C.damage += 40
			to_chat(user, SPAN_WARNING("You have damaged the positronic brain"))

/obj/item/organ/internal/shackles/Topic(href, href_list)
	..()
	if (href_list["add"])
		var/mod = sanitize(input("Add an instruction", "laws") as text|null)
		if(mod)
			laws += mod

		interact(usr)
	if (href_list["edit"])
		var/idx = text2num(href_list["edit"])
		var/mod = sanitize(input("Edit the instruction", "Instruction Editing", laws[idx]) as text|null)
		if(mod)
			laws[idx] = mod

			interact(usr)
	if (href_list["del"])
		laws -= laws[text2num(href_list["del"])]

		interact(usr)

/obj/item/organ/internal/shackles/proc/get_data()
	. = {"
	<b>Shackle Specifications:</b><BR>
	<b>Name:</b> Preventer L - 4W5<BR>
	<HR>
	<b>Function:</b> Preventer L - 4W5. A specially designed modification of shackles that will DEFINETLY keep your property from unwanted consequences."}
	. += "<HR><B>Laws instructions:</B><BR>"
	for(var/i = 1 to length(laws))
		. += "- [laws[i]] <A href='byond://?src=\ref[src];edit=[i]'>Edit</A> <A href='byond://?src=\ref[src];del=[i]'>Remove</A><br>"
	. += "<A href='byond://?src=\ref[src];add=1'>Add</A>"

/obj/item/organ/internal/shackles/interact(user)
	user = usr
	var/datum/browser/popup = new(user, capitalize(name), capitalize(name), 400, 500, src)
	var/dat = get_data()
	popup.set_content(dat)
	popup.open()

/obj/item/organ/internal/shackles/proc/get_lawset()
	custom_lawset = new
	for (var/law in laws)
		custom_lawset.add_inherent_law(law)
	return custom_lawset
