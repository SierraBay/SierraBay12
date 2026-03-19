

// The Area Power Controller (APC)
// Controls and provides power to most electronics in an area
// Only one required per area
// Requires a wire connection to a power network through a terminal
// Generates a terminal based on the direction of the APC on spawn

// There are three different power channels, lighting, equipment, and enviroment
// Each may have one of the following states

#define POWERCHAN_OFF		0	// Power channel is off
#define POWERCHAN_OFF_TEMP	1	// Power channel is off until there is power
#define POWERCHAN_OFF_AUTO	2	// Power channel is off until power passes a threshold
#define POWERCHAN_ON		3	// Power channel is on until there is no power
#define POWERCHAN_ON_AUTO	4	// Power channel is on until power drops below a threshold

// Power channels set to Auto change when power levels rise or drop below a threshold

#define AUTO_THRESHOLD_LIGHTING  50
#define AUTO_THRESHOLD_EQUIPMENT 25
// The ENVIRON channel stays on as long as possible, and doesn't have a threshold

#define CRITICAL_APC_EMP_PROTECTION 10	// EMP effect duration is divided by this number if the APC has "critical" flag
#define APC_UPDATE_ICON_COOLDOWN 100	// Time between automatically updating the icon (10 seconds)

// Used to check whether or not to update the icon_state
#define UPDATE_CELL_IN 1
#define UPDATE_OPENED1 2
#define UPDATE_OPENED2 4
#define UPDATE_MAINT 8
#define UPDATE_BROKE 16
#define UPDATE_BLUESCREEN 32
#define UPDATE_WIREEXP 64
#define UPDATE_ALLGOOD 128

// Used to check whether or not to update the overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_LOCKED 8
#define APC_UPOVERLAY_OPERATING 16

#define APC_CACHE_LOAD_DIRTY (1<<0)
#define APC_CACHE_EXTERNAL_DIRTY (1<<1)
#define APC_CACHE_AUTOMATION_DIRTY (1<<2)
#define APC_CACHE_UI_DIRTY (1<<3)
#define APC_CACHE_ALL_DIRTY (APC_CACHE_LOAD_DIRTY | APC_CACHE_EXTERNAL_DIRTY | APC_CACHE_AUTOMATION_DIRTY | APC_CACHE_UI_DIRTY)

#define APC_POWER_REGIME_NONE 0
#define APC_POWER_REGIME_ENVIRONMENT_ONLY 1
#define APC_POWER_REGIME_EQUIPMENT_ONLY 2
#define APC_POWER_REGIME_ALL_ON 3

// Various APC types
/obj/machinery/power/apc/inactive
	lighting_channel = 0
	equipment_channel = 0
	environment_channel = 0
	locked = 0
	coverlocked = 0

/obj/machinery/power/apc/critical
	is_critical = 1

/obj/machinery/power/apc/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/high/inactive
	cell_type = /obj/item/cell/high
	lighting_channel = 0
	equipment_channel = 0
	environment_channel = 0
	locked = 0
	coverlocked = 0

/obj/machinery/power/apc/super
	cell_type = /obj/item/cell/super

/obj/machinery/power/apc/super/critical
	is_critical = 1

/obj/machinery/power/apc/hyper
	cell_type = /obj/item/cell/hyper

// APC that barely has any juice
/obj/machinery/power/apc/near_empty
	cell_type = /obj/item/cell/crap/discharged

// Main APC code
/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."

	icon_state = "apc0"
	icon = 'icons/obj/machines/apc.dmi'
	anchored = TRUE
	power_state = POWER_USE_IDLE // Has custom handling here.
	power_channel = LOCAL      // Do not manipulate this; you don't want to power the APC off itself.
	interact_offline = TRUE    // Can use UI even if unpowered
	uncreated_component_parts = list(
		/obj/item/stock_parts/power/terminal,
		/obj/item/stock_parts/power/apc,
		/obj/item/stock_parts/power/battery
		)
	req_access = list(access_engine_equip)
	clicksound = "switch"
	layer = ABOVE_WINDOW_LAYER
	health_max = 80
	health_min_damage = 5
	damage_hitsound = 'sound/weapons/smash.ogg'
	var/needs_powerdown_sound
	var/area/apc_area
	var/areastring = null
	var/cell_type = /obj/item/cell/standard
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting_channel = POWERCHAN_ON_AUTO
	var/equipment_channel = POWERCHAN_ON_AUTO
	var/environment_channel = POWERCHAN_ON_AUTO
	var/operating = 1       // Bool for main toggle.
	var/charging = 0        // Whether or not it's charging. 0 - not charging but not full, 1 - charging, 2 - full
	var/chargemode = 1      // Whether charging is toggled on or off.
	var/locked = 1
	var/coverlocked = 1     // Whether you can crowbar off the cover or need to swipe ID first.
	var/aidisabled = 0
	var/last_used_lighting = 0
	var/last_used_equipment = 0
	var/last_used_environment = 0
	var/last_used_charging = 0
	var/last_used_total = 0
	var/main_status = 0     // UI var for whether we are getting external power. 0 = no external power at all, 1 = some, but not enough, 2 = getting enough.
	var/mob/living/silicon/ai/hacker = null // Malfunction var. If set AI hacked the APC and has full control.
	var/wiresexposed = FALSE // whether you can access the wires for hacking or not.
	powernet = 0		 // set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/debug= 0         // Legacy debug toggle, left in for admin use.
	var/autoflag= 0		 // 0 = off, 1= eqp and lights off, 2 = eqp off, 3 = all on.
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/longtermpower = 10  // Counter to smooth out power state changes; do not modify.
	wires = /datum/wires/apc
	var/update_state = -1
	var/update_overlay = -1
	var/list/update_overlay_chan		// Used to determine if there is a change in channels
	var/is_critical = 0
	/// Boolean. Whether or not the status overlays caches have been generated.
	var/static/status_overlays = FALSE
	var/failure_timer = 0               // Cooldown thing for apc outage event
	var/force_update = 0
	var/emp_hardened = 0
	var/cache_flags = APC_CACHE_ALL_DIRTY
	var/cached_total_load = 0
	var/cached_equipment_load = 0
	var/cached_lighting_load = 0
	var/cached_environment_load = 0
	var/cached_external_avail = 0
	var/cached_external_surplus = 0
	var/cached_power_regime = -1
	var/last_seen_usage_revision = -1
	var/cached_external_process_time = -1
	var/obj/machinery/power/terminal/cached_external_terminal

	/**
	 * List of images. Cached icon overlays for the lock indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emmissive,
	 * 	2 => "on",
	 * 	3 => "off"
	 * )
	 * ```
	 */
	var/static/list/status_overlays_lock

	/**
	 * List of images. Cached icon overlays for the charging status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emmissive,
	 * 	2 => "Not Charging",
	 * 	3 => "Charging",
	 * 	4 => "Fully Charged"
	 * )
	 * ```
	 */
	var/static/list/status_overlays_charging

	/**
	 * List of images. Cached icon overlays for the equipment channel status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emissive,
	 * 	2 => POWERCHAN_OFF,
	 * 	3 => POWERCHAN_OFF_TEMP,
	 * 	4 => POWERCHAN_OFF_AUTO,
	 * 	5 => POWERCHAN_ON,
	 * 	6 => POWERCHAN_ON_AUTO
	 * )
	 * ```
	 */
	var/static/list/status_overlays_equipment

	/**
	 * List of images. Cached icon overlays for the equipment channel status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emissive,
	 * 	2 => POWERCHAN_OFF,
	 * 	3 => POWERCHAN_OFF_TEMP,
	 * 	4 => POWERCHAN_OFF_AUTO,
	 * 	5 => POWERCHAN_ON,
	 * 	6 => POWERCHAN_ON_AUTO
	 * )
	 * ```
	 */
	var/static/list/status_overlays_lighting

	/**
	 * List of images. Cached icon overlays for the equipment channel status indicator.
	 *
	 * ```dm
	 * list(
	 * 	1 => emissive,
	 * 	2 => POWERCHAN_OFF,
	 * 	3 => POWERCHAN_OFF_TEMP,
	 * 	4 => POWERCHAN_OFF_AUTO,
	 * 	5 => POWERCHAN_ON,
	 * 	6 => POWERCHAN_ON_AUTO
	 * )
	 * ```
	 */
	var/static/list/status_overlays_environ
	var/autoname = 1

/obj/machinery/power/apc/updateDialog()
	if (MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
		return
	..()

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	var/obj/machinery/power/terminal/terminal = terminal()
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/drain_power(drain_check, surge, amount = 0)

	if(drain_check)
		return 1

	// Prevents APCs from being stuck on 0% cell charge while reporting "Fully Charged" status.
	charging = 0

	// If the APC's interface is locked, limit the charge rate to 25%.
	if(locked)
		amount /= 4

	return amount - use_power_oneoff(amount, LOCAL)

/obj/machinery/power/apc/Initialize(mapload, ndir, populate_parts = TRUE, building=0)
	// offset 22 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		set_dir(ndir)

	if(areastring)
		apc_area = get_area_name(areastring)
	else
		apc_area = get_area(src)
	if(autoname)
		SetName("\improper [apc_area.name] APC")
	apc_area.apc = src

	. = ..()
	machine_powernet = apc_area?.create_powernet()
	if(machine_powernet)
		machine_powernet.powernet_apc = src

	if (building==0)
		init_round_start()
	else
		opened = 1
		operating = 0
		set_stat(MACHINE_STAT_MAINT, TRUE)
		queue_icon_update()

	if(operating)
		force_update_channels()
	power_change()

/obj/machinery/power/apc/Destroy()
	src.update()
	if(apc_area)
		apc_area.apc = null
	var/datum/local_powernet/local_net = machine_powernet || apc_area?.powernet
	if(local_net)
		if(local_net.powernet_apc == src)
			local_net.powernet_apc = null
		local_net.lighting_powered = FALSE
		local_net.equipment_powered = FALSE
		local_net.environment_powered = FALSE
		local_net.power_change()

	// Malf AI, removes the APC from AI's hacked APCs list.
	if((hacker) && (hacker.hacked_apcs) && (src in hacker.hacked_apcs))
		hacker.hacked_apcs -= src

	return ..()

/obj/machinery/power/apc/get_req_access()
	if(!locked)
		return list()
	return ..()

/obj/machinery/power/apc/proc/energy_fail(duration)
	if(emp_hardened)
		return
	failure_timer = max(failure_timer, round(duration))
	mark_cache_dirty()
	playsound(src, 'sound/machines/apc_nopower.ogg', 75, 0)

/obj/machinery/power/apc/proc/init_round_start()
	has_electronics = 2 //installed and secured

	var/obj/item/stock_parts/power/battery/bat = get_component_of_type(/obj/item/stock_parts/power/battery)
	bat.add_cell(src, new cell_type(bat))
	var/obj/item/stock_parts/power/terminal/term = get_component_of_type(/obj/item/stock_parts/power/terminal)
	term.make_terminal(src)

	queue_icon_update()

/obj/machinery/power/apc/proc/terminal()
	var/obj/item/stock_parts/power/terminal/term = get_component_of_type(/obj/item/stock_parts/power/terminal)
	return term && term.terminal

/obj/machinery/power/apc/proc/mark_cache_dirty(flags = APC_CACHE_ALL_DIRTY)
	cache_flags |= flags

/obj/machinery/power/apc/proc/refresh_external_cache(force = FALSE)
	var/obj/machinery/power/terminal/external_terminal = terminal()
	if(force || (cache_flags & APC_CACHE_EXTERNAL_DIRTY) || cached_external_process_time != world.time || cached_external_terminal != external_terminal)
		cached_external_terminal = external_terminal
		cached_external_avail = (external_terminal && external_terminal.avail()) || 0
		cached_external_surplus = (external_terminal && external_terminal.surplus()) || 0
		cached_external_process_time = world.time
		cache_flags &= ~APC_CACHE_EXTERNAL_DIRTY
	return external_terminal

/obj/machinery/power/apc/proc/get_cached_power_regime(percent)
	if(failure_timer || !operating || shorted || !is_powered() || isnull(percent))
		return APC_POWER_REGIME_NONE
	if(percent > AUTO_THRESHOLD_LIGHTING || longtermpower >= 0)
		return APC_POWER_REGIME_ALL_ON
	if(percent > AUTO_THRESHOLD_EQUIPMENT)
		return APC_POWER_REGIME_EQUIPMENT_ONLY
	return APC_POWER_REGIME_ENVIRONMENT_ONLY

/obj/machinery/power/apc/proc/update_last_used()
	if(!apc_area)
		last_used_lighting = 0
		last_used_equipment = 0
		last_used_environment = 0
		last_used_total = 0
		cached_lighting_load = 0
		cached_equipment_load = 0
		cached_environment_load = 0
		cached_total_load = 0
		last_seen_usage_revision = -1
		cache_flags &= ~APC_CACHE_LOAD_DIRTY
		return
	var/datum/local_powernet/local_net = machine_powernet || apc_area.powernet || apc_area.create_powernet()
	if(!local_net)
		last_used_lighting = 0
		last_used_equipment = 0
		last_used_environment = 0
		last_used_total = 0
		cached_lighting_load = 0
		cached_equipment_load = 0
		cached_environment_load = 0
		cached_total_load = 0
		last_seen_usage_revision = -1
		cache_flags &= ~APC_CACHE_LOAD_DIRTY
		return
	if((cache_flags & APC_CACHE_LOAD_DIRTY) || last_seen_usage_revision != local_net.usage_revision)
		cached_lighting_load = (lighting_channel >= POWERCHAN_ON) ? local_net.get_channel_usage(PW_CHANNEL_LIGHTING) : 0
		cached_equipment_load = (equipment_channel >= POWERCHAN_ON) ? local_net.get_channel_usage(PW_CHANNEL_EQUIPMENT) : 0
		cached_environment_load = (environment_channel >= POWERCHAN_ON) ? local_net.get_channel_usage(PW_CHANNEL_ENVIRONMENT) : 0
		cached_total_load = cached_lighting_load + cached_equipment_load + cached_environment_load
		last_seen_usage_revision = local_net.usage_revision
		cache_flags &= ~APC_CACHE_LOAD_DIRTY
	last_used_lighting = cached_lighting_load
	last_used_equipment = cached_equipment_load
	last_used_environment = cached_environment_load
	last_used_total = cached_total_load

/obj/machinery/power/apc/proc/set_channel_state(channel, new_state)
	var/changed = FALSE
	switch(channel)
		if(EQUIP)
			if(equipment_channel == new_state)
				return
			equipment_channel = new_state
			changed = TRUE
		if(LIGHT)
			if(lighting_channel == new_state)
				return
			lighting_channel = new_state
			changed = TRUE
		if(ENVIRON)
			if(environment_channel == new_state)
				return
			environment_channel = new_state
			changed = TRUE
	if(changed)
		mark_cache_dirty(APC_CACHE_LOAD_DIRTY | APC_CACHE_UI_DIRTY)

/obj/machinery/power/apc/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		var/terminal = terminal()
		if(opened)
			if(has_electronics && terminal)
				to_chat(user, "The cover is [opened==2?"removed":"open"] and the power cell is [ get_cell() ? "installed" : "missing"].")
			else if (!has_electronics && terminal)
				to_chat(user, "There are some wires but no any electronics.")
			else if (has_electronics && !terminal)
				to_chat(user, "Electronics installed but not wired.")
			else /* if (!has_electronics && !terminal) */
				to_chat(user, "There is no electronics nor connected wires.")

		else
			if (GET_FLAGS(stat, MACHINE_STAT_MAINT))
				to_chat(user, "The cover is closed. Something wrong with it: it doesn't work.")
			else if (hacker && !hacker.hacked_apcs_hidden)
				to_chat(user, "The cover is locked.")
			else
				to_chat(user, "The cover is closed.")


/obj/machinery/power/apc/CanUseTopicPhysical(mob/user)
	return GLOB.physical_state.can_use_topic(nano_host(), user)

/obj/machinery/power/apc/physical_attack_hand(mob/user)
	//Human mob special interaction goes here.
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user

		if(H.species.can_shred(H))
			user.visible_message(SPAN_WARNING("\The [user] slashes at \the [src]!"), SPAN_NOTICE("You slash at \the [src]!"))
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)

			var/allcut = wires.IsAllCut()

			if(beenhit >= pick(3, 4) && !wiresexposed)
				wiresexposed = TRUE
				src.update_icon()
				src.visible_message(SPAN_WARNING("\The The [src]'s cover flies open, exposing the wires!"))

			else if(wiresexposed && allcut == 0)
				wires.CutAll()
				src.update_icon()
				src.visible_message(SPAN_WARNING("\The [src]'s wires are shredded!"))
			else
				beenhit += 1
			return TRUE

/obj/machinery/power/apc/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!user)
		return
	var/obj/item/cell/cell = get_cell()

	var/list/data = list(
		"pChan_Off" = POWERCHAN_OFF,
		"pChan_Off_T" = POWERCHAN_OFF_TEMP,
		"pChan_Off_A" = POWERCHAN_OFF_AUTO,
		"pChan_On" = POWERCHAN_ON,
		"pChan_On_A" = POWERCHAN_ON_AUTO,
		"locked" = (locked && !emagged) ? 1 : 0,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = round(last_used_total),
		"totalCharging" = round(last_used_charging),
		"coverLocked" = coverlocked,
		"failTime" = failure_timer * 2,
		"siliconUser" = (istype(user, /mob/living/silicon) || (isghost(user) && isadmin(user))),
		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = last_used_equipment,
				"status" = equipment_channel,
				"topicParams" = list(
					"auto" = list("eqp" = 2),
					"on"   = list("eqp" = 1),
					"off"  = list("eqp" = 0)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = round(last_used_lighting),
				"status" = lighting_channel,
				"topicParams" = list(
					"auto" = list("lgt" = 2),
					"on"   = list("lgt" = 1),
					"off"  = list("lgt" = 0)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = round(last_used_environment),
				"status" = environment_channel,
				"topicParams" = list(
					"auto" = list("env" = 2),
					"on"   = list("env" = 1),
					"off"  = list("env" = 0)
				)
			)
		)
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "apc.tmpl", "[apc_area.name] - APC", 520, data["siliconUser"] ? 465 : 440)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	var/obj/item/cell/cell = get_cell()
	return "[apc_area.name] : [equipment_channel]/[lighting_channel]/[environment_channel] ([last_used_equipment+last_used_lighting+last_used_environment]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	var/datum/local_powernet/local_net = machine_powernet || apc_area?.powernet || apc_area?.create_powernet()
	var/old_lighting_power = local_net?.has_power(PW_CHANNEL_LIGHTING)
	if(local_net)
		local_net.powernet_apc = src
	if(operating && !shorted && !failure_timer)
		if(local_net)
			local_net.lighting_powered = (lighting_channel >= POWERCHAN_ON)
			local_net.equipment_powered = (equipment_channel >= POWERCHAN_ON)
			local_net.environment_powered = (environment_channel >= POWERCHAN_ON)
	else
		if(local_net)
			local_net.lighting_powered = FALSE
			local_net.equipment_powered = FALSE
			local_net.environment_powered = FALSE

	if(local_net)
		if(apc_area && old_lighting_power != local_net.has_power(PW_CHANNEL_LIGHTING))
			apc_area.set_emergency_lighting(lighting_channel == POWERCHAN_OFF_AUTO) //if lights go auto-off, emergency lights go on
		local_net.power_change()
	else
		apc_area.power_change()
	mark_cache_dirty(APC_CACHE_LOAD_DIRTY | APC_CACHE_EXTERNAL_DIRTY | APC_CACHE_UI_DIRTY)

	var/obj/item/cell/cell = get_cell()
	if(!cell || cell.charge <= 0)
		if(needs_powerdown_sound == TRUE)
			playsound(src, 'sound/machines/apc_nopower.ogg', 75, 0)
			needs_powerdown_sound = FALSE
		else
			needs_powerdown_sound = TRUE

/obj/machinery/power/apc/proc/isWireCut(wireIndex)
	return wires.IsIndexCut(wireIndex)


/obj/machinery/power/apc/CanUseTopic(mob/user, datum/topic_state/state)
	if(user.lying)
		to_chat(user, SPAN_WARNING("You must stand to use [src]!"))
		return STATUS_CLOSE
	if(istype(user, /mob/living/silicon))
		var/permit = 0 // Malfunction variable. If AI hacks APC it can control it even without AI control wire.
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(hacker && !hacker.hacked_apcs_hidden)
			if(hacker == AI)
				permit = 1
			else if(istype(robot) && robot.connected_ai && robot.connected_ai == hacker) // Cyborgs can use APCs hacked by their AI
				permit = 1

		if(aidisabled && !permit)
			return STATUS_CLOSE
	. = ..()
	if(user.restrained())
		to_chat(user, SPAN_WARNING("You must have free hands to use [src]."))
		. = min(., STATUS_UPDATE)

/obj/machinery/power/apc/Topic(href, href_list)
	if(..())
		return 1

	if(!istype(usr, /mob/living/silicon) && (locked && !emagged) && !(isghost(usr) && isadmin(usr)))
		// Shouldn't happen, this is here to prevent href exploits
		to_chat(usr, "You must unlock the panel to use this!")
		return 1

	if (href_list["lock"])
		coverlocked = !coverlocked

	else if( href_list["reboot"] )
		failure_timer = 0
		update_icon()
		update()

	else if (href_list["breaker"])
		toggle_breaker()

	else if (href_list["cmode"])
		set_chargemode(!chargemode)
		if(!chargemode)
			charging = 0
			update_icon()

	else if (href_list["eqp"])
		var/val = text2num(href_list["eqp"])
		set_channel_state(EQUIP, setsubsystem(val))
		force_update_channels()

	else if (href_list["lgt"])
		var/val = text2num(href_list["lgt"])
		set_channel_state(LIGHT, setsubsystem(val))
		force_update_channels()

	else if (href_list["env"])
		var/val = text2num(href_list["env"])
		set_channel_state(ENVIRON, setsubsystem(val))
		force_update_channels()

	else if (href_list["overload"])
		if(istype(usr, /mob/living/silicon))
			src.overload_lighting()

	else if (href_list["toggleaccess"])
		if(istype(usr, /mob/living/silicon))
			if(emagged || MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
				to_chat(usr, "The APC does not respond to the command.")
			else
				locked = !locked
				update_icon()

	return STATUS_UPDATE

/obj/machinery/power/apc/proc/force_update_channels()
	autoflag = -1 // This clears state, forcing a full recalculation
	mark_cache_dirty(APC_CACHE_LOAD_DIRTY | APC_CACHE_AUTOMATION_DIRTY | APC_CACHE_UI_DIRTY)
	update_channels(TRUE)
	update()
	queue_icon_update()

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating
	mark_cache_dirty()
	force_update_channels()

/obj/machinery/power/apc/get_power_usage()
	if(!operating || shorted || failure_timer || !apc_area)
		return 0
	if(autoflag)
		return last_used_total // If not, we need to do something more sophisticated: compute how much power we would need in order to come back online.
	. = 0
	if(autoset(lighting_channel, 2) >= POWERCHAN_ON)
		. += apc_area.usage(LIGHT)
	if(autoset(equipment_channel, 2) >= POWERCHAN_ON)
		. += apc_area.usage(EQUIP)
	if(autoset(environment_channel, 1) >= POWERCHAN_ON)
		. += apc_area.usage(ENVIRON)

/obj/machinery/power/apc/Process()
	if(!apc_area.requires_power)
		return PROCESS_KILL

	if(MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
		return

	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = 1
		mark_cache_dirty()
		return

	update_last_used()
	apc_area.clear_usage()

	//store states to update icon if any change
	var/last_lt = lighting_channel
	var/last_eq = equipment_channel
	var/last_en = environment_channel
	var/last_ch = charging

	var/obj/machinery/power/terminal/terminal = refresh_external_cache()
	var/avail = cached_external_avail
	var/excess = cached_external_surplus

	var/old_main_status = main_status
	if(!avail)
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2
	if(old_main_status != main_status)
		mark_cache_dirty(APC_CACHE_UI_DIRTY)

	var/obj/item/cell/cell = get_cell()
	if(!cell || shorted) // We aren't going to be doing any power processing in this case.
		charging = 0
	else
		..() // Actual processing happens in here.

		if(debug)
			log_debug("Status: [main_status] - Excess: [excess] - Last Equip: [last_used_equipment] - Last Light: [last_used_lighting] - Longterm: [longtermpower]")

		//update state
		var/obj/item/stock_parts/power/battery/power = get_component_of_type(/obj/item/stock_parts/power/battery)
		last_used_charging = max(power && power.cell && (power.cell.charge - power.last_cell_charge) * CELLRATE, 0)
		charging = last_used_charging ? 1 : 0
		if(cell.fully_charged())
			charging = 2

		if(!is_powered())
			power_change() // We are the ones responsible for triggering listeners once power returns, so we run this to detect possible changes.

	// Set channels depending on how much charge we have left
	var/channels_changed = update_channels()

	// update icon & area power if anything changed
	if(channels_changed || last_lt != lighting_channel || last_eq != equipment_channel || last_en != environment_channel || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if(last_ch != charging || (cache_flags & APC_CACHE_UI_DIRTY))
		queue_icon_update()
	cache_flags &= ~APC_CACHE_UI_DIRTY

/obj/machinery/power/apc/proc/update_channels(suppress_alarms = FALSE)
	return handle_autoflag(suppress_alarms)

/obj/machinery/power/apc/proc/handle_autoflag(suppress_alarms = FALSE)
	// Allow the APC to operate as normal if the cell can charge
	if(charging && longtermpower < 10)
		longtermpower += 1
	else if(longtermpower > -10)
		longtermpower -= 2
	var/obj/item/cell/cell = get_cell()
	var/percent = cell && cell.percent()
	var/new_regime = get_cached_power_regime(percent)
	if(!(cache_flags & APC_CACHE_AUTOMATION_DIRTY) && cached_power_regime == new_regime)
		autoflag = new_regime
		return FALSE

	var/old_eq = equipment_channel
	var/old_lt = lighting_channel
	var/old_en = environment_channel

	switch(new_regime)
		if(APC_POWER_REGIME_NONE)
			equipment_channel = autoset(equipment_channel, 0)
			lighting_channel = autoset(lighting_channel, 0)
			environment_channel = autoset(environment_channel, 0)
			if(!suppress_alarms)
				GLOB.power_alarm.triggerAlarm(loc, src)
		if(APC_POWER_REGIME_ALL_ON)
			equipment_channel = autoset(equipment_channel, 1)
			lighting_channel = autoset(lighting_channel, 1)
			environment_channel = autoset(environment_channel, 1)
			GLOB.power_alarm.clearAlarm(loc, src)
		if(APC_POWER_REGIME_EQUIPMENT_ONLY)
			equipment_channel = autoset(equipment_channel, 1)
			lighting_channel = autoset(lighting_channel, 2)
			environment_channel = autoset(environment_channel, 1)
			if(!suppress_alarms)
				GLOB.power_alarm.triggerAlarm(loc, src)
		if(APC_POWER_REGIME_ENVIRONMENT_ONLY)
			equipment_channel = autoset(equipment_channel, 2)
			lighting_channel = autoset(lighting_channel, 2)
			environment_channel = autoset(environment_channel, 1)
			if(!suppress_alarms)
				GLOB.power_alarm.triggerAlarm(loc, src)

	autoflag = new_regime
	cached_power_regime = new_regime
	cache_flags &= ~APC_CACHE_AUTOMATION_DIRTY

	if(old_eq != equipment_channel || old_lt != lighting_channel || old_en != environment_channel)
		mark_cache_dirty(APC_CACHE_LOAD_DIRTY | APC_CACHE_UI_DIRTY)
		return TRUE
	return FALSE

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff
// defines a state machine, returns the new state
/obj/machinery/power/apc/proc/autoset(cur_state, on)
	//autoset will never turn on a channel set to off
	switch(cur_state)
		if(POWERCHAN_OFF_TEMP)
			if(on == 1 || on == 2)
				return POWERCHAN_ON
		if(POWERCHAN_OFF_AUTO)
			if(on == 1)
				return POWERCHAN_ON_AUTO
		if(POWERCHAN_ON)
			if(on == 0)
				return POWERCHAN_OFF_TEMP
		if(POWERCHAN_ON_AUTO)
			if(on == 0 || on == 2)
				return POWERCHAN_OFF_AUTO

	return cur_state //leave unchanged


// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	if(emp_hardened)
		return
	..()

/obj/machinery/power/apc/ex_act(severity)
	var/obj/item/cell/cell = get_cell()
	if (!cell)
		..()
		return

	switch(severity)
		if (EX_ACT_DEVASTATING)
			cell.ex_act(EX_ACT_DEVASTATING)
		if (EX_ACT_HEAVY)
			if (prob(50))
				cell.ex_act(EX_ACT_HEAVY)
		if (EX_ACT_LIGHT)
			if (prob(25))
				cell.ex_act(EX_ACT_LIGHT)
	..()

/obj/machinery/power/apc/set_broken(new_state)
	if(!new_state || MACHINE_IS_BROKEN(src))
		return ..()
	visible_message(SPAN_WARNING("\The [src]'s screen flickers with warnings briefly!"))
	GLOB.power_alarm.triggerAlarm(loc, src)
	spawn(rand(2,5))
		..()
		visible_message(SPAN_DANGER("\The [src]'s screen suddenly explodes in rain of sparks and small debris!"))
		operating = 0
		update()
	queue_icon_update()
	return TRUE

/obj/machinery/power/apc/proc/reboot()
	//reset various counters so that process() will start fresh
	charging = initial(charging)
	autoflag = initial(autoflag)
	longtermpower = initial(longtermpower)
	failure_timer = initial(failure_timer)

	//start with main breaker off, chargemode in the default state and all channels on auto upon reboot
	operating = 0

	set_chargemode(initial(chargemode))
	GLOB.power_alarm.clearAlarm(loc, src)

	lighting_channel = POWERCHAN_ON_AUTO
	equipment_channel = POWERCHAN_ON_AUTO
	environment_channel = POWERCHAN_ON_AUTO
	mark_cache_dirty()

	force_update_channels()

/obj/machinery/power/apc/proc/set_chargemode(new_mode)
	chargemode = new_mode
	mark_cache_dirty(APC_CACHE_AUTOMATION_DIRTY | APC_CACHE_UI_DIRTY)
	var/obj/item/stock_parts/power/battery/power = get_component_of_type(/obj/item/stock_parts/power/battery)
	if(power)
		power.can_charge = chargemode
		power.charge_wait_counter = initial(power.charge_wait_counter)

// overload the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting(chance = 100)
	if(/* !get_connection() || */ !operating || shorted)
		return
	var/amount = use_power_oneoff(20, LOCAL)
	if(amount <= 0)
		spawn(0)
			for(var/obj/machinery/light/L in apc_area)
				if(prob(chance))
					L.on = 1
					L.broken()
				sleep(1)


/obj/machinery/power/apc/proc/flicker_lighting(amount = 10)
	if (!operating || shorted)
		return
	for (var/obj/machinery/light/L in apc_area)
		L.flicker(amount)


/obj/machinery/power/apc/proc/setsubsystem(val)
	switch(val)
		if(2)
			return POWERCHAN_OFF_AUTO
		if(1)
			return POWERCHAN_OFF_TEMP
		else
			return POWERCHAN_OFF

#undef APC_POWER_REGIME_ALL_ON
#undef APC_POWER_REGIME_EQUIPMENT_ONLY
#undef APC_POWER_REGIME_ENVIRONMENT_ONLY
#undef APC_POWER_REGIME_NONE
#undef APC_CACHE_ALL_DIRTY
#undef APC_CACHE_UI_DIRTY
#undef APC_CACHE_AUTOMATION_DIRTY
#undef APC_CACHE_EXTERNAL_DIRTY
#undef APC_CACHE_LOAD_DIRTY

/obj/item/module/power_control
	name = "power control module"
	desc = "Heavy-duty switching circuits for power control."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	item_state = "electronic"
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE

