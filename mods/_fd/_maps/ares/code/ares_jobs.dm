#define WEBHOOK_SUBMAP_LOADED_ARES "webhook_submap_ares"

// Submap datum and archetype.
/singleton/webhook/submap_loaded/ares
	id = WEBHOOK_SUBMAP_LOADED_ARES

/singleton/submap_archetype/ares
	descriptor = "Company Mining Ship"
	map = "Ares"
	crew_jobs = list(/datum/job/submap/ares, /datum/job/submap/ares_cyborg)
	call_webhook = WEBHOOK_SUBMAP_LOADED_ARES

/singleton/hierarchy/outfit/job/cargo/mining/ares
	uniform = /obj/item/clothing/under/grayson
	pda_type = null
	l_ear = null
	id_types = list(/obj/item/card/id/ares)

/datum/job/submap/ares
	title = "Prospecting Specialist"
	total_positions = 6
	supervisors = "Grayson Manufactories mission control"
	info = "ROCK AND STONE BROTHA!"
	outfit_type = /singleton/hierarchy/outfit/job/cargo/mining/ares
	loadout_allowed = TRUE
	skill_points = 20
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_DEVICES = SKILL_BASIC,
		SKILL_MEDICAL = SKILL_BASIC
	)

/datum/job/submap/ares_cyborg
	title = "Corporate Bot"
	total_positions = 1
	supervisors = "your laws and corporate miners"
	minimal_player_age = 7
	account_allowed = 0
	economic_power = 0
	loadout_allowed = FALSE
	outfit_type = /singleton/hierarchy/outfit/job/silicon/cyborg
	hud_icon = "hudblank"
	skill_points = 0

/datum/job/submap/ares_cyborg/handle_variant_join(mob/living/carbon/human/H, alt_title)
	return H && H.Robotize(/mob/living/silicon/robot/flying/mining)

/datum/job/submap/ares_cyborg/equip(mob/living/carbon/human/H)
	return !!H

/datum/job/submap/ares_cyborg/New(datum/submap/_owner, abstract_job = FALSE)
	..()
	alt_titles = SSrobots.robot_alt_titles.Copy()
	alt_titles -= title // So the unit test doesn't flip out if a mob or mmi type is declared for our main title.

/mob/living/silicon/robot/flying/mining
	lawupdate =      FALSE
	icon_state = "drone-service"
	laws =   /datum/ai_laws/nanotrasen
	idcard = /obj/item/card/id/ares
	module = /obj/item/robot_module/flying/mining
	req_access = list(access_ares)

/mob/living/silicon/robot/flying/mining/add_ion_law(law)
	return FALSE

/obj/item/robot_module/flying/mining
	name = "\improper Mining drone module"
	hide_on_manifest = TRUE
	sprites = list(
		"Drone" = "drone-service"
	)
	equipment = list(
		/obj/item/device/flash,
		/obj/item/material/kitchen/rollingpin,
		/obj/item/material/knife/kitchen,
		/obj/item/rsf,
		/obj/item/reagent_containers/dropper/industrial,
		/obj/item/flame/lighter/zippo,
		/obj/item/tray/robotray,
		/obj/item/reagent_containers/borghypo/service,
		/obj/item/borg/sight/meson,
		/obj/item/storage/ore,
		/obj/item/pickaxe/borgdrill,
		/obj/item/extinguisher,
		/obj/item/device/t_scanner,
		/obj/item/device/scanner/mining,
		/obj/item/device/scanner/gas,
		/obj/item/device/scanner/health,
		/obj/item/device/radio/hailing/borg,
		/obj/item/weldingtool/hugetank,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/crowbar,
		/obj/item/wirecutters,
		/obj/item/device/lightreplacer,
		/obj/item/inflatable_dispenser/robot,
		/obj/item/device/multitool,
		/obj/item/device/geiger,
		/obj/item/storage/sheetsnatcher/borg,
		/obj/item/matter_decompiler,
		/obj/item/gripper/no_use/loader,
		/obj/item/gripper/service,
		/obj/item/gripper/miner,
		/obj/item/inducer/borg,
		/obj/item/stack/material/cyborg/steel,
		/obj/item/stack/material/cyborg/aluminium,
		/obj/item/stack/material/rods/cyborg,
		/obj/item/stack/tile/floor/cyborg,
		/obj/item/stack/material/cyborg/glass,
		/obj/item/stack/material/cyborg/glass/reinforced,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/material/cyborg/plasteel
	)
	synths = list(
		/datum/matter_synth/metal =    60000,
		/datum/matter_synth/glass =    40000,
		/datum/matter_synth/plasteel = 20000,
		/datum/matter_synth/wire =     50
	)

	skills = list(
		SKILL_PILOT         = SKILL_EXPERIENCED,
		SKILL_EVA           = SKILL_MASTER,
		SKILL_ATMOS         = SKILL_MASTER,
		SKILL_CONSTRUCTION  = SKILL_EXPERIENCED,
		SKILL_ELECTRICAL    = SKILL_EXPERIENCED,
		SKILL_COMPUTER      = SKILL_EXPERIENCED,
		SKILL_COOKING		= SKILL_MASTER,
		SKILL_CHEMISTRY		= SKILL_EXPERIENCED
	)

/obj/item/robot_module/flying/mining/finalize_synths()
	. = ..()
	var/datum/matter_synth/metal/metal =       locate() in synths
	var/datum/matter_synth/glass/glass =       locate() in synths
	var/datum/matter_synth/plasteel/plasteel = locate() in synths
	var/datum/matter_synth/wire/wire =         locate() in synths

	for(var/thing in list(
		 /obj/item/stack/material/cyborg/steel,
		 /obj/item/stack/material/cyborg/aluminium,
		 /obj/item/stack/material/rods/cyborg,
		 /obj/item/stack/tile/floor/cyborg,
		 /obj/item/stack/material/cyborg/glass/reinforced
		))
		var/obj/item/stack/stack = locate(thing) in equipment
		LAZYDISTINCTADD(stack.synths, metal)

	for(var/thing in list(
		 /obj/item/stack/material/cyborg/glass/reinforced,
		 /obj/item/stack/material/cyborg/glass
		))
		var/obj/item/stack/stack = locate(thing) in equipment
		LAZYDISTINCTADD(stack.synths, glass)

	var/obj/item/stack/cable_coil/cyborg/C = locate() in equipment
	C.synths = list(wire)

	var/obj/item/stack/material/cyborg/plasteel/PL = locate() in equipment
	PL.synths = list(plasteel)

	. = ..()

/obj/item/device/radio/hailing/borg
	power_usage = 0


/obj/submap_landmark/spawnpoint/ares
	name = "Prospecting Specialist"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/ares/cyborg
	name = "Corporate Bot"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/var/const/access_ares = "ACCESS_ARES"
/datum/access/ares
	id = access_ares
	desc = "GMLtd. Miner"
	region = ACCESS_REGION_NONE

/obj/item/card/id/ares
	access = list(access_ares)

#undef WEBHOOK_SUBMAP_LOADED_ARES
