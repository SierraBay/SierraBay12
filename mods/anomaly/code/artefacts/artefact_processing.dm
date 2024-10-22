/obj/item/artefact
	///КД на проверку валидности носителя в случае если носителя нет
	var/user_long_check_cooldown = 3 SECONDS
	var/last_long_user_check = 0
	///КД на проверку валидности носителя в случае если носитель есть
	var/user_check_cooldown = 2 SECONDS
	var/last_user_check = 0
	///Артефакт нуждается в постоянной обработке?
	var/need_to_process = FALSE
	///КД на влияние артефакта на носителя
	var/process_effect_cooldown = 0.5 SECONDS
	var/last_process_effect = 0

	var/additional_process_cooldown = 20 SECONDS
	var/last_additional_process = 0

/obj/item/artefact/Initialize()
	. = ..()
	user_long_check_cooldown = rand(3 SECONDS, 6 SECONDS)
	user_check_cooldown = rand(2 SECONDS, 4 SECONDS)
	additional_process_cooldown = rand(20 SECONDS, 50 SECONDS)
	start_process_by_ssanom()

//Артефакт процессится абсолютно всегда в силу того что невозможно без изменения кор кода предотвратить ситуации, когда артефакт
//Не влият на носителя, например при скидывании на пол и поднятии рюкзака обратно (Как сообщить артефакту о этм событии? Срать в код.)
/obj/item/artefact/Process()
	if(world.time - last_long_user_check >= user_long_check_cooldown)
		last_long_user_check = world.time
	additional_process()
	if(connected_to_anomaly)
		return
	//Если носителя нет, то через большой промежуток времени проверим - вдруг нас кто-то всё таки взял?
	if(!current_user)
		if(world.time - last_long_user_check >= user_long_check_cooldown)
			last_long_user_check = world.time
			for(var/mob/living/user in get_turf(src))
				if(src in user.get_contents())
					update_current_user(user)
	//Если носитель есть, то через более мелкий промежуток времени проверим, что носитель нас ещё носит
	else if(current_user)
		if(world.time - last_user_check >= user_check_cooldown)
			last_user_check = world.time
			update_current_user()
		if(world.time - last_process_effect <= process_effect_cooldown)
			return
		process_artefact_effect_to_user()

/*
Дополнительный процессинг для доп фич. Обычно не используется.
Позволяет легко добавлять новые свойства процессингу не изменяя ядро
*/
/obj/item/artefact/proc/additional_process()
	return

/obj/item/artefact/proc/process_artefact_effect_to_user()
	return


//Добавляем и убираем ВЛАДЕЛЬЦЕВ(кто имеем в рюкзаке арт)
/obj/item/artefact/pickup(mob/living/user)
	.=..()
	update_current_user(user)

/obj/item/artefact/dropped(mob/user)
	.=..()
	update_current_user(user)


/obj/item/artefact/proc/update_current_user(mob/living/user)
	// В случае перемещения предмета между contents или подбора, обновляет своего ПОЛЬЗОВАТЕЛЯ
	if(current_user) //Юзер уже есть,
		if(get_turf(current_user) != get_turf(src)) //проверяем,
			current_user = null
	else if(!current_user)
		current_user = user


/obj/item/artefact/proc/start_process_by_ssanom()
	if(!is_processing)
		START_PROCESSING(SSanom, src)
		SSanom.processing_ammount++


/obj/item/artefact/proc/stop_process_by_ssanom()
	if(is_processing)
		STOP_PROCESSING(SSanom, src)
	if(SSanom.processing_ammount > 0)
		SSanom.processing_ammount--
