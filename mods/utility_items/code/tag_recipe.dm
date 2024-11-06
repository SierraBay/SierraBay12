/obj/item/paper/use_tool(obj/item/P, mob/living/user, list/click_params)
	. = ..()
	if(istype(P, /obj/item/stack/cable_coil))
		to_chat(user, "You made a tag using \the [src] and \the [P].")
		qdel(src)
		var/tag = new /obj/item/tag
		user.put_in_hands(tag)

/obj/item/tag
	name = "tag"
	var/tagname = null
	icon = 'mods/utility_items/icons/tag.dmi'
	icon_state = "paper"
	item_state = "paper"

/obj/item/tag/attack_self()
	return

/obj/item/tag/use_tool(obj/item/P, mob/living/user, list/click_params)
	. = ..()
	if(istype(P, /obj/item/pen))
		tagname = input(user, "Tag name?","Set tag","")
		if(tagname)
			icon_state = "papertag"

/obj/item/tag/examine(mob/user, distance)
	. = ..()
	if(!tagname)
		to_chat(user, "You see a empty tag.")
	else
		to_chat(user, "You see a tag with the name \"[tagname]\".")

/mob/living/simple_animal/use_tool(obj/item/tag/tool, mob/user, list/click_params)
	. = ..()
	if(istype(tool, /obj/item/tag))
		if(tool.tagname)
			to_chat(user, "You named \the [src] as \"[tool.tagname]\".")
			src.name = tool.tagname
			qdel(tool)
		else
			to_chat(user, "Tag has no name on it")
