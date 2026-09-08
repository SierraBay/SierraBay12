/singleton/psionic_power/redaction/meditate
	name =            "Meditation"
	cost =            9
	cooldown =        60
	use_melee =       TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите на себя по голове в зеленом интенте, чтобы начать медитацию."

/singleton/psionic_power/redaction/meditate/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!istype(user) || target != user || user.zone_sel.selecting != BP_HEAD)
		return
	. = ..()
	if(.)
		meditate_tick(user)
		return TRUE

/obj/temporary/psi
	layer = ABOVE_LIGHTING_LAYER

/obj/temporary/psi/Initialize(mapload, duration = 30, _icon = 'icons/effects/effects.dmi', _state, use_rank)
	..()
	pixel_x = rand(8 * use_rank,-8* use_rank)
	pixel_y = rand(8 * use_rank,-8 * use_rank)

/singleton/psionic_power/redaction/meditate/proc/meditate_tick(mob/living/user)
	if(do_after(user, 3 SECONDS, user, DO_SHOW_PROGRESS | DO_USER_INTERRUPT | DO_BOTH_CAN_TURN | DO_USER_UNIQUE_ACT) && !user.psi.suppressed)
		user.psi.attempt_regeneration()
		var/use_rank = user.psi.get_rank(PSI_REDACTION)
		for(var/i = 0; i <= use_rank; i++)
			new /obj/temporary/psi(get_turf(user), 16, 'mods/psionics/icons/effects/psi_effects.dmi', "green[rand(1,8)]", use_rank)
			sleep(1)
		meditate_tick(user)
