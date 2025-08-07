/obj/item/modular_computer/laptop/AltClick(mob/user)
// In order to not have a full override. Setting laptop dir on alt click, to face the user.
	if(CanPhysicallyInteract(user))
		set_dir(get_dir(src, user))
	..()