#include "psistation_areas.dm"
#include "psistation_disk.dm"

/obj/overmap/visitable/sector/psistation
	name = "Strange Station"
	desc = "Scanner shows Science Space Station with -DANGER- beacon. Damage to structural integrity of object detected, no active life indicators detected. Low profile energy indicators present. Minor dark matter glitch in square area.."
	icon_state = "object"

	initial_generic_waypoints = list(
		"nav_psistation_1",
		"nav_psistation_2",
		"nav_psistation_3",
		"nav_psistation_4",
		"nav_psistation_antag"
	)

/datum/map_template/ruin/away_site/psistation
	name = "Psistation"
	id = "awaysite_psistation"
	description = "It's a strange research station."
	prefix = "mods/_maps/psistation/"
	suffixes = list("psistation.dmm")
	spawn_cost = 1
	area_usage_test_exempted_root_areas = list(/area/psistation)

/obj/shuttle_landmark/nav_psistation/nav1
	name = "Navpoint #1"
	landmark_tag = "nav_psistation_1"

/obj/shuttle_landmark/nav_psistation/nav2
	name = "Navpoint #2"
	landmark_tag = "nav_psistation_2"

/obj/shuttle_landmark/nav_psistation/nav3
	name = "Navpoint #3"
	landmark_tag = "nav_psistation_3"

/obj/shuttle_landmark/nav_psistation/nav4
	name = "Navpoint #4"
	landmark_tag = "nav_psistation_4"

/obj/shuttle_landmark/nav_psistation/nav5
	name = "Navpoint #5"
	landmark_tag = "nav_psistation_antag"

#define PSISTATION_SCAN_IDLE 0
#define PSISTATION_SCAN_RUNNING 1
#define PSISTATION_SCAN_DONE 2

/obj/structure/psistation/strange_computer
	name = "Analyzer Computer"
	desc = "It looks like a strange piece of machinery that you probably haven't seen before. Why does it need a floppy disk slot?"
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "psi_extractor"
	anchored = TRUE
	density = TRUE

	var/list/interface_users = list()

/obj/structure/psistation/strange_computer/proc/get_monolith()
	var/turf/T = get_step(src, EAST)
	if(!T)
		return null
	return locate(/obj/structure/psistation/technological_monolith) in T

/obj/structure/psistation/strange_computer/proc/get_window_id()
	return "psi_scan_[x]_[y]_[z]"

/obj/structure/psistation/strange_computer/attack_hand(mob/user)
	open_interface(user)
	return TRUE

/obj/structure/psistation/strange_computer/proc/open_interface(mob/user)
	if(!user || !user.client)
		return
	interface_users |= user
	show_browser(user, build_interface_html(), "window=[get_window_id()];size=460x620")

/obj/structure/psistation/strange_computer/proc/refresh_interface()
	for(var/mob/user in interface_users.Copy())
		if(!user.client || !Adjacent(user) || !winexists(user, get_window_id()))
			interface_users -= user
			continue
		show_browser(user, build_interface_html(), "window=[get_window_id()];size=460x620")

/obj/structure/psistation/strange_computer/Topic(href, href_list)
	if(!usr || usr.incapacitated() || !Adjacent(usr))
		return TRUE
	var/obj/structure/psistation/technological_monolith/monolith = get_monolith()
	switch(href_list["action"])
		if("refresh")
			open_interface(usr)
		if("rescan")
			if(monolith)
				monolith.restart_scan(usr)
			open_interface(usr)
	return TRUE

/obj/structure/psistation/strange_computer/proc/build_interface_html()
	var/obj/structure/psistation/technological_monolith/monolith = get_monolith()
	var/list/L = list()
	L += "<html><head><title>ТЕРМИНАЛ АНАЛИЗАТОРА</title><style>"
	L += "body {background:#0C0C0C; color:#FFFFFF; font-family:Consolas,monospace; font-size:13px; margin:8px;}"
	L += "h2 {margin:0 0 6px 0;} h3 {margin:12px 0 4px 0; border-bottom:1px solid #CCCCCC;}"
	L += "a {color:#3B78FF;} table {width:100%; border-collapse:collapse;} td {padding:2px 4px; vertical-align:top;}"
	L += "td.k {color:#CCCCCC; width:45%;} .bad {color:#C50F1F;} .warn {color:#F9F1A5;} .ok {color:#FFFFFF;}"
	L += ".bar {background:#CCCCCC; border:1px solid #CCCCCC; height:12px;} .fill {background:#CCCCCC; height:12px;}"
	L += "</style></head><body>"
	L += "<h2>ТЕРМИНАЛ АНАЛИЗАТОРА</h2>"
	L += "<a href='?src=\ref[src];action=refresh'>Обновить</a>"

	if(!monolith)
		L += "<h3>Scanner</h3><span class='bad'>УСТРОЙСТВО НЕ ПОДКЛЮЧЕНО</span>"
		L += "</body></html>"
		return jointext(L, "")

	L += " | <a href='?src=\ref[src];action=rescan'>Повторить сканирование</a>"
	L += "<h3>АНАЛИЗАТОР</h3><table>"
	switch(monolith.scan_state)
		if(PSISTATION_SCAN_IDLE)
			L += "<tr><td class='k'>Статус</td><td class='warn'>Сканер пуст</td></tr>"
		if(PSISTATION_SCAN_RUNNING)
			L += "<tr><td class='k'>Статус</td><td class='warn'>Сканирование... [monolith.scan_progress]%</td></tr>"
		if(PSISTATION_SCAN_DONE)
			L += "<tr><td class='k'>Статус</td><td class='ok'>Сканирование завершено</td></tr>"
	L += "</table>"

	if(monolith.scan_state == PSISTATION_SCAN_DONE && monolith.scan_data)
		L += render_scan_data(monolith.scan_data)

	L += "</body></html>"
	return jointext(L, "")

/obj/structure/psistation/strange_computer/proc/render_scan_data(list/D)
	var/list/L = list()
	L += "<h3>Субъект</h3><table>"

	if(D["unsupported"])
		L += "<tr><td colspan='2' class='bad'>НЕ ПОДДЕРЖИВАЕТСЯ</td></tr></table>"
		return jointext(L, "")

	var/status_text = "В сознании"
	var/status_class = "ok"
	switch(D["stat"])
		if(UNCONSCIOUS)
			status_text = "Без сознания"
			status_class = "warn"
		if(DEAD)
			status_text = "Мёртв"
			status_class = "bad"
	L += "<tr><td class='k'>Состояние</td><td class='[status_class]'>[status_text]</td></tr>"
	L += "</table>"

	L += "<h3>Неврологическое состояние</h3><table>"
	var/integrity = D["neural_integrity"]
	var/integrity_class = "ok"
	var/random = hex2num(copytext(md5(D["name"]),-1))
	var/illnesstext = list(
		"Паранойи",
		"Шизофрении",
		"Расщепления личности",
		"Депрессии",
		"Синдрома Капгра",
		"Нервной анорексии",
		"Неустойчивой психопатии",
		"Дереализации",
		"Шизоидной психопатии",
		"Гипостенической неврастении",
		"Эпилептоидного психоза",
		"Невроза",
		"Деменции",
		"Лимский синдром",
		"Булимии",
		"Психастении",
		"Дисфории",
		"Параноидного расстройства личности"
	)
	if(integrity < 50)
		integrity_class = "bad"
	else if(integrity < 90)
		integrity_class = "warn"
	L += "<tr><td class='k'>Цельность</td><td class='[integrity_class]'>[integrity]%</td></tr>"
	L += "<tr><td class='k'>Присутствуют признаки</td><td class='bad'>[illnesstext[random + 1]]</td></tr>"
	L += "</table>"

	L += "<h3>Психометрический анализ</h3><table>"
	if(D["psi"])
		var/list/ranks = D["psi_ranks"]
		for(var/faculty in ranks)
			L += "<tr><td class='k'>[html_encode(copytext(md5(faculty), 1, 5))]</td><td>[ranks[faculty]]</td></tr>"
		if(!length(ranks))
			L += "<tr><td colspan='2' class='warn'>Несформированный потенциал</td></tr>"
		if(D["psi_stamina"])
			L += "<tr><td class='k'>Результат пробы запаса</td><td>[D["psi_stamina"]]</td></tr>"
	else
		L += "<tr><td colspan='2' class='warn'>Образец отсутствует</td></tr>"
	L += "</table>"
	return jointext(L, "")

/obj/structure/psistation/strange_computer/proc/render_damage_row(label, amount)
	var/css = "ok"
	if(amount > 0)
		css = "warn"
	if(amount > 40)
		css = "bad"
	return "<tr><td class='k'>[label]</td><td class='[css]'>[round(amount, 0.1)]</td></tr>"

/obj/structure/psistation/strange_server
	name = "Server"
	desc = "white monolith with soothing hum coming from it's base"
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "server_open0"
	anchored = TRUE
	density = TRUE

	var/codelen = 5

	var/opened = TRUE
	var/max_disks = 3
	var/start_disks = 0
	var/list/stored_disks = list()

/obj/structure/psistation/strange_server/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to min(start_disks, max_disks))
		stored_disks += new /obj/item/stock_parts/computer/hard_drive/portable/psistation_tech(src)
	update_icon()

/obj/structure/psistation/strange_server/Destroy()
	for(var/obj/item/stock_parts/computer/hard_drive/portable/psistation_tech/D in stored_disks)
		D.forceMove(get_turf(src))
	stored_disks.Cut()
	return ..()

/obj/structure/psistation/strange_server/on_update_icon()
	. = ..()
	if(!opened)
		icon_state = "closed_server"
		return
	name = "Server"
	icon_state = "server_open[LAZYLEN(stored_disks)]"

/obj/structure/psistation/strange_server/attack_hand(mob/user)

	if(!opened)
		. = ..()
	else
		take_disk(user)

/obj/structure/psistation/strange_server/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(isMultitool(tool) || ismultimeter(tool))
		if(!do_after(user, 5 SECONDS * user.skill_delay_mult(SKILL_ELECTRICAL)))
			return

		opened = TRUE
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		update_icon()
		visible_message(SPAN_NOTICE("[user] has opened [src]!"))
	. = ..()

/obj/structure/psistation/strange_server/proc/take_disk(mob/user)
	if(!length(stored_disks))
		return

	var/obj/item/stock_parts/computer/hard_drive/portable/psistation_tech/D
	if(length(stored_disks) == 1)
		D = stored_disks[1]
	else
		var/list/options = list()
		var/slot = 0
		for(var/obj/item/stock_parts/computer/hard_drive/portable/psistation_tech/X in stored_disks)
			slot++
			options["Slot [slot]: [X.name]"] = X
		var/choice = input(user, "Which disk do you want to take?", "Server") as null|anything in options
		if(!choice)
			return
		D = options[choice]

	if(!D || !(D in stored_disks) || !Adjacent(user) || user.incapacitated())
		return

	stored_disks -= D
	D.forceMove(get_turf(user))
	user.put_in_hands(D)
	playsound(loc, 'sound/machines/click.ogg', 40, 1)
	user.visible_message(
		SPAN_NOTICE("\The [user] pulls a disk out of \the [src]."),
		SPAN_NOTICE("You pull \the [D] out of \the [src].")
	)
	update_icon()

/obj/structure/psistation/strange_server/attack_hand(obj/item/I, mob/user)
	if(!istype(I, /obj/item/stock_parts/computer/hard_drive/portable/psistation_tech))
		return ..()
	if(!opened)
		to_chat(user, SPAN_WARNING("\The [src] is locked."))
		return TRUE
	if(length(stored_disks) >= max_disks)
		to_chat(user, SPAN_WARNING("All the slots of \the [src] are already taken."))
		return TRUE
	if(!user.drop_from_inventory(I, src))
		return TRUE
	stored_disks += I
	playsound(loc, 'sound/machines/click.ogg', 40, 1)
	user.visible_message(
		SPAN_NOTICE("\The [user] slots a disk into \the [src]."),
		SPAN_NOTICE("You slot \the [I] into \the [src].")
	)
	update_icon()
	return TRUE

/obj/structure/psistation/strange_server_c
	parent_type = /obj/structure/psistation/strange_server
	name = "Closed Server"
	desc = "A strange server that appears to be locked with a smart digital lock."
	icon_state = "closed_server"
	opened = FALSE
	start_disks = 3

/obj/structure/psistation/strange_server3
	parent_type = /obj/structure/psistation/strange_server
	desc = "A strange server with digital blocks inside, they make a small hum when working, the door won't close, a smart lock."
	icon_state = "server_open3"
	start_disks = 3

/obj/structure/psistation/strange_server2
	parent_type = /obj/structure/psistation/strange_server
	desc = "A strange server, inside of which there are digital blocks, but one is missing, they make a small hum when working, the door does not close, a smart lock."
	icon_state = "server_open2"
	start_disks = 2

/obj/structure/psistation/strange_server0
	parent_type = /obj/structure/psistation/strange_server
	desc = "A strange server, which is empty inside, you can see places for something, the door does not close, a smart lock."
	icon_state = "server_open0"
	start_disks = 0

/obj/structure/psistation/technological_monolith_c
	name = "Closed technological monolith"
	desc = "Very strange and frightening machinery, it seems that locks are visible along the contour of the lid, they cannot be opened."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "strangecoffin_closed"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/technological_monolith
	name = "Technological monolith"
	desc = "Very strange and scary machinery, indicators actively blink, scan and emit a low squeak, the lid does not close."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "strangecoffin_open"
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE
	buckle_stance = BUCKLE_FORCE_STAND

	var/scan_state = PSISTATION_SCAN_IDLE
	var/scan_progress = 0
	var/list/scan_data
	var/mob/living/scan_subject
	var/scan_run_id = 0
	var/scan_steps = 10

/obj/structure/psistation/technological_monolith/examine(mob/user, ...)
	. = ..()
	to_chat(user, "You could sit in it. The computer to its left shows what it reads.")

/obj/structure/psistation/technological_monolith/MouseDrop_T(mob/target, mob/user)
	if (!CanMouseDrop(target, user) || !ismob(target))
		return

	density = FALSE
	user_buckle_mob(target, user)
	density = TRUE

	return TRUE

/obj/structure/psistation/technological_monolith/buckle_mob(mob/living/M, ...)
	. = ..()
	if(. && M.buckled == src)
		begin_scan(M)

/obj/structure/psistation/technological_monolith/unbuckle_mob(...)
	. = ..()
	if(scan_subject && scan_subject.buckled != src)
		abort_scan()

/obj/structure/psistation/technological_monolith/proc/begin_scan(mob/living/M)
	set waitfor = FALSE
	scan_run_id++
	var/run = scan_run_id
	scan_subject = M
	scan_state = PSISTATION_SCAN_RUNNING
	scan_progress = 0
	scan_data = null
	visible_message(SPAN_NOTICE("\The [src] hums and its indicators start to sweep over \the [M]."))
	playsound(loc, 'sound/machines/ping.ogg', 50, 1)
	notify_computers()

	for(var/i in 1 to 10)
		sleep(rand(5,10))
		if(QDELETED(src) || run != scan_run_id)
			return
		if(!scan_subject || scan_subject.buckled != src)
			abort_scan()
			return
		scan_progress = min(round(i + rand(10, 20)), 98)
		notify_computers()

	scan_data = build_scan_data(scan_subject)
	scan_state = PSISTATION_SCAN_DONE
	visible_message(SPAN_NOTICE("\The [src] emits a long, low squeak. The scan is complete."))
	playsound(loc, 'sound/machines/ping.ogg', 50, 1)
	notify_computers()

/obj/structure/psistation/technological_monolith/proc/abort_scan()
	scan_run_id++
	scan_state = PSISTATION_SCAN_IDLE
	scan_progress = 0
	scan_data = null
	scan_subject = null
	notify_computers()

/obj/structure/psistation/technological_monolith/proc/restart_scan(mob/user)
	if(scan_subject && scan_subject.buckled == src)
		begin_scan(scan_subject)
	else
		to_chat(user, SPAN_WARNING("There is nobody in \the [src] to scan."))
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 40, 1)

/obj/structure/psistation/technological_monolith/proc/notify_computers()
	var/turf/T = get_step(src, WEST)
	if(!T)
		return
	for(var/obj/structure/psistation/strange_computer/C in T)
		C.refresh_interface()

/obj/structure/psistation/technological_monolith/proc/build_scan_data(mob/living/M)
	var/list/data = list()
	data["name"] = M.real_name ? M.real_name : M.name

	if(!istype(M, /mob/living/carbon/human))
		data["unsupported"] = TRUE
		return data

	var/mob/living/carbon/human/H = M
	data["species"] = H.species ? H.species.name : "НЕИЗВЕСТНО"
	data["stat"] = H.stat
	data["clone"] = H.getCloneLoss()

	var/brain_loss = H.getBrainLoss()
	data["neural_integrity"] = clamp(round(100 - (brain_loss * 100 / max(H.maxHealth, 1))), 0, 100)

	var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
	if(!heart)
		data["heart"] = "No heart"
	else if(heart.pulse == PULSE_NONE)
		data["heart"] = "None"
	else
		data["heart"] = "Present"

	var/datum/psi_complexus/psi = H.psi
	if(psi)
		data["psi"] = TRUE
		var/list/ranks = psi.ranks
		data["psi_ranks"] = ranks ? ranks.Copy() : list()
		var/stamina = psi.stamina
		var/max_stamina = psi.max_stamina
		if(isnum(stamina) && isnum(max_stamina))
			data["psi_stamina"] = "[round(stamina)] / [round(max_stamina)]"
	return data

/obj/structure/psistation/technological_scanner
	name = "Technological Scanner"
	desc = "A very strange and big, huge scanner."
	icon = 'mods/_maps/psistation/psistation_sprites_96.dmi'
	icon_state = "mega_scan"
	anchored = TRUE

/obj/structure/psistation/technological_scanner_a
	name = "Technological Scanner"
	desc = "A very strange and big, huge scanner, it is active."
	icon = 'mods/_maps/psistation/psistation_sprites_96.dmi'
	icon_state = "mega_scan2"
	anchored = TRUE

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation
	faction = "foundation"
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "secbotlaser"
	icon_dead = "secbotlaser"
	explosion_radius = 2
	explosion_max_power = EX_ACT_LIGHT

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation/stun
	icon_state = "secbotstun"
	icon_dead = "secbotstun"

	projectiletype = /obj/item/projectile/beam/stun/smalllaser
	projectilesound = 'sound/weapons/plasma_cutter.ogg'

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation/stun/shield
	icon_state = "secbotstunriot"
	icon_dead = "secbotstunriot"
	natural_armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation/claws
	icon_state = "secbotclaws"
	icon_dead = "secbotclaws"

	projectiletype = null
	natural_weapon = /obj/item/natural_weapon/claws
	ai_holder = /datum/ai_holder/simple_animal/hivebot

/obj/landmark/corpse/bloody/LateInitialize(mapload)
	var/new_species = pickweight(species)
	var/mob/living/carbon/human/corpse = new (loc, new_species)
	corpse.adjustOxyLoss(corpse.maxHealth)
	corpse.setBrainLoss(corpse.maxHealth)
	corpse.adjustBruteLoss(corpse.maxHealth)
	corpse.faction = MOB_FACTION_NEUTRAL
	var/obj/item/organ/internal/heart/heart = corpse.internal_organs_by_name[BP_HEART]
	if (heart)
		heart.pulse = PULSE_NONE
	randomize_appearance(corpse, new_species)
	equip_outfit(corpse)
	corpse.update_icon()
	qdel(src)

/obj/landmark/corpse/husk/LateInitialize(mapload)
	var/new_species = pickweight(species)
	var/mob/living/carbon/human/corpse = new (loc, new_species)
	corpse.adjustOxyLoss(corpse.maxHealth)
	corpse.setBrainLoss(corpse.maxHealth)
	corpse.adjustFireLoss(corpse.maxHealth)
	corpse.ChangeToHusk()
	corpse.faction = MOB_FACTION_NEUTRAL
	var/obj/item/organ/internal/heart/heart = corpse.internal_organs_by_name[BP_HEART]
	if (heart)
		heart.pulse = PULSE_NONE
	randomize_appearance(corpse, new_species)
	equip_outfit(corpse)
	corpse.update_icon()
	qdel(src)
