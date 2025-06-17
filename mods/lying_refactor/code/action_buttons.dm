/datum/action/Checks()// returns 1 if all checks pass
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned)
			return 0
	if(check_flags & AB_CHECK_ALIVE)
		if(owner.stat)
			return 0
	if(check_flags & AB_CHECK_INSIDE)
		if(!(target in owner))
			return 0
	if(check_flags & AB_CHECK_INSIDE_ACCESSORY)
		if(!(target in owner))
			var/obj/item/clothing/C = target.loc
			if (!(istype(C) && (C in owner) && (target in C.accessories)))
				return 0
	return 1
