1
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

/datum/gear_tweak/hand
    var/list/valid_hands
    var/list/last_metadata = list("hand" = null)

/datum/gear_tweak/hand/New(list/hands)
    valid_hands = hands

/datum/gear_tweak/hand/get_contents(list/metadata)
    var/hand = islist(metadata) && metadata["hand"] && (metadata["hand"] in valid_hands) ? metadata["hand"] : valid_hands[1]
    return "Slot: [hand]"

/datum/gear_tweak/hand/get_metadata(mob/user, metadata, title)
    var/hand = input(user, "Choose a slot for the augment installation.", title) as null|anything in valid_hands
    if(!hand)
        hand = islist(metadata) && metadata["hand"] && (metadata["hand"] in valid_hands) ? metadata["hand"] : valid_hands[1]
    last_metadata["hand"] = hand
    if(user?.client?.prefs)
        var/datum/preferences/P = user.client.prefs
        if(!P.gear_list[P.gear_slot])
            P.gear_list[P.gear_slot] = list()
        if(!P.gear_list[P.gear_slot][title])
            P.gear_list[P.gear_slot][title] = list()
        P.gear_list[P.gear_slot][title]["hand"] = hand
        P.save_preferences()
    return list("hand" = hand)

/datum/gear_tweak/hand/tweak_gear_data(metadata, list/gear_data)
    var/hand = null
    if(islist(metadata) && islist(metadata["/datum/gear_tweak/hand"]))
        hand = metadata["/datum/gear_tweak/hand"]["hand"]
    else if(islist(metadata) && metadata["hand"])
        hand = metadata["hand"]
    gear_data["hand"] = (hand && (hand in valid_hands)) ? hand : valid_hands[1]

/datum/gear/augment/toolset_engineer
    display_name = "Integrated engineering toolset (Prosthetic)"
    description = "A lightweight augmentation for the engineer on-the-go. This one comes with a series of common tools."
    path = /obj/item/organ/internal/augment/active/polytool/engineer
    cost = 6
    allowed_roles = list(/datum/job/chief_engineer, /datum/job/senior_engineer, /datum/job/engineer, /datum/job/infsys, /datum/job/roboticist, /datum/job/engineer_trainee, /datum/job/explorer_engineer, /datum/job/rd, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist)

/datum/gear/augment/toolset_engineer/New()
    ..()
    gear_tweaks += new /datum/gear_tweak/hand(list(BP_L_HAND, BP_R_HAND))

/datum/gear/augment/toolset_engineer/spawn_item(mob/living/carbon/human/M, metadata)
    var/list/tweak_data = list()
    var/default_hand = BP_R_HAND
    if(!islist(metadata) && M?.client?.prefs)
        var/list/gear_metadata = M.client.prefs.gear_list[M.client.prefs.gear_slot]?[display_name]
        if(islist(gear_metadata))
            metadata = gear_metadata
        else
            metadata = list()
    for(var/datum/gear_tweak/T in gear_tweaks)
        T.tweak_gear_data(metadata, tweak_data)
    var/hand = tweak_data["hand"] || default_hand
    if(!(hand in list(BP_L_HAND, BP_R_HAND)))
        return FALSE
    var/obj/item/organ/external/hand_organ = M.get_organ(hand)
    if(!hand_organ)
        return FALSE
    var/list/hand_augment_tags = list("[hand]_eng_aug", "[hand]_surg_aug")
    for(var/tag in hand_augment_tags)
        if(M.internal_organs_by_name[tag])
            return FALSE
    var/augment_tag = "[hand]_eng_aug"
    var/obj/item/organ/internal/augment/aug = new path()
    aug.parent_organ = hand
    aug.organ_tag = augment_tag
    if(!aug.replaced(M, hand_organ))
        M.internal_organs |= aug
        M.internal_organs_by_name[augment_tag] = aug
    return TRUE

/datum/gear/augment/toolset_surgical
    display_name = "Integrated surgical toolset (Prosthetic)"
    description = "Part of Zeng-Hu Pharmaceutical's line of biomedical augmentations, this device contains the full set of tools any surgeon would ever need."
    path = /obj/item/organ/internal/augment/active/polytool/surgical
    cost = 6
    allowed_roles = list(/datum/job/rd, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist, /datum/job/roboticist, /datum/job/cmo, /datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/explorer_medic)

/datum/gear/augment/toolset_surgical/New()
    ..()
    gear_tweaks += new /datum/gear_tweak/hand(list(BP_L_HAND, BP_R_HAND))

/datum/gear/augment/toolset_surgical/spawn_item(mob/living/carbon/human/M, metadata)
    var/list/tweak_data = list()
    var/default_hand = BP_L_HAND
    if(!islist(metadata) && M?.client?.prefs)
        var/list/gear_metadata = M.client.prefs.gear_list[M.client.prefs.gear_slot]?[display_name]
        if(islist(gear_metadata))
            metadata = gear_metadata
        else
            metadata = list()
    for(var/datum/gear_tweak/T in gear_tweaks)
        T.tweak_gear_data(metadata, tweak_data)
    var/hand = tweak_data["hand"] || default_hand
    if(!(hand in list(BP_L_HAND, BP_R_HAND)))
        return FALSE
    var/obj/item/organ/external/hand_organ = M.get_organ(hand)
    if(!hand_organ)
        return FALSE
    var/list/hand_augment_tags = list("[hand]_eng_aug", "[hand]_surg_aug")
    for(var/tag in hand_augment_tags)
        if(M.internal_organs_by_name[tag])
            return FALSE
    var/augment_tag = "[hand]_surg_aug"
    var/obj/item/organ/internal/augment/aug = new path()
    aug.parent_organ = hand
    aug.organ_tag = augment_tag
    if(!aug.replaced(M, hand_organ))
        M.internal_organs |= aug
        M.internal_organs_by_name[augment_tag] = aug
    return TRUE

/datum/gear/augment/circuit
    display_name = "Integrated circuit frame (Prosthetic)"
    description = "A DIY modular assembly for advanced circuitry, courtesy of Xion Industrial. Circuitry not included."
    path = /obj/item/organ/internal/augment/active/item/circuit
    cost = 4

/datum/gear/augment/circuit/New()
    ..()
    gear_tweaks += new /datum/gear_tweak/hand(list(BP_L_ARM, BP_R_ARM))

/datum/gear/augment/circuit/spawn_item(mob/living/carbon/human/M, metadata)
    var/list/tweak_data = list()
    var/default_hand = BP_R_ARM
    if(!islist(metadata) && M?.client?.prefs)
        var/list/gear_metadata = M.client.prefs.gear_list[M.client.prefs.gear_slot]?[display_name]
        if(islist(gear_metadata))
            metadata = gear_metadata
        else
            metadata = list()
    for(var/datum/gear_tweak/T in gear_tweaks)
        T.tweak_gear_data(metadata, tweak_data)
    var/hand = tweak_data["hand"] || default_hand
    if(!(hand in list(BP_L_ARM, BP_R_ARM)))
        return FALSE
    var/obj/item/organ/external/arm_organ = M.get_organ(hand)
    if(!arm_organ || !(arm_organ.status & ORGAN_ROBOTIC))
        return FALSE
    var/augment_tag = "[hand]_circ_aug"
    if(M.internal_organs_by_name[augment_tag])
        return FALSE
    var/obj/item/organ/internal/augment/aug = new path()
    aug.parent_organ = hand
    aug.organ_tag = augment_tag
    if(!aug.replaced(M, arm_organ))
        M.internal_organs |= aug
        M.internal_organs_by_name[augment_tag] = aug
    return TRUE

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
