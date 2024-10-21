// Contains everything related to earning research points
var/global/list/rnd_server_list = list()

/datum/experiment_data
	var/saved_best_explosion = 0

	var/list/tech_points = list(
		TECH_MATERIAL = 200,
		TECH_ENGINEERING = 250,
		TECH_PHORON = 600,
		TECH_POWER = 300,
		TECH_BLUESPACE = 700,
		TECH_BIO = 300,
		TECH_COMBAT = 500,
		TECH_MAGNET = 350,
		TECH_DATA = 400,
		TECH_ESOTERIC = 1000,
	)

	var/list/tech_points_rarity = list(
		TECH_BLUESPACE = 3,
		TECH_PHORON = 3,
		TECH_MAGNET = 2,
		TECH_COMBAT = 2,
		TECH_ENGINEERING = 1,
		TECH_POWER = 1,
		TECH_DATA = 1,
		TECH_MATERIAL = 0,
		TECH_BIO = 1,
	)
	// So we don't give points for researching non-artifact item
	var/list/artifact_types = list(
		/obj/machinery/auto_cloner,
		/obj/machinery/power/supermatter,
		/obj/structure/constructshell,
		/obj/machinery/giga_drill,
		/obj/structure/cult/pylon,
		/obj/machinery/replicator,
		/obj/machinery/artifact
	)

	var/list/saved_tech_levels = list() // list("materials" = list(1, 4, ...), ...)
	var/list/saved_autopsy_weapons = list()
	var/list/saved_artifacts = list()
	var/list/saved_small_artefacts = list()
	var/list/saved_urm_interactions = list()
	var/list/saved_plants = list()
	var/list/saved_slimecores = list()
	var/list/saved_spectrometers = list()
	var/list/saved_xenofauna = list()

/datum/experiment_data/proc/init_known_tech()
	for(var/tech in tech_points_rarity)
		var/cap_at = rand(0, 4) - tech_points_rarity[tech]
		if(cap_at > 0)
			if(!saved_tech_levels[tech])
				saved_tech_levels[tech] = list()

			for(var/i in 1 to cap_at)
				saved_tech_levels[tech] |= i
/*
/datum/experiment_data/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list
*/
/datum/experiment_data/proc/get_object_research_value(obj/item/I, ignoreRepeat = FALSE)
	var/list/temp_tech = I.origin_tech
	var/item_tech_points = 0
	var/has_new_tech = FALSE
	var/is_board = istype(I, /obj/item/stock_parts/circuitboard)

	for(var/T in temp_tech)
		if(tech_points[T])
			if(ignoreRepeat)
				item_tech_points += temp_tech[T] * tech_points[T]
			else
				if(saved_tech_levels[T] && (temp_tech[T] in saved_tech_levels[T])) // You only get a fraction of points if you researched items with this level already
					if(!is_board) // Boards are cheap to make so we don't give any points for repeats
						item_tech_points += temp_tech[T] * tech_points[T] * 0.1
				else
					item_tech_points += temp_tech[T] * tech_points[T]
					has_new_tech = TRUE

	if(!ignoreRepeat && !has_new_tech) // We are deconstucting the same items, cut the reward really hard
		item_tech_points = min(item_tech_points, 400)

	return round(item_tech_points)

/datum/experiment_data/proc/do_research_object(obj/item/I)
	var/list/temp_tech = I.origin_tech

	for(var/T in temp_tech)
		if(!saved_tech_levels[T])
			saved_tech_levels[T] = list()

		if(!(temp_tech[T] in saved_tech_levels[T]))
			saved_tech_levels[T] += temp_tech[T]

// Returns ammount of research points received
/datum/experiment_data/proc/read_science_tool(obj/item/device/science_tool/I)
	var/points = 0

	for(var/weapon in I.scanned_autopsy_weapons)
		if(weapon in saved_autopsy_weapons)
			continue
		else
			// These give more points because they are rare or special
			var/list/special_weapons = list(
				"large organic needle" = 10000,
				"fire" = 2000,
				"Explosive blast" = 5000,
				"Hot metal" = 4000,
				"Low Pressure" = 3000,
				"Live animal escaping the body" = 5000,
				"Amaspore Growth" = 5000,
				"Agonizing pain" = 2000
				)
			if(special_weapons[weapon])
				points += special_weapons[weapon]
			else
				points += rand(5,10) * 200 // 1000-2000 points for random weapon

			saved_autopsy_weapons += weapon

	for(var/list/artifact in I.scanned_artifacts)
		var/already_scanned = FALSE
		for(var/list/our_artifact in saved_artifacts)
			if(our_artifact["type"] == artifact["type"] && our_artifact["my_effect"] == artifact["my_effect"] && our_artifact["secondary_effect"] == artifact["secondary_effect"])
				already_scanned = TRUE
				break

		if(!already_scanned)
			points += rand(5,15) * 1000 // 5000-15000 points for random artifact
			saved_artifacts += list(artifact)

	for(var/effect in I.scanned_plants)
		var/list/effects = list(
			"It is well adapted to low pressure levels." = 1500,
			"It is well adapted to high pressure levels." = 1500,
			"It is well adapted to a range of temperatures." = 1500,
			"It is very sensitive to temperature shifts." = 1500,
			"It is well adapted to a range of light levels." = 1500,
			"It is very sensitive to light level shifts." = 1500,
			"It is highly sensitive to toxins." = 1000,
			"It is remarkably resistant to toxins." = 1000,
			"It is highly sensitive to pests." = 1000,
			"It is remarkably resistant to pests." = 1000,
			"It is highly sensitive to weeds." = 1000,
			"It is remarkably resistant to weeds." = 1000,
			"It is able to be planted outside of a tray." = 1000,
			"It is a robust and vigorous vine that will spread rapidly." = 2000,
			"It is carnivorous and will eat tray pests for sustenance." = 1000,
			"It is carnivorous and poses a significant threat to living things around it." = 2000,
			"It is capable of parisitizing and gaining sustenance from tray weeds." = 1000,
			"It will periodically alter the local temperature by " = 2000,
			"bio-luminescent" = 2000,
			"The fruit will function as a battery if prepared appropriately." = 2000,
			"The fruit is covered in stinging spines." = 2000,
			"The fruit is soft-skinned and juicy." = 1000,
			"The fruit is excessively juicy." = 2000,
			"The fruit is internally unstable."	= 3000,
			"The fruit is temporal/spatially unstable." = 3000,
			"It will release gas into the environment." = 3000,
			"It will remove gas from the environment." = 3000
	)
		for(var/l in effects)
			if(findtext(effect, l))
				if(!(l in saved_plants))
					points += effects[l]
					saved_plants += l
		points = I.potency/20 * points

	for(var/s in I.scanned_spectrometers)
		if(s in saved_spectrometers)
			continue
		var/reward = rand(1000, 3000)
		points += reward
		saved_spectrometers += s

	for(var/x in I.scanned_xenofauna)
		if(x in saved_xenofauna)
			continue
		var/reward = 100
		var/species = I.species
		if(species in typesof(/mob/living/simple_animal/hostile/hivebot,/mob/living/simple_animal/hostile/giant_spider,/mob/living/simple_animal/hostile/vagrant))
			reward = rand(500, 1500)
		if(species in typesof(/mob/living/simple_animal/hostile/retaliate/space_whale, /mob/living/simple_animal/hostile/retaliate/parrot, /mob/living/simple_animal/hostile/meat))
			reward = rand(1000, 2000)
		if(species in typesof(/mob/living/simple_animal/hostile/carp/shark,/mob/living/simple_animal/hostile/carp/pike))
			reward = rand(500, 1000)
		if(species in typesof(/mob/living/simple_animal/hostile/leech, /mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/creature, /mob/living/simple_animal/hostile/voxslug))
			reward = rand(100, 600)
		if(species in typesof(/mob/living/simple_animal/hostile/faithless,/mob/living/simple_animal/hostile/creature))
			reward = rand(700, 1200)
		if(species in typesof(/mob/living/simple_animal/hostile/drake))
			reward = rand(3000, 4000)
		if(species in typesof(/mob/living/simple_animal/hostile/bluespace, /mob/living/simple_animal/shade, /mob/living/simple_animal/construct))
			reward = rand(2000, 3000)
		if(species in typesof(/mob/living/simple_animal/passive))
			reward = rand(100, 300)
		if(species in typesof(/mob/living/simple_animal/borer))
			reward = rand(1000, 1500)

		if(species in typesof(/mob/living/simple_animal/hostile/meatstation))
			reward = rand(1000, 2000)

		if(I.new_species)
			reward += rand(1000, 3000)
		points += reward
		saved_xenofauna += x

	for(var/core in I.scanned_slimecores)
		if(core in saved_slimecores)
			continue

		var/reward = 1000
		switch(core)
			if(/obj/item/slime_extract/grey)
				reward = 100
			if(/obj/item/slime_extract/metal)
				reward = 500
			if(/obj/item/slime_extract/gold)
				reward = 2000
			if(/obj/item/slime_extract/adamantine)
				reward = 3000
			if(/obj/item/slime_extract/oil)
				reward = 3000
			if(/obj/item/slime_extract/pink)
				reward = 2500
			if(/obj/item/slime_extract/red)
				reward = 2500
			if(/obj/item/slime_extract/yellow)
				reward = 3000
			if(/obj/item/slime_extract/sepia)
				reward = 3000
			if(/obj/item/slime_extract/bluespace)
				reward = 4000
			if(/obj/item/slime_extract/cerulean)
				reward = 3000
			if(/obj/item/slime_extract/pyrite)
				reward = 3000
			if(/obj/item/slime_extract/rainbow)
				reward = 10000
			else if(parent_type == /obj/item/slime_extract)
				reward = 1000
		points += reward
		saved_slimecores += core

	for(var/obj/item/artefact/artefacts in I.scanned_small_artefacts)
		if(artefacts in saved_small_artefacts)
			continue
		var/reward = 1000
		reward = artefacts.rnd_points
		points += reward
		saved_small_artefacts += artefacts
	for(var/obj/item/small_artefact_scan_disk/input_disk in I.scanned_urm_interactions)
		if(input_disk.interaction_id in saved_urm_interactions)
			continue
		var/reward = input_disk.rnd_points_reward
		points += reward
		saved_urm_interactions += input_disk.interaction_id


	I.clear_data()
	return round(points)

/datum/experiment_data/proc/merge_with(datum/experiment_data/O)
	for(var/tech in O.saved_tech_levels)
		if(!saved_tech_levels[tech])
			saved_tech_levels[tech] = list()

		saved_tech_levels[tech] |= O.saved_tech_levels[tech]

	for(var/weapon in O.saved_autopsy_weapons)
		saved_autopsy_weapons |= weapon

	for(var/list/artifact in O.saved_artifacts)
		var/has_artifact = FALSE
		for(var/list/our_artifact in saved_artifacts)
			if(our_artifact["type"] == artifact["type"] && our_artifact["my_effect"] == artifact["my_effect"] && our_artifact["secondary_effect"] == artifact["secondary_effect"])
				has_artifact = TRUE
				break
		if(!has_artifact)
			saved_artifacts += list(artifact)


	for(var/core in O.saved_slimecores)
		saved_slimecores |= core

	saved_best_explosion = max(saved_best_explosion, O.saved_best_explosion)


// Grants research points when explosion happens nearby
/obj/item/device/beacon/explosion_watcher
	name = "Kinetic Energy Scanner"
	desc = "Scans the level of kinetic energy from explosions"
	var/saved_power_level
	var/added_power
	var/already_earned_power
	var/calculated_research_points = 0
	icon = 'icons/obj/beacon.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/obj/item/device/beacon/explosion_watcher/ex_act(severity)
	return

/obj/item/device/beacon/explosion_watcher/afterattack(obj/machinery/computer/rdconsole/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/machinery/computer/rdconsole))
		if(src.calculated_research_points > 0)
			target.files.research_points += src.calculated_research_points
			to_chat(user, "<span class='notice'>You uploaded to [target.name] [src.calculated_research_points] research points</span>")
			src.calculated_research_points = 0
		else
			to_chat(user, "<span class='notice'>[src.name] has no research value</span>")

/obj/item/device/beacon/explosion_watcher/Initialize()
	. = ..()
	explosion_watcher_list += src

/obj/item/device/beacon/explosion_watcher/Destroy()
	explosion_watcher_list -= src
	return ..()

/obj/item/device/beacon/explosion_watcher/proc/react_explosion(turf/epicenter, power)
	var/atmosmod = 1
	var/atmos = src.return_air()
	power = round(power)
	for(var/obj/machinery/computer/rdconsole/RD as anything in global.RDcomputer_list)
		saved_power_level = RD.files.experiments.saved_best_explosion
		if(power > saved_power_level)
			RD.files.experiments.saved_best_explosion = power
	added_power = max(0, power - saved_power_level)
	already_earned_power = min(saved_power_level, power)
	if(!atmos)
		atmosmod = 1.5
	calculated_research_points += (added_power * 1000 + already_earned_power * 200) / atmosmod


	/*if(calculated_research_points > 0)
		autosay("Detected explosion with power level [power], received [calculated_research_points] research points", name ,"Science", freq = radiochannels["Science"])
	else
		autosay("Detected explosion with power level [power], R&D console is missing or broken", name ,"Science", freq = radiochannels["Science"])
*/
// Universal tool to get research points from autopsy reports, virus info reports, archeology reports, slime cores

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

	var/datum/experiment_data/experiments
	var/list/scanned_autopsy_weapons = list()
	var/list/scanned_artifacts = list()
	var/list/scanned_plants = list()
	var/list/scanned_slimecores = list()
	var/list/scanned_spectrometers = list()
	var/list/scanned_xenofauna = list()
	var/list/scanned_small_artefacts = list()
	var/list/scanned_urm_interactions = list()
	var/species
	var/new_species = FALSE
	var/potency
	var/datablocks = 0

/obj/item/device/science_tool/Initialize()
	. = ..()
	experiments = new

/obj/item/device/science_tool/afterattack(obj/O, mob/living/user)
	var/scanneddata = 0

	if(istype(O, /obj/item/disk/secret_project))
		var/obj/item/disk/secret_project/disk = O
		to_chat(user, "<span class='notice'>[disk] stores approximately [disk.stored_points] research points</span>")
		return

	else if(istype(O,/obj/item/paper/autopsy_report))
		var/obj/item/paper/autopsy_report/report = O
		for(var/datum/autopsy_data/W in report.autopsy_data)
			if(!(W.weapon in scanned_autopsy_weapons))
				scanneddata += 1
				scanned_autopsy_weapons += W.weapon

	else if(istype(O,/obj/item/paper/plant_report))
		var/obj/item/paper/plant_report/report = O
		if(!(report.info in scanned_plants))
			scanneddata += 1
			scanned_plants += report.info
			potency = report.potency
		else
			to_chat(user, "<span class='notice'>[src] already has data about this report</span>")
			return


	else if(istype(O,/obj/item/paper/radiocarbon_spectrometer_report))
		var/obj/item/paper/radiocarbon_spectrometer_report/report = O
		if(!(report in scanned_spectrometers))
			if(report.anomalous)
				scanneddata += 1
				scanned_spectrometers += report
		else
			to_chat(user, "<span class='notice'>[src] already has data about this report</span>")
			return

	else if(istype(O,/obj/item/paper/xenofauna_report))
		var/obj/item/paper/xenofauna_report/report = O
		if(!(report in scanned_xenofauna))
			if(report.species)
				scanneddata += 1
				species = report.species
				if(report.new_species)
					scanneddata += 1
					new_species = report.new_species
			scanned_xenofauna += report
		else
			to_chat(user, "<span class='notice'>[src] already has data about this report</span>")
			return


	else if(istype(O, /obj/item/paper/anomaly_scan))
		var/obj/item/paper/anomaly_scan/report = O
		if(report.artifact)
			for(var/list/artifact in scanned_artifacts)
				if(artifact["type"] == report.artifact && artifact["my_effect"] == report.my_effect && artifact["secondary_effect"] == report.secondary_effect)
					to_chat(user, "<span class='notice'>[src] already has data about this artifact report</span>")
					return

			scanned_artifacts += list(list(
				"type" = report.artifact,
				"my_effect" = report.my_effect,
				"secondary_effect" = report.secondary_effect,
			))
			scanneddata += 1


	else if(istype(O, /obj/item/slime_extract))
		if(!(O.type in scanned_slimecores))
			scanned_slimecores += O.type
			scanneddata += 1
		else
			to_chat(user, "<span class='notice'>[src] already has data about this report</span>")
			return

	if(scanneddata > 0)
		datablocks += scanneddata
		to_chat(user, "<span class='notice'>[src] received [scanneddata] data block[scanneddata>1?"s":""] from scanning [O]</span>")
		return

	else if(istype(O, /obj/item/device/beacon/explosion_watcher))
		var/obj/item/device/beacon/explosion_watcher/explosion = O
		if(explosion.calculated_research_points > 0)
			to_chat(user, "<span class='notice'>Estimated research value of [O.name] is [explosion.calculated_research_points]</span>")
		else
			to_chat(user, "<span class='notice'>[O] has no research value</span>")
		return

	else if(istype(O, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/T = O
		if(T.stored)
			var/science_value = T.stored.level * 1000
			if(science_value > 0)
				to_chat(user, "<span class='notice'>[T] has aproximately [science_value] research points</span>")
		else
			to_chat(user, "<span class='notice'>[O] has no research value</span>")

	else if(istype(O, /obj/item/artefact))
		if(!(O.type in scanned_small_artefacts))
			var/obj/item/artefact/art = O
			scanned_small_artefacts += art.type
			scanneddata += 1
		else
			to_chat(user, "<span class='notice'>[src] already has data about this report</span>")

	else if(istype(O, /obj/item/small_artefact_scan_disk))
		var/obj/item/small_artefact_scan_disk/disk = O
		if(!(disk in scanned_urm_interactions))
			to_chat(user, "<span class='notice'> Collected usefull data from URM disk.</span>")
			scanned_urm_interactions += disk
			scanneddata += 1
		else
			to_chat(user, "<span class='notice'>[O] has no new usefull data</span>")

	else if(istype(O, /obj/item))
		var/science_value = experiments.get_object_research_value(O)
		if(science_value > 0)
			to_chat(user, "<span class='notice'>Estimated research value of [O.name] is [science_value]</span>")
		else
			to_chat(user, "<span class='notice'>[O] has no research value</span>")

/obj/item/device/science_tool/proc/clear_data()
	scanned_autopsy_weapons = list()
	scanned_artifacts = list()
	scanned_plants = list()
	scanned_xenofauna = list()
	scanned_spectrometers = list()
	scanned_slimecores = list()
	datablocks = 0

/obj/item/disk/secret_project
	var/stored_points

/obj/item/disk/secret_project/Initialize()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

	stored_points = rand(1,10)*1000

/obj/item/disk/secret_project/rare/Initialize()
	. = ..()

	stored_points = rand(10, 20)*1000


/datum/design/science_tool
	shortname = "Science Tool"
	desc = "A hand-held device capable of extracting usefull data from various sources, such as paper reports and slime cores."
	id = "science_tool"
	build_type = PROTOLATHE
	materials = list(MATERIAL_STEEL = 1000)
	build_path = /obj/item/device/science_tool
	category = list("Misc")
