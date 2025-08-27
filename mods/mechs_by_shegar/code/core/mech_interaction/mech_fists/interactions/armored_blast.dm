//Крепкие бласты(оружейка СБ)
/obj/machinery/door/blast/regular/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		force_toggle()
		return TRUE
	//Всё равно возвращаем TRUE, чтоб мех не ударял
	to_chat(pilot, SPAN_NOTICE("This structure too reinforced for being damaged by [src]!"))
	return TRUE
