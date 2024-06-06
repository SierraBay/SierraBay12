GLOBAL_VAR_INIT(max_mech, 0)
GLOBAL_VAR_INIT(war_declared, FALSE)

//Запрос кристаллов
/datum/uplink_item/item/services/assault_declaration
	name = "Telecrystal Request"
	desc = "An telecrystal request, which will give you boost of 780 telecrystals, but their teleportation will be detected by sensor arrays of NSV Sierra. Can be bought obly in the five fist minutes of the round."
	item_cost = 1
	antag_roles = list(MODE_MERCENARY)

/datum/uplink_item/item/services/assault_declaration/get_goods(obj/item/device/uplink/U, loc)
	if(world.time > 10 MINUTES || GLOB.war_declared)
		U.visible_message("[U.loc] buzzez and declares, \"Unable to teleport telecrystals.\"")
		return 0
	command_announcement.Announce("В секторе была замечена телепортация большого объема телекристаллов, использующихся Горлекскими Мародерами. Рекомендуется вызвать поддержку с ЦК для урегулирования ситуации.", "Показания датчиков [station_name()]" , msg_sanitized = 1, zlevels = GLOB.using_map.station_levels)
	GLOB.max_mech = 1
	GLOB.war_declared = TRUE
	return new /obj/item/stack/telecrystal(loc, 781)
//Запрос кристаллов



//Вызов боевого меха
/datum/uplink_item/item/structures_and_vehicles/mech
	name = "Combat Mech"
	var/static/BOUGHT_MECH = 0
	desc = "A terrible and at the same time beautiful combat mech to destroy all living things in your way. Comes with special plasma rifle, machinegun and shielding drone. Also, it is almoust EMP-proof!"
	item_cost = 400
	antag_roles = list(MODE_MERCENARY)

/datum/uplink_item/item/structures_and_vehicles/mech/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		U.visible_message("[U.loc] Война не обьявлена, бронетехника не может быть вызвана. Обьявите войну для получения доступа к бронетехнике.\"")
		return new /obj/item/stack/telecrystal(loc, 400)
	if(GLOB.max_mech <= 0)
		U.visible_message("[U.loc] Превышен лимит бронетехники для данной миссии.\"")
		return new /obj/item/stack/telecrystal(loc, 400)
	GLOB.max_mech--
	U.visible_message("[U.loc] Запрос на бронетехнику Горлекса обработан, единица телепортирована на ваше местоположение.\"")
	command_announcement.Announce("В секторе была замечена телепортация бронетехники Мародёров Горлекса.", "Показания датчиков [station_name()]" , msg_sanitized = 1, zlevels = GLOB.using_map.station_levels)
	return new /mob/living/exosuit/premade/merc(loc)
//Вызов боевого меха



//БК на пулемёт меха
/datum/uplink_item/item/structures_and_vehicles/mech_ammo
	name = "Mech machinegun ammo"
	desc = "Box with high-caliber bullets for mech machinegun. 200 bullets inside!"
	antag_roles = list(MODE_MERCENARY)
	item_cost = 50
	path = /obj/item/ammo_magazine/rifle/mech_machinegun
//БК на пулемёт меха
