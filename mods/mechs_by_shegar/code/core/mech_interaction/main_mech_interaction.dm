/mob/living/MouseDrop(atom/over)
	if(usr == src && usr != over)
		if(istype(over, /mob/living/exosuit))
			var/mob/living/exosuit/exosuit = over
			if(exosuit.body)
				//Пилот должен быть определённых размеров и не быть киборгом
				if(usr.mob_size >= exosuit.body.min_pilot_size && usr.mob_size <= exosuit.body.max_pilot_size && !issilicon(usr))
					if(exosuit.enter(src,silent = FALSE,check_incap = TRUE,instant = FALSE))
						return
				else
					to_chat(usr, SPAN_WARNING("You cannot pilot a exosuit of this size."))
					return

	return ..()

/datum/click_handler/default/mech/OnClick(atom/A, params)
	var/mob/living/exosuit/E = user.loc
	if(!istype(E))
		//If this happens something broke tbh
		user.RemoveClickHandler(src)
		return
	if(E.hatch_closed)
		E.ClickOn(A, params, user)
		return
	else return ..()

/mob/living/exosuit/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	if(inmech(user))
		to_chat(user, "You cannot interact with mech inside mech.")
		return
	//Мы тычем ID картой в меха, словно ключами от иномарки.
	if(istype(tool, /obj/item/card/id))
		id_card_interaction(tool, user)

	//Листы материала для более сложного ремонта
	else if(istype(tool, /obj/item/stack/material))
		material_interaction(tool,user)

	//Пила/Сварка для срезания болтов
	else if( ((istype(tool, /obj/item/circular_saw)) || (isWelder(tool))) && user.a_intent == I_HURT)
		destroy_mech_hatch_bolts(tool, user)

	// Проводка для ремонта BURN урона
	else if (isCoil(tool))
		coil_repair(tool,user)

	//Попытка открыть незакрытого(На Lock) меха при помощи лома
	else if (isCrowbar(tool))
		force_open_hatch(tool, user)

	// Exosuit Customization Kit - Customize the exosuit
	else if (istype(tool, /obj/item/device/kit/mech))
		mech_customization(tool,user)
	// Mech Equipment - Install equipment
	else if (istype(tool, /obj/item/mech_equipment))
		install_equipment(tool, user)

	// Multitool - Remove component
	//Персонаж пытающийся взаимодействовать мультитулом может открыть доп взаимодействие?
	else if (istype(tool, /obj/item/device/multitool/multimeter) || isMultitool(tool))
		can_hack_id(tool, user)

	// Power Cell - Install cell
	else if (istype(tool, /obj/item/cell))
		instal_power_cell(tool, user)


	// Screwdriver - Remove cell
	else if (isScrewdriver(tool))
		deinstall_power_cell(tool, user)

	// Welding Tool - Repair physical damage
	else if (isWelder(tool))
		welder_repair(tool, user)

	// Wrench - Toggle securing bolts
	else if (isWrench(tool))
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to access the securing bolts.")
			return
		var/list/options = list(
			"Снять оборудование" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "unequip_equipment"),
			"Разобрать меха" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "dismantle")
			)
		var/choose = show_radial_menu(user, user, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
		if(choose == "Разобрать меха")
			start_dismantle_mech(tool, user)
		else if(choose == "Снять оборудование")
			deinstall_equipment(tool, user)


/mob/living/exosuit/attack_hand(mob/user)
	// Drag the pilot out if possible.
	if(user.a_intent == I_HURT)
		if(passengers_ammount > 0 && hatch_closed)// Стянуть пассажира с меха рукой!
			external_leaving_passenger(mode = MECH_DROP_ANY_PASSENGER)
			return
		if(!LAZYLEN(pilots))
			to_chat(user, SPAN_WARNING("There is nobody inside \the [src]."))
		else if(!hatch_closed)
			var/mob/pilot = pick(pilots)
			user.visible_message(SPAN_DANGER("\The [user] is trying to pull \the [pilot] out of \the [src]!"))
			if(do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE) && user.Adjacent(src) && (pilot in pilots) && !hatch_closed)
				user.visible_message(SPAN_DANGER("\The [user] drags \the [pilot] out of \the [src]!"))
				eject(pilot, silent=1)
		else if(hatch_closed)
			if(MUTATION_FERAL in user.mutations)
				attack_generic(user, 5, "slams")
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*2)
		return
	return


/mob/living/exosuit/proc/selftoggle_mech_hatch_close()
	playsound(src.loc, 'mods/mechs_by_shegar/sounds/mech_peek.ogg', 80, 0, -6)
	//Данный прок выполняет простейшую задачу, либо открывает, либо закрывает меха без участвия человека.
	if(hatch_closed) // <- Кабина закрыта?
		open_hatch()
	else // <- кабина открыта
		close_hatch()
	update_icon()

/mob/living/exosuit/proc/selftoggle_mech_hatch_lock()
	if(hatch_locked) // <- Замок включен
		hatch_locked = FALSE //<- выключили замок
		playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	else
		hatch_locked = TRUE
		playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	update_icon()
	need_update_sensor_effects = TRUE

/mob/living/exosuit/proc/selfopen_mech_hatch()
	playsound(src.loc, 'mods/mechs_by_shegar/sounds/mech_peek.ogg', 80, 0, -6)
	//Данный прок выполняет простейшую задачу, либо открывает, либо закрывает меха без участвия человека.
	if(hatch_locked) // <- Замок включен
		hatch_locked = FALSE //<- выключили замок
		playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	if(hatch_closed) // <- Кабина закрыта?
		open_hatch()
	update_icon()

/mob/living/exosuit/get_inventory_slot(obj/item/I)
	for(var/h in hardpoints)
		if(hardpoints[h] == I)
			return h
	return 0
