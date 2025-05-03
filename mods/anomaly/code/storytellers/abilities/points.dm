/datum/storyteller_ability/proc/can_afford()
	if(!owner)
		return FALSE

	switch(point_type)
		if("scam")
			return owner.current_scam_points >= point_price
		if("anomaly")
			return owner.current_anomaly_points >= point_price
		if("mob")
			return owner.current_mob_points >= point_price
	return FALSE

/datum/storyteller_ability/proc/spend_points()
	if(!owner)
		return

	switch(point_type)
		if("scam")
			owner.current_scam_points -= point_price
		if("anomaly")
			owner.current_anomaly_points -= point_price
		if("mob")
			owner.current_mob_points -= point_price
