/obj/machinery/door_timer/var/datum/computer_file/data/punishment/linked_punishment
/obj/machinery/door_timer/var/sentence_active = FALSE


/obj/machinery/door_timer/proc/load_from_punishment_log(mob/user)
	var/list/options = list()
	var/list/lookup = list()
	for(var/datum/computer_file/data/punishment/P in GLOB.all_punishments)
		if(!P.is_active_brig_sentence())
			continue
		var/label = "[P.fields["offender_name"]] - [P.fields["brig_minutes"]] min ([P.fields["authorized_by"]])"
		options += label
		lookup[label] = P

	if(!LAZYLEN(options))
		to_chat(user, SPAN_WARNING("No active brig sentences found in the Case Dossier."))
		return

	var/choice = input(user, "Select a sentence to load into [id].", "Case Dossier") as null|anything in options
	if(!choice || timing)
		return

	var/datum/computer_file/data/punishment/P = lookup[choice]
	linked_punishment = P
	timeset(text2num(P.fields["brig_minutes"]) * 60)
	to_chat(user, SPAN_NOTICE("Loaded [P.fields["brig_minutes"]] minute sentence for [P.fields["offender_name"]]."))

/obj/machinery/door_timer/OnTopic(mob/user, list/href_list, state)
	. = ..()
	if (href_list["load_punishment"])
		if(!timing)
			load_from_punishment_log(user)
		. = TOPIC_REFRESH
		update_icon()

/obj/machinery/door_timer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = list()

	var/timeval = timing ? timeleft() : timetoset/10
	data["timing"] = timing
	data["minutes"] = round(timeval/60)
	data["seconds"] = timeval % 60
	data["linked_offender"] = linked_punishment ? linked_punishment.fields["offender_name"] : null

	var/list/flashes = list()

	for(var/obj/machinery/flasher/flash in targets)
		var/list/flashdata = list()
		if(flash.last_flash && (flash.last_flash + 150) > world.time)
			flashdata["status"] = 0
		else
			flashdata["status"] = 1
		flashes[LIST_PRE_INC(flashes)] = flashdata

	data["flashes"] = flashes

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-brig_timer.tmpl", name, 270, 185)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
