#define WEBHOOK_SUBMAP_LOADED_SMUGGLER "webhook_submap_smuggler"

// Submap datum and archetype.
/singleton/webhook/submap_loaded/smuggler
	id = WEBHOOK_SUBMAP_LOADED_SMUGGLER

/singleton/submap_archetype/smuggler
	descriptor = "Suspicious Transport Ship"
	map = "Smuggler"
	crew_jobs = list(/datum/job/submap/smuggler)
	call_webhook = WEBHOOK_SUBMAP_LOADED_SMUGGLER

/datum/job/submap/smuggler
	title = "Smuggler"
	total_positions = 5
	supervisors = "nobody but yourself"
	info = "You are the crewman of your small Smuggler's vessel. Keep an eye on your cargo, and avoid other ships. Pursue your goals, trade, smuggle; try not to get caught."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN,SPECIES_RESOMI)
	is_semi_antagonist = TRUE
	outfit_type = /singleton/hierarchy/outfit/job/smuggler
	loadout_allowed = TRUE
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_HAULING = SKILL_BASIC,
		SKILL_COMBAT = SKILL_BASIC,
		SKILL_WEAPONS = SKILL_BASIC,
		SKILL_PILOT = SKILL_BASIC
	)

/singleton/hierarchy/outfit/job/smuggler
	name = "Smuggler Crewman"
	uniform = /obj/item/clothing/under/color/black
	l_ear = null
	l_pocket = /obj/item/device/flashlight/maglight
	shoes = /obj/item/clothing/shoes/black
	pda_type = /obj/item/modular_computer/pda
	belt = /obj/item/gun/energy/gun/small

/obj/submap_landmark/spawnpoint/smuggler
	name = "Smuggler"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

#undef WEBHOOK_SUBMAP_LOADED_SMUGGLER
