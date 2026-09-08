/datum/map_template/ruin/exoplanet/mod_tribe
	name = "Primitive tribe"
	id = "awaysite_primitive_tribe"
	prefix = "mods/tribe/maps/"
	suffixes = list("tribe.dmm")
	spawn_cost = 3
	player_cost = 4
	spawn_weight = 0.2
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS | TEMPLATE_FLAG_NO_RADS
	ruin_tags = RUIN_HABITAT
	skip_main_unit_tests = TRUE

/area/map_template/tribe_caverns
	name = "\improper Caverns"
	icon_state = "red"

/singleton/submap_archetype/tribe
	descriptor = "Primitive tribe"
	map = "Primitive tribe"
	crew_jobs = list(
		/datum/job/submap/tribe
	)
	whitelisted_species = null
	blacklisted_species = null

/datum/job/submap/tribe
	title = "Primitive"
	info = ""
	total_positions = 10
	economic_power = 0
	loadout_allowed = FALSE
	is_semi_antagonist = TRUE
	whitelisted_species = null
	blacklisted_species = null
	outfit_type = /singleton/hierarchy/outfit/job/mod_tribe

	min_skill = list(
		SKILL_HAULING = SKILL_BASIC,
		SKILL_COMBAT   = SKILL_BASIC
	)

/singleton/hierarchy/outfit/job/mod_tribe
	name = "Tribe outfit"

	uniform = /obj/item/clothing/under/savage_hunter
	shoes = /obj/item/clothing/shoes/sandal
	l_pocket = /obj/item/material/knife/folding/wood
	r_pocket = /obj/item/stack/medical/bruise_pack
	belt = /obj/item/device/flashlight/lantern
	back = /obj/item/material/twohanded/spear/mod_tribe
	pda_type = null
	id_types = null
	l_ear = null
	flags = null

/singleton/hierarchy/outfit/job/mod_tribe/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/savage_hunter/female


/obj/submap_landmark/spawnpoint/tribe
	name = "Primitive"

/obj/submap_landmark/joinable_submap/tribe
	name = "primitive tribe"
	archetype = /singleton/submap_archetype/tribe

/mob/living/carbon/human/proc/mod_tribalize(level)
	if(!GLOB.species_by_name["Tribe_[level]"])
		var/singleton/species/alium/tribe/T = new
		var/obj/overmap/visitable/sector/exoplanet/E = map_sectors["[level]"]
		if(istype(E))
			T.adapt_to_exoplanet(E)
		GLOB.species_by_name["Tribe_[level]"] = T

	set_species("Tribe_[level]")

	nutrition = 450
	hydration = 450

	var/singleton/cultural_info/culture = get_cultural_value(TAG_CULTURE)
	fully_replace_character_name(culture.get_random_name(gender))
	rename_self("Humanoid Alien", 1)

/datum/job/submap/tribe/New(datum/submap/_owner, abstract_job = FALSE)
	// Small chance they might already know another language for some reason
	if(prob(10))
		var/possible_language = pick(
			LANGUAGE_HUMAN_EURO,
			LANGUAGE_HUMAN_RUSSIAN,
			LANGUAGE_GUTTER,
			LANGUAGE_SPACER,
			LANGUAGE_SIGN,
		)

		required_language = possible_language
	..()

/datum/job/submap/tribe/handle_variant_join(mob/living/carbon/human/H, alt_title)
	H.mod_tribalize(H.z)

	return H