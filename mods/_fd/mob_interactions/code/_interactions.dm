#define SPECIES_HAS_TAIL	list(SPECIES_VOX, SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_RESOMI)
#define SPECIES_NO_MOUTH	list(SPECIES_DIONA)
#define SPECIES_NO_EARS		list(SPECIES_IPC, SPECIES_UNATHI, SPECIES_YEOSA)

// --- User procs --- //

/mob/living/carbon/human/verb/interact(atom/target as mob)
	set name = "Interact"
	set category = "IC"

	if(target == src)
		to_chat(src, SPAN_WARNING("Вы не можете взаимодействовать сам с собой!"))
		return

	target.get_interactions(src)

/mob/living/carbon/human/MouseDrop(atom/target)
	. = ..()

	if(target == src)
		return

	if(usr != src)
		return

	target.get_interactions(src)

// --- Interactee procs --- //

/mob/OnTopic(mob/living/carbon/human/user, href_list)
	. = ..()
	if(.)
		return .

	if(!href_list["interaction"])
		return TOPIC_REFRESH

	if(world.time <= user.last_attack + 1 SECONDS)
		return TOPIC_REFRESH

	if(!(src in viewers(user)))
		return TOPIC_REFRESH

	var/message = on_interaction(user, href_list["interaction"])
	if(!message)
		return TOPIC_REFRESH

	user.face_atom(src)
	user.last_attack = world.time

	user.visible_message(message)
	if(istype(user.loc, /obj/structure/closet) && user.loc == loc)
		visible_message(message)

	return TOPIC_HANDLED

/mob/proc/on_interaction(mob/living/carbon/human/user, interaction, message)
	return

/* Interaction panel */
/atom/proc/get_interactions()
	return

/mob/get_interactions(mob/living/carbon/human/user, data = list())
	if(!istype(user))
		return

	var/content_data
	for(var/i in data)
		if(!isnull(i))
			content_data += {"<font size=3><B>[i]:</B></font><BR>"}
		for(var/I in data[i])
			content_data += {"• <A href='?src=\ref[src];interaction=[I]</A><BR>"}

	var/datum/browser/popup = new(usr, "interactions", "Взаимодействия - [src]", 380, 480)
	popup.set_content(content_data)
	popup.open()

	return content_data
