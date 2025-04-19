//Всё что делает устройство - размещает маячок (световой) при использовании
/obj/item/beacon_deployer
	name = "beacon deployer"
	desc = "Special tool created for fast beacon deploys."
	icon = 'mods/anomaly/icons/deployer.dmi'
	icon_state = "beacon_deployer"
	action_button_name = "Use deployer"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 2000)
	var/stored_beacon_amount = 0
	var/max_beacon_amount = 50
	///Отвечает за то, какого цвета будет размещён маячок
	var/current_beacon_type = "Зелёный"

/obj/item/stack/flag
	icon = 'mods/anomaly/icons/marking_beacon.dmi'

/obj/item/stack/flag/set_up()
	upright = 1
	dir = usr.dir
	anchored = TRUE
	update_icon()

/obj/item/stack/flag/proc/set_up_by_projectile()
	upright = 1
	dir = SOUTH
	anchored = TRUE
	update_icon()

///Осмотр
/obj/item/beacon_deployer/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_NOTICE("Внутри [stored_beacon_amount] маячков."))
	to_chat(user, SPAN_GOOD("Используйте Альт + левая кнопка мыши для изменения цвета флага."))
	to_chat(user, SPAN_GOOD("Используйте Кнтрл + левая кнопка мыши для разрядки устройства."))

/obj/item/beacon_deployer/AltClick()
	var/list/options = list(
		"Зелёный" = mutable_appearance('mods/anomaly/icons/deployer.dmi', "green"),
		"Красный" = mutable_appearance('mods/anomaly/icons/deployer.dmi', "red"),
		"Жёлтый" = mutable_appearance('mods/anomaly/icons/deployer.dmi', "yellow"),
		"Синий" = mutable_appearance('mods/anomaly/icons/deployer.dmi', "blue")
	)
	current_beacon_type = show_radial_menu(usr, src, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	return TRUE

/obj/item/beacon_deployer/CtrlClick()
	deploy_beacon(usr, FALSE, 10)
	return TRUE

/obj/item/beacon_deployer/use_tool(obj/item/item, mob/living/user, list/click_params)
	. = ..()
	if(istype(item,/obj/item/stack/flag))
		reload_deployer(user, item)

///Заряжает в деплоер флаги
/obj/item/beacon_deployer/proc/reload_deployer(mob/living/user, obj/item/stack/flag/item)
	if(stored_beacon_amount == max_beacon_amount) //Переполнен
		to_chat(user, SPAN_NOTICE("Полон."))
		return
	//Определяемся, сколько передадим флажков
	var/transfer_amount = item.amount
	if(stored_beacon_amount + item.amount > max_beacon_amount)
		transfer_amount = max_beacon_amount - stored_beacon_amount //Не позволит переполнить запас
	if(transfer_amount > item.amount)
		transfer_amount = item.amount //Не позволит взять больше, чем есть в стаке
	item.use(transfer_amount)
	stored_beacon_amount += transfer_amount
	to_chat(user, SPAN_NOTICE("Вы вставили [transfer_amount] зарядов в установщик."))

/obj/item/beacon_deployer/attack_self(mob/living/user)
	. = ..()
	check_current_turf(user)

///Игрок использовал деплоер. Если маяка нет - поставим. Есть - заберём.
/obj/item/beacon_deployer/proc/check_current_turf(mob/living/user)
	if(locate(/obj/item/stack/flag) in get_turf(src))
		for(var/obj/item/stack/flag/picked_flag in get_turf(src))
			undeploy_beacon(user, picked_flag)
	else
		deploy_beacon(user)

///Разобрать флаг и убрать в деплоер
/obj/item/beacon_deployer/proc/undeploy_beacon(mob/living/user, obj/item/stack/flag/item)
	if(item.upright)
		item.knock_down()
	reload_deployer(user, item)

///Установить флаг из деплоера
/obj/item/beacon_deployer/proc/deploy_beacon(mob/living/user, deploy = TRUE, deploy_amount = 1)
	if(stored_beacon_amount <= 0)
		to_chat(user, SPAN_BAD("Пуст."))
		return
	if(deploy_amount > 1)
		if(deploy_amount > stored_beacon_amount)
			deploy_amount = stored_beacon_amount
	var/type
	if(current_beacon_type == "Зелёный")
		type = /obj/item/stack/flag/green
	else if(current_beacon_type == "Красный")
		type = /obj/item/stack/flag/red
	else if(current_beacon_type == "Синий")
		type = /obj/item/stack/flag/blue
	else if(current_beacon_type == "Жёлтый")
		type = /obj/item/stack/flag/yellow
	if(!type)
		return
	var/obj/item/stack/flag/spawned_flag = new type(get_turf(src))
	spawned_flag.amount = deploy_amount
	stored_beacon_amount -= deploy_amount
	if(deploy)
		spawned_flag.set_up()
		spawned_flag.dir = user.dir
		playsound(src, 'sound/items/shuttle_beacon_complete.ogg', 50)

//С его помощью даже можно стрелять! Флагами.
/obj/item/beacon_deployer/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	try_shoot_flag(target)

/obj/item/projectile/flag
	var/flag_color = "Зелёный"
	nodamage = TRUE
	var/turf/wanted_turf

/obj/item/projectile/flag/Move()
	.=..()
	if(get_turf(src) == wanted_turf)
		flag_act()

/obj/item/projectile/flag/proc/flag_act()
	if(locate(/obj/item/stack/flag) in get_turf(src))
		return FALSE //Не стоооит создавать ещё один флаг, приводит к страшным лагам
	var/type
	if(flag_color == "Зелёный")
		type = /obj/item/stack/flag/green
	else if(flag_color == "Красный")
		type = /obj/item/stack/flag/red
	else if(flag_color == "Синий")
		type = /obj/item/stack/flag/blue
	else if(flag_color == "Жёлтый")
		type = /obj/item/stack/flag/yellow
	var/obj/item/stack/flag/spawned_flag = new type(get_turf(src))
	spawned_flag.amount = 1
	spawned_flag.set_up_by_projectile()
	qdel(src)


/obj/item/beacon_deployer/proc/try_shoot_flag(atom/target)
	usr.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if(stored_beacon_amount <= 0)
		to_chat(usr, SPAN_BAD("Грустно щёлкает."))
		return
	var/obj/item/projectile/flag/flag_projectile = new(get_turf(src))
	flag_projectile.wanted_turf = get_turf(target)
	flag_projectile.flag_color = current_beacon_type
	flag_projectile.icon = 'mods/anomaly/icons/deployer.dmi'
	flag_projectile.icon_state = "flagger"
	stored_beacon_amount--
	flag_projectile.launch(target)


/obj/item/beacon_deployer/full
	stored_beacon_amount = 50
