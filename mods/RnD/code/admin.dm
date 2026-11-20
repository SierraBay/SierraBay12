// Debug panel for Odyssey science briefs (corporate derelict contracts removed).

/datum/admins/var/datum/rnd_mission_debug_panel/rnd_mission_debug_datum = new

/client/proc/rnd_mission_debug()
	set name = "RnD Mission Debug"
	set category = "Debug"
	set desc = "Shows Odyssey science briefs (legacy derelict contracts removed)."

	if(!holder || !check_rights(R_DEBUG))
		return

	holder.rnd_mission_debug_datum.show(src)

/datum/rnd_mission_debug_panel

/datum/rnd_mission_debug_panel/proc/show(client/C)
	if(!C || !C.holder || !check_rights(R_DEBUG, FALSE, C))
		return

	var/dat = {"<html><head><style>
		body { font-family: Verdana, sans-serif; font-size: 12px; background: #1a1a2e; color: #e0e0e0; padding: 8px; }
		h2 { color: #00d4ff; margin: 4px 0; }
		.btn { color: #00d4ff; text-decoration: none; padding: 1px 4px; border: 1px solid #00d4ff; border-radius: 3px; font-size: 11px; }
		.mission { margin-bottom: 8px; padding: 6px; background: #16213e; border: 1px solid #333; border-radius: 4px; border-left: 3px solid #00ff88; }
	</style></head><body>"}
	dat += "<h2>RnD / Odyssey Science</h2>"
	dat += "<a class='btn' href='byond://?src=\ref[src];refresh=1'>Refresh</a> "
	dat += "<a class='btn' href='byond://?src=\ref[src];sci_open_odyssey=1'>Open Odyssey Panel</a>"
	dat += "<hr>"

	if (!odyssey_rnd_active())
		dat += "<p><i>Одиссея не активна. Корпоративные контракты удалены — научные брифы появляются только в Одиссее.</i></p>"
		dat += "<p>Ghost invasion sites mapped: <b>[length(derelict_sites_list)]</b></p>"
	else
		dat += "<p>Подробные проки — в <b>Admin → Odyssey Panel → Наука</b>.</p>"
		var/list/briefs = odyssey_science_active_briefs_ui()
		if (!length(briefs))
			dat += "<i>Нет активных научных брифов.</i>"
		else
			for (var/list/entry in briefs)
				dat += "<div class='mission'>"
				dat += "<b>[entry["title"]]</b> ([entry["kind"]]) — [entry["progress"]]/[entry["target"]]<br>"
				dat += "<i>[entry["brief"]]</i><br>"
				if (entry["reward_credits"])
					dat += "reward: <b>[entry["reward_credits"]]</b> ₮"
				if (entry["target_gene"])
					dat += " · gene=<code>[entry["target_gene"]]</code>"
				if (entry["target_type"])
					dat += " · type=<code>[entry["target_type"]]</code>"
				dat += "</div>"

	dat += "</body></html>"
	show_browser(C, dat, "window=rnd_mission_debug;size=900x700")
	onclose(C, "rnd_mission_debug")

/datum/rnd_mission_debug_panel/Topic(href, href_list)
	..()
	if(!usr || !usr.client || !usr.client.holder)
		return
	if(!check_rights(R_DEBUG, FALSE, usr.client))
		return
	var/client/C = usr.client
	if(href_list["sci_open_odyssey"])
		C.odyssey_panel()
		return
	show(C)
