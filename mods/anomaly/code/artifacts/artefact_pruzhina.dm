//Пружина
/obj/item/artefact/pruzhina
	name = "Something"
	desc = "При подборе этого предмета вы ощущаете словно все мышцы ваших рук напрягаются, словно от лёгкого удара тока. Вы чувствуете, как ваши волосы подымаются дыбом."
	icon_state = "pruzhina"
	rect_to_interactions = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	//артефакт обладает зарядами
	var/charges = 0
	var/max_charges = 3
	stored_energy = 10000
	max_stored_energy = 10000
	var/datum/beam = null
	//Артефакт скопирован с помощью URM
	var/copy = FALSE

/obj/item/artefact/pruzhina/lick_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("Как только вы подносите язык чуть ближе, вы чувствуете острую боль в нём, словно от проводов."))
	user.electoanomaly_act(25, src, BP_HEAD)

/obj/item/artefact/pruzhina/shake_interaction(mob/living/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Ваши внешние сенсоры регистристрируют усиление электромагнитного поля."))
	else
		to_chat(user,SPAN_GOOD("Потреся обьект, вы чувствуете, как тот начинает щёлкать и словно оживать. Чувствуете нечто, подобное мурчанию"))
	add_charge(user)

/obj/item/artefact/pruzhina/bite_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("Как только вы ухватываете обьект зубами, вы чувствуете сильнейшую боль.Глупо."))
	user.electoanomaly_act(75, src, BP_HEAD)

/obj/item/artefact/pruzhina/knock_interaction(mob/living/user)
	angry_activity()

/obj/item/artefact/pruzhina/compress_interaction(mob/living/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("При повышении напряжения в сервоприводах вашей конечности регистрируется обратная сила, возвращающая обьект в исходное состояние."))
	else
		to_chat(user,SPAN_NOTICE("Вы чувствуете как артефакт сопротивляется вашей попытке его сжать, словно какое-то поле отталкивает его обратно."))

/obj/item/artefact/pruzhina/rub_interaction(mob/living/user)
	if(charges > 0)
		sub_charge(user)
		if(isrobot(user))
			to_chat(user,SPAN_NOTICE("Фиксируется электростатическое поле."))
		else
			to_chat(user,SPAN_NOTICE("Вы чувсвуете, как ваши волосы встают дыбом."))
		charge_all_cells_close()
	else
		to_chat(user,SPAN_NOTICE("Обьект не реагирует."))

/obj/item/artefact/pruzhina/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/pruzhina/urm_laser(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/pruzhina/urm_electro(mob/living/user)
	stored_in_urm.last_interaction_id = "pruzhina_eated_electro"
	stored_in_urm.last_interaction_reward = 1000
	return "Зафиксировано как обьект поглотил в себя весь переданный электрический потенциал."

/obj/item/artefact/pruzhina/urm_plasma(mob/living/user)
	if(!copy)
		copy = TRUE
		var/obj/item/artefact/pruzhina/borned_pruzhina = new /obj/item/artefact/pruzhina(get_turf(src))
		borned_pruzhina.copy = TRUE
		stored_in_urm.last_interaction_id = "pruzhina_duped"
		stored_in_urm.last_interaction_reward = 2000
		return "При определённой концентрации потока плазмы Обьект начинает бурно реагировать. Он расширяется в обьёмах, пульсирует, и из одного выходит второй, точно такой же."
	else
		var/obj/anomaly/electra/three_and_three/spawned = new /obj/anomaly/electra/three_and_three/tesla(get_turf(src))
		spawned.kill_later(120 SECONDS)
		delete_artefact()
		stored_in_urm.artefact_inside =  null
		stored_in_urm.last_interaction_id = "pruzhina_was_overpowered"
		stored_in_urm.last_interaction_reward = 5000
		return "При попытке получить ещё один такой обьект при помощи облучение плазмой что-то идёт не так. Обьект расширяется уже куда сильнее и быстрее, после растворяясь на ваших глазах. Вы слышите писк аварийной системы безопасности УИМ."

/obj/item/artefact/pruzhina/urm_phoron(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/pruzhina/react_to_touched(mob/living/user)
	if(!ishuman(user))
		return
	else
		var/mob/living/carbon/human/victim = user
		if(!victim.gloves || victim.gloves.siemens_coefficient != 0)
			to_chat(user, SPAN_BAD("Вы чувствуете в кисти сильный удар тока."))
			victim.electoanomaly_act(10, src, victim.get_active_hand())

/obj/item/artefact/pruzhina/react_at_throw(atom/target, range, speed, mob/thrower, spin, datum/callback/callback)
	create_anomaly_pruzhina(30 SECONDS)

/obj/item/artefact/react_to_emp()
	angry_activity()

/obj/item/artefact/pruzhina/proc/add_charge(mob/living/user)
	if(charges >= max_charges)
		ubercharge_pruzhina(user)
		return FALSE
	else
		charges++
		return TRUE

/obj/item/artefact/pruzhina/proc/sub_charge(user)
	if(charges <= max_charges)
		charges = 0
		return FALSE
	else
		charges--
		return TRUE

/obj/item/artefact/pruzhina/proc/ubercharge_pruzhina(mob/living/user)
	to_chat(user,SPAN_WARNING("Обьект вырывается из ваших рук уже с грозным грохотом и гудением."))
	user.drop_item(src)
	anchored = TRUE
	addtimer(new Callback(src, PROC_REF(create_anomaly_pruzhina)), 2 SECONDS)

/obj/item/artefact/pruzhina/proc/charge_all_cells_close()
//TODO: Избавиться от range() и воспользоваться менее ресурсозатратным методом

	for (var/obj/machinery/power/apc/C in range(3))
		for (var/obj/item/cell/B in C.contents)
			B.give(500)
	for (var/obj/machinery/power/smes/S in range (3))
		S.charge += 500
	for (var/mob/living/silicon/robot/M in range(3))
		for (var/obj/item/cell/D in M.contents)
			D.give(500)
	for(var/obj/item/cell/cells in range(3))
		cells.give(500)

/obj/item/artefact/pruzhina/proc/create_anomaly_pruzhina(time_to_kill)
	if(!time_to_kill)
		time_to_kill = 60 SECONDS
	var/obj/anomaly/electra/three_and_three/spawned = new /obj/anomaly/electra/three_and_three(get_turf(src))
	spawned.kill_later(time_to_kill)
	delete_artefact()


/obj/item/artefact/pruzhina/angry_activity(mob/living/user)
	to_chat(user,SPAN_WARNING("Вас озарила вспышка."))
	var/list/victims = list()
	var/list/objs_not_used = list()
	var/turf/T = get_turf(src)
	get_mobs_and_objs_in_view_fast(T, 3, victims, objs_not_used)
	for(var/mob/living/target in victims)
		target.electoanomaly_act(75, src, BP_CHEST)
		beam = src.Beam(BeamTarget = get_turf(target), icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)


///батарейка, созданная из артефакта Пружина
/obj/item/cell/pruzhina
	name = "powered artefact"
	desc = "Collector with something inside, switched in alternative mode."
	icon = 'mods/anomaly/icons/collectors.dmi'
	icon_state = "collector_closed"
	origin_tech =  null
	//Он незаряжаем никакими обычными способами
	maxcharge = 10000
	matter = list()

/obj/item/cell/pruzhina/give(amount)
	return

/obj/item/cell/pruzhina/attack_self(mob/living/user)
	. = ..()
	var/obj/item/collector/spawned_collector = new /obj/item/collector/pruzhina_inside(get_turf(src))
	spawned_collector.stored_artefact.stored_energy = charge
	qdel(src)

/obj/item/cell/pruzhina/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	return
