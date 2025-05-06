// As long something depends on RnD activity like slime reactions it's belong to RnD.

/singleton/species/moth
	name =             SPECIES_MOTH
	name_plural =      "Mothmans"
	icobase = 'mods/RnD/icons/mob/moth/body.dmi'
	deform =  'mods/RnD/icons/mob/moth/body.dmi'
	tail = "m_moth_wings_monarch"
	tail_animation = 'mods/RnD/icons/mob/moth/moth_wings.dmi'
	default_head_hair_style = "Monarch Antennae"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite/sharp)

	darksight_range = 6
	darksight_tint = DARKTINT_GOOD
	brute_mod = 1.15
	burn_mod =  1.15
	flash_mod = 2 //
	hunger_factor = DEFAULT_HUNGER_FACTOR * 1.5

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
		/singleton/emote/human/swish,
		/singleton/emote/human/wag,
		/singleton/emote/human/sway,
		/singleton/emote/human/qwag,
		/singleton/emote/human/fastsway,
		/singleton/emote/human/swag,
		/singleton/emote/human/stopsway,
		)

	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED
	appearance_flags = SPECIES_APPEARANCE_HAS_HAIR_COLOR | SPECIES_APPEARANCE_HAS_UNDERWEAR | SPECIES_APPEARANCE_HAS_SKIN_COLOR

	flesh_color = "#afa59e"
	base_color = "#333333"
	blood_color = "#862a51"
	organs_icon = 'mods/tajara/icons/tajara_body/organs.dmi'

	move_trail = /obj/decal/cleanable/blood/tracks/paw

/singleton/emote/audible/moth_scream
	key = "scream"
	emote_message_3p = "USER screams."
	emote_sound = 'mods/RnD/sounds/scream_moth.ogg'

/singleton/emote/audible/moth_cough
	key = "cough"
	emote_message_3p = "USER coughs!"
	emote_sound = 'mods/RnD/sounds/mothcough.ogg'

/datum/sprite_accessory/hair/moth
	name = "Monarch Antennae"
	icon_state = "m_moth_antennae_monarch"
	species_allowed = list(SPECIES_MOTH)
	icon = 'mods/RnD/icons/mob/moth/moth_antennae.dmi'
