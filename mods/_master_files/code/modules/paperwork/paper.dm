/obj/item/paper/show_content(mob/user, force, editable)
	if(user)
		get_asset_datum(/datum/asset/simple/paper).send(user)
	return ..()
