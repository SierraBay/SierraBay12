/mob/living/carbon/human/update_body(update_icons=1)

	//Update all limbs and visible organs one by one
	var/list/needs_update = list()
	var/limb_count_update = FALSE
	var/list/missing_bodyparts = list()

	for(var/organ_tag in species.has_limbs)
		var/obj/item/organ/external/limb = organs_by_name[organ_tag]
		if(!isnull(limb))
			var/old_key = icon_render_keys?[organ_tag] //Checks the mob's icon render key list for the bodypart
			var/new_key = json_encode(limb.get_icon_key()) //Generates a key for the current bodypart
			icon_render_keys[organ_tag] = new_key

			if(icon_render_keys[organ_tag] != old_key) //If the keys match, that means the limb doesn't need to be redrawn
				needs_update += limb
		else
			//Limb is missing?
			missing_bodyparts += organ_tag
			limb_count_update = TRUE

	for(var/missing_limb in missing_bodyparts)
		icon_render_keys -= missing_limb

	if(length(needs_update) || limb_count_update)
		//GENERATE NEW LIMBS
		var/list/new_limbs = list()
		for(var/obj/item/organ/external/limb in organs)
			if(limb in needs_update)
				var/list/limb_overlays = limb.get_overlays()
				GLOB.limb_overlays_cache[icon_render_keys[limb.organ_tag]] = limb_overlays
				new_limbs += limb_overlays
			else
				new_limbs += GLOB.limb_overlays_cache[icon_render_keys[limb.organ_tag]]

		if(length(new_limbs))
			overlays_standing[HO_BODY_LAYER] = new_limbs

	update_tail_showing(0)

	if(update_icons)
		queue_icon_update()
