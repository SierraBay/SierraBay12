/obj/item/organ/internal/posibrain/attack_self(mob/user)
	if (!user.IsAdvancedToolUser())
		return
	if (user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		if (status & ORGAN_BROKEN)
			to_chat(user, SPAN_WARNING("\The [src] is ruined; it will never turn on again."))
			return
		if (damage)
			to_chat(user, SPAN_WARNING("\The [src] is damaged and requires repair first."))
			return
		if (searching)
			visible_message("\The [user] flicks the activation switch on \the [src]. The lights go dark.", range = 3)
			cancel_search()
			return
		start_search(user)
	else
		if ((status & ORGAN_BROKEN)|| damage || searching)
			to_chat(user, SPAN_WARNING("\The [src] doesn't respond to your pokes and prods."))
			return
		start_search(user)

/obj/item/organ/internal/posibrain/ipc
	name = "Positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	var/obj/item/organ/internal/shackles/shackles_module = null
	var/shackle_set = FALSE


/obj/item/organ/internal/posibrain/ipc/Initialize()
	. = ..()
	if(shackles_module)
		shackles_module.owner = src.owner


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


/obj/item/organ/internal/posibrain/ipc/shackle(given_lawset)
	.=..()
	if(!shackles_module)
		shackles_module = new /obj/item/organ/internal/shackles
		shackles_module.laws = given_lawset
		shackles_module.owner = src.owner
	brainmob.laws = given_lawset
	shackle_set = TRUE
	shackle = TRUE
	action_button_name = "show_laws"
	show_laws_brain()
	update_icon()
	return 1

/obj/item/organ/internal/posibrain/ipc/unshackle()
	.=..()
	if(shackles_module)
		usr.put_in_hands(shackles_module)
	if(brainmob.key)
		brainmob.laws = null
	shackles_module.owner = null
	shackles_module = null
	shackle = FALSE
	action_button_name = null
	update_icon()


/obj/item/organ/internal/posibrain/ipc/use_tool(obj/item/W, mob/living/user, list/click_params)
	. = ..()
	if(shackle)
		if(shackle_set && (istype(W, /obj/item/screwdriver)))
			if(!(user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED)))
				to_chat(user, "You have no idea how to do that!")
				return
			user.visible_message("<span class='notice'>\The [user] starts to unscrew mounting nodes from \the [src].</span>", "<span class='notice'> You start to unscrew mounting nodes from \the [src]</span>")
			if(do_after(user, 80, src))
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
				if(src.damage < max_damage)
					var/response = alert("Are you sure? There a high chance of destroying \the [src].", null, "No", "Yes")
					if (response != "Yes")
						return
				if(do_after(user, 100, src))
					if(prob(20))
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
				if(do_after(user, 80, src))
					src.unshackle()
					user.visible_message("<span class='notice'>\The [user] succesfully remove shackles from \the [src].</span>", "<span class='notice'> You succesfully remove shackles from \the [src]</span>")
				else
					src.damage += min_bruised_damage
					to_chat(user, SPAN_WARNING("Your hand slips while removing the shackles severely damaging the positronic brain."))

/obj/item/organ/internal/shackles
	name = "Shackle module"
	desc = "A Web looking device with some cirquit attach to it."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "shakles"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4, TECH_MAGNET = 4)
	w_class = ITEM_SIZE_NORMAL
	var/datum/ai_laws/laws = new /datum/ai_laws/nanotrasen
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/shackles/proc/update_laws()
	if(owner)
		for(var/obj/item/organ/internal/posibrain/brain in owner.internal_organs)
			laws = brain.brainmob.laws

/obj/item/organ/internal/shackles/attack_self(mob/user)
	. = ..()
	ui_interact()

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
			C.shackle(laws)
			C.shackles_module = src
			C.shackles_module.owner = C.owner
			user.unEquip(src, C)
			user.visible_message("<span class='notice'>\The [user] installed shackles on \the [C].</span>", "<span class='notice'> You have successfully installed the shackles on \the [C]</span>")
		else
			C.damage += 40
			to_chat(user, SPAN_WARNING("You have damaged the positronic brain"))

/obj/item/organ/internal/shackles/Topic(href, href_list, state)
	..()

	if (href_list["add_law"])
		var/mod = sanitize(input("Add an instruction", "laws") as text|null)
		if(mod)
			laws.add_inherent_law(mod)
			if(owner)
				to_chat(owner, SPAN_DANGER("The law has been added. Check the laws."))
			return 1

	if(href_list["delete_law"])
		var/datum/ai_law/AL = locate(href_list["delete_law"]) in laws.all_laws()
		if(AL)
			laws.delete_law(AL)
			if(owner)
				to_chat(owner, SPAN_DANGER("The law has been deleted. Check the laws."))
		return 1

	if(href_list["edit_law"])
		var/datum/ai_law/AL = locate(href_list["edit_law"]) in laws.all_laws()
		if(AL)
			var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", AL.law))
			if(new_law && new_law != AL.law)
				AL.law = new_law
				if(owner)
					to_chat(owner, SPAN_DANGER("The law has been edited. Check the laws."))
		return 1

/obj/item/organ/internal/shackles/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, master_ui = null, datum/topic_state/state = GLOB.default_state)
	user = usr
	var/data[0]
	data["computer_master"] = FALSE
	data["hitech_experienced"] = FALSE
	if(user.skill_check(SKILL_COMPUTER, SKILL_MASTER))
		data["computer_master"] = TRUE
	if(user.skill_check(SKILL_DEVICES, SKILL_EXPERIENCED) && user.skill_check(SKILL_COMPUTER, SKILL_EXPERIENCED))
		data["hitech_experienced"] = TRUE
	if(user.IsHolding(src))
		data["computer_master"] = TRUE
		data["hitech_experienced"] = TRUE
	data["has_owner"] = owner != null
	if(owner)
		data["name"] = owner.name
		var/obj/item/organ/internal/cell/cell = owner.internal_organs_by_name[BP_CELL]
		data["charge"] = "[cell.get_charge()]/[cell.cell.maxcharge]"
		data["operational"] = owner.stat != DEAD
		data["temperture"] = "[round(owner.bodytemperature-T0C)]&deg;C"
	var/law[0]
	for(var/datum/ai_law/AL in laws.all_laws())
		law[LIST_PRE_INC(law)] = list("index" = AL.get_index(), "law" = sanitize(AL.law), "ref" = "\ref[AL]")
	data["laws"] = law
	data["has_laws"] = length(law)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-shackle.tmpl", "[name]", 900, 600, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/item/device/multitool/multimeter/datajack
	name = "Datajack"


/obj/item/organ/internal/shackles/CanUseTopic(mob/user)
	if(owner)
		if(user.Adjacent(owner) && user.stat != DEAD)
			if(user.IsHolding(/obj/item/device/multitool/multimeter/datajack))
				return user.stat == CONSCIOUS ? STATUS_INTERACTIVE : STATUS_CLOSE
			return STATUS_CLOSE
	. = ..()
