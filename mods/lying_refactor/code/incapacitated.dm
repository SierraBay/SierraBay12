#define PARTIALLY_BUCKLED 1
#define FULLY_BUCKLED 2

/mob/incapacitated(incapacitation_flags = INCAPACITATION_DEFAULT)
	if((incapacitation_flags & INCAPACITATION_RESTING) && resting)
		return TRUE

	if((incapacitation_flags & (INCAPACITATION_BUCKLED_PARTIALLY|INCAPACITATION_BUCKLED_FULLY)))
		var/buckling = buckled()
		if(buckling >= PARTIALLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_PARTIALLY))
			return TRUE
		if(buckling == FULLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_FULLY))
			return TRUE

	if((incapacitation_flags & INCAPACITATION_FORCELYING) && (weakened || LAZYLEN(pinned)))
		return TRUE

	if((incapacitation_flags & INCAPACITATION_STUNNED) && stunned)
		return TRUE

	if((incapacitation_flags & INCAPACITATION_RESTRAINED) && restrained())
		return TRUE
	if((incapacitation_flags & INCAPACITATION_KNOCKOUT) && (stat || paralysis || sleeping || (status_flags & FAKEDEATH)))
		return TRUE

	return FALSE


#undef PARTIALLY_BUCKLED
#undef FULLY_BUCKLED
