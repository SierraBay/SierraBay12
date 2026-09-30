// Emergency alternate-bus trace: click a path from the positronic source to the chassis bus.
// Must stay usable while the chassis is unpowered (lying / soft-crit).

GLOBAL_TYPED_NEW(ipc_emergency_state, /datum/topic_state/ipc_emergency_state)

/datum/topic_state/ipc_emergency_state/can_use_topic(src_object, mob/user)
	if(!istype(user, /mob/living/carbon/human))
		return STATUS_CLOSE
	var/mob/living/carbon/human/H = user
	if(!(H.is_species(SPECIES_IPC) || H.is_species(SPECIES_FBP)))
		return STATUS_CLOSE
	if(!H.client || H.stat == DEAD)
		return STATUS_CLOSE
	if(src_object != H)
		return STATUS_CLOSE
	return STATUS_INTERACTIVE

/datum/nano_module/ipc_power_reroute
	name = "ECS — Alternate Power"
	available_to_ai = FALSE
	var/list/path
	var/list/blocked
	var/list/dead_edges
	var/session_open = FALSE
	var/static/list/neighbors = list(
		"core"  = list("head"),
		"head"  = list("core", "chest"),
		"chest" = list("head", "l_arm", "r_arm", "groin"),
		"l_arm" = list("chest", "bus"),
		"r_arm" = list("chest", "bus"),
		"groin" = list("chest", "l_leg", "r_leg"),
		"l_leg" = list("groin", "bus"),
		"r_leg" = list("groin", "bus"),
		"bus"   = list("l_arm", "r_arm", "l_leg", "r_leg")
	)
	var/static/list/node_labels = list(
		"core"  = "POSI",
		"head"  = "HEAD",
		"chest" = "CHEST",
		"l_arm" = "L-ARM",
		"r_arm" = "R-ARM",
		"groin" = "GROIN",
		"l_leg" = "L-LEG",
		"r_leg" = "R-LEG",
		"bus"   = "BUS"
	)

/datum/nano_module/ipc_power_reroute/New(datum/host, topic_manager)
	path = list("core")
	blocked = list()
	dead_edges = list()
	..()

/datum/nano_module/ipc_power_reroute/Destroy()
	session_open = FALSE
	path.Cut()
	blocked.Cut()
	dead_edges.Cut()
	. = ..()

/datum/nano_module/ipc_power_reroute/proc/get_ipc()
	if(istype(host, /mob/living/carbon/human))
		return host
	return null

/datum/nano_module/ipc_power_reroute/proc/edge_key(a, b)
	return a < b ? "[a]-[b]" : "[b]-[a]"

/datum/nano_module/ipc_power_reroute/proc/node_is_blocked(mob/living/carbon/human/H, id)
	if(id == "core" || id == "bus")
		return FALSE
	var/obj/item/organ/external/E = H.get_organ(id)
	if(!E)
		return TRUE
	if(E.is_broken() || (E.status & ORGAN_DEAD))
		return TRUE
	return ((E.brute_dam + E.burn_dam) / max(1, E.max_damage)) >= 0.7

/datum/nano_module/ipc_power_reroute/proc/edge_is_live(from_id, to_id)
	if(!(to_id in neighbors[from_id]))
		return FALSE
	if(blocked[to_id] || blocked[from_id])
		return FALSE
	return !(edge_key(from_id, to_id) in dead_edges)

/datum/nano_module/ipc_power_reroute/proc/path_has_route()
	var/list/seen = list("core" = TRUE)
	var/list/queue = list("core")
	while(length(queue))
		var/cur = queue[1]
		queue.Cut(1, 2)
		if(cur == "bus")
			return TRUE
		for(var/nxt in neighbors[cur])
			if(seen[nxt])
				continue
			if(!edge_is_live(cur, nxt))
				continue
			seen[nxt] = TRUE
			queue += nxt
	return FALSE

/datum/nano_module/ipc_power_reroute/proc/begin_session(mob/living/carbon/human/H)
	if(session_open)
		return TRUE
	blocked = list()
	dead_edges = list()
	path = list("core")
	for(var/id in list("head", "chest", "l_arm", "r_arm", "groin", "l_leg", "r_leg"))
		if(node_is_blocked(H, id))
			blocked[id] = TRUE
	var/list/taps = list()
	for(var/tap in list("l_arm", "r_arm", "l_leg", "r_leg"))
		if(!blocked[tap])
			taps += tap
	if(!length(taps))
		H.ipc_brain_reroute_cooldown_until = world.time + 100
		to_chat(H, SPAN_WARNING("No intact limb taps. Alternate bus cannot be traced."))
		return FALSE
	dead_edges += edge_key(pick(taps), "bus")
	if(length(taps) > 2 && prob(45))
		var/list/remain = taps.Copy()
		for(var/tap in taps)
			if(edge_key(tap, "bus") in dead_edges)
				remain -= tap
		if(length(remain))
			dead_edges += edge_key(pick(remain), "bus")
	while(!path_has_route() && length(dead_edges))
		dead_edges.Cut(length(dead_edges))
	if(!path_has_route())
		H.ipc_brain_reroute_cooldown_until = world.time + 100
		to_chat(H, SPAN_WARNING("Alternate bus topology failed integrity check."))
		return FALSE
	session_open = TRUE
	H.SetParalysis(0)
	H.set_stat(CONSCIOUS)
	to_chat(H, SPAN_NOTICE("ECS schematic online. Trace an alternate path from the positronic source to the chassis bus."))
	return TRUE

/datum/nano_module/ipc_power_reroute/proc/valid_next()
	if(!length(path))
		return list()
	var/cur = path[length(path)]
	var/list/out = list()
	for(var/nxt in neighbors[cur])
		if(nxt in path)
			continue
		if(!edge_is_live(cur, nxt))
			continue
		out += nxt
	return out

/datum/nano_module/ipc_power_reroute/proc/line_class(a, b)
	if((edge_key(a, b) in dead_edges) || blocked[a] || blocked[b])
		return "rr-line dead"
	for(var/i = 1 to length(path) - 1)
		if((path[i] == a && path[i + 1] == b) || (path[i] == b && path[i + 1] == a))
			return "rr-line live"
	return "rr-line"

/datum/nano_module/ipc_power_reroute/proc/pack_node(id, list/ready)
	var/on_path = (id in path)
	var/is_last = length(path) && path[length(path)] == id
	var/clickable = FALSE
	var/nclass = "rr-node"
	var/hint = node_labels[id]
	if(blocked[id])
		nclass += " dead"
		hint = "FAULT"
	else if(on_path)
		nclass += " live"
		if(is_last && id != "core")
			clickable = TRUE
			hint = "BACK"
		else if(id == "core")
			hint = "SOURCE"
		else if(id == "bus" && is_last)
			hint = "READY"
	else if(id in ready)
		nclass += " ready"
		clickable = TRUE
		hint = "EXTEND"
	else
		nclass += " idle"
	return list(
		"id" = id,
		"label" = node_labels[id],
		"class" = nclass,
		"clickable" = clickable,
		"hint" = hint
	)

/datum/nano_module/ipc_power_reroute/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.ipc_emergency_state)
	var/mob/living/carbon/human/H = get_ipc()
	if(!H || user != H)
		return
	var/list/ready = valid_next()
	var/list/data = list()
	data["src"] = "\ref[src]"
	data["PC_hasheader"] = FALSE
	data["path_str"] = uppertext(jointext(path, " > "))
	data["can_engage"] = (length(path) && path[length(path)] == "bus")
	data["nodes"] = list(
		"core"  = pack_node("core", ready),
		"head"  = pack_node("head", ready),
		"chest" = pack_node("chest", ready),
		"l_arm" = pack_node("l_arm", ready),
		"r_arm" = pack_node("r_arm", ready),
		"groin" = pack_node("groin", ready),
		"l_leg" = pack_node("l_leg", ready),
		"r_leg" = pack_node("r_leg", ready),
		"bus"   = pack_node("bus", ready)
	)
	data["line_core_head"]  = line_class("core", "head")
	data["line_head_chest"] = line_class("head", "chest")
	data["line_chest_larm"] = line_class("chest", "l_arm")
	data["line_chest_rarm"] = line_class("chest", "r_arm")
	data["line_chest_groin"]= line_class("chest", "groin")
	data["line_groin_lleg"] = line_class("groin", "l_leg")
	data["line_groin_rleg"] = line_class("groin", "r_leg")
	data["line_larm_bus"]   = line_class("l_arm", "bus")
	data["line_rarm_bus"]   = line_class("r_arm", "bus")
	data["line_lleg_bus"]   = line_class("l_leg", "bus")
	data["line_rleg_bus"]   = line_class("r_leg", "bus")

	var/obj/item/organ/internal/posibrain/posi = H.internal_organs_by_name[BP_POSIBRAIN]
	data["posi_pct"] = posi ? round((1 - posi.damage / max(1, posi.max_damage)) * 100) : 0
	if(data["can_engage"])
		data["status"] = "PATH VALID — COMMIT ALTERNATE POWER"
		data["status_class"] = "ok"
	else if(!length(ready) && path[length(path)] != "core")
		data["status"] = "NO TAP — BACKTRACK"
		data["status_class"] = "warn"
	else
		data["status"] = "TRACE PATH — POSI TO CHASSIS BUS"
		data["status_class"] = "ecs-active"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-ipc_power_reroute.tmpl", name, 420, 540, state = state)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)

/datum/nano_module/ipc_power_reroute/Topic(href, href_list)
	. = ..()
	var/mob/living/carbon/human/H = get_ipc()
	if(!H || usr != H)
		return TOPIC_NOACTION
	if(href_list["pick"])
		var/id = href_list["pick"]
		if(!(id in neighbors))
			return TOPIC_HANDLED
		if(length(path) && path[length(path)] == id && id != "core")
			path.Cut(length(path))
		else if(id in valid_next())
			path += id
	else if(href_list["reset"])
		path = list("core")
	else if(href_list["abort"])
		H.ipc_drop_emergency_power("Alternate power trace aborted. Chassis bus offline.")
		H.ipc_brain_reroute_cooldown_until = world.time + 80
		return TOPIC_HANDLED
	else if(href_list["engage"])
		if(!length(path) || path[length(path)] != "bus")
			return TOPIC_HANDLED
		if(!H.ipc_can_start_brain_reroute())
			to_chat(H, SPAN_WARNING("Reroute conditions changed. Trace cancelled."))
			session_open = FALSE
			SSnano.close_uis(src)
			return TOPIC_HANDLED
		if(H.ipc_engage_brain_reroute())
			session_open = FALSE
			SSnano.close_uis(src)
			return TOPIC_HANDLED
	else
		return TOPIC_NOACTION
	ui_interact(usr)
	return TOPIC_HANDLED
