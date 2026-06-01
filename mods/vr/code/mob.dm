/mob/living/carbon/human/gib()
	if (has_extension(src, /datum/extension/virtual_surrogate)) // Virtual mobs don't gib
		return death()
	..()

/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	if(M.species.show_ssd && ssd_check())
		var/mob/living/surrogate = SSvirtual_reality.virtual_occupants_to_mobs[M]
		if (surrogate)
			to_chat(surrogate, SPAN_NOTICE(FONT_LARGE("Someone is shaking your body!")))
			surrogate.playsound_local(surrogate.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
	..()

/mob/living/carbon/human/proc/apply_job_equipment()
	var/datum/job/role = SSjobs.get_by_title(job)
	var/list/spawn_in_storage

	var/alt_title = null
	if(mind)
		alt_title = mind.role_alt_title

	delete_inventory(TRUE)

	for (var/obj/item/organ/internal/augment/custom_augment in contents)
		custom_augment.removed(src)
		qdel(custom_augment)

	role.equip(src, mind ? mind.role_alt_title : "", char_branch, char_rank)
	spawn_in_storage = SSjobs.equip_custom_loadout(src, role)

	var/mob/other_mob = role.handle_variant_join(src, alt_title)
	if(other_mob)
		role.post_equip_rank(other_mob, alt_title)
		return other_mob

	if (spawn_in_storage)
		for(var/datum/gear/G in spawn_in_storage)
			G.spawn_in_storage_or_drop(src, client.prefs.Gear()[G.display_name])

/obj/item/organ/internal/brain/removed(mob/living/user)
	if (has_extension(owner, /datum/extension/virtual_surrogate)) // do digital brains dream of electric sheep?
		owner.death()
		..()
		qdel(src)
		return
	..()

/obj/item/organ/internal/brain/handle_severe_brain_damage()
	if (owner && has_extension(owner, /datum/extension/virtual_surrogate)) // Virtual mobs don't get memory loss from brain damage
		return
	..()

/singleton/species
	var/show_vr = "apparently unaware of their surroundings, only responding to stimuli that you can't see"

/singleton/species/proc/get_vr(mob/living/carbon/human/H)
	return ((H && H.isSynthetic()) ? "flashing a 'system occupied' glyph on their monitor" : show_vr)

/mob/living/Destroy()
	if (has_extension(src, /datum/extension/virtual_surrogate))
		death()
	..()

/datum/mind/transfer_to(mob/living/new_character)
	if (current && has_extension(current, /datum/extension/virtual_surrogate))
		var/mob/M = SSvirtual_reality.virtual_mobs_to_occupants[current]
		if(M && M != new_character)
			SSvirtual_reality.remove_virtual_mob(current)
			return
	..()