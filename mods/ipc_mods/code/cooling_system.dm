/obj/item/organ/internal/cooling_system
	name = "cooling system"
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "cooling0"
	organ_tag = BP_COOLING
	parent_organ = BP_GROIN
	status = ORGAN_ROBOTIC
	desc = "The internal liquid cooling system consists of a weighty humming cylinder and a small ribbed block connected by flexible tubes through which clear liquid flows."
	var/refrigerant_max = 90	// Максимальное количество охладителя
	var/refrigerant_rate = 0	// Чем больше это значение, тем сильнее будет идти нагрев владельца. / теперь складывается от протезов
	var/durability_factor = 30	// Чем больше это значение, тем сильнее будет идти нагрев владельца при повреждениях
	var/safety = 1
	damage_reduction = 0.8
	max_damage = 50
	var/sprite_name = "cooling"
	var/fresh_coolant = 0
	var/coolant_purity = 0
	var/datum/reagents/coolant_reagents
	var/used_coolant = 0
	var/heating_modificator
	var/list/coolant_reagents_efficiency = list()
	var/coolant_reagent_water
	// Целевая температура, к которой система охлаждения стремится приблизить тело
	var/thermostat = 80 CELSIUS
	// Полное отключение активного охлаждения через IPC Diagnostics
	var/cooling_enabled = TRUE
	// Последний расход заряда батареи за тик активного охлаждения (0 если неактивно)
	var/last_cooling_drain = 0

/obj/item/organ/internal/cooling_system/Initialize()
	. = ..()
	robotize()
	reagents.clear_reagents()
	reagents.maximum_volume = refrigerant_max
	coolant_reagents_efficiency[/datum/reagent/water] = 17
	coolant_reagents_efficiency[/datum/reagent/ethanol] = 10
	coolant_reagents_efficiency[/datum/reagent/space_cleaner] = 5
	coolant_reagents_efficiency[/datum/reagent/sterilizine] = 3
	coolant_reagents_efficiency[/datum/reagent/coolant] = 0.1
	coolant_reagents_efficiency[/datum/reagent/frostoil] = -8
	reagents.add_reagent(/datum/reagent/coolant, 60)
	reagents.add_reagent(/datum/reagent/water, 30)

/obj/item/organ/internal/cooling_system/emp_act(severity)
	severity = ipc_try_surge_protect(severity)
	if(!severity)
		return
	damage += rand(15 - severity * 5, 20 - severity * 5)
	..(severity)
// Коэффицент эффективности работы смеси
/obj/item/organ/internal/cooling_system/proc/coolant_purity()
	var/total_purity = 0
	fresh_coolant = 0
	coolant_purity = 0
	for (var/datum/reagent/current_reagent in src.reagents.reagent_list)
		if (!current_reagent)
			continue
		var/cur_purity = coolant_reagents_efficiency[current_reagent.type]
		if(!cur_purity)
			cur_purity = 25
		else if(cur_purity < - 10)
			cur_purity = -10
		total_purity += cur_purity * current_reagent.volume
		fresh_coolant += current_reagent.volume
	if(total_purity && fresh_coolant)
		coolant_purity = total_purity / fresh_coolant
		heating_modificator = coolant_purity




/obj/item/organ/internal/cooling_system/proc/get_coolant_drain()
	var/damage_factor = (damage*durability_factor)/max_damage
	return damage_factor

/obj/item/organ/internal/cooling_system/Process()

	if(!owner || owner.stat == DEAD || owner.bodytemperature < 32)
		return
	var/obj/item/organ/internal/cell/C = owner.internal_organs_by_name[BP_CELL]
	if(!C)
		owner.ipc_temp_gain = 0
		return
	coolant_purity()
	handle_cooling()
	..()

/obj/item/organ/internal/cooling_system/proc/handle_cooling()

	var/obj/item/organ/internal/cell/C = owner.internal_organs_by_name[BP_CELL]
	refrigerant_rate = heating_modificator
	if (!C || C.get_charge() < 10)
		return
	if(reagents.total_volume > 0)
		var/bruised_cost = get_coolant_drain()

		if(is_bruised())
			var/reagents_remove = bruised_cost/durability_factor
			reagents.remove_any(reagents_remove)

		if(is_damaged())
			refrigerant_rate += bruised_cost     // Нагрев владельца при повреждениях высчитывается тут.

		if(reagents.get_reagent_amount(/datum/reagent/water) <= (0.3 * reagents.total_volume))
			var/need_more_water = ((refrigerant_max - reagents.get_reagent_amount(/datum/reagent/water))/100)
			take_internal_damage(need_more_water)

	if(reagents.total_volume <= 0)
		refrigerant_rate += 40

/obj/item/organ/internal/cooling_system/proc/get_tempgain()
	var/obj/item/organ/internal/posibrain/ipc/posibrain = owner.internal_organs_by_name[BP_POSIBRAIN]
	var/total_limb_heat = 0
	if(!posibrain)
		return 0
	if(owner.bodytemperature > 550 CELSIUS)
		return 0
	for(var/obj/item/organ/external/part in owner.organs)
		total_limb_heat += part.coolingefficiency

	refrigerant_rate = total_limb_heat

	// Активное охлаждение: когда температура выше целевой, система откачивает тепло
	if(cooling_enabled && owner.bodytemperature > thermostat && reagents.total_volume > 0)
		var/delta = owner.bodytemperature - thermostat
		var/efficiency = 1 - (damage / max_damage) * 0.7
		var/cooling_power = min(delta * 1.5, 15) * efficiency
		// Расход заряда батареи: чем больше охлаждаем, тем больше потребляем
		var/obj/item/organ/internal/cell/AC = owner.internal_organs_by_name[BP_CELL]
		if(AC && AC.cell)
			var/drain = cooling_power * 2
			AC.cell.charge = max(0, AC.cell.charge - drain)
			last_cooling_drain = drain
		refrigerant_rate -= cooling_power
	else
		last_cooling_drain = 0

	return refrigerant_rate

/obj/item/organ/internal/cooling_system/proc/get_coolant_remaining()
	if(status & ORGAN_DEAD)
		return 0
	return round(reagents.total_volume)

/obj/item/organ/internal/cooling_system/Topic(href, list/href_list)
	if(href_list["set_thermostat"])
		if(!owner || owner != usr || !owner.is_species(SPECIES_IPC))
			return
		var/new_temp = input(usr, "Set thermostat target temperature (20–140°C):", "Thermostat", round(thermostat - T0C)) as num
		if(!isnull(new_temp))
			thermostat = clamp(new_temp, 20, 140) + T0C
			to_chat(owner, SPAN_NOTICE("Thermostat set to [round(thermostat - T0C)]°C."))

/obj/item/organ/internal/cooling_system/examine(mob/user, distance)
	. = ..()
	if(distance <= 0)
		to_chat(user, "[icon2html(src, viewers(get_turf(src)))] \The [src] contains [src.reagents.total_volume] units of coolant.")

/obj/item/organ/internal/cooling_system/attack_self(mob/user as mob)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The injection is [safety ? "on" : "off"]."
	to_chat(user, "The injection is [safety ? "on" : "off"].")


/obj/item/organ/internal/cooling_system/afterattack(atom/target, mob/user, flag)
	var/obj/item/reagent_containers/glass/beaker = target
	if (!flag || !istype(beaker))
		return ..()

	var/amount = reagents.get_free_space()
	if (safety)
		if (amount <= 0)
			to_chat(user, SPAN_NOTICE("\The [src] is full."))
			return
		if (beaker.reagents.total_volume <= 0)
			to_chat(user, SPAN_NOTICE("\The [beaker] is empty."))
			return
		amount = beaker.reagents.trans_to_obj(src, refrigerant_max)
		to_chat(user, SPAN_NOTICE("You fill \the [src] with [amount] units from \the [beaker]."))
		playsound(src.loc, 'sound/effects/pour.ogg', 25, 1)
	else
		amount = src.reagents.trans_to_obj(beaker, refrigerant_max)
		to_chat(user, SPAN_NOTICE("You fill \the [beaker] with [amount] units from \the [src]."))
		playsound(src.loc, 'sound/effects/pour.ogg', 25, 1)

// ── SURGE PROTECTOR ──────────────────────────────────────────────────────────
// Дополнительный орган. Поглощает ЭМИ/электрический урон, принимая его на себя.
// Опциональный апгрейд — не выдаётся по умолчанию, доступен через орган принтер.
/obj/item/organ/internal/surge_protector
	name = "surge protector"
	desc = "An electromagnetic surge absorption module. Intercepts and dissipates electrical discharge before it reaches delicate internal systems."
	icon = 'mods/ipc_mods/icons/ipc_icons.dmi'
	icon_state = "cooling1"
	organ_tag = BP_SURGE_PROTECTOR
	parent_organ = BP_CHEST
	status = ORGAN_ROBOTIC
	damage_reduction = 0.9
	max_damage = 50
	surface_accessible = TRUE
	var/last_absorb_time
	var/last_absorb_result

/obj/item/organ/proc/ipc_try_surge_protect(severity)
	if(!severity || !owner)
		return severity
	if(!(owner.is_species(SPECIES_IPC) || owner.is_species(SPECIES_FBP)))
		return severity
	var/obj/item/organ/internal/surge_protector/SP = owner.internal_organs_by_name[BP_SURGE_PROTECTOR]
	if(!istype(SP) || (SP.status & ORGAN_DEAD))
		return severity
	if(src == SP)
		return 0
	return SP.filter_severity(severity)

/obj/item/organ/internal/surge_protector/proc/filter_severity(severity)
	if(!severity || (status & ORGAN_DEAD))
		return severity
	if(last_absorb_time == world.time)
		return last_absorb_result
	last_absorb_time = world.time
	take_internal_damage(rand(5, 12) * max(3 - severity, 1))
	if(status & ORGAN_DEAD)
		if(owner)
			to_chat(owner, SPAN_DANGER("WARNING: Surge protector overloaded and destroyed!"))
		last_absorb_result = severity
		return severity
	if(severity == EMP_ACT_HEAVY)
		last_absorb_result = EMP_ACT_LIGHT
		if(owner)
			to_chat(owner, SPAN_WARNING("Surge protector partially absorbs electromagnetic pulse."))
		return last_absorb_result
	last_absorb_result = 0
	if(owner)
		to_chat(owner, SPAN_WARNING("Surge protector absorbs electromagnetic pulse."))
	return 0

/obj/item/organ/internal/emp_act(severity)
	if(BP_IS_ROBOTIC(src))
		severity = ipc_try_surge_protect(severity)
		if(!severity)
			return
	if(!BP_IS_ROBOTIC(src))
		return
	var/rand_modifier = rand(1, 3)
	switch (severity)
		if (EMP_ACT_HEAVY)
			take_internal_damage(5 * rand_modifier)
		if (EMP_ACT_LIGHT)
			take_internal_damage(2 * rand_modifier)
	..(severity)

/obj/item/organ/internal/cell/emp_act(severity)
	severity = ipc_try_surge_protect(severity)
	if(!severity)
		return
	..(severity)
	if(cell)
		cell.emp_act(severity)
