/// Collects whitelist machinery as created/modified/moved/destroyed deltas.
/proc/odyssey_collect_machinery()
	var/list/entries = list()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/live_ids = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		odyssey_collect_machinery_turf(T, entries, live_ids, state)
		CHECK_TICK
	odyssey_finish_machinery_destroyed(entries, live_ids, state)
	return entries


/proc/odyssey_collect_machinery_turf(turf/T, list/entries, list/live_ids, datum/odyssey_state/state)
	if (!istype(T) || !islist(entries) || !islist(live_ids))
		return
	for (var/obj/machinery/M in T)
		if (QDELETED(M) || M.loc != T || !odyssey_machinery_whitelisted(M))
			continue
		var/id = M.odyssey_persist_id || odyssey_assign_runtime_id(M)
		live_ids[id] = TRUE
		var/list/baseline = state?.machinery_baseline?[id]
		var/list/entry = odyssey_machinery_entry(M, baseline)
		if (entry)
			entries += list(entry)


/proc/odyssey_finish_machinery_destroyed(list/entries, list/live_ids, datum/odyssey_state/state)
	if (!islist(entries) || !islist(live_ids) || !istype(state))
		return
	for (var/id in state.machinery_baseline)
		if (!live_ids[id])
			entries += list(list("id" = id, "action" = "destroyed"))
	return entries


/proc/odyssey_machinery_entry(obj/machinery/M, list/baseline)
	if (!istype(M))
		return null
	var/max_health = M.get_max_health()
	var/cur_health = M.get_current_health()
	var/damaged = max_health > 0 && cur_health < max_health
	var/broken = !!M.reason_broken
	var/turf/T = get_turf(M)
	if (!T)
		return null
	var/action = islist(baseline) ? "modified" : "created"
	if (islist(baseline) && (baseline["x"] != T.x || baseline["y"] != T.y || baseline["z"] != T.z))
		action = "moved"
	var/list/airlock_state
	if (istype(M, /obj/machinery/door/airlock))
		airlock_state = odyssey_airlock_state(M)
	var/list/fabricator_materials
	var/list/fab_disk
	var/list/fab_disk2
	if (istype(M, /obj/machinery/fabricator))
		var/obj/machinery/fabricator/F = M
		fabricator_materials = odyssey_fabricator_materials_state(F)
		fab_disk = odyssey_serialize_portable_drive(F.disk)
		fab_disk2 = odyssey_serialize_portable_drive(F.disk2)
	var/list/computer_programs
	var/list/console_drive
	if (istype(M, /obj/machinery/computer/modular))
		var/obj/machinery/computer/modular/console = M
		computer_programs = odyssey_serialize_modular_computer_programs(console)
		if (istype(console.portable_drive))
			console_drive = odyssey_serialize_portable_drive(console.portable_drive)
	var/list/fridge_items
	var/is_chem_fridge = istype(M, /obj/machinery/smartfridge) && odyssey_smartfridge_chemistry_persistable(M)
	if (is_chem_fridge)
		fridge_items = odyssey_serialize_smartfridge(M)
	var/list/anomaly_state
	if (istype(M, /obj/machinery/anomaly_container))
		anomaly_state = odyssey_serialize_anomaly_container(M)
	var/list/artifact_state
	if (istype(M, /obj/machinery/artifact))
		artifact_state = odyssey_serialize_artifact(M)
	var/list/smes_state
	if (istype(M, /obj/machinery/power/smes))
		smes_state = odyssey_serialize_smes(M)
	var/list/shield_state
	if (istype(M, /obj/machinery/power/shield_generator))
		shield_state = odyssey_serialize_shield_generator(M)
	var/list/cryo_state
	if (istype(M, /obj/machinery/atmospherics/unary/cryo_cell))
		cryo_state = odyssey_serialize_cryo_cell(M)
	var/list/portable_state
	if (istype(M, /obj/machinery/portable_atmospherics))
		portable_state = odyssey_serialize_portable_atmospherics(M)
	var/changed = action != "modified" || damaged || broken || M.emagged || M.panel_open \
		|| baseline["dir"] != M.dir || baseline["name"] != M.name || baseline["anchored"] != M.anchored \
		|| (baseline["pixel_x"] || 0) != M.pixel_x || (baseline["pixel_y"] || 0) != M.pixel_y \
		|| islist(airlock_state) || islist(fabricator_materials) || is_chem_fridge \
		|| islist(anomaly_state) || islist(artifact_state) \
		|| islist(smes_state) || islist(shield_state) || islist(cryo_state) \
		|| islist(portable_state) || islist(fab_disk) || islist(fab_disk2) \
		|| islist(computer_programs) || islist(console_drive)
	if (!changed)
		return null
	var/list/entry = odyssey_base_object_entry(M)
	entry += list(
		"action" = action,
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"health" = cur_health,
		"max_health" = max_health,
		"reason_broken" = M.reason_broken,
		"emagged" = M.emagged,
		"panel_open" = M.panel_open
	)
	if (islist(airlock_state))
		entry["airlock"] = airlock_state
	if (islist(fabricator_materials))
		entry["stored_material"] = fabricator_materials
	if (islist(fab_disk))
		entry["fab_disk"] = fab_disk
	if (islist(fab_disk2))
		entry["fab_disk2"] = fab_disk2
	if (islist(computer_programs))
		entry["computer_programs"] = computer_programs
	if (islist(console_drive))
		entry["console_drive"] = console_drive
	if (is_chem_fridge)
		entry["fridge_items"] = fridge_items || list()
	if (islist(anomaly_state))
		entry["anomaly"] = anomaly_state
	if (islist(artifact_state))
		entry["artifact"] = artifact_state
	if (islist(smes_state))
		entry["smes"] = smes_state
	if (islist(shield_state))
		entry["shield"] = shield_state
	if (islist(cryo_state))
		entry["cryo"] = cryo_state
	if (islist(portable_state))
		entry["portable"] = portable_state
	return entry


/// One stocked atom inside a chemistry smartfridge (beaker/bottle/pill bottle + reagents).
/proc/odyssey_serialize_smartfridge_item(obj/item/I)
	if (!istype(I) || QDELETED(I))
		return null
	if (odyssey_item_path_denylisted(I.type) && !istype(I, /obj/item/reagent_containers) && !istype(I, /obj/item/storage/pill_bottle))
		return null
	var/list/entry = list("type" = "[I.type]")
	if (I.name != initial(I.name))
		entry["name"] = I.name
	if (istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		var/amount = S.get_amount()
		if (!isnum(amount) || amount < 1)
			return null
		entry["amount"] = amount
	if (istype(I, /obj/item/reagent_containers))
		entry["reagents"] = odyssey_serialize_reagents(I)
	if (istype(I, /obj/item/storage))
		var/list/nested = list()
		for (var/obj/item/child in I)
			var/list/child_entry = odyssey_serialize_smartfridge_item(child)
			if (islist(child_entry))
				nested += list(child_entry)
		if (length(nested))
			entry["contents"] = nested
	return entry


/proc/odyssey_serialize_smartfridge(obj/machinery/smartfridge/F)
	if (!istype(F) || !islist(F.item_records))
		return list()
	var/list/out = list()
	for (var/datum/stored_items/store in F.item_records)
		if (!istype(store))
			continue
		if (islist(store.instances))
			for (var/obj/item/I in store.instances)
				if (length(out) >= ODYSSEY_SMARTFRIDGE_MAX_ITEMS)
					return out
				var/list/entry = odyssey_serialize_smartfridge_item(I)
				if (islist(entry))
					out += list(entry)
		// Virtual stock without live instances — spawn-from-path placeholders.
		var/virtual = store.get_amount() - (islist(store.instances) ? length(store.instances) : 0)
		if (virtual > 0 && ispath(store.item_path, /obj/item))
			for (var/i in 1 to virtual)
				if (length(out) >= ODYSSEY_SMARTFRIDGE_MAX_ITEMS)
					return out
				out += list(list("type" = "[store.item_path]"))
	return out


/proc/odyssey_clear_smartfridge(obj/machinery/smartfridge/F)
	if (!istype(F))
		return
	for (var/datum/stored_items/store in F.item_records)
		qdel(store)
	F.item_records = list()
	F.currently_vending = null


/proc/odyssey_spawn_smartfridge_item(list/entry, atom/spawn_at)
	if (!islist(entry) || !spawn_at)
		return null
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (!ispath(path, /obj/item))
		return null
	if (odyssey_item_path_denylisted(path) && !ispath(path, /obj/item/reagent_containers) && !ispath(path, /obj/item/storage/pill_bottle))
		return null
	var/obj/item/I
	if (ispath(path, /obj/item/stack))
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!isnum(amount) || amount < 1)
			amount = 1
		I = new path(spawn_at, amount)
	else
		I = new path(spawn_at)
	if (QDELETED(I) || !istype(I))
		return null
	odyssey_clear_item_autofill(I)
	if (entry["name"])
		I.SetName(entry["name"])
	if (istype(I, /obj/item/reagent_containers) && ("reagents" in entry))
		odyssey_apply_reagents(I, entry["reagents"])
	if (istype(I, /obj/item/storage) && islist(entry["contents"]))
		for (var/list/child_entry in entry["contents"])
			var/obj/item/child = odyssey_spawn_smartfridge_item(child_entry, I)
			if (istype(child) && child.loc != I)
				child.forceMove(I)
	return I


/proc/odyssey_apply_smartfridge_items(obj/machinery/smartfridge/F, list/entries)
	if (!istype(F))
		return
	odyssey_clear_smartfridge(F)
	if (!islist(entries))
		F.update_icon()
		return
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/obj/item/I = odyssey_spawn_smartfridge_item(entry, F)
		if (!istype(I))
			continue
		if (!F.stock_item(I))
			qdel(I)
		CHECK_TICK
	F.update_icon()


/// --- Anomaly containers / artifacts ---

/proc/odyssey_serialize_artifact_trigger(datum/artifact_trigger/T)
	if (!istype(T))
		return null
	var/list/entry = list(
		"type" = "[T.type]",
		"name" = T.name,
		"toggle" = !!T.toggle,
		"trigger_type" = T.trigger_type
	)
	if (istype(T, /datum/artifact_trigger/chemical))
		var/datum/artifact_trigger/chemical/C = T
		var/list/chems = list()
		if (islist(C.required_chemicals))
			for (var/path in C.required_chemicals)
				chems += "[path]"
		entry["required_chemicals"] = chems
	if (istype(T, /datum/artifact_trigger/gas))
		var/datum/artifact_trigger/gas/G = T
		var/list/gases = list()
		if (islist(G.gas_needed))
			for (var/g in G.gas_needed)
				gases["[g]"] = G.gas_needed[g]
		entry["gas_needed"] = gases
	if (istype(T, /datum/artifact_trigger/temperature))
		var/datum/artifact_trigger/temperature/Temp = T
		if (isnull(Temp.min_temp) || Temp.min_temp <= -1e9)
			entry["min_temp"] = "neginf"
		else
			entry["min_temp"] = Temp.min_temp
		if (isnull(Temp.max_temp) || Temp.max_temp >= 1e9)
			entry["max_temp"] = "inf"
		else
			entry["max_temp"] = Temp.max_temp
	return entry


/proc/odyssey_serialize_artifact_effect(datum/artifact_effect/E)
	if (!istype(E))
		return null
	var/list/entry = list(
		"type" = "[E.type]",
		"name" = E.name,
		"effect" = E.effect,
		"effectrange" = E.effectrange,
		"activated" = !!E.activated,
		"chargelevel" = E.chargelevel,
		"chargelevelmax" = E.chargelevelmax,
		"artifact_id" = E.artifact_id,
		"effect_type" = E.effect_type,
		"toggled" = !!E.toggled,
		"on_time" = E.on_time
	)
	var/list/trigger = odyssey_serialize_artifact_trigger(E.trigger)
	if (islist(trigger))
		entry["trigger"] = trigger
	return entry


/proc/odyssey_serialize_artifact(obj/machinery/artifact/A)
	if (!istype(A) || QDELETED(A))
		return null
	var/list/entry = list(
		"type" = "[A.type]",
		"name" = A.name,
		"desc" = A.desc,
		"icon_num" = A.icon_num,
		"icon_state" = A.icon_state,
		"health" = A.get_current_health(),
		"max_health" = A.get_max_health(),
		"can_damage" = !!A.can_damage,
		"damage_type" = A.damage_type,
		"damage_desc" = A.damage_desc
	)
	var/list/primary = odyssey_serialize_artifact_effect(A.my_effect)
	if (islist(primary))
		entry["my_effect"] = primary
	var/list/secondary = odyssey_serialize_artifact_effect(A.secondary_effect)
	if (islist(secondary))
		entry["secondary_effect"] = secondary
	return entry


/proc/odyssey_serialize_anomaly_container(obj/machinery/anomaly_container/C)
	if (!istype(C))
		return null
	if (!C.contained && !C.attached_paper && !C.broken)
		return null
	var/list/entry = list("broken" = !!C.broken)
	if (istype(C.contained))
		var/list/art = odyssey_serialize_artifact(C.contained)
		if (islist(art))
			entry["artifact"] = art
	if (istype(C.attached_paper))
		var/obj/item/paper/P = C.attached_paper
		var/list/paper = list("type" = "[P.type]", "info" = P.info || "", "title" = P.name || "")
		if (P.stamps)
			paper["stamps"] = P.stamps
		entry["paper"] = paper
	return entry


/proc/odyssey_apply_artifact_trigger(datum/artifact_trigger/T, list/data)
	if (!istype(T) || !islist(data))
		return
	if (data["name"])
		T.name = data["name"]
	if (!isnull(data["toggle"]))
		T.toggle = !!data["toggle"]
	if (!isnull(data["trigger_type"]))
		T.trigger_type = data["trigger_type"]
	if (istype(T, /datum/artifact_trigger/chemical) && islist(data["required_chemicals"]))
		var/datum/artifact_trigger/chemical/C = T
		var/list/chems = list()
		for (var/chem_text in data["required_chemicals"])
			var/path = odyssey_resolve_path(chem_text)
			if (ispath(path, /datum/reagent))
				chems += path
		if (length(chems))
			C.required_chemicals = chems
	if (istype(T, /datum/artifact_trigger/gas) && islist(data["gas_needed"]))
		var/datum/artifact_trigger/gas/G = T
		var/list/gases = list()
		for (var/g in data["gas_needed"])
			var/amount = data["gas_needed"][g]
			if (!isnum(amount))
				amount = text2num(amount)
			if (!isnum(amount))
				continue
			gases[g] = amount
		if (length(gases))
			G.gas_needed = gases
	if (istype(T, /datum/artifact_trigger/temperature))
		var/datum/artifact_trigger/temperature/Temp = T
		var/min_raw = data["min_temp"]
		var/max_raw = data["max_temp"]
		if (min_raw == "neginf")
			Temp.min_temp = -INFINITY
		else if (!isnull(min_raw))
			Temp.min_temp = isnum(min_raw) ? min_raw : text2num(min_raw)
		if (max_raw == "inf")
			Temp.max_temp = INFINITY
		else if (!isnull(max_raw))
			Temp.max_temp = isnum(max_raw) ? max_raw : text2num(max_raw)


/proc/odyssey_spawn_artifact_effect(atom/holder, list/data)
	if (!istype(holder) || !islist(data))
		return null
	var/path = odyssey_resolve_path(data["type"])
	if (!ispath(path, /datum/artifact_effect))
		return null
	var/datum/artifact_effect/E = new path(holder)
	if (!istype(E))
		return null
	if (data["name"])
		E.name = data["name"]
	if (!isnull(data["effect"]))
		E.effect = data["effect"]
	if (!isnull(data["effectrange"]))
		E.effectrange = data["effectrange"]
	if (!isnull(data["chargelevel"]))
		E.chargelevel = data["chargelevel"]
	if (!isnull(data["chargelevelmax"]))
		E.chargelevelmax = data["chargelevelmax"]
	if (data["artifact_id"])
		E.artifact_id = data["artifact_id"]
	if (!isnull(data["effect_type"]))
		E.effect_type = data["effect_type"]
	if (!isnull(data["on_time"]))
		E.on_time = data["on_time"]
	E.activated = FALSE
	E.toggled = !!data["toggled"]
	QDEL_NULL(E.trigger)
	if (islist(data["trigger"]))
		var/tpath = odyssey_resolve_path(data["trigger"]["type"])
		if (ispath(tpath, /datum/artifact_trigger))
			E.trigger = new tpath
			odyssey_apply_artifact_trigger(E.trigger, data["trigger"])
	if (!E.trigger)
		E.trigger = new /datum/artifact_trigger/touch
	// Activate only after trigger is restored; keep suspended artifacts off.
	if (data["activated"] && !istype(holder.loc, /obj/machinery/anomaly_container) && !istype(holder, /obj/machinery/anomaly_container))
		E.activated = TRUE
	return E


/proc/odyssey_apply_artifact_state(obj/machinery/artifact/A, list/data)
	if (!istype(A) || !islist(data))
		return
	QDEL_NULL(A.my_effect)
	QDEL_NULL(A.secondary_effect)
	if (data["name"])
		A.SetName(data["name"])
	if (data["desc"])
		A.desc = data["desc"]
	if (!isnull(data["icon_num"]))
		A.icon_num = data["icon_num"]
	if (data["icon_state"])
		A.icon_state = data["icon_state"]
	else
		A.icon_state = "ano[A.icon_num]0"
	A.my_effect = odyssey_spawn_artifact_effect(A, data["my_effect"])
	if (islist(data["secondary_effect"]))
		A.secondary_effect = odyssey_spawn_artifact_effect(A, data["secondary_effect"])
	A.can_damage = !!data["can_damage"]
	if (!isnull(data["damage_type"]))
		A.damage_type = data["damage_type"]
	if (data["damage_desc"])
		A.damage_desc = data["damage_desc"]
	var/max_health = data["max_health"]
	if (isnum(max_health) && max_health > 0)
		A.set_max_health(max_health)
	var/health = data["health"]
	if (isnum(health))
		A.set_health(health)
	A.being_used = FALSE
	A.update_icon()


/proc/odyssey_apply_anomaly_container(obj/machinery/anomaly_container/C, list/data)
	if (!istype(C) || !islist(data))
		return
	if (C.contained)
		var/obj/machinery/artifact/old = C.contained
		C.contained = null
		C.underlays.Cut()
		qdel(old)
	if (C.attached_paper)
		QDEL_NULL(C.attached_paper)
	C.broken = !!data["broken"]
	if (islist(data["artifact"]))
		var/obj/machinery/artifact/A = new /obj/machinery/artifact(get_turf(C))
		odyssey_apply_artifact_state(A, data["artifact"])
		// Force suspension while caged.
		if (A.my_effect)
			A.my_effect.activated = FALSE
		if (A.secondary_effect)
			A.secondary_effect.activated = FALSE
		C.contain(A)
	if (islist(data["paper"]))
		var/list/paper = data["paper"]
		var/ppath = odyssey_resolve_path(paper["type"])
		if (!ispath(ppath, /obj/item/paper))
			ppath = /obj/item/paper
		var/obj/item/paper/P = new ppath(C)
		var/title = paper["title"] || paper["name"]
		P.set_content(paper["info"] || "", title, FALSE)
		if (paper["stamps"])
			P.stamps = paper["stamps"]
		C.attached_paper = P
	if (C.health_dead() || C.broken)
		C.icon_state = "anomaly_container_broken"
	C.update_icon()


/// Non-empty fabricator bunkers as mat_name = amount. Keys are material name strings (RnD lathe).
/proc/odyssey_fabricator_materials_state(obj/machinery/fabricator/F)
	if (!istype(F) || !islist(F.stored_material) || !length(F.stored_material))
		return null
	var/list/materials = list()
	for (var/mat in F.stored_material)
		var/amount = F.stored_material[mat]
		if (!isnum(amount) || amount <= 0)
			continue
		materials["[mat]"] = amount
	if (!length(materials))
		return null
	return materials


/proc/odyssey_apply_fabricator_materials(obj/machinery/fabricator/F, list/data)
	if (!istype(F) || !islist(data))
		return
	F.stored_material = list()
	var/capacity = F.storage_capacity
	for (var/mat in data)
		var/amount = data[mat]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!isnum(amount) || amount <= 0)
			continue
		if (isnum(capacity) && capacity > 0)
			amount = min(amount, capacity)
		F.stored_material[mat] = amount


/proc/odyssey_serialize_hdd_files(obj/item/stock_parts/computer/hard_drive/HDD)
	var/list/files = list()
	if (!istype(HDD))
		return files
	for (var/datum/computer_file/F in HDD.stored_files)
		if (!istype(F) || F.undeletable)
			continue
		if (istype(F, /datum/computer_file/program))
			files += list(list(
				"kind" = "program",
				"type" = "[F.type]",
				"filename" = F.filename
			))
			continue
		if (istype(F, /datum/computer_file/binary/design))
			var/datum/computer_file/binary/design/DF = F
			if (!DF.design)
				continue
			if (DF.design.reverse_engineered)
				var/list/payload = odyssey_rnd_serialize_re_design(DF.design)
				if (islist(payload))
					files += list(list(
						"kind" = "re_design",
						"filename" = F.filename,
						"design" = payload
					))
				continue
			files += list(list(
				"kind" = "design",
				"filename" = F.filename,
				"id" = "[DF.design.id]"
			))
	return files


/proc/odyssey_apply_hdd_files(obj/item/stock_parts/computer/hard_drive/HDD, list/files)
	if (!istype(HDD) || !islist(files))
		return
	var/was_ro = HDD.read_only
	HDD.read_only = FALSE
	var/list/kept = list()
	for (var/datum/computer_file/F in HDD.stored_files)
		if (istype(F) && F.undeletable)
			kept += F
	HDD.stored_files = kept
	HDD.recalculate_size()
	for (var/entry in files)
		if (!islist(entry))
			continue
		var/list/file_entry = entry
		var/kind = file_entry["kind"]
		if (kind == "program")
			var/prog_path = odyssey_resolve_path(file_entry["type"])
			if (!ispath(prog_path, /datum/computer_file/program))
				continue
			var/datum/computer_file/program/P = new prog_path()
			if (file_entry["filename"])
				P.filename = file_entry["filename"]
			HDD.create_file(P)
			continue
		if (kind == "design")
			var/datum/design/D = odyssey_rnd_find_catalog_design(file_entry["id"])
			if (!D?.file)
				continue
			var/datum/computer_file/binary/design/DF = D.file.clone()
			if (file_entry["filename"])
				DF.filename = file_entry["filename"]
			HDD.create_file(DF)
			continue
		if (kind == "re_design")
			var/datum/design/RE = odyssey_rnd_restore_re_design(file_entry["design"])
			if (!istype(RE) || !RE.file)
				continue
			var/datum/computer_file/binary/design/DF = RE.file.clone()
			if (file_entry["filename"])
				DF.filename = file_entry["filename"]
			HDD.create_file(DF)
	HDD.read_only = was_ro


/proc/odyssey_serialize_portable_drive(obj/item/stock_parts/computer/hard_drive/portable/D)
	if (!istype(D))
		return null
	return list(
		"type" = "[D.type]",
		"name" = D.name,
		"read_only" = !!D.read_only,
		"files" = odyssey_serialize_hdd_files(D)
	)


/proc/odyssey_apply_portable_drive_slot(obj/machinery/fabricator/F, slot, list/data)
	if (!istype(F) || !islist(data))
		return
	var/obj/item/stock_parts/computer/hard_drive/portable/existing
	if (slot == 2)
		existing = F.disk2
	else
		existing = F.disk
	if (istype(existing))
		qdel(existing)
		if (slot == 2)
			F.disk2 = null
		else
			F.disk = null
	var/path = odyssey_resolve_path(data["type"])
	if (!ispath(path, /obj/item/stock_parts/computer/hard_drive/portable))
		path = /obj/item/stock_parts/computer/hard_drive/portable
	var/obj/item/stock_parts/computer/hard_drive/portable/D = new path(F)
	if (data["name"])
		D.SetName(data["name"])
	if (!isnull(data["read_only"]))
		D.read_only = !!data["read_only"]
	odyssey_apply_hdd_files(D, data["files"])
	if (slot == 2)
		F.disk2 = D
	else
		F.disk = D


/proc/odyssey_serialize_modular_computer_programs(obj/machinery/computer/modular/C)
	if (!istype(C))
		return null
	var/obj/item/stock_parts/computer/hard_drive/HDD = C.get_component_of_type(/obj/item/stock_parts/computer/hard_drive)
	if (!istype(HDD))
		return null
	var/list/files = odyssey_serialize_hdd_files(HDD)
	if (!length(files))
		return null
	return files


/proc/odyssey_apply_modular_computer_programs(obj/machinery/computer/modular/C, list/files)
	if (!istype(C) || !islist(files))
		return
	var/obj/item/stock_parts/computer/hard_drive/HDD = C.get_component_of_type(/obj/item/stock_parts/computer/hard_drive)
	if (!istype(HDD))
		return
	odyssey_apply_hdd_files(HDD, files)


/proc/odyssey_serialize_smes(obj/machinery/power/smes/S)
	if (!istype(S))
		return null
	return list(
		"charge" = S.charge,
		"capacity" = S.capacity,
		"input_attempt" = !!S.input_attempt,
		"input_level" = S.input_level,
		"output_attempt" = !!S.output_attempt,
		"output_level" = S.output_level,
		"name_tag" = S.name_tag
	)


/proc/odyssey_apply_smes(obj/machinery/power/smes/S, list/data)
	if (!istype(S) || !islist(data))
		return
	if (isnum(data["capacity"]) && data["capacity"] > 0)
		S.capacity = data["capacity"]
	if (isnum(data["charge"]))
		S.charge = clamp(data["charge"], 0, S.capacity)
	if (!isnull(data["input_attempt"]))
		S.input_attempt = !!data["input_attempt"]
	if (isnum(data["input_level"]))
		S.input_level = clamp(data["input_level"], 0, S.input_level_max)
	if (!isnull(data["output_attempt"]))
		S.output_attempt = !!data["output_attempt"]
	if (isnum(data["output_level"]))
		S.output_level = clamp(data["output_level"], 0, S.output_level_max)
	if (!isnull(data["name_tag"]))
		S.name_tag = data["name_tag"]
	S.update_icon()


/proc/odyssey_serialize_shield_generator(obj/machinery/power/shield_generator/G)
	if (!istype(G))
		return null
	return list(
		"running" = G.running,
		"current_energy" = G.current_energy,
		"max_energy" = G.max_energy,
		"field_radius" = G.field_radius,
		"target_radius" = G.target_radius,
		"shield_modes" = G.shield_modes,
		"input_cap" = G.input_cap,
		"overloaded" = !!G.overloaded,
		"offline_for" = G.offline_for,
		"mitigation_em" = G.mitigation_em,
		"mitigation_physical" = G.mitigation_physical,
		"mitigation_heat" = G.mitigation_heat,
		"idle_multiplier" = G.idle_multiplier
	)


/proc/odyssey_apply_shield_generator(obj/machinery/power/shield_generator/G, list/data)
	if (!istype(G) || !islist(data))
		return
	if (isnum(data["max_energy"]) && data["max_energy"] > 0)
		G.max_energy = data["max_energy"]
	if (isnum(data["current_energy"]))
		G.current_energy = clamp(data["current_energy"], 0, G.max_energy)
	if (isnum(data["field_radius"]))
		G.field_radius = max(1, data["field_radius"])
	if (isnum(data["target_radius"]))
		G.target_radius = max(1, data["target_radius"])
	if (!isnull(data["shield_modes"]))
		G.shield_modes = data["shield_modes"]
	if (isnum(data["input_cap"]))
		G.input_cap = data["input_cap"]
	if (!isnull(data["overloaded"]))
		G.overloaded = !!data["overloaded"]
	if (isnum(data["offline_for"]))
		G.offline_for = max(0, data["offline_for"])
	if (isnum(data["mitigation_em"]))
		G.mitigation_em = data["mitigation_em"]
	if (isnum(data["mitigation_physical"]))
		G.mitigation_physical = data["mitigation_physical"]
	if (isnum(data["mitigation_heat"]))
		G.mitigation_heat = data["mitigation_heat"]
	if (isnum(data["idle_multiplier"]))
		G.idle_multiplier = data["idle_multiplier"]
	G.update_upkeep_multiplier()
	var/want_running = data["running"]
	if (!isnum(want_running))
		want_running = text2num(want_running)
	if (!isnum(want_running))
		want_running = SHIELD_OFF
	// OFF/DISCHARGING → down. RUNNING/IDLE kept; SPINNING_UP collapses to RUNNING.
	// regenerate_field() no-ops when running is falsy — set a live state first.
	if (want_running <= SHIELD_DISCHARGING)
		G.shutdown_field()
	else
		G.running = (want_running == SHIELD_SPINNING_UP) ? SHIELD_RUNNING : want_running
		G.regenerate_field()
	G.update_icon()

/proc/odyssey_serialize_cryo_cell(obj/machinery/atmospherics/unary/cryo_cell/C)
	if (!istype(C))
		return null
	if (!C.on && !C.beaker)
		return null
	var/list/entry = list(
		"on" = !!C.on,
		"current_stasis_mult" = C.current_stasis_mult
	)
	if (istype(C.beaker, /obj/item/reagent_containers))
		var/list/beaker = list("type" = "[C.beaker.type]", "name" = C.beaker.name)
		beaker["reagents"] = odyssey_serialize_reagents(C.beaker)
		entry["beaker"] = beaker
	return entry


/proc/odyssey_apply_cryo_cell(obj/machinery/atmospherics/unary/cryo_cell/C, list/data)
	if (!istype(C) || !islist(data))
		return
	if (C.beaker)
		qdel(C.beaker)
		C.beaker = null
	if (islist(data["beaker"]))
		var/list/beaker_data = data["beaker"]
		var/bpath = odyssey_resolve_path(beaker_data["type"])
		if (ispath(bpath, /obj/item/reagent_containers/glass))
			var/obj/item/reagent_containers/glass/B = new bpath(C)
			if (beaker_data["name"])
				B.SetName(beaker_data["name"])
			if ("reagents" in beaker_data)
				odyssey_apply_reagents(B, beaker_data["reagents"])
			C.beaker = B
	if (isnum(data["current_stasis_mult"]))
		C.current_stasis_mult = data["current_stasis_mult"]
	C.on = !!data["on"]
	C.update_use_power(C.on ? POWER_USE_ACTIVE : POWER_USE_IDLE)
	C.update_icon()


/proc/odyssey_serialize_gas_mixture(datum/gas_mixture/mix)
	if (!istype(mix))
		return null
	var/list/gases = list()
	for (var/gasid in mix.gas)
		var/moles = mix.gas[gasid]
		if (!isnum(moles) || moles <= 0)
			continue
		gases[gasid] = moles
	return list(
		"volume" = mix.volume,
		"temperature" = mix.temperature,
		"gas" = gases
	)


/proc/odyssey_apply_gas_mixture(datum/gas_mixture/mix, list/data)
	if (!istype(mix) || !islist(data))
		return
	mix.gas.Cut()
	if (isnum(data["volume"]) && data["volume"] > 0)
		mix.volume = data["volume"]
	if (isnum(data["temperature"]))
		mix.temperature = max(0, data["temperature"])
	if (islist(data["gas"]))
		for (var/gasid in data["gas"])
			var/moles = data["gas"][gasid]
			if (!isnum(moles))
				moles = text2num(moles)
			if (!isnum(moles) || moles <= 0)
				continue
			mix.gas[gasid] = moles
	mix.update_values()


/proc/odyssey_serialize_holding_tank(obj/item/tank/tank)
	if (!istype(tank))
		return null
	var/list/entry = list("type" = "[tank.type]")
	if (tank.name != initial(tank.name))
		entry["name"] = tank.name
	entry["air"] = odyssey_serialize_gas_mixture(tank.air_contents)
	return entry


/proc/odyssey_apply_holding_tank(obj/machinery/portable_atmospherics/P, list/data)
	if (!istype(P))
		return
	if (P.holding)
		qdel(P.holding)
		P.holding = null
	if (!islist(data))
		return
	var/path = odyssey_resolve_path(data["type"])
	if (!ispath(path, /obj/item/tank))
		return
	var/obj/item/tank/tank = new path(P)
	if (data["name"])
		tank.SetName(data["name"])
	if (islist(data["air"]))
		odyssey_apply_gas_mixture(tank.air_contents, data["air"])
	P.holding = tank


/proc/odyssey_serialize_portable_atmospherics(obj/machinery/portable_atmospherics/P)
	if (!istype(P) || istype(P, /obj/machinery/portable_atmospherics/hydroponics/soil/invisible))
		return null
	var/list/entry = list(
		"volume" = P.volume,
		"connected" = !!P.connected_port,
		"use_power" = P.use_power,
		"air" = odyssey_serialize_gas_mixture(P.air_contents)
	)
	if (istype(P.holding, /obj/item/tank))
		entry["holding"] = odyssey_serialize_holding_tank(P.holding)
	var/obj/item/cell/cell = P.get_cell()
	if (istype(cell) && isnum(cell.charge))
		entry["cell_charge"] = cell.charge
	if (istype(P, /obj/machinery/portable_atmospherics/canister))
		var/obj/machinery/portable_atmospherics/canister/C = P
		entry["canister"] = list(
			"valve_open" = !!C.valve_open,
			"release_pressure" = C.release_pressure,
			"release_flow_rate" = C.release_flow_rate,
			"canister_color" = C.canister_color,
			"can_label" = !!C.can_label
		)
	else if (istype(P, /obj/machinery/portable_atmospherics/powered/pump))
		var/obj/machinery/portable_atmospherics/powered/pump/pump = P
		entry["pump"] = list(
			"direction_out" = !!pump.direction_out,
			"target_pressure" = pump.target_pressure
		)
	else if (istype(P, /obj/machinery/portable_atmospherics/powered/scrubber))
		var/obj/machinery/portable_atmospherics/powered/scrubber/S = P
		entry["scrubber"] = list(
			"volume_rate" = S.volume_rate,
			"scrubbing_gas" = S.scrubbing_gas ? S.scrubbing_gas.Copy() : null
		)
	else if (istype(P, /obj/machinery/portable_atmospherics/hydroponics))
		entry["hydro"] = odyssey_serialize_hydroponics(P)
	else if (istype(P, /obj/machinery/portable_atmospherics/cracker))
		var/obj/machinery/portable_atmospherics/cracker/cracker = P
		entry["cracker"] = list("reagent_buffer" = cracker.reagent_buffer ? cracker.reagent_buffer.Copy() : list())
	else if (istype(P, /obj/machinery/portable_atmospherics/reagent_sublimator))
		var/obj/machinery/portable_atmospherics/reagent_sublimator/sub = P
		if (istype(sub.container, /obj/item/reagent_containers))
			var/list/cont = list("type" = "[sub.container.type]")
			if (sub.container.name != initial(sub.container.name))
				cont["name"] = sub.container.name
			cont["reagents"] = odyssey_serialize_reagents(sub.container)
			entry["sublimator_container"] = cont
	return entry


/proc/odyssey_serialize_hydroponics(obj/machinery/portable_atmospherics/hydroponics/H)
	if (!istype(H))
		return null
	var/list/entry = list(
		"waterlevel" = H.waterlevel,
		"nutrilevel" = H.nutrilevel,
		"pestlevel" = H.pestlevel,
		"weedlevel" = H.weedlevel,
		"dead" = !!H.dead,
		"harvest" = !!H.harvest,
		"age" = H.age,
		"sampled" = !!H.sampled,
		"yield_mod" = H.yield_mod,
		"mutation_mod" = H.mutation_mod,
		"toxins" = H.toxins,
		"mutation_level" = H.mutation_level,
		"tray_light" = H.tray_light,
		"health" = H.health,
		"closed_system" = !!H.closed_system,
		"mechanical" = !!H.mechanical
	)
	if (istype(H.seed) && H.seed.name)
		entry["seed"] = H.seed.name
	return entry


/proc/odyssey_apply_hydroponics(obj/machinery/portable_atmospherics/hydroponics/H, list/data)
	if (!istype(H) || !islist(data))
		return
	if (isnum(data["waterlevel"]))
		H.waterlevel = data["waterlevel"]
	if (isnum(data["nutrilevel"]))
		H.nutrilevel = data["nutrilevel"]
	if (isnum(data["pestlevel"]))
		H.pestlevel = data["pestlevel"]
	if (isnum(data["weedlevel"]))
		H.weedlevel = data["weedlevel"]
	H.dead = !!data["dead"]
	H.harvest = !!data["harvest"]
	if (isnum(data["age"]))
		H.age = data["age"]
	H.sampled = !!data["sampled"]
	if (isnum(data["yield_mod"]))
		H.yield_mod = data["yield_mod"]
	if (isnum(data["mutation_mod"]))
		H.mutation_mod = data["mutation_mod"]
	if (isnum(data["toxins"]))
		H.toxins = data["toxins"]
	if (isnum(data["mutation_level"]))
		H.mutation_level = data["mutation_level"]
	if (isnum(data["tray_light"]))
		H.tray_light = data["tray_light"]
	if (isnum(data["health"]))
		H.health = data["health"]
	H.closed_system = !!data["closed_system"]
	if (!isnull(data["mechanical"]))
		H.mechanical = !!data["mechanical"]
	H.seed = null
	if (data["seed"] && SSplants?.seeds)
		H.seed = SSplants.seeds[data["seed"]]
	H.check_level_sanity()
	H.update_icon()


/proc/odyssey_apply_portable_atmospherics(obj/machinery/portable_atmospherics/P, list/data)
	if (!istype(P) || !islist(data))
		return
	if (isnum(data["volume"]) && data["volume"] > 0)
		P.volume = data["volume"]
	if (islist(data["air"]))
		odyssey_apply_gas_mixture(P.air_contents, data["air"])
		if (P.air_contents)
			P.air_contents.volume = P.volume
	odyssey_apply_holding_tank(P, data["holding"])
	if (istype(P, /obj/machinery/portable_atmospherics/reagent_sublimator))
		var/obj/machinery/portable_atmospherics/reagent_sublimator/sub_verbs = P
		if (sub_verbs.holding)
			sub_verbs.verbs |= /obj/machinery/portable_atmospherics/reagent_sublimator/proc/remove_tank
		else
			sub_verbs.verbs -= /obj/machinery/portable_atmospherics/reagent_sublimator/proc/remove_tank
	if ("use_power" in data)
		var/want_power = data["use_power"]
		if (!isnum(want_power))
			want_power = text2num(want_power)
		if (isnum(want_power))
			P.update_use_power(want_power)
	var/obj/item/cell/cell = P.get_cell()
	if (istype(cell) && isnum(data["cell_charge"]))
		cell.charge = clamp(data["cell_charge"], 0, cell.maxcharge)
	if (islist(data["canister"]) && istype(P, /obj/machinery/portable_atmospherics/canister))
		var/obj/machinery/portable_atmospherics/canister/C = P
		var/list/cdata = data["canister"]
		C.valve_open = !!cdata["valve_open"]
		if (isnum(cdata["release_pressure"]))
			C.release_pressure = cdata["release_pressure"]
		if (isnum(cdata["release_flow_rate"]))
			C.release_flow_rate = cdata["release_flow_rate"]
		if (!isnull(cdata["canister_color"]))
			C.canister_color = cdata["canister_color"]
		if (!isnull(cdata["can_label"]))
			C.can_label = !!cdata["can_label"]
	if (islist(data["pump"]) && istype(P, /obj/machinery/portable_atmospherics/powered/pump))
		var/obj/machinery/portable_atmospherics/powered/pump/pump = P
		var/list/pdata = data["pump"]
		pump.direction_out = !!pdata["direction_out"]
		if (isnum(pdata["target_pressure"]))
			pump.target_pressure = pdata["target_pressure"]
	if (islist(data["scrubber"]) && istype(P, /obj/machinery/portable_atmospherics/powered/scrubber))
		var/obj/machinery/portable_atmospherics/powered/scrubber/S = P
		var/list/sdata = data["scrubber"]
		if (isnum(sdata["volume_rate"]))
			S.volume_rate = sdata["volume_rate"]
		var/list/scrub_gases = sdata["scrubbing_gas"]
		if (islist(scrub_gases))
			S.scrubbing_gas = scrub_gases.Copy()
	if (islist(data["hydro"]) && istype(P, /obj/machinery/portable_atmospherics/hydroponics))
		odyssey_apply_hydroponics(P, data["hydro"])
	if (islist(data["cracker"]) && istype(P, /obj/machinery/portable_atmospherics/cracker))
		var/obj/machinery/portable_atmospherics/cracker/cracker = P
		var/list/cr = data["cracker"]
		var/list/buffer = cr["reagent_buffer"]
		if (islist(buffer))
			cracker.reagent_buffer = buffer.Copy()
	if (islist(data["sublimator_container"]) && istype(P, /obj/machinery/portable_atmospherics/reagent_sublimator))
		var/obj/machinery/portable_atmospherics/reagent_sublimator/sub = P
		if (sub.container)
			qdel(sub.container)
			sub.container = null
		var/list/cont = data["sublimator_container"]
		var/cpath = odyssey_resolve_path(cont["type"])
		if (ispath(cpath, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/RC = new cpath(sub)
			if (cont["name"])
				RC.SetName(cont["name"])
			if ("reagents" in cont)
				odyssey_apply_reagents(RC, cont["reagents"])
			sub.container = RC
			sub.verbs |= /obj/machinery/portable_atmospherics/reagent_sublimator/proc/remove_container
	// Port connection after move/place: reconnect or disconnect to match save.
	if (!!data["connected"])
		if (!P.connected_port)
			var/obj/machinery/atmospherics/portables_connector/port = locate() in get_turf(P)
			if (istype(port))
				P.connect(port)
	else if (P.connected_port)
		P.disconnect()
	P.update_icon()


/proc/odyssey_airlock_state(obj/machinery/door/airlock/A)
	if (!istype(A))
		return null
	var/open = !A.density
	if (!A.welded && !A.locked && !A.p_open && !open && !A.lock_cut_state)
		return null
	return list(
		"welded" = !!A.welded,
		"locked" = !!A.locked,
		"p_open" = !!A.p_open,
		"open" = open,
		"lock_cut_state" = A.lock_cut_state
	)


/proc/odyssey_apply_airlock_state(obj/machinery/door/airlock/A, list/data)
	if (!istype(A) || !islist(data))
		return
	A.welded = !!data["welded"]
	A.locked = !!data["locked"]
	A.p_open = !!data["p_open"]
	if (!isnull(data["lock_cut_state"]))
		A.lock_cut_state = data["lock_cut_state"]
	var/want_open = !!data["open"]
	if (want_open == !A.density)
		A.update_icon()
		return
	A.set_density(!want_open)
	if (A.width > 1)
		A.set_fillers_density(A.density)
	if (want_open)
		A.set_opacity(0)
		if (A.width > 1)
			A.set_fillers_opacity(0)
		A.layer = A.open_layer
	else
		A.layer = A.closed_layer
		if (A.visible && !A.glass)
			A.set_opacity(1)
			if (A.width > 1)
				A.set_fillers_opacity(1)
	A.update_nearby_tiles()
	A.update_icon()


/proc/odyssey_apply_machinery_destroy_entry(list/entry)
	if (!islist(entry) || entry["action"] != "destroyed")
		return FALSE
	var/obj/machinery/M = odyssey_find_machine_by_id(entry["id"])
	if (!M)
		return FALSE
	if (!odyssey_atom_persistable(M))
		return FALSE
	odyssey_index_remove(odyssey_ensure_state().persist_index_machinery, entry["id"])
	qdel(M)
	return TRUE


/proc/odyssey_apply_machinery_entry(list/entry)
	if (!islist(entry) || entry["action"] == "destroyed")
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T || !odyssey_turf_persistable(T))
		return FALSE
	var/path = odyssey_resolve_path(entry["type"])
	if (!ispath(path, /obj/machinery))
		return FALSE
	var/obj/machinery/M = odyssey_find_machine_by_id(entry["id"])
	// Continue remaps persist ids — always try turf+type before spawning a duplicate.
	if (!M)
		M = locate(path) in T
	// A 2-tile airlock used to be saved twice and then deleted on load. Spawn it if the mapped one is gone.
	// Never blind-spawn atmospherics (cryo) — breaks pipe networks; mapped cryo must be locate'd.
	if (!M && (entry["action"] == "created" || ispath(path, /obj/machinery/door/airlock/multi_tile)))
		if (!ispath(path, /obj/machinery/atmospherics))
			M = new path(T)
	if (!istype(M))
		return FALSE
	if (entry["id"])
		M.odyssey_persist_id = entry["id"]
		odyssey_index_put(odyssey_ensure_state().persist_index_machinery, entry["id"], M)
	if (get_turf(M) != T)
		// door/Move deconstructs the airlock. Place it without that path.
		if (istype(M, /obj/machinery/door))
			M.loc = T
		else if (!istype(M, /obj/machinery/atmospherics))
			M.forceMove(T)
	if (!isnull(entry["dir"]))
		M.set_dir(entry["dir"])
	odyssey_apply_pixel_offset(M, entry)
	if (entry["name"])
		M.SetName(entry["name"])
	if (!isnull(entry["anchored"]))
		M.anchored = !!entry["anchored"]
	if (!isnull(entry["emagged"]))
		M.emagged = !!entry["emagged"]
	if (!isnull(entry["panel_open"]))
		M.panel_open = !!entry["panel_open"]
	var/saved_health = entry["health"]
	if (!isnull(saved_health) && M.get_max_health() > 0)
		M.set_health(saved_health)
	var/desired_broken = entry["reason_broken"] || 0
	for (var/cause in list(MACHINE_BROKEN_GENERIC, MACHINE_BROKEN_NO_PARTS, MACHINE_BROKEN_HEALTH))
		var/has = !!(M.reason_broken & cause)
		var/want = !!(desired_broken & cause)
		if (has != want)
			M.set_broken(want, cause)
	if (istype(M, /obj/machinery/door/airlock) && islist(entry["airlock"]))
		odyssey_apply_airlock_state(M, entry["airlock"])
	if (istype(M, /obj/machinery/fabricator))
		if (islist(entry["stored_material"]))
			odyssey_apply_fabricator_materials(M, entry["stored_material"])
		if (islist(entry["fab_disk"]))
			odyssey_apply_portable_drive_slot(M, 1, entry["fab_disk"])
		if (islist(entry["fab_disk2"]))
			odyssey_apply_portable_drive_slot(M, 2, entry["fab_disk2"])
	if (istype(M, /obj/machinery/computer/modular) && islist(entry["computer_programs"]))
		odyssey_apply_modular_computer_programs(M, entry["computer_programs"])
	if (istype(M, /obj/machinery/computer/modular) && islist(entry["console_drive"]))
		odyssey_apply_console_portable_drive(M, entry["console_drive"])
	if (istype(M, /obj/machinery/smartfridge) && ("fridge_items" in entry))
		odyssey_apply_smartfridge_items(M, entry["fridge_items"])
	if (istype(M, /obj/machinery/anomaly_container) && islist(entry["anomaly"]))
		odyssey_apply_anomaly_container(M, entry["anomaly"])
	if (istype(M, /obj/machinery/artifact) && islist(entry["artifact"]))
		odyssey_apply_artifact_state(M, entry["artifact"])
	if (istype(M, /obj/machinery/power/smes) && islist(entry["smes"]))
		odyssey_apply_smes(M, entry["smes"])
	if (istype(M, /obj/machinery/power/shield_generator) && islist(entry["shield"]))
		odyssey_apply_shield_generator(M, entry["shield"])
	if (istype(M, /obj/machinery/atmospherics/unary/cryo_cell) && islist(entry["cryo"]))
		odyssey_apply_cryo_cell(M, entry["cryo"])
	if (istype(M, /obj/machinery/portable_atmospherics) && islist(entry["portable"]))
		odyssey_apply_portable_atmospherics(M, entry["portable"])
	if (!istype(M, /obj/machinery/door/airlock) || !islist(entry["airlock"]))
		M.update_icon()
	if (istype(M, /obj/machinery/door))
		var/obj/machinery/door/D = M
		if (D.width > 1)
			D.update_bounds()
	return TRUE

/proc/odyssey_apply_machinery(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_machinery_destroy_entry(entry))
			applied++
		CHECK_TICK
	for (var/list/entry in entries)
		if (odyssey_apply_machinery_entry(entry))
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_machinery applied=[applied]/[length(entries)]")


/proc/odyssey_find_machine_by_id(id)
	if (!id)
		return null
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (islist(state.persist_index_machinery))
		return odyssey_index_get(state.persist_index_machinery, id)
	for (var/obj/machinery/M in world)
		if (!QDELETED(M) && M.odyssey_persist_id == id)
			return M
	return null
