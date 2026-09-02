/datum/computer_file/report/crew_record/generate_nano_data(list/given_access)
	. = ..()
	.["can_view_violations"] = given_access && (access_security_records in given_access)
	.["violations"] = list()
	if(!.["can_view_violations"])
		return

	var/record_name = get_name()
	for(var/datum/computer_file/data/punishment/P in GLOB.all_punishments)
		if(P.fields["offender_name"] != record_name)
			continue
		.["violations"] += list(list(
			"type" = P.fields["type"],
			"charges" = P.fields["charges"],
			"status" = P.status,
			"authorized_by" = P.fields["authorized_by"],
			"issued" = P.fields["issued"]
		))

/datum/nano_module/program/records/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = host.initial_data(program)
	var/list/user_access = get_record_access(user)

	data["message"] = message
	if(active_record)
		send_rsc(user, active_record.photo_front, "front_[active_record.uid].png")
		send_rsc(user, active_record.photo_side, "side_[active_record.uid].png")
		data["pic_edit"] = check_access(user, access_employment_records) || check_access(user, access_security_records)
		data += active_record.generate_nano_data(user_access)
	else
		var/list/all_records = list()

		for(var/datum/computer_file/report/crew_record/R in GLOB.all_crew_records)
			all_records.Add(list(list(
				"name" = R.get_name(),
				"rank" = R.get_job(),
				"milrank" = R.get_rank(),
				"id" = R.uid
			)))
		data["all_records"] = all_records
		data["creation"] = check_access(user, access_employment_records)
		data["dnasearch"] = check_access(user, access_medical_records) || check_access(user, access_forensics_lockers)
		data["fingersearch"] = check_access(user, access_security_records)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-crew_records.tmpl", name, 700, 540, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
