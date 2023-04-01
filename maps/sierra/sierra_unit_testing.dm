/datum/map/sierra
	// Unit test exemptions
	apc_test_exempt_areas = list(
		/area/space = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/exoplanet = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/engineering/auxpower = NO_SCRUBBER|NO_VENT,
		/area/engineering/drone_fabrication = NO_SCRUBBER|NO_VENT,
		/area/engineering/engine_smes = NO_SCRUBBER|NO_VENT,
		/area/holodeck = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/maintenance = NO_SCRUBBER|NO_VENT,
		/area/maintenance/exterior = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/maintenance/compactor = 0,
		/area/turret_protected/ai_cyborg_station = NO_SCRUBBER|NO_VENT,
		/area/maintenance/thirddeck/aft = 0,
		/area/maintenance/waterstore = 0,
		/area/maintenance/abandoned_hydroponics = 0,
		/area/maintenance/firstdeck/aftport = 0,
		/area/maintenance/abandoned_common = 0,
		/area/shuttle = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/shuttle/petrov = 0,
		/area/solar = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/space = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/storage = NO_SCRUBBER|NO_VENT,
		/area/storage/eva = 0,
		/area/storage/auxillary/port = 0,
		/area/storage/primary = 0,
		/area/storage/tech = 0,
		/area/storage/bridge = 0,
		/area/supply = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/thruster = NO_SCRUBBER,
		/area/turbolift = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/vacant = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/vacant/gambling = 0,
		/area/vacant/cargo = NO_SCRUBBER|NO_VENT,
		/area/vacant/infirmary = NO_SCRUBBER|NO_VENT,
		/area/vacant/monitoring = NO_SCRUBBER|NO_VENT,
		/area/rnd/xenobiology/atmos  = NO_SCRUBBER|NO_VENT,
		/area/rnd/xenobiology/cell_1 = NO_APC,
		/area/rnd/xenobiology/cell_2 = NO_APC,
		/area/rnd/xenobiology/cell_3 = NO_APC,
		/area/rnd/xenobiology/cell_4 = NO_APC,
		/area/hydroponics/third_deck_storage = NO_SCRUBBER|NO_VENT
	)

	area_coherency_test_exempt_areas = list(
		/area/space,
		/area/centcom/control,
		/area/maintenance/exterior,
	)

	area_usage_test_exempted_areas = list(
		/area/overmap,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape,
		/area/security/prison,
		/area/syndicate_elite_squad,
		/area/shuttle/syndicate_elite,
		/area/shuttle/syndicate_elite/station,
		/area/shuttle/syndicate_elite/mothership,
		/area/shuttle/escape/centcom,
		/area/rnd/xenobiology/xenoflora_storage,
		/area/turbolift,
		/area/turbolift/start,
		/area/turbolift/firstdeck,
		/area/turbolift/seconddeck,
		/area/turbolift/thirddeck,
		/area/beach,
		/area/template_noop,
		/area/rnd/xenobiology/cell_1,
		/area/rnd/xenobiology/cell_2,
		/area/rnd/xenobiology/cell_3,
		/area/rnd/xenobiology/cell_4
	)

/datum/unit_test/zas_area_test/ai_chamber
	name = "ZAS: AI Chamber"
	area_path = /area/turret_protected/ai

/datum/unit_test/zas_area_test/cargo_bay
	name = "ZAS: Cargo Bay"
	area_path = /area/quartermaster/storage

/datum/unit_test/zas_area_test/supply_centcomm
	name = "ZAS: Supply Shuttle (CentComm)"
	area_path = /area/supply/dock

/*
/datum/unit_test/zas_area_test/virology
	name = "ZAS: Virology"
	area_path = /area/medical/virology
*/

/datum/unit_test/zas_area_test/xenobio
	name = "ZAS: Xenobiology"
	area_path = /area/rnd/xenobiology


// =================================================================
// RESOMI
// =================================================================

/datum/unit_test/mob_damage/resomi
	name = "MOB: Resomi damage check template"
	template = /datum/unit_test/mob_damage/resomi
	mob_type = /mob/living/carbon/human/resomi

/datum/unit_test/mob_damage/resomi/brute
	name = "MOB: Resomi Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = EXTRA_VULNERABLE

/datum/unit_test/mob_damage/resomi/fire
	name = "MOB: Resomi Fire Damage Check"
	damagetype = DAMAGE_BURN
	expected_vulnerability = EXTRA_VULNERABLE

/datum/unit_test/mob_damage/resomi/tox
	name = "MOB: Resomi Toxins Damage Check"
	damagetype = DAMAGE_TOXIN

/datum/unit_test/mob_damage/resomi/oxy
	name = "MOB: Resomi Oxygen Damage Check"
	damagetype = DAMAGE_OXY

/datum/unit_test/mob_damage/resomi/genetic
	name = "MOB: Resomi Genetic Damage Check"
	damagetype = DAMAGE_GENETIC

/datum/unit_test/mob_damage/resomi/pain
	name = "MOB: Resomi Pain Damage Check"
	damagetype = DAMAGE_PAIN

// =================================================================
// TAJARA
// =================================================================
/datum/unit_test/mob_damage/tajara
	name = "MOB: Tajara damage check template"
	template = /datum/unit_test/mob_damage/tajara
	mob_type = /mob/living/carbon/human/tajaran

/datum/unit_test/mob_damage/tajara/brute
	name = "MOB: Tajara Brute Damage Check"
	damagetype = DAMAGE_BRUTE
	expected_vulnerability = EXTRA_VULNERABLE

/datum/unit_test/mob_damage/tajara/fire
	name = "MOB: Tajara Fire Damage Check"
	damagetype = DAMAGE_BURN
	expected_vulnerability = EXTRA_VULNERABLE

/datum/unit_test/mob_damage/tajara/tox
	name = "MOB: Tajara Toxins Damage Check"
	damagetype = DAMAGE_TOXIN

/datum/unit_test/mob_damage/tajara/oxy
	name = "MOB: Tajara Oxygen Damage Check"
	damagetype = DAMAGE_OXY

/datum/unit_test/mob_damage/tajara/genetic
	name = "MOB: Tajara Genetic Damage Check"
	damagetype = DAMAGE_GENETIC

/datum/unit_test/mob_damage/tajara/pain
	name = "MOB: Tajara Pain Damage Check"
	damagetype = DAMAGE_PAIN
