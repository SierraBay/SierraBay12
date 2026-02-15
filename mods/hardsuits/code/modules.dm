/obj/item/rig/proc/find_module(module_type)
	for(var/obj/item/rig_module/module in installed_modules)
		if(istype(module, module_type))
			return module
	return null

/datum/design/item/mechfab/rig/selfrepair
	category = "Hardsuits"
	name = "Self-repair Module"
	build_path = /obj/item/rig_module/selfrepair
	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 2000,  MATERIAL_PLASTIC = 3000)
	req_tech = list(TECH_MAGNET = 4, TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	id = "self_repair"
	sort_string = "WCAZZ"

/datum/design/item/mechfab/rig/simple_ai
	category = "Hardsuits"
	name = "AI-rig simple"
	build_path = /obj/item/rig_module/simple_ai
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000,  MATERIAL_PLASTIC = 1000)
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	id = "ai_basic"
	sort_string = "WCAXX"

/datum/design/item/mechfab/rig/advanced_ai
	category = "Hardsuits"
	name = "AI-rig advanced"
	build_path = /obj/item/rig_module/simple_ai/advanced
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 3000,  MATERIAL_SILVER = 2000)
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 4, TECH_ENGINEERING = 5)
	id = "ai_advanced"
	sort_string = "WCAXZ"

/obj/item/rig_module/selfrepair
	name = "hardsuit self-repair module"
	desc = "A somewhat complicated looking complex full of tools."
	icon_state = "selfrepair"
	icon = 'mods/hardsuits/icons/modules.dmi'
	interface_name = "self-repair module"
	interface_desc = "A module capable of repairing stuctural rig damage on the spot."
	activate_string = "Begin repair"
	deactivate_string = "Stop repair"
	toggleable = TRUE
	usable = FALSE
	selectable = FALSE
	show_toggle_button = TRUE
	use_power_cost = 0
	module_cooldown = 0
	origin_tech = "engineering=3;programming=3"

	charges = list(
		list("steel",   "steel",   /obj/item/stack/material/steel,  30))

/obj/item/rig_module/selfrepair/activate(forced = FALSE)
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, SPAN_NOTICE("Starting self-repair sequence"))

	return TRUE

/obj/item/rig_module/selfrepair/Process()
	if(!active)
		return passive_power_cost

	var/mob/living/carbon/human/H = holder.wearer

	if(!holder.chest.brute_damage && !holder.chest.burn_damage)
		deactivate()
		to_chat(H, SPAN_NOTICE("Self-repair is completed."))
		return passive_power_cost

	var/datum/rig_charge/charge = charges["steel"]

	if(!charge)
		deactivate()
		return FALSE

	active_power_cost = passive_power_cost
	if(holder.chest.brute_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 3)

		charge.charges -= chargeuse
		holder.chest.repair_breaches(DAMAGE_BRUTE, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 150
	else if(holder.chest.burn_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 3)

		charge.charges -= chargeuse
		holder.chest.repair_breaches(DAMAGE_BURN, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 150
	else
		deactivate()
		to_chat(H, SPAN_DANGER("Not enough materials to continue self-repair"))

	return active_power_cost

/obj/item/rig_module/selfrepair/accepts_item(obj/item/input_item, mob/living/user)
	var/mob/living/carbon/human/H = holder.wearer

	if(istype(input_item, /obj/item/stack/material/steel) && istype(H) && user == H)
		var/obj/item/stack/material/steel/metal = input_item
		var/datum/rig_charge/charge = charges["steel"]

		var/total_used = 30
		total_used = min(total_used, 30 - charge.charges)
		total_used = min(total_used, metal.get_amount())

		metal.use(total_used)
		charge.charges += total_used
		if(total_used)
			to_chat(user, SPAN_NOTICE("You transfer [total_used] of metal lists into the suit reservoir."))
		return TRUE

	return FALSE

/obj/item/rig_module/selfrepair/adv
	name = "hardsuit advanced self-repair module"

/obj/item/rig_module/selfrepair/adv/Process()
	if(!active)
		return passive_power_cost

	var/mob/living/carbon/human/H = holder.wearer
	var/obj/item/organ/external/DBP

	for(var/obj/item/organ/external/BP in H.organs)
		if(BP_IS_ROBOTIC(BP))
			if(BP.brute_dam)
				DBP = BP
			else if(BP.burn_dam)
				DBP = BP

	if(!holder.chest.brute_damage && !holder.chest.burn_damage && !DBP)
		deactivate()
		to_chat(H,SPAN_NOTICE("Self-repair is completed."))
		return passive_power_cost

	var/datum/rig_charge/charge = charges["steel"]

	if(!charge)
		deactivate()
		return FALSE

	active_power_cost = passive_power_cost
	if(holder.chest.brute_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 2)

		charge.charges -= chargeuse
		holder.chest.repair_breaches(DAMAGE_BRUTE, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 150
	else if(holder.chest.burn_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 2)

		charge.charges -= chargeuse
		holder.chest.repair_breaches(DAMAGE_BURN, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 150
	else if(DBP?.brute_dam && charge.charges > 0)
		var/chargeuse = min(charge.charges, 2)
		DBP.heal_damage(10, 0, 0, 1)
		charge.charges -= chargeuse

		active_power_cost = chargeuse * 200
	else if(DBP?.burn_dam && charge.charges > 0)
		var/chargeuse = min(charge.charges, 2)
		DBP.heal_damage(0, 10, 0, 1)
		charge.charges -= chargeuse

		active_power_cost = chargeuse * 200
	else
		deactivate()
		to_chat(H, SPAN_DANGER("Not enough materials to continue self-repair"))

	return active_power_cost
