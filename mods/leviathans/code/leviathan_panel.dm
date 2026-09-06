/datum/leviathan_panel
	var/list/leviathan_spawn_types = list(
		"Medusa" = /obj/overmap/event/leviathan/medusa,
		"Dragon" = /obj/overmap/event/leviathan/dragon,
		"Swarm"  = /obj/overmap/event/leviathan/swarm
	)

/datum/leviathan_panel/proc/main_interact()
	var/mob/user = usr
	var/list/data = list("<center><font size='3'><b>LEVIATHAN CONTROL PANEL</b></font></center><hr>")
	data += "<a href='?src=\ref[src];refresh=1'>\[REFRESH\]</a> "
	data += "<a href='?src=\ref[src];spawn=1'>\[SPAWN NEW\]</a><br><br>"

	data += "<table border='1' style='width:100%; border-collapse: collapse;'>"
	data += "<tr>\
		<th>Name</th>\
		<th>Health</th>\
		<th>Speed</th>\
		<th>Target</th>\
		<th>Cooldown</th>\
		<th>AI</th>\
		<th>Actions</th>\
	</tr>"

	for(var/obj/overmap/event/leviathan/L in GLOB.active_leviathans)
		if(QDELETED(L))
			continue
		
		var/target_name = "None"
		var/atom/T = (L.manual_ai ? L.forced_target?.resolve() : L.target_ship?.resolve())
		if(T)
			if(isturf(T))
				target_name = "Coord ([T.x], [T.y])"
			else
				target_name = T.name

		var/cooldown = max(0, (L.next_damage_time - world.time) / 10)
		
		data += "<tr>"
		data += "<td><a href='?src=\ref[src];jump=\ref[L]'>[L.name]</a></td>"
		data += "<td><a href='?src=\ref[src];set_hp=\ref[L]'>[L.health]/[L.max_health]</a></td>"
		data += "<td><a href='?src=\ref[src];set_speed=\ref[L]'>[L.leviathan_speed]</a></td>"
		data += "<td><a href='?src=\ref[src];set_target=\ref[L]'>[target_name]</a></td>"
		data += "<td>[cooldown]s</td>"
		data += "<td><a href='?src=\ref[src];toggle_ai=\ref[L]'>[L.manual_ai ? "MANUAL" : "AUTO"]</a></td>"
		data += "<td>\
			<a href='?src=\ref[src];heal=\ref[L]'>\[HEAL\]</a> \
			<a href='?src=\ref[src];delete=\ref[L]'>\[DEL\]</a>\
		</td>"
		data += "</tr>"

	data += "</table>"

	var/datum/browser/popup = new(user, "leviathan_panel", "Leviathan Control Panel", 800, 600)
	popup.set_content(data.Join())
	popup.open()

/datum/leviathan_panel/Topic(href, href_list)
	if(!check_rights(R_FUN))
		return

	if(href_list["refresh"])
		main_interact()
		return

	if(href_list["spawn"])
		handle_spawn(usr)
		main_interact()
		return

	var/obj/overmap/event/leviathan/L = locate(href_list["heal"] || href_list["delete"] || href_list["set_hp"] || href_list["set_speed"] || href_list["set_target"] || href_list["toggle_ai"] || href_list["jump"])
	
	if(!L || QDELETED(L))
		main_interact()
		return

	if(href_list["heal"])
		handle_heal(usr, L)
	else if(href_list["delete"])
		handle_delete(usr, L)
	else if(href_list["set_hp"])
		handle_set_hp(usr, L)
	else if(href_list["set_speed"])
		handle_set_speed(usr, L)
	else if(href_list["toggle_ai"])
		handle_toggle_ai(usr, L)
	else if(href_list["set_target"])
		handle_set_target(usr, L)
	else if(href_list["jump"])
		usr.forceMove(get_turf(L))

	main_interact()

/datum/leviathan_panel/proc/handle_spawn(mob/user)
	var/type_label = input(user, "Select leviathan type", "Spawn Leviathan") as null|anything in leviathan_spawn_types
	if(!type_label)
		return
		
	var/lev_type = leviathan_spawn_types[type_label]
	var/turf/T = get_turf(user)
	if(!istype(T, /turf/unsimulated/map))
		T = locate(user.x, user.y, GLOB.using_map.overmap_z)
	
	if(T)
		new lev_type(T)
		message_admins("[key_name_admin(user)] spawned [type_label] at [T.x], [T.y], [T.z]")

/datum/leviathan_panel/proc/handle_heal(mob/user, obj/overmap/event/leviathan/L)
	L.health = L.max_health
	L.is_healing = FALSE
	message_admins("[key_name_admin(user)] healed [L]")

/datum/leviathan_panel/proc/handle_delete(mob/user, obj/overmap/event/leviathan/L)
	message_admins("[key_name_admin(user)] deleted [L]")
	qdel(L)

/datum/leviathan_panel/proc/handle_set_hp(mob/user, obj/overmap/event/leviathan/L)
	var/new_hp = input(user, "Enter new health (Max: [L.max_health])", "Set Health", L.health) as null|num
	if(!isnull(new_hp))
		L.health = clamp(new_hp, 0, L.max_health)
		message_admins("[key_name_admin(user)] set health of [L] to [L.health]")

/datum/leviathan_panel/proc/handle_set_speed(mob/user, obj/overmap/event/leviathan/L)
	var/new_speed = input(user, "Enter new speed (current: [L.leviathan_speed])", "Set Speed", L.leviathan_speed) as null|num
	if(!isnull(new_speed))
		L.leviathan_speed = new_speed
		message_admins("[key_name_admin(user)] set speed of [L] to [L.leviathan_speed]")

/datum/leviathan_panel/proc/handle_toggle_ai(mob/user, obj/overmap/event/leviathan/L)
	L.manual_ai = !L.manual_ai
	if(!L.manual_ai)
		L.forced_target = null
		L.find_target()
	message_admins("[key_name_admin(user)] toggled AI of [L] to [L.manual_ai ? "MANUAL" : "AUTO"]")

/datum/leviathan_panel/proc/handle_set_target(mob/user, obj/overmap/event/leviathan/L)
	var/choice = alert(user, "Set target to?", "Set Target", "Ship", "Coordinates", "Cancel")
	if(choice == "Ship")
		var/list/targets = list()
		for(var/obj/overmap/visitable/ship/S in SSshuttle.ships)
			if(S.z != GLOB.using_map.overmap_z)
				continue
			targets["[S.name] ([S.x], [S.y])"] = S
		
		var/target_label = input(user, "Select ship to target", "Set Target") as null|anything in targets
		if(target_label)
			var/obj/overmap/visitable/ship/S = targets[target_label]
			L.forced_target = weakref(S)
			L.manual_ai = TRUE
			message_admins("[key_name_admin(user)] set target of [L] to ship [S.name]")
	else if(choice == "Coordinates")
		var/tx = input(user, "Enter X coordinate (1-[GLOB.using_map.overmap_size])", "Set Target", L.x) as null|num
		var/ty = input(user, "Enter Y coordinate (1-[GLOB.using_map.overmap_size])", "Set Target", L.y) as null|num
		if(tx && ty)
			var/turf/T = locate(tx, ty, GLOB.using_map.overmap_z)
			if(T)
				L.forced_target = weakref(T)
				L.manual_ai = TRUE
				message_admins("[key_name_admin(user)] set target of [L] to coordinates ([tx], [ty])")

GLOBAL_TYPED_AS(leviathan_panel, /datum/leviathan_panel, new)

/client/proc/leviathan_panel()
	set category = "Fun"
	set name = "Leviathan Panel"
	if(!check_rights(R_FUN))
		return
	
	var/datum/leviathan_panel/LP = GLOB.leviathan_panel
	LP.main_interact()
