/datum/antagonist/cultist/Initialize()
	. = ..()
	global.Tier1Runes = list(
		/mob/proc/convert_rune,
		/mob/proc/teleport_rune,
		/mob/proc/tome_rune,
		/mob/proc/wall_rune,
		/mob/proc/ajorney_rune,
		/mob/proc/defile_rune,
		/mob/proc/stun_imbue,
		/mob/proc/emp_imbue,
		/mob/proc/cult_communicate,
		/mob/proc/obscure,
		/mob/proc/reveal,
		/mob/proc/burn_imbue
		)

	global.Tier2Runes = list(
		/mob/proc/armor_rune,
		/mob/proc/offering_rune,
		/mob/proc/drain_rune,
		/mob/proc/emp_rune,
		/mob/proc/massdefile_rune,
		/mob/proc/wrath_imbue,
		/mob/proc/hellhunter_rune,
		/mob/proc/hellbucket_rune,
		/mob/proc/hellstone_rune
		)

	global.Tier3Runes = list(
		/mob/proc/weapon_rune,
		/mob/proc/shell_rune,
		/mob/proc/bloodboil_rune,
		/mob/proc/confuse_rune,
		/mob/proc/revive_rune
		)
