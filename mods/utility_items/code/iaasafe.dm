// ИЗМЕНЕННЫЕ ДЛЯ ВИДА ПРЕДМЕТЫ
/obj/item/gun/projectile/automatic/iso
	name = "ISO-4 SMG"
	desc = "A compact submachine gun designed for NanoTrasen Internal Security Operatives. Useful when bureaucracy no longer helps."

/obj/item/clothing/suit/armor/pcarrier/iso
	accessories = list(/obj/item/clothing/accessory/armor_plate/tactical, /obj/item/clothing/accessory/arm_guards/heavy, /obj/item/clothing/accessory/leg_guards/heavy, /obj/item/clothing/accessory/storage/pouches/large)
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON


// СЕЙФ
/obj/item/storage/secure/safe/iaa
	icon = 'mods/utility_items/icons/isosafe.dmi'
	startswith = list(
		/obj/item/gun/projectile/automatic/iso = 1,
		/obj/item/ammo_magazine/proto_smg = 2,
		/obj/item/clothing/suit/armor/pcarrier/iso = 1,
		/obj/item/clothing/head/helmet = 1
	)

/obj/item/storage/secure/safe/iaa/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/storage/secure/safe/iaa/attack_hand(mob/user)
	if (locked)
		return
	else
		open(usr)

/obj/item/storage/secure/iaa/attack_self(mob/user)
	return

/obj/item/storage/secure/safe/iaa/use_tool(obj/item/W, mob/living/user, list/click_params)

	if(isid(W))
		var/obj/item/card/id/current_id = W
		var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
		if(has_access(list(access_iaa), current_id.access))
			if(locked)
				if(security_state.current_security_level.name == "code red")
					ClearOverlays()
					AddOverlays(image(icon, icon_opened))
					user.show_message(SPAN_NOTICE("You unlock \the [src]."))
					playsound(src, 'sound/machines/defib_SafetyOn.ogg', 100)
					locked = !locked
			else
				ClearOverlays()
				user.show_message(SPAN_NOTICE("You lock \the [src]."))
				playsound(src, 'sound/machines/defib_SafetyOff.ogg', 100)
				locked = !locked
			return TRUE
		else
			to_chat(user, SPAN_WARNING("\The [src] buzzes you off!"))
			playsound(src, 'sound/machines/defib_SafetyOff.ogg', 100)
			return TRUE

	if (!locked)
		return ..()

	if (istype(W, /obj/item/melee/energy/blade) && emag_act(INFINITY, user, "You slice through the lock of \the [src]"))
		var/datum/effect/spark_spread/spark_system = new /datum/effect/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, 1)
		return TRUE

	else
		to_chat(user, SPAN_WARNING("\The [src] is locked and cannot be opened!"))
		return TRUE
