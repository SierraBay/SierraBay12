/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	..()
	if(!src.isSynthetic() || src.stat == DEAD || src.bodytemperature < 32)
		return
	if(bodytemperature >= getSpeciesOrSynthTemp(HEAT_LEVEL_1))
		var/burn_dam = 0
		if(status_flags & GODMODE)	return TRUE	//godmode
		if(bodytemperature < getSpeciesOrSynthTemp(HEAT_LEVEL_2))
			burn_dam = bodytemperature / 100
		else if(bodytemperature < getSpeciesOrSynthTemp(HEAT_LEVEL_3))
			burn_dam = bodytemperature / 100
		else
			burn_dam = bodytemperature / 100
		var/organ = pick(organs)
		if(burn_dam)
			apply_damage(damage = burn_dam, damagetype = DAMAGE_BURN, used_weapon = "High Body Temperature", armor_pen = 100, silent = TRUE, given_organ = organ)


////////////////////////////
/// сделать радейку и эми параметры тут
///////////////////////////
