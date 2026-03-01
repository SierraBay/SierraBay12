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
	return new /obj/item/stack/telecrystal(loc, 781)
//Запрос кристаллов



//Вызов боевого меха
/datum/uplink_item/item/structures_and_vehicles/combat_mech
	name = "Combat Mech"
	var/static/BOUGHT_MECH = 0
	desc = "A terrible and at the same time beautiful combat mech to destroy all living things in your way. Comes with laser and energy drone! Have NO armour plates."
	item_cost = 300
	antag_roles = list(MODE_MERCENARY)

/datum/uplink_item/item/structures_and_vehicles/combat_mech/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Запрос не оформлен, бронетехника не может быть вызвана. Запросите доп. средства для получения доступа к бронетехнике."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	if(GLOB.max_mech <= 0)
		to_chat(usr, SPAN_BAD("Превышен лимит бронетехники для данной миссии."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	GLOB.max_mech--
	to_chat(usr, SPAN_GOOD("Запрос на бронетехнику Горлекса обработан, единица телепортирована на ваше местоположение."))
	command_announcement.Announce("В секторе была замечена телепортация бронетехники Мародёров Горлекса.", "Показания датчиков [station_name()]" , msg_sanitized = 1, zlevels = GLOB.using_map.station_levels)
	return new /mob/living/exosuit/premade/merc(loc)



//СМГ меха вместе с патронами
/datum/uplink_item/item/structures_and_vehicles/smg_mech_kit
	name = "Mech machinegun"
	desc = "Mech highcapacity machinegun with a box of ammo!"
	antag_roles = list(MODE_MERCENARY)
	item_cost = 100

/datum/uplink_item/item/structures_and_vehicles/smg_mech_kit/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Запрос не оформлен, снаряжение меха не доступно."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	new /obj/item/mech_equipment/mounted_system/taser/ballistic/smg/high_capacity(loc)
	return new /obj/item/ammo_magazine/proto_smg/mech/high_capacity(loc)




//Ракетомёт с зажигательными
/datum/uplink_item/item/structures_and_vehicles/rocket_mech_kit
	name = "Mech rocket launch system"
	desc = "Rocket system with incendary rockets!"
	antag_roles = list(MODE_MERCENARY)
	item_cost = 100

/datum/uplink_item/item/structures_and_vehicles/rocket_mech_kit/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Запрос не оформлен, снаряжение меха не доступно."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	new /obj/item/mech_equipment/mounted_system/taser/ballistic/launcher/merc(loc)
	new /obj/item/ammo_magazine/rockets_casing/fire/high_capacity(loc)
	return new /obj/item/ammo_magazine/rockets_casing/fire/high_capacity(loc)



//Броня мехов
/datum/uplink_item/item/structures_and_vehicles/armour_kit/buletproof_mech
	name = "Bag with buletproof armor plates for mechs"
	desc = "Have 12 buletproof plates inside."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 100


/datum/uplink_item/item/structures_and_vehicles/armour_kit/buletproof_mech/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Запрос не оформлен, снаряжение меха не доступно."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	new /obj/item/storage/backpack/dufflebag/syndie/buletproof_plates(loc)
	return new /obj/item/storage/backpack/dufflebag/syndie/buletproof_plates(loc)


/datum/uplink_item/item/structures_and_vehicles/armour_kit/laserproof_mech
	name = "Bag with laserproof armor plates for mechs"
	desc = "Have 12 laserproof plates inside."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 100

/datum/uplink_item/item/structures_and_vehicles/armour_kit/laserproof_mech/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Запрос не оформлен, снаряжение меха не доступно."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	new /obj/item/storage/backpack/dufflebag/syndie/laserproof_plates(loc)
	return new /obj/item/storage/backpack/dufflebag/syndie/laserproof_plates(loc)

/datum/uplink_item/item/structures_and_vehicles/armour_kit/buletproof_and_laserproof_mech
	name = "Bag with laser and bulet proof armor plates for mech"
	desc = "Have 6 buletproof and 6 laserproof plates inside."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 100

/datum/uplink_item/item/structures_and_vehicles/armour_kit/buletproof_and_laserproof_mech/get_goods(obj/item/device/uplink/U, loc)
	if(!GLOB.war_declared)
		to_chat(usr, SPAN_BAD("Запрос не оформлен, снаряжение меха не доступно."))
		return new /obj/item/stack/telecrystal(loc, item_cost)
	new /obj/item/storage/backpack/dufflebag/syndie/buletproof_plates(loc)
	return new /obj/item/storage/backpack/dufflebag/syndie/laserproof_plates(loc)



//Сами сумки с бронёй
/obj/item/storage/backpack/dufflebag/syndie/buletproof_plates
	startswith = list(
		/obj/item/mech_external_armor/buletproof,
		/obj/item/mech_external_armor/buletproof,
		/obj/item/mech_external_armor/buletproof,
		/obj/item/mech_external_armor/buletproof,
		/obj/item/mech_external_armor/buletproof,
		/obj/item/mech_external_armor/buletproof
	)

/obj/item/storage/backpack/dufflebag/syndie/laserproof_plates
	startswith = list(
		/obj/item/mech_external_armor/laserproof,
		/obj/item/mech_external_armor/laserproof,
		/obj/item/mech_external_armor/laserproof,
		/obj/item/mech_external_armor/laserproof,
		/obj/item/mech_external_armor/laserproof,
		/obj/item/mech_external_armor/laserproof
	)
