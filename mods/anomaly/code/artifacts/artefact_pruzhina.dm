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

/obj/item/artefact/pruzhina/proc/create_anomaly_pruzhina(mob/living/user)
	var/obj/anomaly/electra/three_and_three/spawned = new /obj/anomaly/electra/three_and_three(get_turf(src))
	spawned.kill_later(60 SECONDS)
	qdel(src)


/obj/item/artefact/pruzhina/angry_activity(mob/living/user)
	/*
	if(charges = 0)
		to_chat(user,SPAN_WARNING("Обьект растворяется в ваших руках."))
		qdel(src)
	*/
//else
	to_chat(user,SPAN_WARNING("Вас озарила вспышка."))
	var/list/victims = list()
	var/list/objs_not_used = list()
	var/turf/T = get_turf(src)
	get_mobs_and_objs_in_view_fast(T, 3, victims, objs_not_used)
	for(var/mob/living/target in victims)
		target.electoanomaly_act(75, src, BP_CHEST)
		beam = src.Beam(BeamTarget = get_turf(target), icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)


// new /obj/item/cell/pruzhina(get_turf(src))


///батарейка, созданная из артефакта Пружина
/obj/item/cell/pruzhina
	name = "powered artefact"
	desc = "dam."
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
