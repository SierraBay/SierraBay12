/obj/item/bolt
	name = "Bolt"
	desc = "A simple bolt, kindly twisted for you by engineers."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt"
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 200)

/obj/item/bolt/Crossed(O)
	. = ..()
	if(ishuman(usr))
		for(var/obj/item/storage/bolt_bag/bag in usr)
			if(bag.autocollect)
				if(bag.can_be_inserted(src, usr, 0))
					src.forceMove(bag)

/obj/item/storage/bolt_bag
	name = "Bag with bolts"
	desc = "Sturdy bolt storage bag."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt_bag"
	action_button_name = "Pull out from bag"
	allow_quick_gather = TRUE
	allow_quick_empty  = TRUE
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 10
	var/autocollect = TRUE

/obj/item/storage/bolt_bag/attack_self(mob/living/user)
	if(LAZYLEN(contents))
		usr.put_in_hands(pick(contents))


/obj/item/storage/bolt_bag/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_GOOD("Нажмите ПКМ по мешку, выберите toggle autocollect для переключения режима автоподбора."))

/obj/item/storage/bolt_bag/verb/toggle_autocollect()
	set category = "Object"
	set name = "toggle autocollect"
	set src in usr

	autocollect = !autocollect
	if(autocollect)
		to_chat(usr, SPAN_GOOD("Теперь вы автоматически складываете болты/маяки в мешочек при пересечении с ними."))
	else
		to_chat(usr, SPAN_BAD("Больше вы НЕ складываете автоматически болты/маяки в мешочек при пересечении с ними."))

/obj/item/storage/bolt_bag/full_of_bolts
	startswith = list(
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt
	)

//Адвансед болд
/obj/item/bolt/advanced_bolt
	name = "anomaly beacon"
	desc = "Small device for detecting static electric field."
	icon_state = "beacon_green"

/obj/item/bolt/advanced_bolt/Move()
	. = ..()
	on_update_icon()

/obj/item/bolt/advanced_bolt/dropped(mob/user)
	. = ..()
	on_update_icon()

/obj/item/bolt/advanced_bolt/add_fingerprint(mob/M, ignoregloves, obj/item/tool)
	on_update_icon()
	. = ..()

/obj/item/bolt/advanced_bolt/on_update_icon()
	. = ..()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return
	if(LAZYLEN(current_turf.list_of_in_range_anomalies))
		icon_state = "beacon_red"
	else
		icon_state = "beacon_green"

/obj/item/storage/bolt_bag/full_of_beacons
	name = "Bag with beacons"
	desc = "Sturdy beacon storage bag."
	startswith = list(
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt,
		/obj/item/bolt/advanced_bolt
	)

/datum/design/item/bluespace/beacon
	name = "electrostatis beacon"
	desc = "Small metal beacon with simple electronic inside which can detect powerfull electrostatic field."
	id = "electro_beacon"
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 2, TECH_POWER = 2)
	build_path = /obj/item/bolt/advanced_bolt
	materials = list(MATERIAL_ALUMINIUM = 500, MATERIAL_STEEL = 500, MATERIAL_PLASTIC = 500)
	sort_string = "VAWAB"

//Ниже будут изменяться matter у разных предметов, чтоб те имели в составе железо и подобное
/obj/item/ammo_casing
	matter = list(MATERIAL_STEEL = 10) //Мало, чтоб не абузили

/obj/item/tank
	matter = list(MATERIAL_STEEL = 100)
