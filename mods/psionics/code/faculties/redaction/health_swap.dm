/singleton/psionic_power/redaction/health_swap
	name =            "Health Swap"
	cost =            25
	cooldown =        1 SECONDS
	use_grab =        TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Возьмите жертву в жёлтый захват, переключитесь на дружественный интент и после нацелившись на грудь кликните по жертве. Внутренние органы обоих участников переноса имунны к любому урону в течении минуты после переноса. Соотношение перенесённого урона зависит от уровня псионики дисциплины Редакция."
	admin_log = TRUE

/singleton/psionic_power/redaction/health_swap/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!ishuman(target) || user.zone_sel.selecting != BP_CHEST)
		return FALSE
	. = ..()
	if(.)
		var/answer = alert(user, "Если вы хотите перенести урон с органов и конечностей ОТ СЕБЯ к ЦЕЛИ - жмите \"ОТ ЦЕЛИ КО МНЕ\", если хотите от цели к себе то жмите \"ОТ МЕНЯ К ЦЕЛИ\"", "Перенос повреждений", "От меня к цели", "От цели ко мне")
		//answer может длится сколько угодно, потому нужно перепроверить условия после ответа
		if(get_dist(get_turf(user), get_turf(target)) > 1.5)
			to_chat(user, "Я слишком далеко.")
			return
		if(target.grabbed_by && target.grabbed_by == user)
			to_chat(user, "Я должен держать цель!")
			return
		target.organs_psi_invisibility(user)
		if(!do_after(user, 5 SECONDS, target, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
			to_chat(user, "В таких условиях сосредоточиться просто невозможно!")
			return

		if(target.grabbed_by && target.grabbed_by == user)
			to_chat(user, "Мне нужно продолжать держать цель в захвате!")
			return

		var/red_rank = user.psi.get_rank(PSI_REDACTION) - 1
		if(answer == "От меня к цели")
			red_rank += target.psi_buffer_give
			transfer_from_psyker_to_target(user, target, red_rank)
		else if(answer == "От цели ко мне")
			red_rank += target.psi_buffer_take
			red_rank = clamp(red_rank, 0, 4)
			transfer_from_target_to_psyker(user, target, red_rank)
		setup_psi_swap_buffer(target, user.psi.get_rank(PSI_REDACTION) - 1)
		target.update_icon()
		return TRUE

///Отжимает брут урон с органов и конечностей и переносит к псионику
/singleton/psionic_power/redaction/health_swap/proc/transfer_from_target_to_psyker(mob/living/carbon/human/user, mob/living/carbon/human/target, result_rank)
	//Перенос у внешних органов
	for(var/thing in target.organs)
		var/obj/item/organ/external/E = thing
		var/obj/item/organ/external/detected_organ = user.get_organ(E.organ_tag)
		if(BP_IS_ROBOTIC(E) || BP_IS_ROBOTIC(detected_organ))
			continue
		if(BP_IS_CRYSTAL(E) || BP_IS_CRYSTAL(detected_organ))
			continue
		//Перенос брута
		var/brute_steal = (E.brute_dam) * ((result_rank * 25)/100)
		E.heal_damage(brute = brute_steal)
		detected_organ.take_external_damage(brute = brute_steal)
		//Перенос бёрна
		var/burn_steal = (E.burn_dam) * ((result_rank * 25)/100)
		E.heal_damage(burn = burn_steal)
		detected_organ.take_external_damage(burn = burn_steal)
		E.psy_swap_flags_to_organ(detected_organ, result_rank)


	//Перенос у внутренних органов
	for(var/thing in target.internal_organs)
		var/obj/item/organ/internal/E = thing
		var/obj/item/organ/internal/detected_organ = user.internal_organs_by_name[E.organ_tag]
		if(BP_IS_ROBOTIC(E) || BP_IS_ROBOTIC(detected_organ))
			continue
		if(BP_IS_CRYSTAL(E) || BP_IS_CRYSTAL(detected_organ))
			continue
		//Перенос брута
		var/damage_steal = (E.damage) * ((result_rank * 25)/100)
		E.heal_damage(damage_steal)
		detected_organ.take_internal_damage(damage_steal)
		E.psy_swap_flags_to_organ(detected_organ, result_rank)
	return TRUE


/singleton/psionic_power/redaction/health_swap/proc/transfer_from_psyker_to_target(mob/living/carbon/human/user, mob/living/carbon/human/target, result_rank)
	///Перенос с конечностей
	for(var/thing in user.organs)
		var/obj/item/organ/external/E = thing
		var/obj/item/organ/external/detected_organ = target.get_organ(E.organ_tag)
		if(BP_IS_ROBOTIC(E) || BP_IS_ROBOTIC(detected_organ))
			continue
		if(BP_IS_CRYSTAL(E) || BP_IS_CRYSTAL(detected_organ))
			continue
		var/brute_give = (E.brute_dam) * ((result_rank * 25)/100)
		//Перенос брута
		E.heal_damage(brute = brute_give)
		detected_organ.take_external_damage(brute = brute_give)
		//Перенос бёрна
		var/burn_give = (E.burn_dam) * ((result_rank * 25)/100)
		E.heal_damage(burn = burn_give)
		detected_organ.take_external_damage(burn = burn_give)
		E.psy_swap_flags_to_organ(detected_organ, result_rank)
	//Перенос у внутренних органов
	for(var/thing in user.internal_organs)
		var/obj/item/organ/internal/E = thing
		var/obj/item/organ/internal/detected_organ = target.internal_organs_by_name[E.organ_tag]
		if(BP_IS_ROBOTIC(E) || BP_IS_ROBOTIC(detected_organ))
			continue
		if(BP_IS_CRYSTAL(E) || BP_IS_CRYSTAL(detected_organ))
			continue
		//Перенос брута
		var/damage_give = (E.damage) * ((result_rank * 25)/100)
		E.heal_damage(damage_give)
		detected_organ.take_internal_damage(damage_give)
		E.psy_swap_flags_to_organ(detected_organ, result_rank)

/mob/living/carbon/human
	var/psi_buffer_take = 0 //Буфер забирания
	var/psi_buffer_give = 0 //Буфер отдачи
	var/psi_buffer_timer

/mob/living/carbon/human/proc/clear_psi_buffer()
	psi_buffer_take = 0
	psi_buffer_give = 0

//Для того чтоб избежать ситуации при которой:
//Игрок переносит 50 процентов повреждений у чувака
//Пытается перенести второй раз и от половины отбирается ещё 50 процентов
//И существует этот баффер. Если у пользователя 50% переноса, то вторым переносом он должен полностью перенести весь урон
/singleton/psionic_power/redaction/health_swap/proc/setup_psi_swap_buffer(mob/living/carbon/human/target, redaction_rank)
	target.psi_buffer_take = redaction_rank
	target.psi_buffer_give = redaction_rank
	//Если таймер уже существует - сносим старый
	if(target.psi_buffer_timer)
		deltimer(target.psi_buffer_timer)
		target.psi_buffer_timer = null
	target.psi_buffer_timer = addtimer(new Callback(target, TYPE_PROC_REF(/mob/living/carbon/human, clear_psi_buffer)), 3 MINUTES)

/obj/item/organ/internal
	var/psyker_invincible = FALSE
	var/psyker_invincible_timer

/mob/living/carbon/human/proc/organs_psi_invisibility(mob/living/carbon/human/psyker, time = 10 SECONDS)
	for(var/thing in internal_organs)
		var/obj/item/organ/internal/E = thing
		var/obj/item/organ/internal/detected_organ = psyker.internal_organs_by_name[E.organ_tag]
		if(BP_IS_ROBOTIC(E) || BP_IS_ROBOTIC(detected_organ))
			continue
		if(BP_IS_CRYSTAL(E) || BP_IS_CRYSTAL(detected_organ))
			continue
		E.psyker_temp_invincible(10 SECONDS)
		detected_organ.psyker_temp_invincible(10 SECONDS)


///Отключение псионической неуязвимости органов
/obj/item/organ/internal/proc/clear_psyker_invinsibility()
	psyker_invincible = FALSE

/obj/item/organ/internal/proc/psyker_temp_invincible(invincible_time = 10 SECONDS)
	if(psyker_invincible_timer)
		deltimer(psyker_invincible_timer)
		psyker_invincible_timer = null
	psyker_invincible_timer = addtimer(new Callback(src, PROC_REF(clear_psyker_invinsibility)), invincible_time)
	psyker_invincible = TRUE

/obj/item/organ/proc/psy_swap_flags_to_organ(obj/item/organ/input_organ, result_rank)
// Ученик
	var/rank = result_rank - 1
	if(rank >= PSI_RANK_APPRENTICE)
		if(status & ORGAN_BLEEDING)
			status &= ~ORGAN_BLEEDING
			input_organ.status |= ORGAN_BLEEDING

		if(status & ORGAN_BROKEN)
			status &= ~ORGAN_BROKEN
			input_organ.status |= ORGAN_BROKEN

// Оперант
	if(rank >= PSI_RANK_OPERANT)
		if(status & ORGAN_DISFIGURED)
			status &= ~ORGAN_DISFIGURED
			input_organ.status |= ORGAN_DISFIGURED

		if(status & ORGAN_MUTATED)
			status &= ~ORGAN_MUTATED
			input_organ.status |= ORGAN_MUTATED

// Мастер
	if(rank >= PSI_RANK_MASTER)
		if(status & ORGAN_ARTERY_CUT)
			status &= ~ORGAN_ARTERY_CUT
			input_organ.status |= ORGAN_ARTERY_CUT

		if(status & ORGAN_TENDON_CUT)
			status &= ~ORGAN_TENDON_CUT
			input_organ.status |= ORGAN_TENDON_CUT

		if(status & ORGAN_DEAD)
			status &= ~ORGAN_DEAD
			input_organ.status |= ORGAN_DEAD
