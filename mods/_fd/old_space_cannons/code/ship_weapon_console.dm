/obj/machinery/computer/ship/ship_weapon
	name = "Ship weapon control"
	icon_keyboard = "syndie_key"
	icon_screen = "tcboss"

	core_skill = SKILL_ARMAMENT
	var/skill_offset = SKILL_TRAINED - 1 //After which skill level it starts to matter. -1, because we have to index from zero

	var/overmapdir = 0

	var/caldigit = 4		//number of digits that needs calibration
	var/list/calibration	//what it is
	var/list/calexpected	//what is should be

	var/next_shot = 0		//round time where the next shot can start from
	var/coolinterval = 30 SECONDS //time to wait between safe shots in deciseconds

	var/console_html_name = "mods-space_weapon.tmpl"
	var/gun_name = "Epic cannon"

	var/front_type = /obj/machinery/ship_weapon/front_part
	var/middle_type = /obj/machinery/ship_weapon/middle_part
	var/back_type = /obj/machinery/ship_weapon/back_part
	var/munition_type = /obj/item/ammo_magazine/ammobox

	var/obj/machinery/ship_weapon/front_part/front
	var/obj/machinery/ship_weapon/middle_part/middle
	var/obj/machinery/ship_weapon/back_part/back
	var/obj/item/ammo_magazine/ammobox/munition

	var/link_range = 10		//How far can the above stuff be maximum before we start complaining

	var/ammo_per_shot = 1	//��� ����� ���� ��������� �� �������
	var/burst_size = 3		//������� ��� ���
	var/fire_interval = 5	//��� ����� ����� ������ ���

	var/fire_delay = 0

	var/shake_camera_force = 8

	var/fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'
	var/prefire_sound = null

	var/far_fire_sound = 'sound/effects/explosionfar.ogg'
	var/far_prefire_sound = null

	var/muzzle_flash = /obj/projectile/bullet/muzzle/ship_weapon
	var/muzzle_color = null

	var/play_emptymag_sound = 1

/obj/machinery/computer/ship/ship_weapon/Initialize()
	. = ..()
	link_parts()
	reset_calibration()
	linked = map_sectors["[z]"]

/obj/machinery/computer/ship/ship_weapon/Destroy()
	release_links()
	. = ..()

/obj/machinery/computer/ship/ship_weapon/proc/link_parts()
	if(is_valid_setup())
		return TRUE

	for(front in SSmachines.machinery)
		if(get_dist(src, front) >= link_range || front.z != src.z || !istype(front,front_type))
			continue
		var/backwards = turn(front.dir, 180)
		middle = locate() in get_step(front, backwards)
		if(!middle || get_dist(src, middle) >= link_range || middle.z != src.z || !istype(middle,middle_type))
			continue
		back = locate() in get_step(middle, backwards)
		if(!back || get_dist(src, back) >= link_range || back.z != src.z || !istype(back,back_type))
			continue
		if(is_valid_setup())
			GLOB.destroyed_event.register(front, src, .proc/release_links)
			GLOB.destroyed_event.register(middle, src, .proc/release_links)
			GLOB.destroyed_event.register(back, src, .proc/release_links)
			return TRUE
	return FALSE

/obj/machinery/computer/ship/ship_weapon/proc/is_valid_setup()
	if(front && middle && back)
		var/everything_in_range = (get_dist(src, front) < link_range) && (get_dist(src, middle) < link_range) && (get_dist(src, back) < link_range)
		var/everything_in_order = (middle.Adjacent(front) && middle.Adjacent(back)) && (front.dir == middle.dir && middle.dir == back.dir)
		var/everything_has_valid_path = (istype(front,front_type) && istype(middle,middle_type) && istype(back,back_type))
		return everything_in_order && everything_in_range && everything_has_valid_path
	return FALSE

/obj/machinery/computer/ship/ship_weapon/proc/release_links()
	GLOB.destroyed_event.unregister(front, src, .proc/release_links)
	GLOB.destroyed_event.unregister(middle, src, .proc/release_links)
	GLOB.destroyed_event.unregister(back, src, .proc/release_links)
	front = null
	middle = null
	back = null

/obj/machinery/computer/ship/ship_weapon/proc/get_calibration()
	var/list/calresult[caldigit]
	for(var/i = 1 to caldigit)
		if(calibration[i] == calexpected[i])
			calresult[i] = 2
		else if(calibration[i] in calexpected)
			calresult[i] = 1
		else
			calresult[i] = 0
	return calresult

/obj/machinery/computer/ship/ship_weapon/proc/reset_calibration()
	calexpected = new /list(caldigit)
	calibration = new /list(caldigit)
	for(var/i = 1 to caldigit)
		calexpected[i] = rand(0,9)
		calibration[i] = 0

/obj/machinery/computer/ship/ship_weapon/proc/cal_accuracy()
	var/top = 0
	var/divisor = caldigit * 2 //maximum possible value, aka 100% accuracy
	for(var/i in get_calibration())
		top += i
	return round(top * 100 / divisor)

/obj/machinery/computer/ship/ship_weapon/proc/get_next_shot_seconds()
	return max(0, (next_shot - world.time) / 10)

/obj/machinery/computer/ship/ship_weapon/proc/cool_failchance()
	return get_next_shot_seconds() * 1000 / coolinterval

/obj/machinery/computer/ship/ship_weapon/proc/get_charge()
	for(var/obj/item/ammo_magazine/ammobox/ammo in get_turf(back))
		if(istype(ammo,munition_type))
			munition = ammo
	if(munition) return munition
	else return FALSE

/obj/machinery/computer/ship/ship_weapon/proc/get_ammo_type()
	munition = locate() in get_turf(back)
	if(munition && istype(munition,munition_type))
		var/obj/item/ammo_casing/AC = munition.stored_ammo[munition.stored_ammo.len]
		return AC.projectile_type

/obj/machinery/computer/ship/ship_weapon/proc/get_ammo()
	munition = locate() in get_turf(back)
	if(munition && istype(munition,munition_type))
		return munition.stored_ammo.len

/obj/machinery/computer/ship/ship_weapon/proc/remove_ammo()
	munition = locate() in get_turf(back)
	if(get_ammo() >= ammo_per_shot)
		var/to_remove = munition.stored_ammo[get_ammo()]
		munition.stored_ammo -= to_remove
		munition.contents -= to_remove
//		QDEL_NULL(to_remove) // RUNTIME: Was deleted before initialization
	return

/obj/machinery/computer/ship/ship_weapon/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	if(!linked)
		display_reconnect_dialog(user, "[gun_name] synchronization")
		return

	var/data[0]

	if (!link_parts())
		data["faillink"] = TRUE
	else
		data["calibration"] = calibration
		data["overmapdir"] = overmapdir
		data["cal_accuracy"] = cal_accuracy()
		data["next_shot"] = round(get_next_shot_seconds())
		data["nopower"] = !data["faillink"] && (!front.powered() || !middle.powered() || !back.powered())
		data["skill"] = user.get_skill_value(core_skill) > skill_offset

		var/ammo_count_console = SPAN_BOLD("UNKNOWN ERROR")
		switch(get_charge())
			if(FALSE)
				ammo_count_console = "[SPAN_BOLD("ERROR")]: No valid ammo detected."
			if("energy")
				ammo_count_console = ""
			else
				ammo_count_console = get_ammo()
		data["chargeload"] = ammo_count_console

		var/charge = SPAN_BOLD("UNKNOWN ERROR")
		switch(get_charge())
			if(FALSE)
				charge = "No valid ammo detected"
			if("energy")
				charge = "/Energy/"
			else
				var/obj/item/ammo_magazine/ammobox = get_charge()
				charge = ammobox.name
		data["chargename"] = charge

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, console_html_name, "[linked.name] [gun_name]", 400, 550)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/ship/ship_weapon/OnTopic(mob/user, list/href_list, state)
	. = ..()
	if(.)
		return

	if(!linked)
		return TOPIC_HANDLED

	if (href_list["choose"])
		overmapdir = sanitize_integer(text2num(href_list["choose"]), 0, 10, 0)
		reset_calibration()

	if(href_list["calibration"])
		var/input = input("0-9", "[gun_name] calibration", 0) as num|null
		if(!isnull(input)) //can be zero so we explicitly check for null
			var/calnum = sanitize_integer(text2num(href_list["calibration"]), 0, caldigit)//sanitiiiiize
			calibration[calnum + 1] = sanitize_integer(input, 0, 9, 0)//must add 1 because nanoui indexes from 0

	if(href_list["skill_calibration"])
		for(var/i = 1 to min(caldigit, user.get_skill_value(core_skill) - skill_offset))
			calibration[i] = calexpected[i]

	if(href_list["fire"])
		var/atomcharge_ammo = get_ammo()
		if(atomcharge_ammo != "energy")
			if(atomcharge_ammo < ammo_per_shot)
				return TOPIC_REFRESH
		if(prob(cool_failchance())) //Some moron disregarded the cooldown warning. Let's blow in their face.
			log_and_message_admins("[gun_name] ������ �����������", location=get_turf(middle))
			explosion(middle, rand(7, 12))
			explosion(front, rand(5, 9))
			if(front)
				front.set_broken()
			next_shot = coolinterval + world.time
			return TOPIC_REFRESH
		next_shot = coolinterval + world.time + fire_interval * burst_size
		log_and_message_admins("attempted to fire the [gun_name].")
		for(var/i = 1 to burst_size)
			if(atomcharge_ammo == 0 && play_emptymag_sound)
				playsound(get_charge(), 'sound/weapons/smg_empty_alarm.ogg', 100, 0)
			if(!get_charge())
				break
			fire(user)
			sleep(fire_interval)
		reset_calibration()
	return TOPIC_REFRESH
