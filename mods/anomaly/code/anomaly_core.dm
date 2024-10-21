/*В данном файле располагается ЯДРО аномалий.
В данном файле вы найдёте:
-Реагирование аномалий на различные события
-Активация аномалий из-за каких либо событий и условий
-Обработка перезарядки, КД аномалии
-Инициализация аномалии в мире
*/
#define LONG_ANOMALY_EFFECT 1
#define MOMENTUM_ANOMALY_EFFECT 2
#define DEFAULT_ANOMALY_EFFECT 0
#define isanomaly(A) istype(A, /obj/anomaly)

/obj/anomaly
	name = "Аномалия. Вы не должны это видеть."
	anchored = TRUE //Чтоб аномалию не двигало в случае чего
	//COULDOWN AND SMTH
	///Аномалия уходит на КД после срабатывания?
	var/can_be_discharged = FALSE
	///Время КД после срабатывания
	var/cooldown_time = 5 SECONDS
	///Холдер времени последней активации
	var/last_activation_time = 0
	///У аномалии ваще есть КД?
	var/have_cooldown = TRUE
	///Аномалия заряжается после срабатывания
	var/currently_charging_after_activation = FALSE
	///Лист существ/обьектов/предметов которые МОГУТ взвести аномалию
	var/list/iniciators = list(
		/mob/living
	)
	//Аномалия НИКОГДА не взведётся от данных инициаторов
	var/list/never_iniciate = list()
	///Обьекты, которые взводят аномалию лишь при определённых условиях
	var/list/special_iniciators = list()
	///Список этих самых специальных условий для аномалии
	var/list/special_iniciators_flags = list()
	/// Радиус, в котором бьёт аномалия. Ваша аномалия может "Чуять" на одном расстоянии, а бить на более большом!
	var/effect_range = 0

	///Список турфов, находящиеся в зоне поражения
	var/list/effected_turfs = list()
	///Сколько раз аномалия даёт свой эффект
	//TODO: доделать эту фичу
	var/activation_ammount = 1
	///Аномке требуется предзарядка перед ударом
	var/need_preload = FALSE
	///Детектор запищит, если он появится в зоне поражения этой аномалии
	var/detectable_effect_range = FALSE


///Аномалия по причине пересечения или ещё какой причине проверяет, может ли она "Взвестить от этого инициатора"
/obj/anomaly/proc/can_be_activated(atom/movable/target)
	for(var/i in iniciators)
		if(istype(target, i))
			return TRUE

	if(LAZYLEN(special_iniciators)) //у аномалии ЕСТЬ специальные инициаторы
		if(special_iniciators_flags.Find("MUST_BE_METAL"))
			for( var/i in special_iniciators )
				if(!istype(target, i))
					continue
				var/obj/item/founded = target
				if(!founded.matter)
					return FALSE
				if(founded.matter.Find(MATERIAL_STEEL) || founded.matter.Find(MATERIAL_ALUMINIUM) || founded.matter.Find(MATERIAL_PLASTEEL))
					return TRUE
	return FALSE

///Сама активация аномалии
/obj/anomaly/proc/activate_anomaly()
	return

//Обязательно вызываем обработку результатов активации
/obj/anomaly/activate_anomaly()
	.=..()
	handle_after_activation()



///Пост-обработка действия аномалии.
/obj/anomaly/proc/handle_after_activation()
	last_activation_time = world.time
	if(with_sound)
		playsound(src, sound_type, 100, FALSE  )
	if(effect_type == LONG_ANOMALY_EFFECT)
		handle_long_effect()
	else
		do_momentum_animation()
		start_recharge()


///Эффект на цели от аномалии. Огонь, удар тока, что угодно
/obj/anomaly/proc/get_effect_by_anomaly(atom/movable/target)
	return

///Аномалия перезаряжается и после ищет возбудителя в зоне поражения. Это начало.
/obj/anomaly/proc/start_recharge()
	set waitfor = 0
	if(currently_charging_after_activation)
		return FALSE
	currently_charging_after_activation = TRUE
	currently_active = FALSE
	addtimer(new Callback(src, PROC_REF(continue_recharge)), cooldown_time)

///Аномалия перезаряжается и после ищет возбудителя в зоне поражения. Это конец.
/obj/anomaly/proc/continue_recharge()
	var/list/victims = list()
	var/list/objs = list()
	var/turf/T = get_turf(src)
	get_mobs_and_objs_in_view_fast(T, 0, victims, objs)
	for(var/atom/movable/target in victims)
		if(can_be_activated(target))
			currently_charging_after_activation = FALSE
			activate_anomaly()
			return TRUE
	for(var/atom/movable/target in objs)
		if(can_be_activated(target))
			currently_charging_after_activation = FALSE
			activate_anomaly()
			return TRUE
	//В случае если ядро аномалии ничего не нашло на своём тайтле из угроз, мы опросим её остальные части
	if(multitile)
		var/found = FALSE
		for(var/obj/anomaly/part/part in list_of_parts)
			if(part.part_check_title())
				found = TRUE
		if(found)
			currently_charging_after_activation = FALSE
			activate_anomaly()
			return TRUE
		else
			currently_charging_after_activation = FALSE
	else
		currently_charging_after_activation = FALSE
		return FALSE

///Кто-то или что-то пересекло расположение аномалии
/obj/anomaly/Crossed(atom/movable/O)
	anomaly_been_crossed(O)

/obj/anomaly/proc/anomaly_been_crossed(atom/movable/O)
	if(!isready())
		return
	if(can_be_activated(O))
		currently_active = TRUE
		activate_anomaly()
	return

/obj/anomaly/Move()
	. = ..()
	for(var/atom/atoms in loc)
		src.anomaly_been_crossed(atoms)

///Аномалия подготовлена к следующему удару?
/obj/anomaly/proc/isready()
	if(currently_active)
		return
	if(currently_charging_after_activation)
		return FALSE
	if(have_cooldown)
		if((world.time - last_activation_time) < cooldown_time)
			return FALSE
	return TRUE

//Спавн аномалии, её размещение и т.д
/obj/anomaly/Initialize()
	. = ..()
	SSanom.add_anomaly_in_list(src)
	preload_time = cooldown_time
	if(ranzomize_with_initialize)
		ranzomize_parameters()
	icon_state = idle_effect_type
	if(have_static_sound)
		GLOB.sound_player.PlayLoopingSound(src, "\ref[src]", static_sound_type, 10, 6)
	if(detectable_effect_range)
		calculate_effected_turfs_from_new_anomaly(src)
	if(can_walking && prob(chance_spawn_walking))
		check_anomaly_ai()
