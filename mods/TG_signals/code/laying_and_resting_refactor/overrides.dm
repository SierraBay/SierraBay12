/mob/UpdateLyingBuckledAndVerbStatus()
	if(!resting && cannot_stand() && can_stand_overridden())
		set_lying(FALSE)
	else if(buckled)
		anchored = TRUE
		if(istype(buckled))
			if(isnull(buckled.buckle_stance))
				// Используем флаг позиции
				set_lying(incapacitated(INCAPACITATION_POSITION))
			else
				lying = buckled.buckle_stance
			if(buckled.buckle_movable)
				anchored = FALSE
	else
		// Только проверка физического положения
		set_lying(incapacitated(INCAPACITATION_POSITION))

	if(lying)
		set_density(FALSE)
	else
		set_density(initial(density))
	reset_layer()

	for(var/obj/item/grab/G in grabbed_by)
		if(G.force_stand())
			set_lying(new_status = FALSE)
		regenerate_icons()
	if( lying != lying_prev )
		update_icons()

//Recover from stuns.
/mob/changeling_synaptizine_overdose()
	set category = "Changeling"
	set name = "Adrenaline Surge (20)"
	set desc = "Removes all stuns instantly, and reduces future stuns."

	var/datum/changeling/changeling = changeling_power(20,0,100,UNCONSCIOUS)
	if(!changeling)
		return FALSE
	changeling.chem_charges -= 20

	var/mob/living/carbon/human/C = src
	to_chat(C, "<span class='notice'>Energy rushes through us.  [C.lying ? "We arise." : ""]</span>")
	C.set_stat(CONSCIOUS)
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetWeakened(0)
	C.setHalLoss(0)
	C.set_lying(new_status = FALSE)
	C.blinded = 0
	C.eye_blind = 0
	C.eye_blurry = 0
	C.ear_deaf = 0
	C.ear_damage = 0
	C.clear_confused()
	C.sleeping = 0
//	C.reagents.add_reagent("toxin", 10)
	C.reagents.add_reagent("synaptizine", 10)

	if(src.mind.changeling.recursive_enhancement)
		src.mind.changeling.recursive_enhancement = FALSE


	return TRUE


/mob/living/carbon/slime/handle_regular_status_updates()

	blinded = null

	health = maxHealth - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

	if(health < 0 && stat != DEAD)
		death()
		return

	if(getHalLoss())
		setHalLoss(0)

	if(prob(30))
		adjustOxyLoss(-1)
		adjustToxLoss(-1)
		adjustFireLoss(-1)
		adjustCloneLoss(-1)
		adjustBruteLoss(-1)

	if (src.stat == DEAD)
		set_lying(new_status = TRUE)
		src.blinded = 1
	else
		if (src.paralysis || src.stunned || src.weakened || (status_flags && FAKEDEATH)) //Stunned etc.
			if (src.stunned > 0)
				src.set_stat(CONSCIOUS)
			if (src.weakened > 0)
				set_lying(new_status = FALSE)
				src.set_stat(CONSCIOUS)
			if (src.paralysis > 0)
				src.blinded = 0
				set_lying(new_status = FALSE)
				src.set_stat(CONSCIOUS)

		else
			src.lying = 0
			src.set_stat(CONSCIOUS)

	if (src.stuttering) src.stuttering = 0

	if (src.eye_blind)
		src.eye_blind = 0
		src.blinded = 1

	if (src.ear_deaf > 0) src.ear_deaf = 0
	if (src.ear_damage < 25)
		src.ear_damage = 0

	src.set_density(!src.lying)

	if (src.sdisabilities & BLINDED)
		src.blinded = 1
	if (src.sdisabilities & DEAFENED)
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry = 0

	if (src.druggy > 0)
		src.druggy = 0

	return 1
