/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(ooc_notes)
		to_chat(usr, "[src]'s Metainfo:<br>[ooc_notes]")
	else if(client)
		to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
	else
		to_chat(usr, "[src] does not have any stored infomation!")

	return

/mob/living
	var/ooc_notes = null

/datum/preferences/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	..()
	character.ooc_notes = metadata

/mob/living/carbon/human/OnTopic(mob/user, href_list)
	if(href_list["ooc_notes"])
		src.Examine_OOC()
		return TOPIC_HANDLED
	..()

/datum/category_item/player_setup_item/physical/flavor/content(mob/user)
	. = ..()
	. += "<a href='?src=\ref[src];metadata=1'>Set OOC notes</a><br/>"

/datum/category_item/player_setup_item/physical/flavor/OnTopic(href,list/href_list, mob/user)
	if(href_list["metadata"])
		var/new_metadata = sanitize(input(user, "Введите информация о себе, которую смогут увидеть другие игроки в описании персонажа. Например, Вы можете написать пожелания относительно того, хотите ли оказаться жертвой антагониста или ролевые предпочтения.", "Игровые предпочтения" , pref.metadata) as message|null)
		if(new_metadata && CanUseTopic(user))
			pref.metadata = new_metadata
		return TOPIC_HANDLED
	..()
