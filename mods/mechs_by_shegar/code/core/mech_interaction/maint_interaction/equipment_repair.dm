/mob/living/exosuit/proc/equipment_welder_repair(obj/item/tool, mob/user)
	var/list/possible_repair_equipment = list()
	for (var/hardpoint in hardpoints)
		if(hardpoints[hardpoint])
			var/obj/item/mech_equipment/equipment = hardpoints[hardpoint]
			if(equipment.can_be_repaired())
				LAZYADD(possible_repair_equipment, hardpoints[hardpoint])
	if(!LAZYLEN(possible_repair_equipment))
		to_chat(user, SPAN_GOOD("Чинить нечего"))
		return FALSE

	var/list/options = list()
	for(var/obj/item/mech_equipment/equipment in possible_repair_equipment)
		LAZYADD(options, equipment)
		options[equipment] = mutable_appearance(equipment.icon, equipment.icon_state)

	var/obj/item/mech_equipment/choose = show_radial_menu(user, src, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	choose.try_repair_module(tool, user)
