/*
Просчитывание реакций артефактов

Пример применения в коде:

var/list/result_effects = calculate_artefact_reaction(src, "ЭМИ") <- здесь, мы получаем весь список реакций артефактов в инвентаре персонажа на событие (ЭМИ/Взрыв/Падение и прочие, вы всегда можете добавить своё!)
if(result_effects) <- Всегда проверяйте, что вам не выдало null
	if(result_effects.Find("Защищает от ЭМИ")) <- Теперь, ищем нужную нам реакцию на событие.
		return <-



*/
///В случае применения выдаёт список реакций артефактов внутри моба
/proc/calculate_artefact_reaction(mob/living/user, anomaly_type)
//Используем общий для всех участок кода по реакции артефакта на событие
	var/list/detected_artefacts_in_victim = generate_artefacts_in_mob_list(user)
	if(!LAZYLEN(detected_artefacts_in_victim))
		return FALSE
	var/list/result_effects = list() //Весь список эффектов возникший при ударе
	//Электровоздействие(Электра)
	if(anomaly_type == "Электра")
		for(var/obj/item/artefact/choosed_artefact in detected_artefacts_in_victim)
			LAZYADD(result_effects, choosed_artefact.react_at_electra(user))
		return result_effects
	//Воздействие трамплина(Кидание)
	else if(anomaly_type == "Трамплин")
		for(var/obj/item/artefact/choosed_artefact in detected_artefacts_in_victim)
			LAZYADD(result_effects, choosed_artefact.react_at_tramplin(user))
		return result_effects
	//Воздействие вспышки(Ослепление)
	else if(anomaly_type == "Вспышка")
		for(var/obj/item/artefact/choosed_artefact in detected_artefacts_in_victim)
			LAZYADD(result_effects, choosed_artefact.react_at_vspishka(user))
		return result_effects
	else if(anomaly_type == "Гиб Рвача")
		for(var/obj/item/artefact/choosed_artefact in detected_artefacts_in_victim)
			LAZYADD(result_effects, choosed_artefact.react_at_rvach_gib(user))
		return result_effects
	else if(anomaly_type == "ЭМИ")
		for(var/obj/item/artefact/choosed_artefact in detected_artefacts_in_victim)
			LAZYADD(result_effects, choosed_artefact.react_at_emp_on_user(user))
		return result_effects
	else if(anomaly_type == "Падение с высоты")
		for(var/obj/item/artefact/choosed_artefact in detected_artefacts_in_victim)
			LAZYADD(result_effects, choosed_artefact.react_at_failing(user))
		return result_effects

/proc/generate_artefacts_in_mob_list(mob/living/user)
	if(!istype(user, /mob/living))
		return
	var/list/output_artefacts = list()
	for(var/obj/item/artefact/picked_artefact in user.get_contents())
		if(!picked_artefact.artefact_in_collector())
			LAZYADD(output_artefacts, picked_artefact)
	return output_artefacts

/obj/item/artefact/proc/artefact_in_collector()
	if(istype(loc, /obj/item/collector))
		return TRUE
	else
		return FALSE


/obj/item/artefact/proc/react_at_electra(mob/living/user)
	return

/obj/item/artefact/proc/react_at_tramplin(mob/living/user)
	return

/obj/item/artefact/proc/react_at_vspishka(mob/living/user)
	return

/obj/item/artefact/proc/react_at_rvach_gib(mob/living/user)
	return

/obj/item/artefact/proc/react_at_emp_on_user(mob/living/user)
	return

/obj/item/artefact/proc/react_at_failing(mob/living/user)
	return

/mob/living/emp_act(severity)
	var/list/result_effects = calculate_artefact_reaction(src, "ЭМИ")
	if(result_effects)
		if(result_effects.Find("Защищает от ЭМИ"))
			return
	. = ..()

/obj/item/artefact/throw_at(atom/target, range, speed, mob/thrower, spin, datum/callback/callback)
	react_at_throw()
	. = ..()
	update_current_user()

///Вызывается для реагирования артефакта на тот факт, что им швыряются
/obj/item/artefact/proc/react_at_throw(atom/target, range, speed, mob/thrower, spin, datum/callback/callback)
	return

/obj/item/artefact/proc/react_to_touched(mob/living/user)
	return

/obj/item/artefact/emp_act(severity)
	. = ..()
	react_at_emp()

/obj/item/artefact/proc/react_at_emp()
	return

/obj/item/artefact/proc/react_to_remove_from_collector()
	if(!is_processing)
		start_process_by_ssanom()

/obj/item/artefact/proc/react_to_insert_in_collector()
	if(is_processing)
		stop_process_by_ssanom()
