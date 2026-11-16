/obj/item/robot_parts/l_hand
	name = "left hand"
	desc = "A skeletal prosthetic hand wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list(BP_L_HAND)
	model_info = 1
	bp_tag = BP_L_HAND
	w_class = ITEM_SIZE_SMALL

/obj/item/robot_parts/r_hand
	name = "right hand"
	desc = "A skeletal prosthetic hand wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list(BP_R_HAND)
	model_info = 1
	bp_tag = BP_R_HAND
	w_class = ITEM_SIZE_SMALL

/obj/item/robot_parts/l_foot
	name = "left foot"
	desc = "A skeletal prosthetic foot wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list(BP_L_FOOT)
	model_info = 1
	bp_tag = BP_L_FOOT
	w_class = ITEM_SIZE_SMALL

/obj/item/robot_parts/r_foot
	name = "right foot"
	desc = "A skeletal prosthetic foot wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list(BP_R_FOOT)
	model_info = 1
	bp_tag = BP_R_FOOT
	w_class = ITEM_SIZE_SMALL

/obj/item/robot_parts/proc/get_robolimb_icon_state()
	switch (bp_tag)
		if (BP_CHEST)
			return "torso"
		if (BP_GROIN)
			return "groin"
		if (BP_HEAD)
			return "head"
		if (BP_L_ARM)
			return "l_arm"
		if (BP_R_ARM)
			return "r_arm"
		if (BP_L_LEG)
			return "l_leg"
		if (BP_R_LEG)
			return "r_leg"
		if (BP_L_HAND)
			return "l_hand"
		if (BP_R_HAND)
			return "r_hand"
		if (BP_L_FOOT)
			return "l_foot"
		if (BP_R_FOOT)
			return "r_foot"
	return icon_state

/obj/item/robot_parts/proc/apply_robolimb_appearance()
	if (!istext(model_info))
		return
	var/datum/robolimb/R = all_robolimbs[model_info]
	if (!istype(R))
		return
	var/state = get_robolimb_icon_state()
	if (state in icon_states(R.icon))
		icon = R.icon
		icon_state = state

/obj/item/prosthetic_kit
	name = "prosthetic kit"
	desc = "A sealed requisition case. Use it in hand to unpack a single prosthetic part."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "box"
	item_state = "syringe_kit"
	w_class = ITEM_SIZE_NORMAL
	var/manufacturer

/obj/item/prosthetic_kit/Initialize(mapload, company)
	. = ..()
	if (company)
		manufacturer = company
	if (manufacturer)
		SetName("[manufacturer] prosthetic kit")
		desc = "A sealed requisition case from [manufacturer]. Use it in hand to unpack a single prosthetic part of that brand."

/obj/item/prosthetic_kit/attack_self(mob/user)
	var/list/choices = list(
		"Left arm" = /obj/item/organ/external/arm,
		"Right arm" = /obj/item/organ/external/arm/right,
		"Left hand" = /obj/item/organ/external/hand,
		"Right hand" = /obj/item/organ/external/hand/right,
		"Left leg" = /obj/item/organ/external/leg,
		"Right leg" = /obj/item/organ/external/leg/right,
		"Left foot" = /obj/item/organ/external/foot,
		"Right foot" = /obj/item/organ/external/foot/right,
		"Head" = /obj/item/organ/external/head,
		"Torso" = /obj/item/organ/external/chest,
		"Groin" = /obj/item/organ/external/groin
	)
	var/choice = input(user, "Select a prosthetic part to unpack.", name) as null|anything in choices
	if (!choice || !user.use_sanity_check(src))
		return
	var/part_path = choices[choice]
	var/obj/item/organ/external/part = new part_path(get_turf(user))
	part.robotize(manufacturer)
	part.status |= ORGAN_CUT_AWAY
	user.visible_message(
		SPAN_NOTICE("[user] unpacks \a [part] from \the [src]."),
		SPAN_NOTICE("You unpack \a [part] from \the [src].")
	)
	qdel(src)
	user.put_in_hands(part)
