/mob/living/carbon/human/proc/process_spawn_augments(datum/preferences/input_prefs)
	var/datum/preferences/prefs
	if(input_prefs)
		prefs = input_prefs
	else
		prefs = client.prefs

	for(var/augment in prefs.augments_list)
		var/aug_singl_type = prefs.augments_list[augment]
		if(aug_singl_type == "Пусто")
			continue
		var/singleton/cyber_choose/augment/augment_choose_prototype = GET_SINGLETON(text2path(aug_singl_type))
		var/aug_type = augment_choose_prototype.instal_aug_type
		if(!augment_choose_prototype || !aug_type)
			continue
		var/obj/item/organ/internal/augment/install_aug = new aug_type(src)
		var/obj/item/organ/external/parent = install_aug.get_valid_parent_organ(src)
		var/surgery_step = GET_SINGLETON(/singleton/surgery_step/internal/replace_organ)
		if(install_aug.surgery_configure(src, src, parent, null, surgery_step))
			to_chat(src, SPAN_BAD("ХЭЙ! Мы пытались установить вам [install_aug.name], но у нас не вышло!"))
			qdel(install_aug)
			continue
		install_aug.forceMove(src)
		install_aug.replaced(src, parent)
		install_aug.onRoundstart()

		if(prefs.augments_names[augment] != "Пусто")
			install_aug.name = prefs.augments_names[augment]
		if(prefs.augments_descs[augment] != "Пусто")
			install_aug.desc = prefs.augments_descs[augment]







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
