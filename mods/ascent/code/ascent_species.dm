/datum/species/mantid

	name =                   SPECIES_MANTID_ALATE
	name_plural =            "Kharmaan Alates"
	show_ssd =               "quiescent"

	description = "When human explorers finally arrived at the outer reaches of Skrellian space, they hoped to find \
	new frontiers and new planets to exploit. They were largely not expecting to have entire expeditions lost \
	amid reports of highly advanced, astonishingly violent mantid-cephlapodean sentients with particle cannons."

	icobase =                 'mods/ascent/icons/alate/body.dmi'
	deform =                  'mods/ascent/icons/alate/body.dmi'
	damage_overlays =         'mods/ascent/icons/alate/damage_mask.dmi'
	blood_mask =              'mods/ascent/icons/alate/blood_mask.dmi'
	organs_icon =             'mods/ascent/icons/organs.dmi'

	blood_color =             "#660066"
	flesh_color =             "#009999"
	hud_type =                /datum/hud_data/mantid
	move_trail =              /obj/decal/cleanable/blood/tracks/snake

	speech_chance = 100
	speech_sounds = list(
		'sound/voice/ascent1.ogg',
		'sound/voice/ascent2.ogg',
		'sound/voice/ascent3.ogg',
		'sound/voice/ascent4.ogg',
		'sound/voice/ascent5.ogg',
		'sound/voice/ascent6.ogg'
	)

	siemens_coefficient =   0.2 // Crystalline body.
	oxy_mod =               0.8 // Don't need as much breathable gas as humans.
	toxins_mod =            0.8 // Not as biologically fragile as meatboys.
	radiation_mod =         0.5 // Not as biologically fragile as meatboys.
	flash_mod =               2 // Highly photosensitive.

	min_age =                 1
	max_age =                20
	slowdown =               -1
	rarity_value =            3
	gluttonous =              2
	body_temperature =        null

	breath_type =             GAS_METHYL_BROMIDE
	exhale_type =             GAS_METHANE
	poison_types =            list(GAS_PHORON)

	genders =                 list(MALE)

	appearance_flags =        0
	species_flags =           SPECIES_FLAG_NO_SCAN  | SPECIES_FLAG_NO_SLIP        | SPECIES_FLAG_NO_MINOR_CUT
	spawn_flags =             SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_IS_WHITELISTED

	heat_discomfort_strings = list(
		"You feel brittle and overheated.",
		"Your overheated carapace flexes uneasily.",
		"Overheated ichor trickles from your eyes."
		)
	cold_discomfort_strings = list(
		"Frost forms along your carapace.",
		"You hear a faint crackle of ice as you shift your freezing body.",
		"Your movements become sluggish under the weight of the chilly conditions."
		)
	unarmed_types = list(
		/datum/unarmed_attack/claws/strong/gloves,
		/datum/unarmed_attack/bite/sharp
	)

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/insectoid),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/insectoid/mantid),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/insectoid),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/insectoid),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/insectoid),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/insectoid),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/insectoid),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/insectoid),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/insectoid),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/insectoid),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/insectoid)
	)

	has_organ = list(
		BP_HEART =             /obj/item/organ/internal/heart/insectoid,
		BP_STOMACH =           /obj/item/organ/internal/stomach/insectoid,
		BP_LUNGS =             /obj/item/organ/internal/lungs/insectoid,
		BP_LIVER =             /obj/item/organ/internal/liver/insectoid,
		BP_KIDNEYS =           /obj/item/organ/internal/kidneys/insectoid,
		BP_BRAIN =             /obj/item/organ/internal/brain/insectoid,
		BP_EYES =              /obj/item/organ/internal/eyes/insectoid,
		BP_SYSTEM_CONTROLLER = /obj/item/organ/internal/controller
	)

	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_ALATE,
		TAG_RELIGION =  RELIGION_KHARMAANI
	)

	descriptors = list(
		/datum/mob_descriptor/height = -1,
		/datum/mob_descriptor/body_length = -2
		)

	pain_emotes_with_pain_level = list(
			list(/singleton/emote/visible/ascent_shine, /singleton/emote/visible/ascent_dazzle) = 80,
			list(/singleton/emote/visible/ascent_glimmer, /singleton/emote/visible/ascent_pulse) = 50,
			list(/singleton/emote/visible/ascent_flicker, /singleton/emote/visible/ascent_glint) = 20,
		)

	exertion_effect_chance = 10
	exertion_hydration_scale = 1
	exertion_reagent_scale = 5
	exertion_reagent_path = /datum/reagent/lactate
	exertion_emotes_biological = list(
		/singleton/emote/exertion/biological,
		/singleton/emote/exertion/biological/breath,
		/singleton/emote/exertion/biological/pant
	)

/datum/species/mantid/skills_from_age(age)
	. = 0

/datum/species/mantid/handle_sleeping(mob/living/carbon/human/H)
	return

/datum/species/mantid/get_blood_name()
	return "hemolymph"

/datum/species/mantid/post_organ_rejuvenate(obj/item/organ/org, mob/living/carbon/human/H)
	org.status |= ORGAN_CRYSTAL

/datum/species/mantid/equip_survival_gear(mob/living/carbon/human/H, extendedtank = 1)
	return

/// Gyne ///

/datum/species/mantid/gyne

	name =                    SPECIES_MANTID_GYNE
	name_plural =             "Kharmaan Gynes"

	genders =                 list(FEMALE)
	icobase =                 'mods/ascent/icons/gyne/body.dmi'
	deform =                  'mods/ascent/icons/gyne/body.dmi'
	icon_template =           'mods/ascent/icons/gyne/template.dmi'
	damage_overlays =         'mods/ascent/icons/gyne/damage_mask.dmi'
	blood_mask =              'mods/ascent/icons/gyne/blood_mask.dmi'

	gluttonous =              3
	slowdown =                2
	rarity_value =           10
	min_age =                 5
	max_age =               500
	blood_volume =         1200
	spawns_with_stack =       0

	spawn_flags =             SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_IS_WHITELISTED//INF

	pixel_offset_x =        -4
	antaghud_offset_y =      18
	antaghud_offset_x =      4

	bump_flag =               HEAVY
	push_flags =              ALLMOBS
	swap_flags =              ALLMOBS

	override_limb_types = list(
		BP_HEAD = /obj/item/organ/external/head/insectoid/mantid,
		BP_GROIN = /obj/item/organ/external/groin/insectoid/mantid/gyne
	)

	descriptors = list(
		/datum/mob_descriptor/height = 5,
		/datum/mob_descriptor/body_length = 2
	)

	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_GYNE,
		TAG_RELIGION =  RELIGION_KHARMAANI
	)

/datum/species/mantid/gyne/skills_from_age(age)
	. = 0

/datum/species/mantid/gyne/attempt_grab(mob/living/carbon/human/grabber, mob/living/target)
	if(grabber != target)
		grabber.unEquip(grabber.l_hand)
		grabber.unEquip(grabber.r_hand)
		to_chat(grabber, SPAN_WARNING("You drop everything as you seize \the [target]!"))
		playsound(grabber.loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
	. = ..(grabber, target, GRAB_NAB)

/datum/species/mantid/gyne/New()
	equip_adjust = list(
		slot_l_hand_str = list(
			"[NORTH]" = list("x" = -4, "y" = 12),
			"[EAST]" = list("x" =  -4, "y" = 12),
			"[SOUTH]" = list("x" = -4, "y" = 12),
			"[WEST]" = list("x" =  -4, "y" = 12)
		)
	)
	..()

/datum/hud_data/mantid
	gear = list(
		"i_clothing" =   list("loc" = ui_iclothing, "name" = "Uniform",      "slot" = slot_w_uniform, "state" = "center", "toggle" = 1),
		"o_clothing" =   list("loc" = ui_oclothing, "name" = "Suit",         "slot" = slot_wear_suit, "state" = "suit",   "toggle" = 1),
		"mask" =         list("loc" = ui_mask,      "name" = "Mask",         "slot" = slot_wear_mask, "state" = "mask",   "toggle" = 1),
		"gloves" =       list("loc" = ui_gloves,    "name" = "Gloves",       "slot" = slot_gloves,    "state" = "gloves", "toggle" = 1),
		"eyes" =         list("loc" = ui_glasses,   "name" = "Glasses",      "slot" = slot_glasses,   "state" = "glasses","toggle" = 1),
		"l_ear" =        list("loc" = ui_l_ear,     "name" = "Left Ear",     "slot" = slot_l_ear,     "state" = "ears",   "toggle" = 1),
		"r_ear" =        list("loc" = ui_r_ear,     "name" = "Right Ear",    "slot" = slot_r_ear,     "state" = "ears",   "toggle" = 1),
		"head" =         list("loc" = ui_head,      "name" = "Hat",          "slot" = slot_head,      "state" = "hair",   "toggle" = 1),
		"shoes" =        list("loc" = ui_shoes,     "name" = "Shoes",        "slot" = slot_shoes,     "state" = "shoes",  "toggle" = 1),
		"suit storage" = list("loc" = ui_sstore1,   "name" = "Suit Storage", "slot" = slot_s_store,   "state" = "suitstore"),
		"back" =         list("loc" = ui_back,      "name" = "Back",         "slot" = slot_back,      "state" = "back"),
		"id" =           list("loc" = ui_id,        "name" = "ID",           "slot" = slot_wear_id,   "state" = "id"),
		"storage1" =     list("loc" = ui_storage1,  "name" = "Left Pocket",  "slot" = slot_l_store,   "state" = "pocket"),
		"storage2" =     list("loc" = ui_storage2,  "name" = "Right Pocket", "slot" = slot_r_store,   "state" = "pocket"),
		"belt" =         list("loc" = ui_belt,      "name" = "Belt",         "slot" = slot_belt,      "state" = "belt")
		)

/// ----- MONARCH GAS ----- ///

/datum/species/nabber/monarch_worker
	name = SPECIES_MONARCH_WORKER
	name_plural = "Monarch Serpentid Workers"
	description = "close cousins to the Giant Armoured Serpentids, saved from their crippled homeworld hundreds of \
	years ago and now allies and peers within the Ascent."
	icobase = 'icons/mob/human_races/species/nabber/body_msw.dmi'
	deform = 'icons/mob/human_races/species/nabber/body_msw.dmi'
	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_IS_WHITELISTED
	appearance_flags = 0
	base_skin_colours = null
	has_organ = list(
		BP_BRAIN =             /obj/item/organ/internal/brain/insectoid/nabber,
		BP_EYES =              /obj/item/organ/internal/eyes/insectoid/nabber,
		BP_TRACH =             /obj/item/organ/internal/lungs/insectoid/nabber,
		BP_HEART =             /obj/item/organ/internal/heart/open,
		BP_LIVER =             /obj/item/organ/internal/liver/insectoid/nabber,
		BP_STOMACH =           /obj/item/organ/internal/stomach/insectoid,
		BP_SYSTEM_CONTROLLER = /obj/item/organ/internal/controller
	)

	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_SERPENTID,
		TAG_RELIGION =  RELIGION_KHARMAANI
	)

/datum/species/nabber/monarch_worker/skills_from_age(age)
	. = 0

/datum/species/nabber/monarch_worker/get_bodytype(mob/living/carbon/human/H)
	return SPECIES_NABBER

/datum/species/nabber/monarch_worker/equip_survival_gear(mob/living/carbon/human/H)
	return

/// Queen ///

/datum/species/nabber/monarch_queen
	name = SPECIES_MONARCH_QUEEN
	name_plural = "Monarch Serpentid Queens"
	description = "close cousins to the Giant Armoured Serpentids, saved from their crippled homeworld hundreds of \
	years ago and now allies and peers within the Ascent. Queens, who were saved from a dying world by the Kharmaani \
	and eventually promoted from 'entertaining pets' to the middle men that keep Ascent society functioning smoothly. \
	Gynes have tremendous difficulties in communicating with each other politely, so the queens act as intermediaries, \
	smoothing over the fractious and unproductive squabbling."

	silent_steps = TRUE

	icobase = 'icons/mob/human_races/species/nabber/msq/body.dmi'
	deform = 'icons/mob/human_races/species/nabber/msq/body.dmi'
	blood_mask = 'icons/mob/human_races/species/nabber/msq/blood_mask.dmi'
	damage_mask = 'icons/mob/human_races/species/nabber/msq/damage_mask.dmi'

	genders = list(FEMALE)

	total_health = 150

	mob_size = MOB_MEDIUM
	breath_pressure = 21
	blood_volume = 600

	appearance_flags = 0
	base_skin_colours = null
	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_IS_WHITELISTED

	has_organ = list(
		BP_BRAIN =             /obj/item/organ/internal/brain/insectoid/nabber,
		BP_EYES =              /obj/item/organ/internal/eyes/insectoid/msq,
		BP_TRACH =             /obj/item/organ/internal/lungs/insectoid/nabber,
		BP_LIVER =             /obj/item/organ/internal/liver/insectoid/nabber,
		BP_HEART =             /obj/item/organ/internal/heart/open,
		BP_STOMACH =           /obj/item/organ/internal/stomach,
		BP_SYSTEM_CONTROLLER = /obj/item/organ/internal/controller,
		BP_VOICE =    /obj/item/organ/internal/voicebox/nabber/ascent
		)

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/insectoid),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/insectoid/nabber),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/insectoid),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/insectoid),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/insectoid),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/insectoid),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/insectoid),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/insectoid),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/insectoid),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/insectoid),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/insectoid)
		)

	descriptors = list(
		/datum/mob_descriptor/height = -1,
		/datum/mob_descriptor/body_length = -1
		)


	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_SERPENTID,
		TAG_RELIGION =  RELIGION_KHARMAANI
		)

/datum/species/nabber/monarch_queen/New()
	equip_adjust = list(
		slot_belt_str = list(
			"[NORTH]" = list("x" = 0, "y" = 0),
			"[EAST]" = list("x" = 8, "y" = 0),
			"[SOUTH]" = list("x" = 0, "y" = 0),
			"[WEST]" = list("x" = -8, "y" = 0)
		)
	)
	..()

/datum/species/nabber/monarch_queen/skills_from_age(age)
	. = 0

/datum/species/nabber/monarch_queen/equip_survival_gear(mob/living/carbon/human/H)
	return
