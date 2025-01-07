/obj/item/advanced_bolt
	name = "anomaly beacon"
	desc = "Small device for detecting static electric field."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "beacon_green"
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 200)

/obj/item/advanced_bolt/Crossed(O)
	. = ..()
	if(ishuman(usr))
		for(var/obj/item/storage/bolt_bag/bag in usr)
			if(bag.autocollect)
				bag.can_be_inserted(src, usr, 0)
				src.forceMove(bag)

/obj/item/advanced_bolt/Move()
	. = ..()
	on_update_icon()


/obj/item/advanced_bolt/dropped(mob/user)
	. = ..()
	on_update_icon()


/obj/item/advanced_bolt/add_fingerprint(mob/M, ignoregloves, obj/item/tool)
	on_update_icon()
	. = ..()




/obj/item/advanced_bolt/on_update_icon()
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
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt,
		/obj/item/advanced_bolt
	)

/datum/design/item/bluespace/beacon
	name = "electrostatis beacon"
	desc = "Small metal beacon with simple electronic inside which can detect powerfull electrostatic field."
	id = "electro_beacon"
	req_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 2, TECH_POWER = 2)
	build_path = /obj/item/advanced_bolt
	materials = list(MATERIAL_ALUMINIUM = 500, MATERIAL_STEEL = 500, MATERIAL_PLASTIC = 500)
	sort_string = "VAWAB"
