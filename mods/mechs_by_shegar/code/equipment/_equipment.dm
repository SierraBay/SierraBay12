// Defining all of this here so it's centralized.
// Used by the exosuit HUD to get a 1-10 value representing charge, ammo, etc.
/obj/item/mech_equipment
	name = "mech hardpoint system"
	icon = 'mods/mechs_by_shegar/icons/mech_equipment.dmi'
	icon_state = ""
	matter = list(MATERIAL_STEEL = 10000, MATERIAL_PLASTIC = 5000, MATERIAL_OSMIUM = 500)
	force = 10
//	var/can_be_pickuped = FALSE

	var/list/restricted_hardpoints
	var/mob/living/exosuit/owner
	var/list/restricted_software

	var/equipment_delay = 0
	var/active_power_use = 1 KILOWATTS // How much does it consume to perform and accomplish usage
	var/passive_power_use = 0          // For gear that for some reason takes up power even if it's supposedly doing nothing (mech will idly consume power)
	var/mech_layer = MECH_GEAR_LAYER //For the part where it's rendered as mech gear
	var/require_adjacent = TRUE
	var/active = FALSE //For gear that has an active state (ie, floodlights)
	/// Отвечает за то, мешает ли модуль посадке пассажира в занятый хардпоинт.
	var/disturb_passengers = FALSE
	///Сколько тепла выделяется за каждое использование этого модуля
	var/heat_generation = 0
	///Генерация тепла от модуля при активном состоянии оного
	var/active_heat_generation = 0

	/// Замедление при переноске
	var/slowdown_held = 3 // Yes, you can carry it. But this thing is cumbersome.

/obj/item/mech_component/Initialize()
	slowdown_per_slot[slot_l_hand] =  slowdown_held
	slowdown_per_slot[slot_r_hand] =  slowdown_held

	. = ..()

/*
/obj/item/mech_equipment/attack_hand(mob/user)
	if(!can_be_pickuped && !owner)
		to_chat(user, SPAN_BAD("Я такое не подниму!"))
		return
	else
		.=..()
*/

/obj/item/mech_equipment/MouseDrop(atom/over_atom, atom/source_loc, atom/over_loc, source_control, over_control, list/mouse_params)
	if(!CanMouseDrop(over_atom, usr))
		return
	if(istype(over_atom, /mob/living/exosuit))
		var/obj/structure/heavy_vehicle_frame/input_frame = over_atom
		input_frame.use_tool(src, usr)

///Требуется ли скилл БОЕВОЙ ОПЫТ в пилотировании мехов чтоб использовать этот модуль
/obj/item/mech_equipment/proc/need_combat_skill()
	return FALSE

///Некоторые модули могут по своему реагировать на ближнюю атаку, например железный щит или флэш
/obj/item/mech_equipment/proc/have_specific_melee_attack()
	return FALSE

///Данный модуль может быть починен. К примеру - железный щит
/obj/item/mech_equipment/proc/can_be_repaired()
	return FALSE

/obj/item/mech_equipment/proc/try_repair_module(tool, user)
	return FALSE

/obj/item/mech_equipment/afterattack(atom/target, mob/living/user, inrange, params)
	if(require_adjacent)
		if(!inrange)
			return 0
	if (owner && loc == owner && ((user in owner.pilots) || user == owner))
		if(target in owner.contents)
			return 0

		if(!(owner.get_cell()?.check_charge(active_power_use * CELLRATE)))
			to_chat(user, SPAN_WARNING("The power indicator flashes briefly as you attempt to use \the [src]"))
			return 0
		return 1
	else
		return 0

/obj/item/mech_equipment/attack_self(mob/user)
	if (owner && loc == owner && ((user in owner.pilots) || user == owner))
		if(!(owner.get_cell()?.check_charge(active_power_use * CELLRATE)))
			to_chat(user, SPAN_WARNING("The power indicator flashes briefly as you attempt to use \the [src]"))
			return 0
		return 1
	else
		return 0

/obj/item/mech_equipment/examine(mob/user, distance)
	. = ..()
	if(user.skill_check(SKILL_DEVICES, SKILL_BASIC))
		if(length(restricted_software))
			to_chat(user, SPAN_SUBTLE("It seems it would require [english_list(restricted_software)] to be used."))
		if(length(restricted_hardpoints))
			to_chat(user, SPAN_SUBTLE("You figure it could be mounted in the [english_list(restricted_hardpoints)]."))

/obj/item/mech_equipment/proc/deactivate()
	active = FALSE
	return

/obj/item/mech_equipment/proc/installed(mob/living/exosuit/_owner)
	owner = _owner
	//generally attached. Nothing should be able to grab it
	canremove = FALSE

/obj/item/mech_equipment/proc/uninstalled()
	if(active)
		deactivate()
	owner = null
	canremove = TRUE

/obj/item/mech_equipment/proc/wreck() //Module has been destroyed
	return

/obj/item/mech_equipment/Destroy()
	owner = null
	. = ..()

/obj/item/mech_equipment/proc/get_effective_obj()
	return src

/obj/item/mech_equipment/proc/MouseDragInteraction(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	//Get intent updated
	if(user != owner)
		owner.a_intent = user.a_intent
	if(user.zone_sel)
		owner.zone_sel.set_selected_zone(user.zone_sel.selecting)
	else
		owner.zone_sel.set_selected_zone(BP_CHEST)

/obj/item/mech_equipment/mob_can_unequip(mob/M, slot, disable_warning)
	. = ..()
	if(. && owner)
		//Installed equipment shall not be unequiped.
		return FALSE

/obj/item/mech_equipment/mounted_system
	var/holding_type
	var/obj/item/gun/projectile/holding

/obj/item/mech_equipment/mounted_system/attack_self(mob/user)
	. = ..()
	if(. && holding)
		return holding.attack_self(user)

/obj/item/mech_equipment/mounted_system/proc/forget_holding()
	if(holding) //It'd be strange for this to be called with this var unset
		GLOB.destroyed_event.unregister(holding, src, .proc/forget_holding)
		holding = null
		qdel(src)

/obj/item/mech_equipment/mounted_system/Initialize()
	. = ..()
	if(holding_type)
		holding = new holding_type(src)
		GLOB.destroyed_event.register(holding, src, .proc/forget_holding)
	if(holding)
		if(!icon_state)
			icon = holding.icon
			icon_state = holding.icon_state


/obj/item/mech_equipment/mounted_system/Destroy()
	GLOB.destroyed_event.unregister(holding, src, .proc/forget_holding)
	if(holding)
		QDEL_NULL(holding)
	. = ..()


/obj/item/mech_equipment/mounted_system/get_effective_obj()
	return (holding ? holding : src)

/obj/item/mech_equipment/mounted_system/get_hardpoint_status_value()
	return (holding ? holding.get_hardpoint_status_value() : null)

/obj/item/mech_equipment/mounted_system/get_hardpoint_maptext()
	return (holding ? holding.get_hardpoint_maptext() : null)

/obj/item/proc/get_hardpoint_status_value()
	return null

/obj/item/proc/get_hardpoint_maptext()
	return null

/obj/item/mech_equipment/mounted_system/get_cell()
	if(owner && loc == owner)
		return owner.get_cell()
	return null

//Задача функции - проверить, может ли использоваться модуль. Код идентичен /obj/item/mech_equipment/afterattck
// Но данная функция написана для возможности модовых мехов
/obj/item/mech_equipment/proc/module_can_be_used(atom/target, mob/living/user, inrange)
	if(require_adjacent)
		if(!inrange)
			return FALSE
	if (owner && loc == owner && ((user in owner.pilots) || user == owner))
		if(target in owner.contents)
			return FALSE

		if(!(owner.get_cell()?.check_charge(active_power_use * CELLRATE)))
			to_chat(user, SPAN_WARNING("The power indicator flashes briefly as you attempt to use \the [src]"))
			return FALSE
		return TRUE
	else
		return FALSE
