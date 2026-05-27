// MANIPULATION TREE
//
// Abilities in this tree allow the AI to physically manipulate systems around the station.
// T1 - Electrical Pulse - Sends out pulse that breaks some lights and sometimes even APCs. This can actually break the AI's APC so be careful!
// T2 - Reboot camera - Allows the AI to reactivate a camera.
// T3 - Emergency Forcefield - Allows the AI to project 1 tile forcefield that blocks movement and air flow. Forcefield dissipates over time. It is also very susceptible to energetic weaponry.
// T4 - Machine Overload - Detonates machine of choice in a minor explosion. Two of these are usually enough to kill or K/O someone.
// T5 - Machine Upgrade - Upgrades a machine of choice. Upgrade behavior can be defined for each machine independently.


// BEGIN RESEARCH DATUMS

/datum/malf_research_ability/manipulation/electrical_pulse
	ability = /datum/game_mode/malfunction/verb/electrical_pulse
	price = 250
	next = new/datum/malf_research_ability/manipulation/reboot_camera()
	name = "T1 - Electrical Pulse"


/datum/malf_research_ability/manipulation/reboot_camera
	ability = /datum/game_mode/malfunction/verb/reboot_camera
	price = 1000
	next = new/datum/malf_research_ability/manipulation/emergency_forcefield()
	name = "T2 - Reboot Camera"


/datum/malf_research_ability/manipulation/emergency_forcefield
	ability = /datum/game_mode/malfunction/verb/emergency_forcefield
	price = 2000
	next = new/datum/malf_research_ability/manipulation/machine_overload()
	name = "T3 - Emergency Forcefield"


/datum/malf_research_ability/manipulation/machine_overload
	ability = /datum/game_mode/malfunction/verb/machine_overload
	price = 4000
	next = new/datum/malf_research_ability/manipulation/machine_upgrade()
	name = "T4 - Machine Overload"

/datum/malf_research_ability/manipulation/machine_upgrade
	ability = /datum/game_mode/malfunction/verb/machine_upgrade
	price = 4000
	name = "T5 - Machine Upgrade"

// END RESEARCH DATUMS
// BEGIN ABILITY VERBS

/datum/game_mode/malfunction/verb/electrical_pulse()
	set name = "Electrical Pulse"
	set desc = "15 CPU - Sends feedback pulse through the power grid, overloading some sensitive systems, such as lights."
	set category = "Software"
	var/price = 15
	var/mob/living/silicon/ai/user = usr
	if(!ability_prechecks(user, price) || !ability_pay(user,price))
		return
	to_chat(user, "Sending feedback pulse...")
	var/list/valid_zlevels = GetConnectedZlevels(user.z)
	for(var/obj/machinery/power/apc/AP as anything in SSmachines.get_machinery_of_type(/obj/machinery/power/apc))
		if(!(AP.z in valid_zlevels))
			continue
		if(prob(5))
			AP.overload_lighting()
		if(prob(2.5) && (get_area(AP) != get_area(user))) // Very very small chance to actually destroy the APC, but not if the APC is powering the AI.
			AP.set_broken(TRUE)
	user.hacking = 1
	log_ability_use(user, "electrical pulse")
	spawn(15 SECONDS)
		if(user && !QDELETED(user))
			user.hacking = 0

/datum/game_mode/malfunction/verb/reboot_camera(obj/machinery/camera/target as obj in cameranet.cameras)
	set name = "Reboot Camera"
	set desc = "100 CPU - Reboots a damaged but not completely destroyed camera."
	set category = "Software"
	var/price = 100
	var/mob/living/silicon/ai/user = usr

	if(target && !istype(target))
		to_chat(user, "This is not a camera.")
		return

	if(!target)
		var/list/valid_cameras = get_cameras_in_network(user)
		if(!length(valid_cameras))
			to_chat(user, "No valid cameras found on your connected network.")
			return
		target = input(user, "Select camera to reboot", "Reboot Camera") as null|obj in valid_cameras
		if(!target)
			return

	if(!user || QDELETED(user) || user.stat == DEAD || user.is_dead() || !user.malfunctioning || !user.research)
		return

	if(!target || QDELETED(target) || !can_ai_reach_target(user, target))
		to_chat(user, "This camera is outside your accessible network.")
		return

	if(!ability_prechecks(user, price) || !ability_pay(user, price))
		return

	target.stat = initial(target.stat)
	target.reset_wires()
	target.update_icon()
	target.update_coverage()
	to_chat(user, "Camera reactivated.")
	log_ability_use(user, "reset camera", target)


/datum/game_mode/malfunction/verb/emergency_forcefield(turf/T as turf in world)
	set name = "Emergency Forcefield"
	set desc = "275 CPU - Uses the emergency shielding system to create temporary barrier which lasts for few minutes, but won't resist gunfire."
	set category = "Software"
	var/price = 275
	var/mob/living/silicon/ai/user = usr
	if(!T)
		to_chat(user, "Please select a turf by clicking on it directly in your camera view.")
		return
	if(!istype(T))
		return
	if(!can_ai_reach_target(user, T))
		to_chat(user, "This location is outside your accessible network.")
		return
	if(!ability_prechecks(user, price) || !ability_pay(user, price))
		return

	to_chat(user, "Emergency forcefield projection completed.")
	new/obj/machinery/shield/malfai(T)
	user.hacking = 1
	log_ability_use(user, "emergency forcefield", T)
	spawn(2 SECONDS)
		if(user && !QDELETED(user))
			user.hacking = 0


/datum/game_mode/malfunction/verb/machine_overload(obj/machinery/M as obj in SSmachines.get_all_machinery())
	set name = "Machine Overload"
	set desc = "400 CPU - Causes cyclic short-circuit in machine, resulting in weak explosion after some time."
	set category = "Software"
	var/price = 400
	var/mob/living/silicon/ai/user = usr

	if(!M)
		var/list/valid_machines = get_machines_in_network(user)
		if(!length(valid_machines))
			to_chat(user, "No valid machines found on your connected network.")
			return
		M = input(user, "Select machine to overload", "Machine Overload") as null|obj in valid_machines
		if(!M)
			return

	if(!user || QDELETED(user) || user.stat == DEAD || user.is_dead() || !user.malfunctioning || !user.research)
		return

	if(!M || QDELETED(M) || !can_ai_reach_target(user, M))
		to_chat(user, "This machine is outside your accessible network.")
		return

	if(!ability_prechecks(user, price))
		return

	var/obj/machinery/power/N = M

	var/explosion_intensity = 2

	// Verify if we can overload the target, if yes, calculate explosion strength. Some things have higher explosion strength than others, depending on charge(APCs, SMESs)
	if(N && istype(N)) // /obj/machinery/power first, these create bigger explosions due to direct powernet connection
		if(!istype(N, /obj/machinery/power/apc) && !istype(N, /obj/machinery/power/smes/buildable) && (!N.powernet || !N.powernet.avail)) // Directly connected machine which is not an APC or SMES. Either it has no powernet connection or it's powernet does not have enough power to overload
			to_chat(user, SPAN_NOTICE("ERROR: Low network voltage. Unable to overload. Increase network power level and try again."))
			return
		else if (istype(N, /obj/machinery/power/apc)) // APC. Explosion is increased by available cell power.
			var/obj/machinery/power/apc/A = N
			var/obj/item/cell/cell = A.get_cell()
			if(cell && cell.charge)
				explosion_intensity = 4 + round((cell.charge / CELLRATE) / 100000)
			else
				to_chat(user, SPAN_NOTICE("ERROR: APC Malfunction - Cell depleted or removed. Unable to overload."))
				return
		else if (istype(N, /obj/machinery/power/smes/buildable)) // SMES. These explode in a very very very big boom. Similar to magnetic containment failure when messing with coils.
			var/obj/machinery/power/smes/buildable/S = N
			if(S.charge && S.RCon)
				explosion_intensity = 4 + round((S.charge / CELLRATE) / 100000)
			else
				// Different error texts
				if(!S.charge)
					to_chat(user, SPAN_NOTICE("ERROR: SMES Depleted. Unable to overload. Please charge SMES unit and try again."))
				else
					to_chat(user, SPAN_NOTICE("ERROR: SMES RCon error - Unable to reach destination. Please verify wire connection."))
				return
	else if(M && istype(M)) // Not power machinery, so it's a regular machine instead. These have weak explosions.
		if(!M.use_power) // Not using power at all
			to_chat(user, SPAN_NOTICE("ERROR: No power grid connection. Unable to overload."))
			return
		if(M.inoperable()) // Not functional
			to_chat(user, SPAN_NOTICE("ERROR: Unknown error. Machine is probably damaged or power supply is nonfunctional."))
			return
	else // Not a machine at all (what the hell is this doing in Machines list anyway??)
		to_chat(user, SPAN_NOTICE("ERROR: Unable to overload - target is not a machine."))
		return

	explosion_intensity = min(explosion_intensity, 12) // 3, 6, 12 explosion cap

	if(!ability_pay(user,price))
		return

	M.use_power_oneoff(250 KILOWATTS)

	// Trigger a powernet alarm. Careful engineers will probably notice something is going on.
	var/area/temp_area = get_area(M)
	if(temp_area)
		var/obj/machinery/power/apc/temp_apc = temp_area.apc
		var/obj/machinery/power/terminal/terminal = temp_apc?.terminal()
		if (terminal?.powernet)
			terminal.powernet.trigger_warning(50)
			if (prob(explosion_intensity))
				temp_apc.emp_act(1)


	log_ability_use(user, "machine overload", M)
	M.visible_message(SPAN_NOTICE("BZZZZZZZT"))
	var/turf/epicenter = get_turf(M)
	var/final_range = min(round(explosion_intensity * 0.35), 4) // Cap range to 4 tiles maximum to keep it balanced and avoid destroying half the station!
	spawn(5 SECONDS)
		if(epicenter)
			explosion(epicenter, final_range)
		if(M && !QDELETED(M))
			qdel(M)

/datum/game_mode/malfunction/verb/machine_upgrade(obj/machinery/M as obj in SSmachines.get_all_machinery())
	set name = "Machine Upgrade"
	set desc = "800 CPU - Pushes existing hardware to it's technological limits by rapidly upgrading it's software."
	set category = "Software"
	var/price = 800
	var/mob/living/silicon/ai/user = usr

	if(!M)
		var/list/valid_machines = get_machines_in_network(user)
		if(!length(valid_machines))
			to_chat(user, "No valid machines found on your connected network.")
			return
		M = input(user, "Select machine to upgrade", "Machine Upgrade") as null|obj in valid_machines
		if(!M)
			return

	if(!user || QDELETED(user) || user.stat == DEAD || user.is_dead() || !user.malfunctioning || !user.research)
		return

	if(!M || QDELETED(M) || !can_ai_reach_target(user, M))
		to_chat(user, "This machine is outside your accessible network.")
		return

	if(!ability_prechecks(user, price))
		return

	if(M.malf_upgraded)
		to_chat(user, "\The [M] has already been upgraded.")
		return

	if(!ability_pay(user, price))
		return

	if(!M.malf_upgrade(user))
		to_chat(user, "\The [M] cannot be upgraded.")
		if(user && !QDELETED(user) && user.research)
			user.research.stored_cpu += price
		return

// END ABILITY VERBS
