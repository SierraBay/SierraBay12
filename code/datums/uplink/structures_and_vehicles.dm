/datum/uplink_item/item/structures_and_vehicles
	category = /datum/uplink_category/structures_and_vehicles


/datum/uplink_item/item/structures_and_vehicles/ofd_charge_fire
	name = "FR1-ENFER charge"
	desc = "An obstruction field disperser charge that causes a localised fire."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 80
	path = /obj/structure/ship_munition/disperser_charge/fire


/datum/uplink_item/item/structures_and_vehicles/ofd_charge_emp
	name = "EM2-QUASAR charge"
	desc = "An obstruction field disperser charge that emits an electromagnetic pulse."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 80
	path = /obj/structure/ship_munition/disperser_charge/emp


/datum/uplink_item/item/structures_and_vehicles/ofd_charge_explosive
	name = "XP4-INDARRA charge"
	desc = "An obstruction field disperser charge that explodes."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 80
	path = /obj/structure/ship_munition/disperser_charge/explosive


/datum/uplink_item/item/structures_and_vehicles/ofd_charge_mining
	name = "MN3-BERGBAU charge"
	desc = "An obstruction field disperser charge that extracts ore."
	antag_roles = list(MODE_MERCENARY)
	item_cost = 80
	path = /obj/structure/ship_munition/disperser_charge/mining

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

/datum/uplink_item/item/structures_and_vehicles/mech_ammo
	name = "Mech machinegun ammo"
	desc = "Box with high-caliber bullets for mech machinegun. 200 bullets inside!"
	antag_roles = list(MODE_MERCENARY)
	item_cost = 50
	path = /obj/item/ammo_magazine/rifle/mech_machinegun
