/obj/item/mech_equipment/mounted_system/flamethrower
	name = "\improper \"Lynx\" flamethower"
	icon_state = "mech_flamer"
	heat_generation = 100
	holding_type = /obj/item/flamethrower/full/mech
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)

/obj/item/mech_equipment/mounted_system/flamethrower/need_combat_skill()
	return TRUE

/obj/item/mech_equipment/mounted_system/flamethrower/attack_self(mob/user)
	. = ..()
	if(owner && holding)
		update_icon()

/obj/item/mech_equipment/mounted_system/flamethrower/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(!CanPhysicallyInteract(user))
		return ..()

	var/obj/item/flamethrower/full/mech/FM = holding
	if(istype(FM))
		if(isCrowbar(W) && FM.beaker)
			if(FM.beaker)
				user.visible_message(SPAN_NOTICE("\The [user] pries out \the [FM.beaker] using \the [W]."))
				FM.beaker.dropInto(get_turf(user))
				FM.beaker = null
				return TRUE

		if (istype(W, /obj/item/reagent_containers) && W.is_open_container() && (W.w_class <= FM.max_beaker))
			if(FM.beaker)
				to_chat(user, SPAN_NOTICE("There is already a tank inserted!"))
				return TRUE
			if(user.unEquip(W, FM))
				user.visible_message(SPAN_NOTICE("\The [user] inserts \the [W] inside \the [src]."))
				FM.beaker = W
			return TRUE
	return ..()

/obj/item/mech_equipment/mounted_system/flamethrower/on_update_icon()
	if(owner && holding)
		var/obj/item/flamethrower/full/mech/FM = holding
		if(istype(FM))
			if(FM.lit)
				icon_state = "mech_flamer_lit"
			else icon_state = "mech_flamer"

			if(owner)
				owner.update_icon()

/obj/item/flamethrower/full/mech
	max_beaker = ITEM_SIZE_NORMAL
	range = 5
	desc = "A Hephaestus brand 'Prometheus' flamethrower. Bigger and better."
	var/mob/living/exosuit/owner

/obj/item/flamethrower/full/mech/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/chem_disp_cartridge(src)

/obj/item/flamethrower/full/mech/get_hardpoint_maptext()
	return beaker ? "[lit ? "ON" : "OFF"]-:-[beaker.reagents.total_volume]/[beaker.reagents.maximum_volume]" : "NO TANK"

/obj/item/flamethrower/full/mech/get_hardpoint_status_value()
	return beaker ? beaker.reagents.total_volume/beaker.reagents.maximum_volume : 0
