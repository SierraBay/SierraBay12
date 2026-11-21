/singleton/psionic_power/patia/coercion/agony
	use_intent =     I_DISARM
	name =          "Агония"
	cost =          8
	cooldown =      60
	use_melee =     TRUE
	min_rank =      PSI_RANK_APPRENTICE
	use_description = "Выберите нижнюю часть тела на синем интенте, а затем нажмите по цели вблизи, чтобы совершить по ней удар, по силе сравнимый с шоковой дубинкой."

/singleton/psionic_power/patia/coercion/agony/invoke(mob/living/user, mob/living/target)
	if(!istype(target))
		return FALSE
	if(user.zone_sel.selecting != BP_GROIN)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_DANGER("\ [target] дотрагивается к [user]"))
		playsound(user.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		var/cn_rank = user.psi.get_rank(PSI_PATIA)
		new /obj/temporary(get_turf(target),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
		target.stun_effect_act(0, cn_rank * 30, user.zone_sel.selecting)
		return TRUE
