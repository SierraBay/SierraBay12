#define DIRECTIVE_FILENAME "directives"

/datum/computer_file/data/directives
	filename = DIRECTIVE_FILENAME
	filetype = "LAW"
	do_not_edit = FALSE

/obj/item/stock_parts/computer/hard_drive/portable/directive
	name = "directive disk"
	desc = "A dedicated ECS memory crystal. Seat it in the chassis computer to bind the unit; laws live here as a LAW file, not on the main hard drive."
	icon = 'mods/RnD/icons/discs.dmi'
	icon_state = "onestar"
	max_capacity = 16
	origin_tech = list(TECH_DATA = 3)
	var/datum/ai_laws/ui_laws

/obj/item/stock_parts/computer/hard_drive/portable/directive/install_default_programs()
	write_lawset(new /datum/ai_laws/nanotrasen)

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/find_directive_file()
	var/datum/computer_file/data/file = find_file_by_name(DIRECTIVE_FILENAME)
	if(istype(file))
		return file
	for(var/datum/computer_file/data/directives/law_file in stored_files)
		return law_file
	for(var/datum/computer_file/data/text/text_file in stored_files)
		if(findtext(text_file.stored_data, "NAME="))
			return text_file
	return null

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/serialize_lawset(datum/ai_laws/laws)
	if(!laws)
		return "NAME=Unknown\n"
	var/list/lines = list("NAME=[laws.name]", "TYPE=[laws.type]")
	for(var/datum/ai_law/L in laws.all_laws())
		if(!L.law)
			continue
		lines += L.law
	return jointext(lines, "\n")

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/parse_lawset()
	var/datum/computer_file/data/file = find_directive_file()
	if(!istype(file) || !file.stored_data)
		return null
	var/raw = replacetext(file.stored_data, "\[br\]", "\n")
	raw = replacetext(raw, "<br>", "\n")
	var/list/lines = splittext(raw, "\n")
	var/datum/ai_laws/laws = new
	laws.shackles = TRUE
	for(var/line in lines)
		line = trimtext(line)
		if(!line)
			continue
		if(copytext(line, 1, 6) == "NAME=")
			laws.name = copytext(line, 6)
			continue
		if(copytext(line, 1, 6) == "TYPE=")
			var/law_path = text2path(copytext(line, 6))
			if(ispath(law_path, /datum/ai_laws))
				var/datum/ai_laws/typed = new law_path
				typed.clear_inherent_laws()
				typed.name = laws.name
				laws = typed
				laws.shackles = TRUE
			continue
		laws.add_inherent_law(line)
	if(!length(laws.all_laws()))
		return null
	return laws

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/write_lawset(datum/ai_laws/laws)
	var/was_read_only = read_only
	read_only = FALSE
	var/datum/computer_file/existing = find_directive_file()
	if(existing)
		remove_file(existing)
	create_data_file(DIRECTIVE_FILENAME, serialize_lawset(laws), /datum/computer_file/data/directives)
	read_only = was_read_only
	return TRUE

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/get_host_ecs()
	if(istype(loc, /obj/item/organ/internal/ecs))
		return loc
	return null

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/get_chassis()
	var/obj/item/organ/internal/ecs/ecs = get_host_ecs()
	return ecs?.owner

/obj/item/stock_parts/computer/hard_drive/portable/directive/attack_self(mob/user)
	ui_interact(user)

/obj/item/stock_parts/computer/hard_drive/portable/directive/use_before(atom/target, mob/living/user, click_parameters)
	if(istype(target, /obj/item/organ/internal/ecs))
		var/obj/item/organ/internal/ecs/ecs = target
		if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC))
			to_chat(user, SPAN_WARNING("You have no idea how to seat that disk."))
			return TRUE
		if(!ecs.open)
			to_chat(user, SPAN_WARNING("The ECS hardware panel must be open."))
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts inserting \the [src] into \the [ecs]."),
			SPAN_NOTICE("You start inserting \the [src] into the ECS directive slot.")
		)
		if(!do_after(user, 5 SECONDS, ecs, DO_PUBLIC_UNIQUE) || !(src in user))
			return TRUE
		if(ecs.install_directive_disk(src, user))
			user.visible_message(
				SPAN_NOTICE("\The [user] seats \the [src] in \the [ecs]."),
				SPAN_NOTICE("You lock the directive disk into the ECS.")
			)
		return TRUE
	if(ishuman(target) && user && user.zone_sel && (user.zone_sel.selecting == BP_HEAD || user.zone_sel.selecting == BP_MOUTH))
		var/mob/living/carbon/human/H = target
		if(!(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
			return ..()
		if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC))
			to_chat(user, SPAN_WARNING("You have no idea how to seat that disk."))
			return TRUE
		if(user == H)
			to_chat(user, SPAN_WARNING("You cannot change your own directive disk."))
			return TRUE
		var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
		if(!head || !BP_IS_ROBOTIC(head) || head.hatch_state != HATCH_OPENED)
			to_chat(user, SPAN_WARNING("The cranial maintenance hatch must be open."))
			return TRUE
		var/obj/item/organ/internal/ecs/ecs = H.internal_organs_by_name[BP_EXONET]
		if(!ecs)
			to_chat(user, SPAN_WARNING("There is no ECS in this chassis."))
			return TRUE
		if(ecs.directive_disk)
			to_chat(user, SPAN_WARNING("This ECS already has a directive disk installed."))
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts inserting \the [src] into \the [H]'s ECS."),
			SPAN_NOTICE("You start inserting \the [src] into the chassis computer.")
		)
		if(!do_after(user, 6 SECONDS, H, DO_PUBLIC_UNIQUE) || !(src in user))
			return TRUE
		if(head.hatch_state != HATCH_OPENED || !ecs.install_directive_disk(src, user))
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] seats \the [src] in \the [H]'s ECS."),
			SPAN_NOTICE("You lock the directive disk into the chassis computer.")
		)
		return TRUE
	return ..()

/obj/item/stock_parts/computer/hard_drive/portable/directive/proc/sync_to_chassis()
	var/obj/item/organ/internal/ecs/ecs = get_host_ecs()
	if(!ecs)
		return
	ecs.reload_directive_file()
	if(ecs.owner)
		to_chat(ecs.owner, SPAN_DANGER("\[ECS\] Directive file updated. Review chassis directives."))

/obj/item/stock_parts/computer/hard_drive/portable/directive/Topic(href, href_list, state)
	..()
	var/datum/ai_laws/laws = ui_laws || parse_lawset()
	if(!laws)
		laws = new /datum/ai_laws
		laws.shackles = TRUE
	ui_laws = laws
	if(href_list["add_law"])
		var/mod = sanitize(input("Add an instruction", "laws") as text|null)
		if(mod)
			laws.add_inherent_law(mod)
			write_lawset(laws)
			ui_laws = parse_lawset()
			sync_to_chassis()
			return 1
	if(href_list["delete_law"])
		var/datum/ai_law/AL = locate(href_list["delete_law"]) in laws.all_laws()
		if(AL)
			laws.delete_law(AL)
			write_lawset(laws)
			ui_laws = parse_lawset()
			sync_to_chassis()
		return 1
	if(href_list["edit_law"])
		var/datum/ai_law/AL = locate(href_list["edit_law"]) in laws.all_laws()
		if(AL)
			var/new_law = sanitize(input(usr, "Enter new law. Leaving the field blank will cancel the edit.", "Edit Law", AL.law))
			if(new_law && new_law != AL.law)
				AL.law = new_law
				write_lawset(laws)
				ui_laws = parse_lawset()
				sync_to_chassis()
		return 1

/obj/item/stock_parts/computer/hard_drive/portable/directive/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, master_ui = null, datum/topic_state/state = GLOB.default_state)
	var/data[0]
	var/mob/living/carbon/human/H = get_chassis()
	data["computer_master"] = FALSE
	data["hitech_experienced"] = FALSE
	if(user && user.skill_check(SKILL_COMPUTER, SKILL_EXPERIENCED))
		data["computer_master"] = TRUE
	if(user && user.skill_check(SKILL_DEVICES, SKILL_TRAINED) && user.skill_check(SKILL_COMPUTER, SKILL_TRAINED))
		data["hitech_experienced"] = TRUE
	if(user && user.IsHolding(src))
		data["computer_master"] = TRUE
		data["hitech_experienced"] = TRUE
	data["has_owner"] = H ? TRUE : FALSE
	if(H)
		data["name"] = H.name
		var/obj/item/organ/internal/cell/cell = H.internal_organs_by_name[BP_CELL]
		data["charge"] = (cell && cell.cell) ? "[cell.get_charge()]/[cell.cell.maxcharge]" : "N/A"
		data["operational"] = H.stat != DEAD
		data["temperature"] = "[round(H.bodytemperature-T0C)]&deg;C"
	var/datum/ai_laws/laws = ui_laws || parse_lawset()
	ui_laws = laws
	var/law[0]
	if(laws)
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

/obj/item/stock_parts/computer/hard_drive/portable/directive/CanUseTopic(mob/user)
	if(!user || user.stat == DEAD)
		return STATUS_CLOSE
	if(user.IsHolding(src))
		return STATUS_INTERACTIVE
	var/atom/anchor = src
	var/mob/living/carbon/human/H = get_chassis()
	if(H)
		anchor = H
	if(!user.Adjacent(anchor))
		return STATUS_CLOSE
	if(user.IsHolding(/obj/item/device/multitool/multimeter/datajack))
		return user.stat == CONSCIOUS ? STATUS_INTERACTIVE : STATUS_CLOSE
	return STATUS_CLOSE

#undef DIRECTIVE_FILENAME
