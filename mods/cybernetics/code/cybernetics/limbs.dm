#include "limbs\body.dm"
#include "limbs\groin.dm"
#include "limbs\head.dm"
#include "limbs\left_arm.dm"
#include "limbs\left_foot.dm"
#include "limbs\left_hand.dm"
#include "limbs\left_leg.dm"
#include "limbs\right_arm.dm"
#include "limbs\right_foot.dm"
#include "limbs\right_hand.dm"
#include "limbs\right_leg.dm"

/singleton/cyber_choose/limb
	avaible_hardpoints = list(
		BP_HEAD,
		BP_CHEST,
		BP_GROIN,
		BP_R_ARM,
		BP_R_HAND,
		BP_L_ARM,
		BP_L_HAND,
		BP_R_LEG,
		BP_R_FOOT,
		BP_L_LEG,
		BP_L_FOOT
	)
	good_sides = list(
		"В отличии от мясных конечностей, протезы можно ремонтировать.",
		"Повреждения протезов вызывает не настоящую боль - голоболь, что не может остановить ваше сердце.",
		"Протез не обладает кровотоком, а значит, не может кровоточить."
	)
	bad_sides = list(
		"Страдает от ЭМИ",
		"В отличии от мясных конечностей, протезы не могут регенерировать сами по себе.",
		"Разнообразная медицина не может влиять на конечность, по типу регенерации от бикардина")
	//Прототип, с которого и будет подсасываться разнообразные значения и описания
	var/datum/robolimb/robolimb_data = /datum/robolimb




/singleton/cyber_choose/limb/remove_limb
	augment_name = "Отсутствие конечности"
	aug_description = "Конечность будет отсутствовать."
	avaible_hardpoints = list(
		BP_R_ARM,
		BP_R_HAND,
		BP_L_ARM,
		BP_L_HAND,
		BP_R_LEG,
		BP_R_FOOT,
		BP_L_LEG,
		BP_L_FOOT
		)
	good_sides = list("Хорошего в этом мало. Например, в отсутствующую конечность нельзя попасть атакой.")
	neutral_sides = list("В случае отсутствия одной из ног, вам выдадут коляску.")
	bad_sides = list("Конечность полностью отсутствует")
	robolimb_data = null























































/datum/robolimb/bishop
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
	)
	speed_modifier = - 1
	coolingefficiency = 0.3
	expensive = TRUE

/datum/robolimb/bishop/rook
	company = "Bishop Rook"
	desc = "This limb has a polished metallic casing and a holographic face emitter."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_rook.dmi'
	has_eyes = FALSE
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
	)
	speed_modifier = - 0.7
	coolingefficiency = 0.4

/datum/robolimb/bishop/alt
	company = "Bishop Alt."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/bishop/alt/monitor
	company = "Bishop Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/hephaestus
	company = "Hephaestus Industries"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	unavailable_at_fab = 1

	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 0.5
	coolingefficiency = 0.8

/datum/robolimb/hephaestus/alt
	company = "Hephaestus Alt."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/hephaestus/titan
	company = "Hephaestus Titan"
	desc = "This limb has a casing of an olive drab finish, providing a reinforced housing look."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_titan.dmi'
	has_eyes = FALSE
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_RESISTANT,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	expensive = TRUE
	speed_modifier = 1.2
	coolingefficiency = 1

/datum/robolimb/hephaestus/alt/monitor
	company = "Hephaestus Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	can_eat = null
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/zenghu
	company = "Zeng-Hu"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	can_eat = 1
	unavailable_at_fab = 1
	allowed_bodytypes = list(SPECIES_HUMAN,SPECIES_IPC)
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 0.4
	siemens_coefficient = 0.8


/datum/robolimb/zenghu/spirit
	company = "Zeng-Hu Spirit"
	desc = "This limb has a sleek black and white polymer finish."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_spirit.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = - 0.3
	coolingefficiency = 0.4

/datum/robolimb/xion
	company = "Xion"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = 0,
		energy = 0,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)

/datum/robolimb/xion/econo
	company = "Xion Econ"
	desc = "This skeletal mechanical limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_econo.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = 0,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 0.7
	addmax_damage = - 8
	addmin_broken_damage = - 15

/datum/robolimb/xion/alt
	company = "Xion Alt."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/xion/alt/monitor
	company = "Xion Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	can_eat = null
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/nanotrasen
	company = "NanoTrasen"
	desc = "This limb is made from a cheap polymer."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 0.2
	coolingefficiency = 0.6
	siemens_coefficient = 1.2

/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	can_eat = 1
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = ARMOR_ENERGY_MINOR,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)

/datum/robolimb/economy
	company = "Ward-Takahashi Econ."
	desc = "A simple robotic limb with retro design. Seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_economy.dmi'
	armor = list(
		melee = 0,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 1.2
	speed_modifier = 0.1
	addmax_damage = - 5
	addmin_broken_damage = - 10

/datum/robolimb/wardtakahashi/alt
	company = "Ward-Takahashi Alt."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/wardtakahashi/alt/monitor
	company = "Ward-Takahashi Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	can_eat = null
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/morpheus
	company = "Morpheus"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)

/datum/robolimb/morpheus/alt
	company = "Morpheus Atlantis"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_atlantis.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/morpheus/alt/blitz
	company = "Morpheus Blitz"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_blitz.dmi'
	applies_to_part = list(BP_HEAD)
	has_eyes = FALSE
	unavailable_at_fab = 1

/datum/robolimb/morpheus/alt/airborne
	company = "Morpheus Airborne"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_airborne.dmi'
	applies_to_part = list(BP_HEAD)
	has_eyes = FALSE
	unavailable_at_fab = 1

/datum/robolimb/morpheus/alt/prime
	company = "Morpheus Prime"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_prime.dmi'
	applies_to_part = list(BP_HEAD)
	has_eyes = FALSE
	unavailable_at_fab = 1

/datum/robolimb/mantis
	company = "Morpheus Mantis"
	desc = "This limb has a casing of sleek black metal and repulsive insectile design."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_mantis.dmi'
	unavailable_at_fab = 1
	has_eyes = FALSE
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = - 0.1
	coolingefficiency = 0.52

/datum/robolimb/morpheus/monitor
	company = "Morpheus Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_monitor.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1
	has_eyes = FALSE
	allowed_bodytypes = list(SPECIES_IPC)
	has_screen = TRUE

/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	can_eat = 1
	skintone = 1
	unavailable_at_fab = 1
	expensive = TRUE
	species_cannot_use = list(SPECIES_IPC)

/datum/robolimb/shellguard
	company = "Shellguard"
	desc = "This limb has a sturdy and heavy build to it."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_main.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_RESISTANT,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 0.8
	coolingefficiency = 0.8
	addmax_damage = 10
	addmin_broken_damage = 5

/datum/robolimb/shellguard/alt
	company = "Shellguard Alt."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/shellguard/alt/monitor
	company = "Shellguard Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_monitor.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1
	allowed_bodytypes = list(SPECIES_IPC)
	has_screen = TRUE

/datum/robolimb/vox
	company = "Arkmade"
	icon = 'icons/mob/human_races/cyberlimbs/vox/primalis.dmi'
	unavailable_at_fab = 1
	allowed_bodytypes = list(SPECIES_VOX)
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 1.2
	coolingefficiency = 0.4
	addmax_damage = 10
	addmin_broken_damage = 5

/datum/robolimb/vox/crap
	company = "Improvised"
	icon = 'icons/mob/human_races/cyberlimbs/vox/improvised.dmi'
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)

/datum/robolimb/resomi
	company = "Small prosthetic"
	desc = "This prosthetic is small and fit for nonhuman proportions."
	armor = list(
		melee = 2,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
