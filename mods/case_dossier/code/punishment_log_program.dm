/datum/computer_file/program/punishment_log
	filename = "punishlog"
	filedesc = "Case Dossier"
	extended_desc = "Official NTsec program for the issuing and tracking of crew punishments."
	size = 6
	program_icon_state = "warrant"
	program_key_state = "security_key"
	program_menu_icon = "flag"
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
	required_access = access_security
	nanomodule_path = /datum/nano_module/program/punishment_log
	category = PROG_SEC

/datum/nano_module/program/punishment_log
	name = "Case Dossier"
	available_to_ai = TRUE
	var/datum/computer_file/data/punishment/active_punishment
	var/message = null

/datum/nano_module/program/punishment_log/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data(program)

	data["message"] = message
	data["active_punishment"] = null
	data["punishments"] = list()

	if(active_punishment)
		data["active_punishment"] = punishment_ui_data(active_punishment)
	else
		for(var/datum/computer_file/data/punishment/P in GLOB.all_punishments)
			data["punishments"] += list(punishment_ui_data(P, FALSE))

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-punishment_log.tmpl", name, 700, 540, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/program/punishment_log/proc/punishment_ui_data(datum/computer_file/data/punishment/P, detailed = TRUE)
	var/list/data = list(
		"id" = P.uid,
		"offender_name" = P.fields["offender_name"],
		"offender_job" = P.fields["offender_job"],
		"type" = P.fields["type"],
		"authorized_by" = P.fields["authorized_by"],
		"issued" = P.fields["issued"],
		"status" = P.status
	)

	if(detailed)
		data["charges"] = P.fields["charges"]
		data["brig_minutes"] = P.fields["brig_minutes"]
		data["fine_amount"] = P.fields["fine_amount"]
		data["notes"] = P.fields["notes"]
		data["criminal_status"] = P.fields["criminal_status"]
		data["punishment_types"] = GLOB.punishment_types
		data["punishment_statuses"] = GLOB.punishment_statuses
		data["security_statuses"] = GLOB.security_statuses
	else
		var/charges = P.fields["charges"]
		if(LAZYLEN(charges) > 50)
			charges = copytext(charges, 1, 50) + "..."
		data["charges"] = charges

	return data

/datum/nano_module/program/punishment_log/proc/find_punishment_by_id(id)
	if(!id)
		return null
	for(var/datum/computer_file/data/punishment/P in GLOB.all_punishments)
		if(P.uid == id)
			return P
	return null

/datum/nano_module/program/punishment_log/proc/find_offender_mob(offender_name)
	RETURN_TYPE(/mob/living/carbon/human)
	for(var/mob/living/carbon/human/H in GLOB.human_mobs)
		if(H.real_name == offender_name)
			return H
	return null

/datum/nano_module/program/punishment_log/proc/collect_fine(mob/user, datum/computer_file/data/punishment/P)
	var/amount = text2num(P.fields["fine_amount"])
	if(!amount || amount <= 0)
		to_chat(user, SPAN_WARNING("No fine amount was set - nothing was charged."))
		return FALSE

	var/mob/living/carbon/human/H = find_offender_mob(P.fields["offender_name"])
	if(!H)
		to_chat(user, SPAN_WARNING("Unable to locate [P.fields["offender_name"]] to charge the fine."))
		return FALSE

	var/obj/item/card/id/id_card = H.GetIdCard()
	if(!id_card)
		to_chat(user, SPAN_WARNING("[P.fields["offender_name"]] isn't carrying an ID - unable to charge the fine."))
		return FALSE

	var/datum/money_account/payer = get_account(id_card.associated_account_number)
	if(!payer)
		to_chat(user, SPAN_WARNING("[P.fields["offender_name"]] has no linked bank account - unable to charge the fine."))
		return FALSE

	var/datum/job/security_job_ref = /datum/job/officer
	var/datum/money_account/security_account = department_accounts[initial(security_job_ref.department)]
	if(!security_account)
		to_chat(user, SPAN_WARNING("Unable to locate the Security department account - unable to charge the fine."))
		return FALSE

	if(payer.money < amount)
		to_chat(user, SPAN_WARNING("[P.fields["offender_name"]] only has [GLOB.using_map.local_currency_name_short][payer.money], not enough to cover the [GLOB.using_map.local_currency_name_short][amount] fine."))
		return FALSE

	payer.transfer(security_account, amount, "Fine: [P.fields["charges"]]")
	to_chat(user, SPAN_NOTICE("[GLOB.using_map.local_currency_name_short][amount] transferred from [P.fields["offender_name"]]'s account to the Security department account."))
	return TRUE

/datum/nano_module/program/punishment_log/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["back"])
		. = TRUE
		if(active_punishment && !(active_punishment in GLOB.all_punishments))
			qdel(active_punishment)
		active_punishment = null
		return

	if(href_list["clear_message"])
		message = null
		return TRUE

	if(href_list["open_punishment"])
		active_punishment = find_punishment_by_id(text2num(href_list["open_punishment"]))
		return TRUE

	if(href_list["print_punishment"])
		. = TRUE
		if(!program || !program.computer.has_component(PART_PRINTER))
			to_chat(usr, SPAN_WARNING("Hardware Error: Printer not found."))
			return
		var/datum/computer_file/data/punishment/P = active_punishment || find_punishment_by_id(text2num(href_list["print_punishment"]))
		if(!P)
			to_chat(usr, SPAN_WARNING("Internal error: Punishment record not found."))
			return
		program.computer.print_paper(punishment_to_text(P), "Notice of Punishment - [P.fields["offender_name"]]")
		return

	var/mob/user = usr
	if(!istype(user))
		return
	var/obj/item/card/id/I = user.GetIdCard()
	if(!istype(I) || !I.registered_name || !(access_security in I.access))
		to_chat(user, "Authentication error: Unable to locate ID with appropriate access to allow this operation.")
		return

	if(href_list["new_punishment"])
		. = TRUE
		var/datum/computer_file/data/punishment/P = new()
		GLOB.all_punishments -= P // Not a real record until it's explicitly saved.
		P.fields["offender_name"] = "Unknown"
		P.fields["offender_job"] = "N/A"
		P.fields["charges"] = "No charges specified"
		P.fields["type"] = GLOB.punishment_types[1]
		P.fields["brig_minutes"] = ""
		P.fields["fine_amount"] = ""
		P.fields["notes"] = ""
		P.fields["authorized_by"] = "Unauthorized"
		P.fields["criminal_status"] = GLOB.default_security_status
		P.fields["issued"] = "[stationdate2text()] [stationtime2text()]"
		active_punishment = P
		return

	if(href_list["set_status"])
		. = TRUE
		var/datum/computer_file/data/punishment/P = find_punishment_by_id(text2num(href_list["set_status"]))
		var/new_status = href_list["status"]
		if(P && (new_status in GLOB.punishment_statuses))
			P.status = new_status
		return

	if(!active_punishment)
		return

	if(href_list["select_offender"])
		. = TRUE
		var/list/namelist = list()
		for(var/datum/computer_file/report/crew_record/CR in GLOB.all_crew_records)
			namelist += "[CR.get_name()] \[[CR.get_job()]\]"
		var/new_person = sanitize(input(user, "Please select the offender.", "Offender") as null|anything in namelist)
		if(!new_person)
			return
		var/entry_components = splittext(new_person, " \[")
		active_punishment.fields["offender_name"] = entry_components[1]
		active_punishment.fields["offender_job"] = copytext(entry_components[2], 1, LAZYLEN(entry_components[2]))
		return

	if(href_list["custom_offender"])
		. = TRUE
		var/new_name = sanitize(input(user, "Please input the offender's name.", "Offender", active_punishment.fields["offender_name"]) as null|text)
		var/new_job = sanitize(input(user, "Please input the offender's position.", "Offender", active_punishment.fields["offender_job"]) as null|text)
		if(!new_name || !new_job)
			return
		active_punishment.fields["offender_name"] = new_name
		active_punishment.fields["offender_job"] = new_job
		return

	if(href_list["edit_charges"])
		. = TRUE
		var/new_charges = sanitize(input(user, "Please input the charges.", "Charges", active_punishment.fields["charges"]) as null|text)
		if(!new_charges)
			return
		active_punishment.fields["charges"] = new_charges
		return

	if(href_list["edit_type"])
		. = TRUE
		var/new_type = input(user, "Please select the type of punishment.", "Punishment", active_punishment.fields["type"]) as null|anything in GLOB.punishment_types
		if(!new_type)
			return
		active_punishment.fields["type"] = new_type
		return

	if(href_list["edit_brig_minutes"])
		. = TRUE
		var/new_minutes = input(user, "Please input the brig sentence, in minutes.", "Brig Time", text2num(active_punishment.fields["brig_minutes"])) as null|num
		if(isnull(new_minutes))
			return
		active_punishment.fields["brig_minutes"] = "[max(0, round(new_minutes))]"
		return

	if(href_list["edit_fine_amount"])
		. = TRUE
		var/new_amount = input(user, "Please input the fine amount, in credits.", "Fine", text2num(active_punishment.fields["fine_amount"])) as null|num
		if(isnull(new_amount))
			return
		active_punishment.fields["fine_amount"] = "[max(0, round(new_amount))]"
		return

	if(href_list["edit_notes"])
		. = TRUE
		var/new_notes = sanitize(input(user, "Please input any additional notes.", "Notes", active_punishment.fields["notes"]) as null|message)
		if(isnull(new_notes))
			return
		active_punishment.fields["notes"] = new_notes
		return

	if(href_list["edit_criminal_status"])
		. = TRUE
		var/new_status = input(user, "Update the offender's criminal status on their crew record.", "Criminal Status", active_punishment.fields["criminal_status"]) as null|anything in GLOB.security_statuses
		if(!new_status)
			return
		active_punishment.fields["criminal_status"] = new_status
		return

	if(href_list["authorize"])
		. = TRUE
		active_punishment.fields["authorized_by"] = "[I.registered_name] - [I.assignment ? I.assignment : "(Unknown)"]"
		return

	if(href_list["sync_criminal_status"])
		. = TRUE
		if(!(access_brig in I.access))
			to_chat(user, "Authentication error: Unable to locate ID with appropriate access to allow this operation.")
			return
		var/datum/computer_file/report/crew_record/CR = get_crewmember_record(active_punishment.fields["offender_name"])
		if(!CR)
			to_chat(user, SPAN_NOTICE("No matching crew record found for [active_punishment.fields["offender_name"]]."))
			return
		CR.set_criminalStatus(active_punishment.fields["criminal_status"])
		var/mob/living/carbon/human/H = find_offender_mob(active_punishment.fields["offender_name"])
		if(H)
			SET_BIT(H.hud_updateflag, WANTED_HUD)
			H.handle_regular_hud_updates()
		to_chat(user, SPAN_NOTICE("Crew record updated to reflect criminal status: [active_punishment.fields["criminal_status"]]."))
		return

	if(href_list["save_punishment"])
		. = TRUE
		var/is_new = !(active_punishment in GLOB.all_punishments)
		GLOB.all_punishments |= active_punishment
		if(is_new && active_punishment.fields["type"] == "Fine")
			collect_fine(user, active_punishment)
		broadcast_security_hud_message("\A punishment ([active_punishment.fields["type"]]) has been [is_new ? "issued to" : "updated for"] <b>[active_punishment.fields["offender_name"]]</b>.", nano_host())
		message = "Punishment record for [active_punishment.fields["offender_name"]] saved."
		active_punishment = null
		return

	if(href_list["delete_punishment"])
		. = TRUE
		GLOB.all_punishments -= active_punishment
		qdel(active_punishment)
		active_punishment = null
		return

/datum/nano_module/program/punishment_log/proc/punishment_to_text(datum/computer_file/data/punishment/P)
	. = "\[center]\[h3]" + GLOB.using_map.station_name + " Notice of Punishment\[/center]\[/h3] \
	      \[b]System: \[/b]" + GLOB.using_map.system_name
	. += "\n\n\[b]Offender: \[/b]" + P.fields["offender_name"]
	. += "\n\[b]Position: \[/b]" + P.fields["offender_job"]
	. += "\n\n\[b]Charges: \[/b]" + P.fields["charges"]
	. += "\n\[b]Punishment: \[/b]" + P.fields["type"]
	if(P.fields["type"] == "Brig Time" && P.fields["brig_minutes"])
		. += " ([P.fields["brig_minutes"]] minutes)"
	if(P.fields["type"] == "Fine" && P.fields["fine_amount"])
		. += " ([P.fields["fine_amount"]] credits)"
	if(P.fields["notes"])
		. += "\n\[b]Notes: \[/b]" + P.fields["notes"]
	. += "\n\n\[b]Issued: \[/b]" + P.fields["issued"]
	. += "\n\[b]Authorized by: \[/b]" + P.fields["authorized_by"]
	. += "\n\[b]Status: \[/b]" + P.status
	. += "\n\n\[small]THIS DOCUMENT IS AN OFFICIAL RECORD OF DISCIPLINARY ACTION TAKEN BY SHIP SECURITY.\[/small]"
