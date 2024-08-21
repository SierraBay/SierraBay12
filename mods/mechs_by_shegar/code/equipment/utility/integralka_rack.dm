/obj/item/mech_equipment/mounted_system/circuit
	name = "exosuit circuit rack"
	icon_state = "mech_power"
	holding_type = null //We must get the holding item externally
	desc = "A DIY circuit rack for exosuit. Circuitry not included."
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER,HARDPOINT_RIGHT_SHOULDER)
	restricted_software = list(MECH_SOFTWARE_UTILITY)


/obj/item/mech_equipment/mounted_system/circuit/use_tool(obj/item/W, mob/user)
	if(isCrowbar(W))
		if(holding)
			holding.canremove = 1
			holding.dropInto(loc)
			to_chat(user, SPAN_NOTICE("You take out \the [holding]."))
			holding = null
			playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		else
			to_chat(user, SPAN_WARNING("The frame is empty!"))
	else if(istype(W, /obj/item/device/electronic_assembly/large/exo))
		if(holding)
			to_chat(user, SPAN_WARNING("There's already an assembly in there."))
		else if(user.unEquip(W, src))
			holding = W
			holding.canremove = 0
			playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	return ..()
