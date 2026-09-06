/obj/structure/coatrack/proc/remove_suit(mob/user)
	//Данные могли измениться, если сразу несколько игроков будут взаимодействовать
	if(!suit)
		return
	if(!user.put_in_active_hand(suit))
		suit.dropInto(user.loc)
	suit = null
	CutOverlays(suit_image)
	suit_image = null



/obj/structure/coatrack/proc/remove_helmet(mob/user)
	if(!helmet)
		return
	if(!user.put_in_active_hand(helmet))
		helmet.dropInto(user.loc)
	helmet = null
	CutOverlays(helmet_image)
	helmet_image = null
