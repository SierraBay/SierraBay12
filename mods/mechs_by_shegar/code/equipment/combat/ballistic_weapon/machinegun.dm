//Пулемёт
/obj/item/mech_equipment/mounted_system/taser/ballistic
	name = "\improper Military \"Vulcan\" machinegun"
	desc = "Military mounted machinegun for combat mechs."
	icon_state = "mech_scatter"
	holding_type = /obj/item/gun/projectile/automatic/assault_rifle/mounted

/obj/item/mech_equipment/mounted_system/taser/ballistic/need_combat_skill()
	return TRUE

/obj/item/mech_equipment/mounted_system/taser/ballistic/attack_hand(mob/user)
	holding.unload_ammo(user, allow_dump=0)
	get_hardpoint_maptext()

/obj/item/mech_equipment/mounted_system/taser/ballistic/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(!holding.ammo_magazine)
		holding.load_ammo(item,user)
		get_hardpoint_maptext()
	. = ..()

/obj/item/gun/projectile/automatic/assault_rifle/mounted
	name = "mech machinegun"
	desc = "Very big machinegun with classic calibre."
	icon = 'icons/obj/guns/saw.dmi'
	force = 10
	burst = 3
	accuracy = 1
	bulk = GUN_BULK_RIFLE
	caliber = CALIBER_RIFLE
	w_class = ITEM_SIZE_HUGE
	one_hand_penalty= 0
	load_method = SINGLE_CASING|SPEEDLOADER
	max_shells = 200
	ammo_type = /obj/item/ammo_casing/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle/mech_machinegun
	has_safety = FALSE
	firemodes = list(
		list("mode_name" = "semi auto", burst=4, fire_delay=null, move_delay=null, one_hand_penalty=8, burst_accuracy=null, dispersion=null),
		)

/obj/item/mech_equipment/mounted_system/taser/ballistic/mounted/need_combat_skill()
	return TRUE

/obj/item/ammo_magazine/rifle/mech_machinegun
	max_ammo = 200
	icon_state = "machinegun"
	mag_type = SPEEDLOADER
	w_class = ITEM_SIZE_HUGE
//Пулемёт
