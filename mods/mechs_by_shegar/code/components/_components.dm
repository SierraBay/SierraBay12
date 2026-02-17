/obj/item/mech_component
	icon = 'mods/mechs_by_shegar/icons/mech_parts_held.dmi'
	w_class = ITEM_SIZE_GARGANTUAN
	gender = PLURAL
	color = COLOR_GUNMETAL
	atom_flags = ATOM_FLAG_CAN_BE_PAINTED
//	anchored = TRUE //Часть меха нешуточно тяжёлые, кто их вообще сможет утащить?

	throw_range = 1

	var/on_mech_icon = 'mods/mechs_by_shegar/icons/mech_parts.dmi'
	var/exosuit_desc_string
	var/total_damage = 0
	var/brute_damage = 0
	var/burn_damage = 0
	var/damage_state = 1
	var/list/has_hardpoints = list()
	var/decal
	var/power_use = 0
	matter = list(MATERIAL_STEEL = 15000, MATERIAL_PLASTIC = 1000, MATERIAL_OSMIUM = 500)
	dir = SOUTH
	var/obj/item/mech_external_armor/installed_armor
	var/can_have_external_armour = TRUE
	var/armour_can_be_removed = TRUE
	var/armour_can_be_installed = TRUE

	///Отвечает за минимальное возможное ХП части меха, ОБЯЗАТЕЛЬНО прописывайте этот пункт. При ремонте повреждений
	///листом материала максимальное ХП части меха уменьшается, min_damage является минимальным пределом до куда будет
	///снижаться макс ХП меха.
	var/min_damage = 5
	///Отвечает за ТЕКУЩУЮ структурную целостность части, вычисляется по max_damage - ( brute_damage + burn_damage)
	var/current_hp
	///Отвечает за МАКСИМАЛЬНУЮ структурную целостность части, выставляеться до инициализации
	var/max_hp = 60
	/// Отвечает за то на сколько снижается максимальное хп части после ремонта. Обратите внимание, что макс хп падает
	///лишь при ремонте листами материала.
	var/repair_damage = 5
	///Отвечает за максимальное число урона, при котором не потребуется ремонт листами матеиала, можно обойтись сваркой.
	///Если количество ХП ниже этого значения - ремонт лишь листами.
	var/max_repair = 5
	///Отвечает за то какой материал требуется для ремонта данной части листами. Проверяется переменная при клику листами по
	///меху.
	var/req_material = MATERIAL_STEEL
	///Содержит в себе значение НЕЧИНИБЕЛЬНОГО урона что скопился в части.
	var/unrepairable_damage = 0
	///Обозначает вес компонента в КИЛОГРАММАХ
	var/weight = 100
	//Можно ли взять часть в руки
//	var/can_be_pickuped = FALSE
	///Модификатор урона по части, когда она принимает урон лицевой стороной
	var/front_modificator_damage = 1
	///Модификатор урона по части, когда она принимает урон задней стороной
	var/back_modificator_damage = 1.5
	///Гарантированный дополнительный урон, когда часть принимает урон лицевой стороной
	var/front_additional_damage = 0
	///Гарантированный дополнительный урон, когда часть принимает урон задней стороной
	var/back_additional_damage = 4
	///Применяется при установки части которая в себе содержит несколько частей (Условно траки или паучьи ноги)
	var/obj/item/mech_component/doubled_owner
	///ТЭГ компонента. Применяется если мы не хотим чтоб игроки хитрили, как в случае СБ меха, или части были
	//Несовместимы.
	var/component_tag = null
	///Владелец части
	var/mob/living/exosuit/owner
	//Кто-то прям сейчас пытается тащить нашу часть!
	var/turf/haul_turf
	///Максимальное тепло, которое может хранить в себе часть меха.
	var/max_heat = 100
	///Количество тепла, которое сбрасывает данная часть
	var/heat_cooling = 5
	///Количество тепла, которое вырабатывает данная часть при использовании
	var/heat_generation = 5
	///Количество тепла, выделяемое при ЭМИ ударе
	var/emp_heat_generation = 50
	var/list/whitelist_equipment_paths = list()

	/// Замедление при переноске
	var/slowdown_held = 6 // Yes, you can carry it. But this thing is cumbersome.

/obj/item/mech_component/Initialize()
	slowdown_per_slot[slot_l_hand] =  slowdown_held
	slowdown_per_slot[slot_r_hand] =  slowdown_held

	. = ..()

/obj/item/mech_component/attack_hand(mob/user)
	.=..()
	if(user.mob_size >= MOB_LARGE)
		to_chat(user, SPAN_NOTICE("You casually lift \the [src] without paying attention to its weight."))
	if(user.mob_size == MOB_MEDIUM)
		user.adjust_stamina(-25)
		to_chat(user, SPAN_WARNING("You bend when you lift heavy \the [src]."))
	if(user.mob_size <= MOB_SMALL)
		user.adjust_stamina(-50)
		to_chat(user, SPAN_WARNING("You can barely stand under the weight of \the [src]."))


/obj/item/mech_component/MouseDrop(atom/over_atom, atom/source_loc, atom/over_loc, source_control, over_control, list/mouse_params)
	if(!CanMouseDrop(over_atom, usr))
		return
	if(istype(over_atom, /obj/structure/heavy_vehicle_frame))
		var/obj/structure/heavy_vehicle_frame/input_frame = over_atom
		input_frame.use_tool(src, usr)
	.=..()

/*
/obj/item/mech_component/attack_hand(mob/user)
	if(!can_be_pickuped)
		to_chat(user, SPAN_BAD("Этот предмет слишком тяжел, чтобы перемещать его в одиночку"))
		to_chat(user, SPAN_GOOD("Найдите напарника и вместе с ним перетягивайте этот предмет по полу в нужную вам сторону"))
		to_chat(user, SPAN_GOOD("Грузовая тележка также позволяет перемещать тяжелые предметы"))
		return
	else
		.=..()

/obj/item/mech_component/MouseDrop(atom/over_atom, atom/source_loc, atom/over_loc, source_control, over_control, list/mouse_params)
	if(!CanMouseDrop(over_atom, usr))
		return
	if(istype(over_atom, /obj/structure/heavy_vehicle_frame))
		var/obj/structure/heavy_vehicle_frame/input_frame = over_atom
		input_frame.use_tool(src, usr)
	if(istype(over_atom, /turf))
		try_team_hauling(usr, over_atom)
	.=..()

/obj/item/mech_component/proc/try_team_hauling(mob/living/user, turf/new_turf)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(human.stamina < 60)
		to_chat(human, SPAN_WARNING("Вы слишком устали, чтобы тянуть это!"))
		return FALSE
	human.adjust_stamina(-50)
	if(haul_turf && haul_turf == new_turf)
		haul_turf = null
		src.Move(new_turf)
		return TRUE
	else if(haul_turf && haul_turf != new_turf)
		haul_turf = null
		human.adjust_stamina(-100)
		to_chat(human, SPAN_WARNING("Вы и ваш напарник тянете в разные стороны! Координируйтесь!"))
		return FALSE
	haul_turf = new_turf
	if(do_after(user, 10 SECONDS, src, DO_PUBLIC_UNIQUE))
		haul_turf = null
	else
		haul_turf = null
*/

/obj/item/mech_component/proc/update_component_owner()
	if(ismech(loc))
		owner = loc
	else
		owner = null

/obj/item/mech_component/Initialize()
	current_hp = max_hp
	. = ..()
	update_parts_images()

/obj/item/mech_component/proc/emp_heat(severity, emp_armor, mob/living/exosuit/mech) //Накидываем тепло учитывая армор меха
	if(emp_armor > 0.8)
		emp_armor = 0.8
	if(mech.add_heat(emp_heat_generation * (1 - emp_armor)))
		return TRUE

/obj/item/mech_component/set_color(new_colour)
	var/last_colour = color
	color = new_colour
	return color != last_colour

/obj/item/mech_component/emp_act(severity)
	take_burn_damage(rand((10 - (severity*3)),15-(severity*4)))
	..()

/obj/item/mech_component/examine(mob/user)
	. = ..()
	if(ready_to_install())
		to_chat(user, SPAN_NOTICE("It is ready for installation."))
	else
		show_missing_parts(user)

//These icons have multiple directions but before they're attached we only want south.
/obj/item/mech_component/set_dir()
	..(SOUTH)

/obj/item/mech_component/proc/show_missing_parts(mob/user)
	return

/obj/item/mech_component/proc/prebuild()
	update_components()

/obj/item/mech_component/proc/install_component(obj/item/thing, mob/user)
	if(user.unEquip(thing, src))
		user.visible_message(SPAN_NOTICE("\The [user] installs \the [thing] in \the [src]."))
		update_components()
		return 1

/obj/item/mech_component/proc/update_health()
	total_damage = brute_damage + burn_damage
	if(total_damage > max_hp)
		total_damage = max_hp

	current_hp = max_hp - total_damage - unrepairable_damage
	var/prev_state = damage_state
	damage_state = clamp(round((total_damage/max_hp) * 4), MECH_COMPONENT_DAMAGE_UNDAMAGED, MECH_COMPONENT_DAMAGE_DAMAGED_TOTAL)
	if(damage_state > prev_state)
		if(damage_state == MECH_COMPONENT_DAMAGE_DAMAGED_BAD)
			playsound(src.loc, 'sound/mecha/internaldmgalarm.ogg', 40, 1)
		if(damage_state == MECH_COMPONENT_DAMAGE_DAMAGED_TOTAL)
			playsound(src.loc, 'sound/mecha/critdestr.ogg', 50)

/obj/item/mech_component/proc/ready_to_install()
	return 1

/obj/item/mech_component/proc/repair_brute_damage(amt)
	take_brute_damage(-amt)

/obj/item/mech_component/proc/repair_burn_damage(amt)
	take_burn_damage(-amt)

/obj/item/mech_component/proc/take_brute_damage(amt)
	brute_damage = max(0, brute_damage + amt)
	if(brute_damage > max_hp - unrepairable_damage - burn_damage)
		brute_damage = max_hp - unrepairable_damage - burn_damage
	update_health()
	if(total_damage == max_hp)
		take_component_damage(amt,0)

/obj/item/mech_component/proc/take_burn_damage(amt)
	burn_damage = max(0, burn_damage + amt)
	if(burn_damage > max_hp - unrepairable_damage - brute_damage)
		burn_damage = max_hp - unrepairable_damage - brute_damage
	update_health()
	if(total_damage == max_hp)
		take_component_damage(0,amt)

/obj/item/mech_component/proc/take_component_damage(brute, burn)
	var/list/damageable_components = list()
	for(var/obj/item/robot_parts/robot_component/RC in contents)
		damageable_components += RC
	if(!LAZYLEN(damageable_components))
		return
	var/obj/item/robot_parts/robot_component/RC = pick(damageable_components)
	if(RC.take_damage(brute, burn))
		qdel(RC)
		update_components()

/obj/item/mech_component/use_tool(obj/item/thing, mob/living/user, list/click_params)
	if (isScrewdriver(thing))
		screwdriver_interaction(user)
		return TRUE
	if (isWelder(thing))
		welder_interacion(thing, user)
		return TRUE
	if (isWrench(thing))
		wrench_interacion(thing, user)
		return TRUE
	if (isCoil(thing))
		repair_burn_generic(thing, user)
		return TRUE
	if (istype(thing, /obj/item/device/robotanalyzer))
		to_chat(user, SPAN_NOTICE("Diagnostic Report for \the [src]:"))
		return_diagnostics(user)
		return TRUE

		//Ткнули листом материала
	else if(istype(thing, /obj/item/stack/material))
		material_interaction(thing, user)
		return TRUE

	return ..()

/obj/item/mech_component/proc/update_components()
	return

/obj/item/mech_component/proc/repair_brute_generic(obj/item/weldingtool/WT, mob/user)
	if(!istype(WT))
		return
	if(!brute_damage)
		to_chat(user, SPAN_NOTICE("You inspect \the [src] but find nothing to weld."))
		return
	if(!WT.isOn())
		to_chat(user, SPAN_WARNING("Turn \the [WT] on, first."))
		return
	if(WT.can_use((SKILL_MAX + 1) - user.get_skill_value(SKILL_CONSTRUCTION), user))
		user.visible_message(
			SPAN_NOTICE("\The [user] begins welding the damage on \the [src]..."),
			SPAN_NOTICE("You begin welding the damage on \the [src]...")
		)
		var/repair_value = 10 * max(user.get_skill_value(SKILL_CONSTRUCTION), user.get_skill_value(SKILL_DEVICES))
		if(user.do_skilled(1 SECOND, SKILL_DEVICES , src, 0.6) && brute_damage && WT.remove_fuel((SKILL_MAX + 1) - user.get_skill_value(SKILL_CONSTRUCTION), user))
			repair_brute_damage(repair_value)
			to_chat(user, SPAN_NOTICE("You mend the damage to \the [src]."))
			playsound(user.loc, 'sound/items/Welder.ogg', 25, 1)

/obj/item/mech_component/proc/repair_burn_generic(obj/item/stack/cable_coil/CC, mob/user)
	if(!istype(CC))
		return
	if(!burn_damage)
		to_chat(user, SPAN_NOTICE("\The [src]'s wiring doesn't need replacing."))
		return

	var/needed_amount = 6 - user.get_skill_value(SKILL_ELECTRICAL)
	if(CC.get_amount() < needed_amount)
		to_chat(user, SPAN_WARNING("You need at least [needed_amount] unit\s of cable to repair this section."))
		return

	user.visible_message("\The [user] begins replacing the wiring of \the [src]...")

	if(user.do_skilled(1 SECOND, SKILL_DEVICES , src, 0.6) && burn_damage)
		if(QDELETED(CC) || QDELETED(src) || !CC.use(needed_amount))
			return

		repair_burn_damage(25)
		to_chat(user, SPAN_NOTICE("You mend the damage to \the [src]'s wiring."))
		playsound(user.loc, 'sound/items/Deconstruct.ogg', 25, 1)
	return

/obj/item/mech_component/proc/get_damage_string()
	switch(damage_state)
		if(MECH_COMPONENT_DAMAGE_UNDAMAGED)
			return SPAN_COLOR(COLOR_GREEN, "undamaged")
		if(MECH_COMPONENT_DAMAGE_DAMAGED)
			return SPAN_COLOR(COLOR_YELLOW, "damaged")
		if(MECH_COMPONENT_DAMAGE_DAMAGED_BAD)
			return SPAN_COLOR(COLOR_ORANGE, "badly damaged")
		if(MECH_COMPONENT_DAMAGE_DAMAGED_TOTAL)
			return SPAN_COLOR(COLOR_RED, "almost destroyed")
	return SPAN_COLOR(COLOR_RED, "destroyed")

/obj/item/mech_component/proc/return_diagnostics(mob/user)
	to_chat(user, SPAN_NOTICE("[capitalize(src.name)]:"))
	to_chat(user, SPAN_NOTICE(" - Integrity: <b> [current_hp]/[max_hp]([round(((current_hp / max_hp)) * 100)]%)</b> Unrepairable damage: <b><font color = red>[unrepairable_damage]</font></b>" ))

/obj/item/mech_component
	//Список изображений внутрянки в части меха
	var/list/internal_parts_list_images = list()

/obj/item/mech_component/proc/update_parts_images()
	return
