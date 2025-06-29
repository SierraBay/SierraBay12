/datum/gear/augment
	sort_category = "Augments"
	category = /datum/gear/augment
	cost = 2

/datum/gear/augment/muscle_boost
	display_name = "Mechanical muscles"
	description = "Nanofiber tendons powered by an array of actuators increase the speed and agility of the user. You may want to install these in pairs to see a result."
	path = /obj/item/organ/internal/augment/boost/muscle
	cost = 8
	flags = GEAR_HAS_NO_CUSTOMIZATION

/datum/gear/augment/muscle_boost/spawn_item(mob/living/carbon/human/M, datum/gear_data/gear_data)
	var/success = FALSE
	var/obj/item/organ/external/left_leg = M.get_organ(BP_L_LEG)
	var/obj/item/organ/external/right_leg = M.get_organ(BP_R_LEG)
	if(left_leg)
		var/obj/item/organ/internal/augment/boost/muscle/left_muscle = new path()
		left_muscle.organ_tag = "muscle_boost_l_leg"
		left_muscle.parent_organ = BP_L_LEG
		if(left_muscle.replaced(M, left_leg))
			success = TRUE
		else
			M.internal_organs |= left_muscle
			M.internal_organs_by_name[left_muscle.organ_tag] = left_muscle
			success = TRUE
	if(right_leg)
		var/obj/item/organ/internal/augment/boost/muscle/right_muscle = new path()
		right_muscle.organ_tag = "muscle_boost_r_leg"
		right_muscle.parent_organ = BP_R_LEG
		if(right_muscle.replaced(M, right_leg))
			success = TRUE
		else
			M.internal_organs |= right_muscle
			M.internal_organs_by_name[right_muscle.organ_tag] = right_muscle
			success = TRUE
	return success

/datum/gear/augment/vision
	display_name = "Adaptive binoculars"
	description = "Digital glass 'screens' can be deployed over the eyes. At the user's control, their image can be greatly enhanced, providing a view of distant areas."
	path = /obj/item/organ/internal/augment/active/item/adaptive_binoculars
	cost = 8
	flags = GEAR_HAS_NO_CUSTOMIZATION

/datum/gear/augment/head
	display_name = "Iatric monitor"
	description = "A small computer system constantly tracks your physiological state and vital signs. A muscle gesture can be used to receive a simple diagnostic report, not unlike that from a handheld scanner."
	path = /obj/item/organ/internal/augment/active/iatric_monitor
	cost = 6
	flags = GEAR_HAS_NO_CUSTOMIZATION

/datum/gear/augment/chest
	display_name = "Subdermal armour"
	description = "A flexible composite mesh designed to prevent tearing and puncturing of underlying tissue."
	path = /obj/item/organ/internal/augment/armor
	cost = 8
	allowed_roles = list(/datum/job/captain, /datum/job/hop, /datum/job/rd, /datum/job/cmo, /datum/job/chief_engineer, /datum/job/hos, /datum/job/iaa, /datum/job/iso, /datum/job/adjutant)

/datum/gear/augment/chest_air_system
	display_name = "Internal air system"
	description = "A flexible air sac, made from a complex, bio-compatible polymer, is installed into the respiratory system. It gradually replenishes itself with breathable gas from the surrounding environment as you breathe, and you can later use it as a source of internals."
	path = /obj/item/organ/internal/augment/active/internal_air_system
	cost = 6
	allowed_roles = list(/datum/job/chief_engineer, /datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys, /datum/job/engineer_trainee, /datum/job/explorer_engineer, /datum/job/captain, /datum/job/hop, /datum/job/rd, /datum/job/cmo, /datum/job/chief_engineer, /datum/job/hos, /datum/job/iaa, /datum/job/iso, /datum/job/adjutant)

/datum/gear/augment/toolset_engineer
	display_name = "Integrated engineering toolset (Prosthetic)"
	description = "A lightweight augmentation for the engineer on-the-go. This one comes with a series of common tools."
	path = /obj/item/organ/internal/augment/active/polytool/engineer
	cost = 6
	allowed_roles = list(/datum/job/chief_engineer, /datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys, /datum/job/roboticist, /datum/job/engineer_trainee, /datum/job/explorer_engineer, /datum/job/rd, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist)

/datum/gear/augment/toolset_engineer/New()
	..()
	var/list/options = list()
	options["left hand"] = /obj/item/organ/internal/augment/active/polytool/engineer/left
	options["right hand"] = /obj/item/organ/internal/augment/active/polytool/engineer/right
	gear_tweaks += new /datum/gear_tweak/path(options)

/obj/item/organ/internal/augment/active/polytool/engineer/left
	name = "left hand engineering polytool"
	parent_organ = BP_L_HAND
	organ_tag = "l_hand_aug"

/obj/item/organ/internal/augment/active/polytool/engineer/right
	name = "right hand engineering polytool"
	parent_organ = BP_R_HAND
	organ_tag = "r_hand_aug"

/datum/gear/augment/toolset_surgical
	display_name = "Integrated surgical toolset (Prosthetic)"
	description = "Part of Zeng-Hu Pharmaceutical's line of biomedical augmentations, this device contains the full set of tools any surgeon would ever need."
	path = /obj/item/organ/internal/augment/active/polytool/surgical
	cost = 6
	allowed_roles = list(/datum/job/rd, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist, /datum/job/roboticist, /datum/job/cmo, /datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/explorer_medic)

/datum/gear/augment/toolset_surgical/New()
	..()
	var/list/options = list()
	options["left hand"] = /obj/item/organ/internal/augment/active/polytool/surgical/left
	options["right hand"] = /obj/item/organ/internal/augment/active/polytool/surgical/right
	gear_tweaks += new /datum/gear_tweak/path(options)

/obj/item/organ/internal/augment/active/polytool/surgical/left
	name = "left hand surgical polytool"
	parent_organ = BP_L_HAND
	organ_tag = "l_hand_aug"

/obj/item/organ/internal/augment/active/polytool/surgical/right
	name = "right hand surgical polytool"
	parent_organ = BP_R_HAND
	organ_tag = "r_hand_aug"

/datum/gear/augment/circuit
	display_name = "Integrated circuit frame (Prosthetic)"
	description = "A DIY modular assembly for advanced circuitry, courtesy of Xion Industrial. Circuitry not included."
	path = /obj/item/organ/internal/augment/active/item/circuit
	cost = 4

/datum/gear/augment/circuit/New()
	..()
	var/list/options = list()
	options["left arm"] = /obj/item/organ/internal/augment/active/item/circuit/left
	options["right arm"] = /obj/item/organ/internal/augment/active/item/circuit/right
	gear_tweaks += new /datum/gear_tweak/path(options)

/obj/item/organ/internal/augment/active/item/circuit/left
	name = "left arm circuit frame"
	parent_organ = BP_L_ARM
	organ_tag = "l_arm_aug"

/obj/item/organ/internal/augment/active/item/circuit/right
	name = "right arm circuit frame"
	parent_organ = BP_R_ARM
	organ_tag = "r_arm_aug"

#define ORGAN_STYLE ( \
  (organ.status & ORGAN_ROBOTIC) ? 1 \
: (organ.status & ORGAN_CRYSTAL) ? 2 \
: 0 \
)

#define ORGAN_STYLE_OK ( \
   style == 0 && (augment_flags & AUGMENT_BIOLOGICAL) \
|| style == 1 && (augment_flags & AUGMENT_MECHANICAL) \
|| style == 2 && (augment_flags & AUGMENT_CRYSTALINE) \
)

/obj/item/organ/internal/augment/get_valid_parent_organ(mob/living/carbon/subject)
	if (!istype(subject))
		return
	var/style
	var/obj/item/organ/external/organ
	var/list/organs = subject.organs_by_name
	if ((augment_slots & AUGMENT_CHEST) && !organs["[BP_CHEST]_aug"] && (organ = organs[BP_CHEST]))
		style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
	if ((augment_slots & AUGMENT_ARMOR) && !organs["[BP_CHEST]_aug_armor"] && (organ = organs[BP_CHEST]))
		style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
	if ((augment_slots & AUGMENT_GROIN) && !organs["[BP_GROIN]_aug"] && (organ = organs[BP_GROIN]))
		style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
	if ((augment_slots & AUGMENT_HEAD) && !organs["[BP_HEAD]_aug"] && (organ = organs[BP_HEAD]))
		style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
	if ((augment_slots & AUGMENT_EYES) && !organs["[BP_HEAD]_aug_eyes"] && (organ = organs[BP_HEAD]))
		style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
	if ((augment_slots & AUGMENT_FLUFF) && !organs["[BP_HEAD]_aug_fluff"] && (organ = organs[BP_HEAD]))
		style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
	if (augment_slots & AUGMENT_ARM)
		if((parent_organ == BP_L_ARM || parent_organ == BP_R_ARM) && !organs["[parent_organ]_aug"] && (organ = organs[parent_organ]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_L_ARM]_aug"] && (organ = organs[BP_L_ARM]))
			style = ORGAN_STYLE
		if (ORGAN_STYLE_OK)
			return organ
		if (!organs["[BP_R_ARM]_aug"] && (organ = organs[BP_R_ARM]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
	if (augment_slots & AUGMENT_HAND)
		if((parent_organ == BP_L_HAND || parent_organ == BP_R_HAND) && !organs["[parent_organ]_aug"] && (organ = organs[parent_organ]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_L_HAND]_aug"] && (organ = organs[BP_L_HAND]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_R_HAND]_aug"] && (organ = organs[BP_R_HAND]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
	if (augment_slots & AUGMENT_LEG)
		if((parent_organ == BP_L_LEG || parent_organ == BP_R_LEG) && !organs["[parent_organ]_aug"] && (organ = organs[parent_organ]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_L_LEG]_aug"] && (organ = organs[BP_L_LEG]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_R_LEG]_aug"] && (organ = organs[BP_R_LEG]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
	if (augment_slots & AUGMENT_FOOT)
		if((parent_organ == BP_L_FOOT || parent_organ == BP_R_FOOT) && !organs["[parent_organ]_aug"] && (organ = organs[parent_organ]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_L_FOOT]_aug"] && (organ = organs[BP_L_FOOT]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ
		if (!organs["[BP_R_FOOT]_aug"] && (organ = organs[BP_R_FOOT]))
			style = ORGAN_STYLE
			if (ORGAN_STYLE_OK)
				return organ

#undef ORGAN_STYLE_OK
#undef ORGAN_STYLE

/obj/item/device/electronic_assembly/augment/afterattack(atom/target, mob/living/user, proximity)
	if(!proximity)
		return
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/E = H.get_organ(user.zone_sel.selecting)
		if(E && (E.organ_tag in list(BP_L_ARM, BP_R_ARM)))
			for(var/obj/item/organ/internal/augment/active/item/circuit/A in E.internal_organs)
				if(A.use_tool(src, user, list()))
					return TRUE
			to_chat(user, SPAN_WARNING("No compatible augment found in [E.name]."))
			return TRUE
	return ..()
