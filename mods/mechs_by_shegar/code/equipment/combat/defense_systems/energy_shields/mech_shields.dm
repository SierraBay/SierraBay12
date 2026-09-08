#define NORMAL_MODE 1 //Стандартный режим работы энергощита
#define WIDE_MODE 2
/obj/item/mech_equipment/shields
	name = "exosuit shield droid"
	desc = "The Hephaestus Armature system is a well liked energy deflector system designed to stop any projectile before it has a chance to become a threat."
	icon_state = "shield_droid"
	var/obj/aura/mechshield/aura = null
	var/max_charge = 150
	var/charge = 150
	var/last_recharge = 0
	var/charging_rate = 7500 * CELLRATE
	var/cooldown = 4 SECONDS //Time until we can recharge again after a blocked impact
	restricted_hardpoints = list(HARDPOINT_BACK)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)
	var/OVERHEAT = FALSE
	var/last_overheat = 0
	var/overheat_cooldown = 50 SECONDS //Огромное окно для пробития меха.
	var/current_mode = NORMAL_MODE
//	can_be_pickuped = TRUE
	//Содержит в себе список установленных вспомогательных частей щита.
	var/list/deployed_wide_parts = list()

/obj/item/mech_equipment/shields/installed(mob/living/exosuit/_owner)
	. = ..()
	aura = new(owner, src)

/obj/item/mech_equipment/shields/need_combat_skill()
	return TRUE

///Альтернативным режимом у энергощита является щит шириною в 3 тайла для поддержки союзников
/obj/item/mech_equipment/shields/AltClick(mob/living/pilot)
	. = ..()
	if(current_mode == NORMAL_MODE)
		current_mode = WIDE_MODE
	else if(current_mode == WIDE_MODE)
		current_mode = NORMAL_MODE
	//После того как мы сменили мод, нужно попросить игру апдейтнуть состояние
	update_wide_mode_status()

///Обновит состояние вспомогательных частей энергощита
/obj/item/mech_equipment/shields/proc/update_wide_mode_status()
	//Если энергощит не активен, зачем нам что-то обновлять?
	if(!active)
		return
	//Если щит активен, вспомогательные не установлены и установлен широкий мод - надо установить вспомогательные части
	if(!LAZYLEN(deployed_wide_parts) && active && current_mode == WIDE_MODE)
		deploy_shields_helpers()
	if(LAZYLEN(deployed_wide_parts) && !active)
		undeploy_shields_helpers()

///Функция разложит вспомогательные части энергощита
/obj/item/mech_equipment/shields/proc/deploy_shields_helpers()
	var/obj/mech_shield_hepler/left_shield_helper = new /obj/mech_shield_hepler(get_ranged_target_turf(get_turf(src),turn(owner.dir, 90) ,1))
	var/obj/mech_shield_hepler/right_shield_helper = new /obj/mech_shield_hepler(get_ranged_target_turf(get_turf(src),turn(owner.dir, -90) ,1))
	left_shield_helper.dir = owner.dir
	right_shield_helper.dir = owner.dir
	LAZYADD(deployed_wide_parts, list(left_shield_helper, right_shield_helper))

///Функция сложит вспомогательные части энергощита
/obj/item/mech_equipment/shields/proc/undeploy_shields_helpers()
	for(var/obj/mech_shield_hepler/picked in deployed_wide_parts)
		qdel(picked)


///Этот обьект является вспомогательной частью энергощита
/obj/mech_shield_hepler
	//Энергощит, "сыном" которого он и является.
	var/obj/item/mech_equipment/shields/owner
	icon_state = "shield"



/obj/item/mech_equipment/shields/proc/stop_damage(damage)
	var/difference = damage - charge
	charge = clamp(charge - damage, 0, max_charge)

	last_recharge = world.time
	owner.add_heat(difference)
	if(difference >= 0)
		toggle()
		OVERHEAT = TRUE
		src.visible_message("The energy shield flashes and blinks in separate sections, then suddenly disappears, emitting a sad hum.")
		playsound(owner.loc,'mods/mechs_by_shegar/sounds/mecha_shield_deflector_fail.ogg',60,0)
		update_icon()
		last_overheat = world.time
		delayed_toggle()
		return difference
	else return 0

/obj/item/mech_equipment/shields/proc/toggle()
	if(charge == -1)
		charge = 0
		src.visible_message("The mech's computer flashes: WARNING! Shield overheat detected!","The mech's computer beeps, reporting a shield error!",0) //[INF] Для предотвращения абуза
		playsound(owner.loc,'mods/mechs_by_shegar/sounds/mecha_shield_deflector_fail.ogg',60,0)
		OVERHEAT = TRUE
		update_icon()
		delayed_toggle()
		return
	if(OVERHEAT)
		if((world.time - last_overheat) < overheat_cooldown)
			src.visible_message("Shields still overheated!","Shields still overheated!",0)
			return
	if(!aura)
		return
	aura.toggle()
	update_icon()
	if(aura.active)
		playsound(owner,'mods/mechs_by_shegar/sounds/mecha_mech_shield_up.ogg',50,0)
		START_PROCESSING(SSobj, src)
	else
		playsound(owner,'mods/mechs_by_shegar/sounds/mecha_mech_shield_down.ogg',50,1)
		STOP_PROCESSING(SSobj, src)
	active = aura.active
	passive_power_use = active ? 1 KILOWATTS : 0
	owner.update_icon()



/obj/item/mech_equipment/shields/Process()
	//Обновление спрайта с течением времени
	if(charge < max_charge)
		aura.on_update_icon()
	if((world.time - last_recharge) < cooldown)
		return
	if(charge >= max_charge)
		var/obj/item/cell/cell = owner.get_cell()
		cell.use(charging_rate/4)
		return
	var/obj/item/cell/cell = owner.get_cell()
	var/actual_required_power = 2*clamp(max_charge - charge, 0, charging_rate)
	if(cell)
		var/value = cell.use(actual_required_power)
		charge += value
		owner.add_heat(value)

/obj/item/mech_equipment/shields/proc/delayed_toggle() //Отложит поднятие щита на опр время, без вреда работы коду
	set waitfor = 0
	if(charge == -1)
		return
	sleep(overheat_cooldown)
	if(OVERHEAT)
		src.visible_message("Overheat terminated,energy shield automaticly up!","Overheat terminated,energy shield automaticly up",0)
		charge=200
		OVERHEAT = FALSE
		update_icon()
		toggle()
		var/obj/item/cell/cell = owner.get_cell()
		cell.use(max_charge)
	else
		OVERHEAT = TRUE
		delayed_toggle()

/obj/item/mech_equipment/shields/uninstalled()
	QDEL_NULL(aura)
	toggle() //Предотвратит обработку оного когда он не в мехе
	. = ..()

/obj/item/mech_equipment/shields/attack_self(mob/user)
	. = ..()
	if(.)
		toggle()

/obj/item/mech_equipment/shields/deactivate()
	if(active)
		toggle()
	..()

/obj/item/mech_equipment/shields/on_update_icon()
	if(OVERHEAT)
		icon_state= "shield_droid_overheat"
		return
	if(!aura)
		return
	if(aura.active)
		icon_state = "shield_droid_a"
	else
		icon_state = "shield_droid"

/obj/item/mech_equipment/shields/Process()
	if(charge >= max_charge)
		return
	if((world.time - last_recharge) < cooldown)
		return
	var/obj/item/cell/cell = owner.get_cell()

	var/actual_required_power = clamp(max_charge - charge, 0, charging_rate)

	if(cell)
		charge += cell.use(actual_required_power)

/obj/item/mech_equipment/shields/get_hardpoint_status_value()
	return charge / max_charge

/obj/item/mech_equipment/shields/get_hardpoint_maptext()
	if(OVERHEAT)
		return "["OVERHEAT!"]"
	else
		return "[(aura && aura.active) ? "ONLINE" : "OFFLINE"]: [round((charge / max_charge) * 100)]%"
