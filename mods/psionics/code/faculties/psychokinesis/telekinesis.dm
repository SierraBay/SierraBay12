/singleton/psionic_power/psychokinesis/telekinesis
	name =            "Telekinesis"
	cost =            10
	cooldown =        15
	use_ranged =      TRUE
	use_manifest =    FALSE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по отдалённом объекту или существу на жёлтом интенте с выбранным телом, чтобы захватить его телекинезом."
	admin_log =       FALSE
	use_sound =       'sound/effects/psi/power_used.ogg'
	var/global/list/valid_machine_types = list(
		/obj/machinery
	)

/singleton/psionic_power/psychokinesis/telekinesis/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_GROIN && user.zone_sel.selecting != BP_CHEST)
		return FALSE
	if(user.a_intent != I_GRAB)
		return FALSE
	. = ..()
	if(.)

		var/distance = get_dist(user, target)
		if(distance > user.psi.get_rank(PSI_PSYCHOKINESIS) * 3)
			to_chat(user, SPAN_WARNING("Моих сил недостаточно, чтобы достать до этого объекта."))
			return FALSE

		if(istype(target, /obj/machinery))
			for(var/mtype in valid_machine_types)
				if(istype(target, mtype))
					var/obj/machinery/machine = target
					return machine.do_simple_ranged_interaction(user)
		else if(istype(target, /mob) || istype(target, /obj))
			var/obj/item/psychic_power/telekinesis/tk = new(user)
			if(tk.set_focus(target))
				tk.sparkle()
				user.visible_message(SPAN_DANGER("[user] вытягивает руку вперёд, чуть сжимая пальцы."))
				return tk

	return FALSE
