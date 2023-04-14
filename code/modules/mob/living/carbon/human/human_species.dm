/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	virtual_mob = null

/mob/living/carbon/human/dummy/mannequin/Initialize()
	. = ..()
	STOP_PROCESSING_MOB(src)
	GLOB.human_mobs -= src
	delete_inventory()

/mob/living/carbon/human/dummy/mannequin/add_to_living_mob_list()
	return FALSE

/mob/living/carbon/human/dummy/mannequin/add_to_dead_mob_list()
	return FALSE

/mob/living/carbon/human/dummy/mannequin/fully_replace_character_name(new_name)
	..("[new_name] (mannequin)", FALSE)

/mob/living/carbon/human/dummy/mannequin/InitializeHud()
	return	// Mannequins don't get HUDs

/mob/living/carbon/human/skrell/Initialize(mapload)
	head_hair_style = "Skrell Male Tentacles"
	. = ..(mapload, SPECIES_SKRELL)

<<<<<<< ours
/mob/living/carbon/human/resomi/New(new_loc)
	head_hair_style = "Resomi Plumage"
	..(new_loc, SPECIES_RESOMI)

/mob/living/carbon/human/tajaran/New(new_loc)
	head_hair_style = "Tajaran Ears"
	..(new_loc, SPECIES_TAJARA)

/mob/living/carbon/human/unathi/New(new_loc)
=======
/mob/living/carbon/human/unathi/Initialize(mapload)
>>>>>>> theirs
	head_hair_style = "Unathi Horns"
	. = ..(mapload, SPECIES_UNATHI)

/mob/living/carbon/human/vox/Initialize(mapload)
	head_hair_style = "Long Vox Quills"
	. = ..(mapload, SPECIES_VOX)

/mob/living/carbon/human/diona/Initialize(mapload)
	. = ..(mapload, SPECIES_DIONA)

/mob/living/carbon/human/machine/Initialize(mapload)
	. = ..(mapload, SPECIES_IPC)

/mob/living/carbon/human/nabber/Initialize(mapload)
	pulling_punches = TRUE
	. = ..(mapload, SPECIES_NABBER)

/mob/living/carbon/human/monkey/Initialize(mapload)
	gender = pick(MALE, FEMALE)
	. = ..(mapload, SPECIES_MONKEY)

/mob/living/carbon/human/farwa/Initialize(mapload)
	. = ..(mapload, "Farwa")

/mob/living/carbon/human/neaera/Initialize(mapload)
	. = ..(mapload, "Neaera")

/mob/living/carbon/human/stok/Initialize(mapload)
	. = ..(mapload, "Stok")

/mob/living/carbon/human/adherent/Initialize(mapload)
	. = ..(mapload, SPECIES_ADHERENT)
