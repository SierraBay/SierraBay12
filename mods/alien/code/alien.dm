/mob/living/carbon/human/alien
	var/cloaked = 0
	var/list/abilities = list()

/mob/living/carbon/human/alien/Initialize(mapload)
	head_hair_style = "Bald"
	name = "Abomination"
	real_name = "Abomination"
	voice = "Abomination"
	voice_name = "Abomination"

	. = ..(mapload, SPECIES_XENO)

/singleton/species/alien
	name = SPECIES_XENO
	name_plural = "Aliens"

	genders = list(PLURAL)
	pronouns = list(PRONOUNS_IT_ITS)

	rarity_value = 3

	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/sharp)

	hidden_from_codex = TRUE
	mob_size = MOB_LARGE
	strength = STR_VHIGH

	hud_type = /datum/hud_data/alien

	has_fine_manipulation = 0
	siemens_coefficient = 0

	slowdown = -0.5
	brute_mod = 0.5 // Hardened carapace.
	burn_mod = 2    // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	species_flags = SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_SLIP | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_PAIN
	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_ROBOTIC_INTERNAL_ORGANS

	icobase = 'mods/alien/icons/r_alien.dmi'
	deform = 'mods/alien/icons/r_alien.dmi'

	blood_color = "#552f9c"
	flesh_color = "#282846"

	breath_type = null

	has_organ = list(
		"heart" =           /obj/item/organ/internal/heart,
		"brain" =           /obj/item/organ/internal/brain/xeno,
		"plasma vessel" =   /obj/item/organ/internal/plasmavessel,
		"hive node" =       /obj/item/organ/internal/hivenode,
		"nutrient vessel" = /obj/item/organ/internal/diona/nutrients
	)

/obj/item/organ/internal/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon = 'mods/alien/icons/organs.dmi'
	icon_state = "chitin"

/obj/item/organ/internal/plasmavessel
	name = "plasma vessel"
	icon = 'mods/alien/icons/organs.dmi'
	icon_state = "xgibdown1"
	organ_tag = "plasma vessel"

/obj/item/organ/internal/hivenode
	name = "hive node"
	icon = 'mods/alien/icons/organs.dmi'
	icon_state = "xgibmid2"
	organ_tag = "hive node"

var/list/EXAMINE_XENO = list('mods/alien/sounds/alien_examine1.ogg','mods/alien/sounds/alien_examine2.ogg', 'mods/alien/sounds/alien_examine3.ogg', 'mods/alien/sounds/alien_examine4.ogg', 'mods/alien/sounds/alien_examine5.ogg')

/mob/living/carbon/human/examine()
	if(isalien(src))
		if(src.stat != DEAD)
			to_chat(usr, "<span class='alert'>О ГОСПОДИ!</span>")
			playsound_local(get_turf(usr), pick(EXAMINE_XENO), 20)
	..()

/datum/language/xenocommon
	name = LANGUAGE_XENO
	colour = "vox"
	desc = "The common tongue of the xenomorphs."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "hisses"
	key = "m"
	syllables = list("hsss", "hs", "hssssss")
	hidden_from_codex = TRUE
	machine_understands = 0
	flags = RESTRICTED | NO_STUTTER
