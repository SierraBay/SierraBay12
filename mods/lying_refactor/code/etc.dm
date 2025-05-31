
//ЧУДО из чудес, мобики могут взаимодействовать с предметами даже лёжа

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/put_in_l_hand(obj/item/W)
	if(!istype(W))
		return FALSE
	return TRUE

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/put_in_r_hand(obj/item/W)
	if(!istype(W))
		return FALSE
	return TRUE

/mob/is_physically_disabled()
	// Основная проверка: заблокированы ли действия
	if(incapacitated(INCAPACITATION_ACTION_BLOCKED))
		return TRUE

	return FALSE

/mob/cannot_stand()
	return incapacitated(INCAPACITATION_KNOCKDOWN | INCAPACITATION_BUCKLED_FULLY | INCAPACITATION_WEAKENED)
