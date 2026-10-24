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
	if(!attach_count)
		return ""
	var/list/names = list()
	for(var/path in attachments)
		var/atom/part = path
		names += initial(part.name)
	return "At least [attach_count] installed components from: [jointext(names, ", ")]."
