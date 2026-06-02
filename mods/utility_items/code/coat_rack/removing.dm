/obj/structure/coatrack/proc/remove_helmet(mob/user)
	if(!helmet)
		return
	if(!user.put_in_active_hand(helmet))
		helmet.dropInto(user.loc)
	helmet = null
	CutOverlays(helmet_image)
	helmet_image = null
