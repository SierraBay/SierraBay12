// Syndicate Teleportation Device

/obj/item/storage/briefcase/std
	desc = "It's an old-looking briefcase with some high-tech markings. It has a label on it, which reads: \"ONLY WORKS NEAR SPACE\"."
	origin_tech = list(TECH_BLUESPACE = 3, TECH_ILLEGAL = 3)
	storage_slots = 10
	override_w_class = list(/obj/item/gun/projectile/shotgun/pump)
	var/obj/item/device/uplink/uplink
	var/authentication_complete = FALSE
	var/del_on_send = TRUE

/obj/item/storage/briefcase/std/attackby(obj/item/I, mob/user)
	if(I.hidden_uplink)
		visible_message("\The [src] blinks green!")
		uplink = I.hidden_uplink
		authentication_complete = TRUE
	..()

/obj/item/storage/briefcase/std/proc/can_launch()
	return authentication_complete && (locate(/turf/space) in view(get_turf(src)))

/obj/item/storage/briefcase/std/attack_self(mob/user)
	ui_interact(user)

/obj/item/storage/briefcase/std/interact(mob/user)
	ui_interact(user)

/obj/item/storage/briefcase/std/proc/ui_data(mob/user)
	var/list/list/data = list()

	data["can_launch"] = can_launch()
	data["fixer"] = GLOB.traitors.fixer.name
	data["owner"] = uplink.uplink_owner ? uplink.uplink_owner.name : "Unknown"
	data["is_owner"] = uplink.uplink_owner && (uplink.uplink_owner == user.mind)
	data["contracts"] = list()

	for(var/datum/antag_contract/item/C in GLOB.traitors.fixer.return_contracts())
		if(!C.check(src))
			continue
		data["contracts"].Add(list(list(
			"name" = C.name,
			"desc" = C.desc,
			"reward" = C.reward
		)))

	return data

/obj/item/storage/briefcase/std/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!authentication_complete)
		audible_message("\The [src] blinks red.")
		return
	var/list/data = ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "std.tmpl", "[name]", 400, 430)
		ui.set_initial_data(data)
		ui.open()

/obj/item/storage/briefcase/std/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr) || isobserver(usr))
		return

	if(!authentication_complete)
		return FALSE

	if(href_list["launch"])
		if(!can_launch())
			return FALSE

		for(var/datum/antag_contract/item/C in GLOB.all_contracts)
			if(C.completed)
				continue
			C.on_container(src)
		for(var/obj/item/I in contents)
			if(I.hidden_uplink == uplink)
				remove_from_storage(I, get_turf(src))
				continue
			qdel(I)
		contents = list()
		if(del_on_send)
			if(ishuman(loc))
				to_chat(loc, SPAN("notice", "\The [src] fades away in a brief flash of light."))
			uplink.complimentary_std = TRUE // We can get a new one for free once again
			qdel(src)

	if(.)
		SSnano.update_uis(src)

// Implant

/obj/item/implant/spy
	name = "spying implant"
	desc = "Used for spying purposes."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_ILLEGAL = 2)
	var/activated = FALSE
	var/timer

/obj/item/implant/spy/proc/check_compilation()
	if(!imp_in)
		return FALSE
	for(var/datum/antag_contract/implant/C in GLOB.traitors.fixer.return_contracts())
		C.check(src)

/obj/item/implant/spy/implanted(mob/source)
	timer = addtimer(CALLBACK(src, .proc/check_compilation), 1 MINUTES, TIMER_STOPPABLE)
	return TRUE

/obj/item/implant/spy/removed()
	..()
	deltimer(timer)

/obj/item/implanter/spy
	name = "implanter (S)"
	desc = "It has a small label: \"Use your uplink for authorization\"."
	imp = /obj/item/implant/spy

/obj/item/implanter/spy/attackby(obj/item/I, mob/user)
	if(imp && istype(imp, /obj/item/implant/spy) && I.hidden_uplink)
		imp.hidden_uplink = I.hidden_uplink
		to_chat(user, SPAN("notice", "You authorize the [src] with \the [I]."))

/obj/item/implantcase/spy
	name = "glass case - 'spy'"
	imp = /obj/item/implant/spy
