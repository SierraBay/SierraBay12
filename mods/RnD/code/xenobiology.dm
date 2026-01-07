// As long something depends on RnD activity like slime reactions it's belong to RnD.

/singleton/species/moth
	name =             SPECIES_MOTH
	name_plural =      "Mothmans"
	icobase = 'mods/RnD/icons/mob/moth/body.dmi'
	deform =  'mods/RnD/icons/mob/moth/body.dmi'
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch)

	default_facial_hair_style = "Plain Antennae"
	default_head_hair_style = "Plain Wings"

	darksight_range = 6
	darksight_tint = DARKTINT_GOOD
	brute_mod = 1.15
	burn_mod =  1.15
	flash_mod = 2 // We have big eyes
	hunger_factor = DEFAULT_HUNGER_FACTOR * 1.5

	genders = list(PLURAL)
	pronouns = list(PRONOUNS_THEY_THEM)

	gluttonous = GLUT_TINY
	hidden_from_codex = TRUE
	health_hud_intensity = 1.75

	maneuvers = list(/singleton/maneuver/leap/grab)
	standing_jump_range = 3 // Because we have some wings after all

	speech_sounds = list('mods/RnD/sounds/mothchitter.ogg')
	speech_chance = 20

	min_age = 19
	max_age = 120

	description = "Sometimes Science is a very cruel and mad mother of monsters."

	pain_emotes_with_pain_level = list(
			list(/singleton/emote/audible/moth_scream) = 80,
			list(/singleton/emote/audible/moth_scream) = 50,
			list(/singleton/emote/audible/moth_cough) = 20,
		)


	default_emotes = list(
		/singleton/emote/audible/moth_scream,
		/singleton/emote/audible/moth_cough,
		/singleton/emote/audible/moth_laugh
		)

	spawn_flags = SPECIES_IS_RESTRICTED
	appearance_flags = SPECIES_APPEARANCE_HAS_LIPS | SPECIES_APPEARANCE_HAS_UNDERWEAR

	flesh_color = "#f7d896"
	base_color = "#333333"
	blood_color = "#b9ae9c"
	organs_icon = 'mods/RnD/icons/mob/moth/moth_organs.dmi'

	move_trail = /obj/decal/cleanable/blood/tracks/paw

	has_organ = list(
		BP_HEART =    /obj/item/organ/internal/heart,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver,
		BP_STOMACH =  /obj/item/organ/internal/stomach,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_EYES =     /obj/item/organ/internal/eyes/moth
		)

/mob/living/carbon/human/moth/Initialize(mapload)
	head_hair_style = "Plain Wings"
	facial_hair_style = "Plain Antennae"
	. = ..(mapload, SPECIES_MOTH)

// A crutch on a crutch and a crutch drives. BLOCKHAIR isn't our friend.

/obj/item/clothing/head/helmet
	species_restricted = list("exclude", SPECIES_NABBER, SPECIES_ADHERENT, SPECIES_MOTH)

/obj/item/clothing/head/helmet/space
	species_restricted = list("exclude", SPECIES_NABBER, SPECIES_DIONA, SPECIES_MOTH)

/singleton/emote/audible/moth_scream
	key = "scream"
	emote_message_3p = "USER screams."
	emote_sound = 'mods/RnD/sounds/scream_moth.ogg'

/singleton/emote/audible/moth_cough
	key = "cough"
	emote_message_3p = "USER coughs!"
	emote_sound = 'mods/RnD/sounds/mothcough.ogg'

/singleton/emote/audible/moth_laugh
	key = "laugh"
	emote_message_3p = "USER laughs."
	emote_sound = 'mods/RnD/sounds/mothlaugh.ogg'

/obj/item/organ/internal/eyes/moth
	icon = 'mods/RnD/icons/mob/moth/eyes.dmi'
	eye_icon = 'mods/RnD/icons/mob/moth/eyes.dmi'


/datum/sprite_accessory/facial_hair/moth
	name = "Plain Antennae"
	icon_state = "plain"
	species_allowed = list(SPECIES_MOTH)
	gender = NEUTER
	do_coloration = FALSE
	icon = 'mods/RnD/icons/mob/moth/facial.dmi'

// Since we're not "true" species and only a gimmic for Xenobio, we use limited amount of wings (only those, which don't need corresponding bodymark). Also wings are our "hair" and not a standalone organ with proper overlays.

/datum/sprite_accessory/hair/moth
	name = "Plain Wings"
	icon_state = "plain"
	species_allowed = list(SPECIES_MOTH)
	gender = NEUTER
	do_coloration = FALSE
	icon = 'mods/RnD/icons/mob/moth/hair.dmi'

/datum/sprite_accessory/hair/moth/monarch
	name = "Monarch Wings"
	icon_state = "monarch"

/datum/sprite_accessory/hair/moth/luna
	name = "Luna Wings"
	icon_state = "luna"

/datum/sprite_accessory/hair/moth/atlas
	name = "Atlas Wings"
	icon_state = "atlas"

/datum/sprite_accessory/hair/moth/ragged
	name = "Ragged Wings"
	icon_state = "ragged"

// How we makes moths. Because of, you know, dependency on one specific entity, this reactions also belongs to RnD mod

/singleton/reaction/slime/mothtoxin
	name = "Mothman Mutation Toxin"
	result = /datum/reagent/mothtoxin
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/slime_extract/green

/* Transformations */
/datum/reagent/mothtoxin
	name = "Contaminated Mutation Toxin"
	description = "A corruptive toxin produced by slimes. This one looks like ."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#b9ae9c"
	metabolism = REM * 0.2
	value = 2
	should_admin_log = TRUE

/datum/reagent/mothtoxin/affect_blood(mob/living/carbon/human/affected, removed)
	if(!istype(affected))
		return
	if(affected.species.name == SPECIES_MOTH)
		return
	affected.adjustToxLoss(40 * removed)

/datum/reagent/mothtoxin/affect_metabolites(mob/living/carbon/human/H, dose)
	if(!istype(H))
		return
	if(H.species.name == SPECIES_MOTH)
		return
	if (dose < 1 || prob(30))
		return
	remove_self(dose)
	var/list/meatchunks = list()
	for(var/limb_tag in list(BP_R_ARM, BP_L_ARM, BP_R_LEG,BP_L_LEG))
		var/obj/item/organ/external/E = H.get_organ(limb_tag)
		if(E && !E.is_stump() && !BP_IS_ROBOTIC(E) && E.species.name != SPECIES_MOTH)
			meatchunks += E
	if(!length(meatchunks))
		if(prob(10))
			to_chat(H, SPAN_DANGER("Your flesh rapidly mutates!"))
			H.set_species(SPECIES_MOTH)
			H.shapeshifter_set_colour("#f7d896")
			H.shapeshifter_select_hair() // Let them choose their wings and antennae
		return
	var/obj/item/organ/external/O = pick(meatchunks)
	to_chat(H, SPAN_DANGER("Your [O.name]'s flesh mutates rapidly!"))
	if(!GLOB.mob_ref_to_species_name[any2ref(H)])
		GLOB.mob_ref_to_species_name[any2ref(H)] = H.species.name
	meatchunks = list(O) | O.children
	for(var/obj/item/organ/external/E in meatchunks)
		E.species = GLOB.species_by_name[SPECIES_MOTH]
		E.skin_tone = null
		E.s_col = ReadRGB("#b9ae9c")
		E.s_col_blend = ICON_ADD
		E.status &= ~ORGAN_BROKEN
		E.status |= ORGAN_MUTATED
		E.limb_flags &= ~ORGAN_FLAG_CAN_BREAK
		E.dislocated = -1
		E.max_damage = 5
		E.update_icon(1)
	O.max_damage = 15
	if(prob(10))
		to_chat(H, SPAN_DANGER("Your new [O.name] explodes with a stream of blood and unformed chitin!"))
		O.droplimb()
	H.update_body()
