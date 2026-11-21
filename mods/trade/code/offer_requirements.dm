/datum/trade_offer/proc/get_installed_parts(atom/movable/target)
	var/list/parts = list()
	if(istype(target, /obj/machinery))
		var/obj/machinery/machine = target
		if(islist(machine.component_parts))
			parts |= machine.component_parts
	if(istype(target, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = target
		parts |= computer.get_all_components()
	if(istype(target, /obj/item/camera_assembly))
		var/obj/item/camera_assembly/camera = target
		if(islist(camera.upgrades))
			parts |= camera.upgrades
	if(istype(target, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/gun = target
		if(gun.silenced && gun.silencer)
			parts |= gun.silencer
	return parts

/datum/trade_offer/proc/check_attachments(atom/movable/target)
	if(!attach_count)
		return TRUE
	var/count = 0
	for(var/obj/item/part as anything in get_installed_parts(target))
		if(!istype(part) || QDELETED(part) || part.loc != target)
			continue
		if(is_path_in_list(part.type, attachments))
			count++
	return count >= attach_count

/datum/trade_offer/proc/get_requirements()
	var/list/details = list()
	if(reagent_type)
		var/datum/reagent/reagent = reagent_type
		var/rname = initial(reagent.name) || "reagent"
		details += "Requires [amount * reagent_volume]u total ([amount]x [reagent_volume]u [rname] in one or more reagent containers; containers returned)."
	else if(live_required)
		details += "Requires [amount]x live specimen inside a stasis cage (cage remains on pad)."
	else if(native_stack_size > 1)
		details += "Requires [amount]x full stack ([native_stack_size] units per stack)."
	if(attach_count)
		var/list/names = list()
		for(var/path in attachments)
			var/atom/part = path
			names += initial(part.name)
		details += "At least [attach_count] installed components from: [jointext(names, ", ")]."
	return jointext(details, " ")
