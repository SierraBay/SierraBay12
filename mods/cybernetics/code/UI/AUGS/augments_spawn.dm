/mob/living/carbon/human/proc/process_spawn_augments()
	for(var/augment in client.prefs.augments_list)
		var/aug_singl_type = client.prefs.augments_list[augment]
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
