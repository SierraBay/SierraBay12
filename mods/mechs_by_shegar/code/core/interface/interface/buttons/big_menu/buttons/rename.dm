/obj/screen/exosuit/menu_button/rename
	name = "rename"
	icon_state = "rename"


/obj/screen/exosuit/menu_button/rename/activated()
	owner.rename(usr)

/mob/living/exosuit/proc/rename(mob/user)
	if(user != src && !(user in pilots))
		return
	var/new_name = sanitize(input("Enter a new exosuit designation.", "Exosuit Name") as text|null, max_length = MAX_NAME_LEN)
	if(!new_name || new_name == name || (user != src && !(user in pilots)))
		return
	SetName(new_name)
	to_chat(user, SPAN_NOTICE("You have redesignated this exosuit as \the [name]."))
