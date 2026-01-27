/datum/robolimb
	var/list/armor
	var/siemens_coefficient		//чем больше, тем хуже
	var/speed_modifier = 0
	var/coolingefficiency = 0.5 // это база // меньше лучше
	var/expensive = 0 ///// 0 - бюджет протезы, 1 - нормальные, 2 - дорогие
	var/addmax_damage
	var/addmin_broken_damage
	var/have_synth_skin = FALSE

	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		rad = ARMOR_RAD_MINOR
	)

/obj/item/organ/external
	var/coolingefficiency
	var/expensive = 0
	var/have_synth_skin = FALSE
	var/synth_skin_health

/mob/living/carbon/human/get_armors_by_zone(obj/item/organ/external/def_zone, damage_type, damage_flags)
	if(!def_zone)
		def_zone = ran_zone()
	if(!istype(def_zone))
		def_zone = get_organ(check_zone(def_zone))
	if(!def_zone)
		return ..()

	. = list()
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/obj/item/clothing/gear in protective_gear)
		if(length(gear.accessories))
			for(var/obj/item/clothing/accessory/bling in gear.accessories)
				if(bling.body_parts_covered & def_zone.body_part)
					var/armor = get_extension(bling, /datum/extension/armor)
					if(armor)
						. += armor
		if(gear.body_parts_covered & def_zone.body_part)
			var/armor = get_extension(gear, /datum/extension/armor)
			if(armor)
				. += armor
	var/obj/item/organ/external/p_limb
	for(var/limb in BP_ALL_LIMBS)
		var/obj/item/organ/external/E = src.get_organ(limb)
		if(def_zone == E)
			p_limb = organs_by_name[limb]
			if(BP_IS_ROBOTIC(p_limb))
				var/datum/extension/armor/prosthetics_armor = get_extension(p_limb, /datum/extension/armor)
				if(prosthetics_armor)
					. += prosthetics_armor
	// Add inherent armor to the end of list so that protective equipment is checked first
	. += ..()

/obj/item/organ/external/robotize(company, skip_prosthetics = 0, keep_organs = 0)
	if(BP_IS_ROBOTIC(src))
		return

	..()

	dislocated = -1
	remove_splint()
	update_icon(1)
	unmutate()

	slowdown = 0
	if(company)
		var/datum/robolimb/R = all_robolimbs[company]
		if(!istype(R) || (species && (species.name in R.species_cannot_use)) || \
			(species && !(species.get_bodytype(owner) in R.allowed_bodytypes)) || \
			(length(R.applies_to_part) && !(organ_tag in R.applies_to_part)))
			R = basic_robolimb
		else
			model = company
			force_icon = R.icon
			name = "robotic [initial(name)]"
			desc = "[R.desc] It looks like it was produced by [R.company]."
		armor = R.armor
		siemens_coefficient = R.siemens_coefficient
		slowdown = R.speed_modifier
		coolingefficiency = R.coolingefficiency
		expensive = R.expensive
		max_damage = max_damage +  R.addmax_damage
		min_broken_damage = min_broken_damage +  R.addmin_broken_damage
		set_extension(src, /datum/extension/armor, armor)
		have_synth_skin = R.have_synth_skin
		if(have_synth_skin)
			synth_skin_health = max_damage

	for(var/obj/item/organ/external/T in children)
		T.robotize(company, 1)

	if(owner)

		if(!skip_prosthetics)
			owner.full_prosthetic = null // Will be rechecked next isSynthetic() call.

		if(!keep_organs)
			for(var/obj/item/organ/thing in internal_organs)
				if(istype(thing))
					if(thing.vital || BP_IS_ROBOTIC(thing))
						continue
					internal_organs -= thing
					owner.internal_organs_by_name[thing.organ_tag] = null
					owner.internal_organs_by_name -= thing.organ_tag
					owner.internal_organs.Remove(thing)
					qdel(thing)

		while(null in owner.internal_organs)
			owner.internal_organs -= null

	CLEAR_FLAGS(status, ORGAN_ARTERY_CUT)

	return 1


/datum/robolimb/bishop
	company = "Bishop"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	unavailable_at_fab = 1

	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
	)
	speed_modifier = - 0.3
	coolingefficiency = 0.3
	expensive = 2

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
	speed_modifier = - 0.2
	coolingefficiency = 0.4
	expensive = 2

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
	expensive = 1
	speed_modifier = 0.5
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
	have_synth_skin = TRUE
	expensive = 2


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
	expensive = 1

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
	has_screen = 2

/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	can_eat = 1
	skintone = 1
	unavailable_at_fab = 1
	expensive = 2
	have_synth_skin = TRUE
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
