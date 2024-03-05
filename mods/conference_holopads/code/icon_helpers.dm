/proc/getFullIcon(atom/A)	//Returns a complete flat icon for all dirs
	if(!A)
		return
	var/icon/complete = icon('icons/effects/effects.dmi', "icon_state"="nothing")
	for(var/currdir in list(NORTH, SOUTH, EAST, WEST))
		var/icon/icon_dir = getFlatIcon(A,currdir,always_use_defdir=1)
		complete.Insert(icon_dir,dir=currdir)
		qdel(icon_dir)
	return complete
