/obj/machinery/computer/telescience
	name = "\improper Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_screen = "telesci"
	icon_keyboard = "telesci_key"
	light_color = COLOR_BLUE
	//circuit = /obj/item/stock_parts/circuitboard/telesci_console
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	var/last_target

	var/rotation = 0
	var/angle = 45
	var/power = 5

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80, 100)
	var/teleporting = 0
	var/starting_crystals = 0	//Edit this on the map, seriously.
	var/max_crystals = 5
	var/list/crystals = list()
	var/obj/item/device/gps/inserted_gps

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.forceMove(loc)
		inserted_gps = null
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	. = ..()
	to_chat(user, "There are [crystals.len ? crystals.len : "no"] bluespace crystal\s in the crystal slots.")

/obj/machinery/computer/telescience/Initialize()
	. = ..()
	recalibrate()
	for(var/i = 1; i <= starting_crystals; i++)
		crystals += new /obj/item/bluespace_crystal/artificial(null) // starting crystals

/obj/machinery/computer/telescience/use_tool(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/bluespace_crystal))
		if LAZYLEN(crystals >= max_crystals)
			to_chat(user, "<span class='warning'>There are not enough crystal slots.</span>")
			return
		user.drop_item(src)
		crystals += W
		W.forceMove(null)
		user.visible_message("[user] inserts [W] into \the [src]'s crystal slot.", "<span class='notice'>You insert [W] into \the [src]'s crystal slot.</span>")
		updateDialog()
	else if(istype(W, /obj/item/device/gps))
		if(!inserted_gps)
			inserted_gps = W
			user.unEquip(W)
			W.forceMove(src)
			user.visible_message("[user] inserts [W] into \the [src]'s GPS device slot.", "<span class='notice'>You insert [W] into \the [src]'s GPS device slot.</span>")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			telepad = M.buffer
			M.buffer = null
			to_chat(user, "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>")
	else
		..()

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.physical_attack_hand(user)

/obj/machinery/computer/telescience/physical_attack_hand(mob/user)
	if(..())
		return
	if(!user.skill_check(SKILL_SCIENCE, SKILL_EXPERIENCED))
		to_chat(user, "<span class='warning'>You see a lot of complex variables that you cannot understand.</span>")
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data via use of Multitool.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='?src=\ref[src];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='?src=\ref[src];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='?src=\ref[src];setrotation=1'>Set Bearing</A>"
		t += "<div class='statusDisplay'>[rotation]&deg;</div>"
		t += "<A href='?src=\ref[src];setangle=1'>Set Elevation</A>"
		t += "<div class='statusDisplay'>[angle]&deg;</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= power_options.len; i++)
			if(crystals.len + telepad.efficiency  < i)
				t += "<span class='linkOff'>[power_options[i]]</span>"
				continue
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<A href='?src=\ref[src];setpower=[i]'>[power_options[i]]</A>"
		t += "</div>"

		t += "<A href='?src=\ref[src];setz=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		t += "<BR><A href='?src=\ref[src];send=1'>Send</A>"
		t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
		t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Crystals</A> <A href='?src=\ref[src];eject=1'>Eject Crystals</A>"

		// Information about the last teleport
		t += "<BR><div class='statusDisplay'>"
		if(!last_tele_data)
			t += "No teleport data found."
		else
			t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<BR>"
			//t += "Distance: [round(last_tele_data.distance, 0.1)]m<BR>"
			t += "Time: [round(last_tele_data.time, 0.1)] secs<BR>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/datum/effect/spark_spread/sparks = new /datum/effect/spark_spread()
		sparks.set_up(5, 0, get_turf(telepad))
		sparks.start()
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)

		var/truePower = clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = clamp(angle, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		last_target = target
		var/area/A = get_area(target)
		flick("pad-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, 1)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		spawn(round(proj_data.time) * 10) // in seconds
			if(!telepad)
				return
			if(telepad.stat & src.is_powered())
				return
			teleporting = 0
			teleport_cooldown = world.time + (power * 2)
			teles_left -= 1

			// use a lot of power
			use_power_oneoff(power * 10)

			temp_msg = "Teleport successful.<BR>"
			if(teles_left < 10)
				temp_msg += "<BR>Calibration required soon."
			else
				temp_msg += "Data printed below."

			var/datum/effect/spark_spread/sparks = new /datum/effect/spark_spread()
			sparks.set_up(5, 0, telepad)
			sparks.start()

			var/turf/source = target
			var/turf/dest = get_turf(telepad)
			var/log_msg = ""
			log_msg += ": [key_name(user)] has teleported "

			if(sending)
				source = dest
				dest = target

			flick("pad-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			for(var/atom/movable/ROI in source)
				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						if(L.buckled)
							// TP people on office chairs
							if(L.buckled.anchored)
								continue

							log_msg += "[key_name(L)] (on a chair), "
						else
							continue
					else if(!isobserver(ROI))
						continue
				if(ismob(ROI))
					var/mob/T = ROI
					log_msg += "[key_name(T)], "
				else
					log_msg += "[ROI.name]"
					if (istype(ROI, /obj/structure/closet))
						var/obj/structure/closet/C = ROI
						log_msg += " ("
						for(var/atom/movable/Q as mob|obj in C)
							if(ismob(Q))
								log_msg += "[key_name(Q)], "
							else
								log_msg += "[Q.name], "
						if (dd_hassuffix(log_msg, "("))
							log_msg += "empty)"
						else
							//log_msg = dd_limittext(log_msg, length(log_msg) - 2)
							log_msg += ")"
					log_msg += ", "
				// ELAR's animation of human's telepoartation
				if(ishuman(ROI))
					animated_teleportation(ROI, dest)
				else
					do_teleport(ROI, dest)

			if (dd_hassuffix(log_msg, ", "))
				//log_msg = dd_limittext(log_msg, length(log_msg) - 2)
			else
				log_msg += "nothing"
			log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [z_co] ([A ? A.name : "null area"])"
			investigate_log(log_msg, "telesci")
			updateDialog()

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(rotation == null || angle == null || z_co == null || telepad == null)
		temp_msg = "ERROR!<BR>Set a angle, rotation and sector."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ERROR!<BR>No power selected!"
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR!<BR>Elevation is less than 1 or greater than 90."
		return
	if(z_co in GLOB.using_map.admin_levels)
		telefail()
		temp_msg = "ERROR! Sector is invalid! Valid sectors are [english_list(GLOB.using_map.player_levels)]."
		return
	if(!user.skill_check(SKILL_SCIENCE, SKILL_MASTER) && !(z_co in GLOB.using_map.station_levels))
		telefail()
		temp_msg = "ERROR! Bad configuration provided by the user. Unable to charge the teleporter."
		return
	// Да если у тебя мастер науки, ты все равно огребешь за телепорты с кораблика на планету в другом конце карты
	if(GLOB.using_map.use_overmap && !(z_co in GetConnectedZlevels(telepad.z)))
		var/obj/item/stock_parts/building_material/material = telepad.get_component_of_type(/obj/item/stock_parts/building_material)
		if(!(material && material.number_of_type(/obj/item/stack/material/diamond)!=0))
			telefail()
			temp_msg = "ERROR! Can not reach that sector. It's too far or need an upgrade!"
			return
		else
			telepad.visible_message(SPAN_NOTICE("\The [telepad] shines brighter when it's diamond lens focuses bluespace power!"))
			var/obj/overmap/visitable/we = map_sectors["[telepad.z]"]
			var/turf/T = get_turf(we)
			var/located = FALSE
			for(var/obj/overmap/visitable/candidate in T)
				if(candidate == we)
					continue
				if(z_co in candidate.map_z)
					located = TRUE
					break
			// Мы не нашли цель в нашем секторе, попробуем более серьезные варианты.
			if(!located)
				var/obj/item/stock_parts/power/battery/battery = telepad.get_component_of_type(/obj/item/stock_parts/power/battery)
				// Больше чем advanced меньше чем enchanced и да мы тратим энергию независимо от успеха
				if(!(battery && battery.can_use_power_oneoff(telepad, (1500 / CELLRATE), LOCAL) && battery.use_power_oneoff(telepad, (1500 / CELLRATE), LOCAL)))
					telefail()
					temp_msg = "ERROR! Can not reach that sector. Not enough power buffer capacity!"
					return
				else
					playsound(telepad, 'sound/machines/apc_nopower.ogg', 25, 0)
					telepad.visible_message(SPAN_NOTICE("\The [telepad] makes an loud sound as it internal capacitor quickly loose it's power!"))
					var/list/near_sectors = T.AdjacentTurfs()
					for(var/turf/Z in near_sectors)
						for(var/obj/overmap/visitable/candidate in Z)
							if(candidate == we)
								continue
							if(z_co in candidate.map_z)
								located = TRUE
								break
						if(located)
							break
					if(!located)
						telefail()
						temp_msg = "ERROR! Can not reach that sector. Too far. You did your best..."
						return
	if(teles_left > 0)
		doteleport(user)
	else
		telefail()
		temp_msg = "ERROR!<BR>Calibration required."
		return
	return

/obj/machinery/computer/telescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.forceMove(src.loc)
		crystals -= I
	power = 0

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(!telepad)
		updateDialog()
		return
	if(telepad.panel_open)
		temp_msg = "Telepad undergoing physical maintenance operations."

	if(href_list["setrotation"])
		var/new_rot = input("Please input desired bearing in degrees.", name, rotation) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(..())
			return
		angle = clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			if(crystals.len + telepad.efficiency >= index)
				power = power_options[index]

	if(href_list["setz"])
		var/new_z = input("Please input desired sector.", name, z_co) as num
		if(..())
			return
		z_co = clamp(round(new_z), 1, 35)

	if(href_list["ejectGPS"])
		if(inserted_gps)
			inserted_gps.forceMove(loc)
			inserted_gps = null

	if(href_list["setMemory"])
		if(last_target && inserted_gps)
			inserted_gps.locked_location = last_target
			temp_msg = "Location saved."
		else
			temp_msg = "ERROR!<BR>No data was stored."

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		recalibrate(usr)
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE:<BR>Bluespace crystals ejected."

	updateDialog()

/obj/machinery/computer/telescience/proc/recalibrate(mob/user)
	var/mult = 1
	if(user?.skill_check(SKILL_SCIENCE, SKILL_MASTER))
		mult = 2
	teles_left = rand(30, 40) * mult
	power_off = rand(-4, 0) / mult
	rotation_off = rand(-10, 10) / mult
