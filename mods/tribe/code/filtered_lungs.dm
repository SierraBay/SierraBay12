/obj/item/organ/internal/lungs/filtered
	name = "alien lungs"
	var/list/ignore_gases = list()
	can_be_printed = FALSE

/obj/item/organ/internal/lungs/filtered/sync_breath_types()
	..()
	if(istype(species, /singleton/species/alium/tribe))
		var/singleton/species/alium/tribe/S = species
		ignore_gases = S.ignore_gases

// Is not replaceable, can't really die
/obj/item/organ/internal/lungs/filtered/die()
	if(LAZYLEN(ignore_gases))
		return
	..()

/obj/item/organ/internal/lungs/filtered/handle_breath(datum/gas_mixture/breath, forced)

	if(!owner)
		return 1

	if(!breath || (max_damage <= 0))
		breath_fail_ratio = 1
		handle_failed_breath()
		return 1

	var/breath_pressure = breath.return_pressure()
	check_rupturing(breath_pressure)

	var/datum/gas_mixture/environment = loc.return_air_for_internal_lifeform()
	last_ext_pressure = environment && environment.return_pressure()
	last_int_pressure = breath_pressure
	if(breath.total_moles == 0)
		breath_fail_ratio = 1
		handle_failed_breath()
		return 1

	var/safe_pressure_min = min_breath_pressure // Minimum safe partial pressure of breathable gas in kPa
	// Lung damage increases the minimum safe pressure.
	safe_pressure_min *= 1 + rand(1,4) * damage/max_damage

	if(!forced && owner.chem_effects[CE_BREATHLOSS] && !owner.chem_effects[CE_STABLE]) //opiates are bad mmkay
		safe_pressure_min *= 1 + rand(1,4) * owner.chem_effects[CE_BREATHLOSS]

	var/failed_inhale = 0
	var/failed_exhale = 0

	var/inhaling = breath.gas[breath_type]
	var/inhale_efficiency = min(round(((inhaling/breath.total_moles)*breath_pressure)/safe_pressure_min, 0.001), 3)

	// Not enough to breathe
	if(inhale_efficiency < 1)
		if(prob(20) && active_breathing)
			if(inhale_efficiency < 0.8)
				owner.emote("gasp")
			else if(prob(20))
				to_chat(owner, SPAN_WARNING("It's hard to breathe..."))
		breath_fail_ratio = 1 - inhale_efficiency
		failed_inhale = 1
	else
		breath_fail_ratio = 0

	owner.oxygen_alert = failed_inhale * 2

	var/inhaled_gas_used = inhaling / 4
	breath.adjust_gas(breath_type, -inhaled_gas_used, update = 0) //update afterwards

	owner.phoron_alert = 0 // Reset our toxins alert for now.
	if(!failed_inhale) // Enough gas to tell we're being poisoned via chemical burns or whatever.
		var/poison_total = 0
		if(poison_types)
			for(var/gname in breath.gas)
				if(poison_types[gname])
					poison_total += breath.gas[gname]
		if(((poison_total/breath.total_moles)*breath_pressure) > safe_toxins_max)
			owner.phoron_alert = 1

	// Pass reagents from the gas into our body.
	// Presumably if you breathe it you have a specialized metabolism for it, so we drop/ignore breath_type. Also avoids
	// humans processing thousands of units of oxygen over the course of a round for the sole purpose of poisoning vox.
	var/ratio = BP_IS_ROBOTIC(src)? 0.66 : 1
	for(var/gasname in breath.gas - breath_type - ignore_gases)
		var/breathed_product = gas_data.breathed_product[gasname]
		if(breathed_product)
			var/reagent_amount = breath.gas[gasname] * REAGENT_GAS_EXCHANGE_FACTOR * ratio
			 // Little bit of sanity so we aren't trying to add 0.0000000001 units of CO2, and so we don't end up with 99999 units of CO2.
			if(reagent_amount >= 0.05)
				owner.reagents.add_reagent(breathed_product, reagent_amount)
				breath.adjust_gas(gasname, -breath.gas[gasname], update = 0) //update after

	// Moved after reagent injection so we don't instantly poison ourselves with CO2 or whatever.
	if(exhale_type && (!istype(owner.wear_mask) || !(exhale_type in owner.wear_mask.filtered_gases)))
		breath.adjust_gas_temp(exhale_type, inhaled_gas_used, owner.bodytemperature, update = 0) //update afterwards

	// Were we able to breathe?
	var/failed_breath = failed_inhale || failed_exhale
	if(!failed_breath)
		last_successful_breath = world.time
		owner.adjustOxyLoss(-5 * inhale_efficiency)
		if(!BP_IS_ROBOTIC(src) && species.breathing_sound && is_below_sound_pressure(get_turf(owner)))
			if(breathing || owner.shock_stage >= 10)
				sound_to(owner, sound(species.breathing_sound,0,0,0,5))
				breathing = 0
			else
				breathing = 1

	handle_temperature_effects(breath)
	breath.update_values()

	if(failed_breath)
		handle_failed_breath()
	else
		owner.oxygen_alert = 0
	return failed_breath