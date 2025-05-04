/obj/machinery/door/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		toggle()
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE

//Аир лок
/obj/machinery/door/firedoor/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(!blocked)
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		toggle(forced = TRUE)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(!locked && (inoperable() || !is_powered()))
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		toggle(forced = TRUE)
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE

/obj/machinery/door/blast/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		force_toggle()
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE
