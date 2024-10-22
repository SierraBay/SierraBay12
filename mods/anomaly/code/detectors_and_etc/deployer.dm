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
	var/current_beacon_type = "Green"

///Осмот
/obj/item/beacon_deployer/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_NOTICE("Its [stored_beacon_amount] inside."))
	to_chat(user, SPAN_GOOD("Use Alt + LBM to swap flag color."))
	to_chat(user, SPAN_GOOD("User Cntrl + LBM to unload some flags."))

/obj/item/beacon_deployer/AltClick()
	current_beacon_type = input(usr, "Choose flag color","Choose") as null|anything in list("Green", "Red", "Yellow", "Blue")
	return TRUE

/obj/item/beacon_deployer/CtrlClick()
	deploy_beacon(usr, FALSE, 10)
	return TRUE


///Кнопка слева сверху для деплоера
/obj/item/beacon_deployer/verb/use_deployer()
	set category = "Object"
	set name = "Use flag deployer"
	set src in usr

	if(!usr.incapacitated())
		check_current_turf(usr)
		usr.update_action_buttons()


/obj/item/beacon_deployer/use_tool(obj/item/item, mob/living/user, list/click_params)
	. = ..()
	if(istype(item,/obj/item/stack/flag))
		reload_deployer(user, item)

///Заряжает в деплоер флаги
/obj/item/beacon_deployer/proc/reload_deployer(mob/living/user, obj/item/stack/flag/item)
	if(stored_beacon_amount == max_beacon_amount) //Переполнен
		to_chat(user, SPAN_NOTICE("Deployer is full."))
		return
	//Определяемся, сколько передадим флажков
	var/transfer_amount = item.amount
	if(stored_beacon_amount + item.amount > max_beacon_amount)
		transfer_amount = max_beacon_amount - stored_beacon_amount //Не позволит переполнить запас
	if(transfer_amount > item.amount)
		transfer_amount = item.amount //Не позволит взять больше, чем есть в стаке
	item.use(transfer_amount)
	stored_beacon_amount += transfer_amount
	to_chat(user, SPAN_NOTICE("You inserted [transfer_amount] flags in autodeployer."))

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
		to_chat(user, SPAN_BAD("Deployer is empty."))
		return
	if(deploy_amount > 1)
		if(deploy_amount > stored_beacon_amount)
			deploy_amount = stored_beacon_amount
	var/type
	if(current_beacon_type == "Green")
		type = /obj/item/stack/flag/green
	else if(current_beacon_type == "Red")
		type = /obj/item/stack/flag/red
	else if(current_beacon_type == "Blue")
		type = /obj/item/stack/flag/blue
	else if(current_beacon_type == "Yellow")
		type = /obj/item/stack/flag/yellow
	if(!type)
		return
	var/obj/item/stack/flag/spawned_flag = new type(get_turf(src))
	spawned_flag.amount = deploy_amount
	stored_beacon_amount -= deploy_amount
	if(deploy)
		spawned_flag.set_up()
		playsound(src, 'sound/items/shuttle_beacon_complete.ogg', 50)






/obj/item/beacon_deployer/full
	stored_beacon_amount = 50
