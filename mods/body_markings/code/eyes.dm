/obj/item/organ/external/head/get_icon_key()
	. = ..()

	if(owner?.makeup_style && !BP_IS_ROBOTIC(src) && (species && (species.appearance_flags & SPECIES_APPEARANCE_HAS_LIPS)))
		. += "[owner.makeup_style]"
	else
		. += "nolips"

	var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[owner.species.vision_organ ? owner.species.vision_organ : BP_EYES]
	if(eyes)
		. += "[rgb(eyes.eye_colour[1], eyes.eye_colour[2], eyes.eye_colour[3])]"

	for(var/datum/sprite_accessory/marking/eye_marking as anything in markings)
		if(eye_marking.draw_target == MARKING_TARGET_EYES)
			. += "-[eye_marking.name][markings[eye_marking]]"

/obj/item/organ/external/head/on_update_icon()
	..()

	if(owner)
		if(draw_eyes)
			var/icon/I = get_eyes()
			if(I)
				var/mutable_appearance/eye_appearance = mutable_appearance(I, flags = DEFAULT_APPEARANCE_FLAGS)
				mob_overlays |= eye_appearance
			for(var/mutable_appearance/eye_marking as anything in get_eye_marking_overlays())
				mob_overlays |= eye_marking

			var/image/eye_glow = get_eye_overlay()
			if(eye_glow)
				AddOverlays(eye_glow)

		if(owner.makeup_style && !BP_IS_ROBOTIC(src) && (species && (species.appearance_flags & SPECIES_APPEARANCE_HAS_LIPS)))
			var/mutable_appearance/lip_appearance = mutable_appearance('icons/mob/human_races/species/human/lips.dmi', "lips_[owner.makeup_style]_s", flags = DEFAULT_APPEARANCE_FLAGS)
			mob_overlays |= lip_appearance

	SetOverlays(mob_overlays)
	var/hair_icon = get_hair_icon()
	AddOverlays(hair_icon)

/obj/item/organ/external/head/proc/get_eye_marking_overlays()
	var/list/sorted = list()
	for(var/datum/sprite_accessory/marking/M as anything in markings)
		if(M.draw_target != MARKING_TARGET_EYES)
			continue
		var/icon/I = icon(M.icon, M.icon_state)
		var/list/rgb = rgb2num(markings[M])
		if(length(rgb) < 3)
			continue
		I.MapColors(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
			rgb[1] / 255, rgb[2] / 255, rgb[3] / 255, 0
		)
		ADD_SORTED(sorted, list(list(M.draw_order, I)), GLOBAL_PROC_REF(cmp_marking_order))
	var/list/result = list()
	for(var/entry in sorted)
		result += mutable_appearance(entry[2], flags = DEFAULT_APPEARANCE_FLAGS)
	return result
