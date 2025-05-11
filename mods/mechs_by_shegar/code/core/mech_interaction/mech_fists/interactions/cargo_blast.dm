//Обычные бласты(в карго)
/obj/machinery/door/blast/shutters/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		force_toggle()
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE
