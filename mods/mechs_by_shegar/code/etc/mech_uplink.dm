GLOBAL_VAR_AS(max_mech, 0)
GLOBAL_VAR_AS(war_declared, FALSE)

//Запрос кристаллов
/datum/uplink_item/item/services/assault_declaration
	name = "Telecrystal Request"
	desc = "An telecrystal request, which will give you boost of 780 telecrystals, but their teleportation will be detected by sensor arrays of NSV Sierra. Can be bought obly in the five fist minutes of the round."
	item_cost = 1
	antag_roles = list(MODE_MERCENARY)

/datum/uplink_item/item/services/assault_declaration/get_goods(obj/item/device/uplink/U, loc)
	if(round_duration_in_ticks > 15 MINUTES)
		to_chat(usr, SPAN_BAD("Дополнительные средства не могут быть выделены, прошло слишком много времени."))
		return
	if(GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Дополнительные средства не могут быть выделены, превышен лимит средств."))
		return
	to_chat(usr, SPAN_GOOD("Запрос одобрен, доп средства выделены."))
	command_announcement.Announce("В секторе была замечена телепортация большого объема телекристаллов, использующихся Горлекскими Мародерами. Рекомендуется вызвать поддержку с ЦК для урегулирования ситуации.", "Показания датчиков [station_name()]" , msg_sanitized = 1, zlevels = GLOB.using_map.station_levels)
	GLOB.max_mech = 1
	GLOB.war_declared = TRUE
	var/singleton/public_access/public_method/open_door = GET_SINGLETON(/singleton/public_access/public_method/open_door)
	for(var/obj/machinery/door/blast/D as anything in SSmachines.get_machinery_of_type(/obj/machinery/door/blast))
		if(D.id_tag == "merc_war_door")
			open_door.perform(D)
	return new /obj/item/stack/telecrystal(loc, 781)
//Запрос кристаллов



//Вызов боевого меха
/datum/uplink_item/item/structures_and_vehicles/combat_mech
	name = "Combat Mech"
	var/static/BOUGHT_MECH = 0
	desc = "A terrible and at the same time beautiful combat mech to destroy all living things in your way. Comes with laser and energy drone! Have NO armour plates."
	item_cost = 300
	antag_roles = list(MODE_MERCENARY)

/datum/uplink_item/item/structures_and_vehicles/combat_mech/get_goods(obj/item/device/uplink/U, loc, mob/user)
	if(!GLOB.war_declared)
		to_chat(user, SPAN_BAD("Запрос не оформлен, бронетехника не может быть вызвана. Запросите доп. средства для получения доступа к бронетехнике."))
		return new /obj/item/stack/telecrystal(loc, cost(U.uses, U))
	if(GLOB.max_mech <= 0)
		to_chat(user, SPAN_BAD("Превышен лимит бронетехники для данной миссии."))
		return new /obj/item/stack/telecrystal(loc, cost(U.uses, U))
	GLOB.max_mech--
	to_chat(user, SPAN_GOOD("Запрос на бронетехнику Горлекса обработан, единица телепортирована на ваше местоположение."))
	command_announcement.Announce("В секторе была замечена телепортация бронетехники Мародёров Горлекса.", "Показания датчиков [station_name()]" , msg_sanitized = 1, zlevels = GLOB.using_map.station_levels)
	return new /mob/living/exosuit/premade/merc(loc)
//Вызов боевого меха



//Броня мехов: сумки с внешними бронеэлементами
/datum/uplink_item/item/structures_and_vehicles/armour_kit
	antag_roles = list(MODE_MERCENARY)
	item_cost = 100
	///Сумки, которые приходят с покупкой
	var/list/bag_types

/datum/uplink_item/item/structures_and_vehicles/armour_kit/get_goods(obj/item/device/uplink/U, loc, mob/user)
	if(!GLOB.war_declared)
		to_chat(user, SPAN_BAD("Запрос не оформлен, снаряжение меха не доступно."))
		return new /obj/item/stack/telecrystal(loc, cost(U.uses, U))
	for(var/bag_type in bag_types)
		. = new bag_type(loc)

/datum/uplink_item/item/structures_and_vehicles/armour_kit/buletproof_mech
	name = "Bag with buletproof armor plates for mechs"
	desc = "Have 12 buletproof plates inside."
	bag_types = list(
		/obj/item/storage/backpack/dufflebag/syndie/buletproof_plates,
		/obj/item/storage/backpack/dufflebag/syndie/buletproof_plates
	)

/datum/uplink_item/item/structures_and_vehicles/armour_kit/laserproof_mech
	name = "Bag with laserproof armor plates for mechs"
	desc = "Have 12 laserproof plates inside."
	bag_types = list(
		/obj/item/storage/backpack/dufflebag/syndie/laserproof_plates,
		/obj/item/storage/backpack/dufflebag/syndie/laserproof_plates
	)

/datum/uplink_item/item/structures_and_vehicles/armour_kit/buletproof_and_laserproof_mech
	name = "Bag with laser and bulet proof armor plates for mech"
	desc = "Have 6 buletproof and 6 laserproof plates inside."
	bag_types = list(
		/obj/item/storage/backpack/dufflebag/syndie/buletproof_plates,
		/obj/item/storage/backpack/dufflebag/syndie/laserproof_plates
	)

//Сами сумки с бронёй
/obj/item/storage/backpack/dufflebag/syndie/buletproof_plates
	startswith = list(/obj/item/mech_external_armor/buletproof = 6)

/obj/item/storage/backpack/dufflebag/syndie/laserproof_plates
	startswith = list(/obj/item/mech_external_armor/laserproof = 6)
//Броня мехов



//БК на пулемёт меха
/datum/uplink_item/item/structures_and_vehicles/mech_ammo
	name = "Mech machinegun ammo"
	desc = "Box with high-caliber bullets for mech machinegun. 200 bullets inside!"
	antag_roles = list(MODE_MERCENARY)
	item_cost = 50
	path = /obj/item/ammo_magazine/rifle/mech_machinegun
//БК на пулемёт меха
