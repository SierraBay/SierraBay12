// Contains experiment data tracking and science scan handling
// server list moved into research subsystem

/datum/experiment_data
	var/list/saved_tech_levels = list() // list("materials" = list(1, 4, ...), ...)

/datum/experiment_data/proc/init_known_tech()
	return

/datum/experiment_data/proc/do_research_object(obj/item/I)
	var/list/temp_tech = I.origin_tech

	for(var/T in temp_tech)
		if(!saved_tech_levels[T])
			saved_tech_levels[T] = list()

		if(!(temp_tech[T] in saved_tech_levels[T]))
			saved_tech_levels[T] += temp_tech[T]

/datum/experiment_data/proc/merge_with(datum/experiment_data/O)
	for(var/tech in O.saved_tech_levels)
		if(!saved_tech_levels[tech])
			saved_tech_levels[tech] = list()

		saved_tech_levels[tech] |= O.saved_tech_levels[tech]


// Tracks nearby explosions for informational purposes
/obj/item/device/beacon/explosion_watcher
	name = "Kinetic Energy Scanner"
	desc = "Scans the level of kinetic energy from explosions"
	var/last_power = 0
	icon = 'icons/obj/beacon.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/obj/item/device/beacon/explosion_watcher/ex_act(severity)
	return

/obj/item/device/beacon/explosion_watcher/afterattack(obj/machinery/computer/rdconsole/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/machinery/computer/rdconsole))
		if(last_power > 0)
			to_chat(user, "<span class='notice'>[src.name] last recorded power level: [last_power]</span>")
		else
			to_chat(user, "<span class='notice'>[src.name] has no recorded data</span>")

/obj/item/device/beacon/explosion_watcher/Initialize()
	. = ..()
	explosion_watcher_list += src

/obj/item/device/beacon/explosion_watcher/Destroy()
	explosion_watcher_list -= src
	return ..()

/obj/item/device/beacon/explosion_watcher/proc/react_explosion(turf/epicenter, power)
	last_power = round(power)


// Universal tool to collect science data from reports and samples

/obj/item/paper/anomaly_scan
	var/artifact
	var/my_effect
	var/secondary_effect

/obj/item/paper/plant_report
	var/potency

/obj/item/paper/plant_report/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(istype(tool,/obj/item/pen))
		return
	return ..()


/obj/item/paper/radiocarbon_spectrometer_report

/obj/item/paper/xenofauna_report

/obj/item/device/science_tool
	name = "science tool"
	icon = 'mods/RnD/icons/device.dmi'
	icon_state = "science"
	item_state = "sciencetool"
	item_icons = list(
		slot_r_hand_str = 'mods/RnD/icons/mob/righthand.dmi',
		slot_l_hand_str = 'mods/RnD/icons/mob/lefthand.dmi',
		)
	desc = "A hand-held device capable of extracting usefull data from various sources, such as paper reports and slime cores."
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = list(TECH_ENGINEERING = 1, TECH_DATA = 1)

/obj/item/device/science_tool/afterattack(obj/O, mob/living/user)
	return ..()

/datum/design/science_tool
	shortname = "Science Tool"
	desc = "A hand-held device capable of extracting usefull data from various sources, such as paper reports and slime cores."
	id = "science_tool"
	build_type = PROTOLATHE
	materials = list(MATERIAL_STEEL = 1000)
	build_path = /obj/item/device/science_tool
	category = list("Misc")
