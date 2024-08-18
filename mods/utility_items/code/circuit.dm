/obj/item/organ/internal/augment/active/simple/circuit
	name = "integrated circuit frame"
	action_button_name = "Activate Circuit"
	icon_state = "circuit"
	augment_slots = AUGMENT_ARM
	holding_type = null //We must get the holding item externally
	//Limited to robolimbs
	augment_flags = AUGMENT_MECHANICAL
	desc = "A DIY modular assembly, courtesy of Xion Industrial. Circuitry not included"


/obj/item/organ/internal/augment/active/simple/circuit/use_tool(obj/item/W as obj, mob/user as mob)
	if(isCrowbar(W))
		//Remove internal circuit
		if(holding)
			holding.canremove = 1
			holding.dropInto(loc)
			to_chat(user, SPAN_WARNING("You take out \the [holding]."))
			holding = null
			playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		else to_chat(user, SPAN_WARNING("The augment is empty!"))
		return
	if(istype(W, /obj/item/device/electronic_assembly/augment))
		if(holding)
			to_chat(user, SPAN_WARNING("There's already an assembly in there."))
		else if(user.unEquip(W, src))
			holding = W
			holding.canremove = 0
			playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		return

	..()
