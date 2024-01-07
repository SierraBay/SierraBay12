/datum/species/machine

	passive_temp_gain = 0  // This should cause IPCs to stabilize at ~80 C in a 20 C environment.(5)


	has_organ = list(
		BP_POSIBRAIN = /obj/item/organ/internal/posibrain,
		BP_EYES = /obj/item/organ/internal/eyes/robot,
		BP_COOLING = /obj/item/organ/internal/cooling_system
		)

// ROBOT ORGAN PRINTER
/obj/machinery/organ_printer/robot
	products = list(
		BP_HEART    = list(/obj/item/organ/internal/heart,      25),
		BP_LUNGS    = list(/obj/item/organ/internal/lungs,      25),
		BP_KIDNEYS  = list(/obj/item/organ/internal/kidneys,    20),
		BP_EYES     = list(/obj/item/organ/internal/eyes,       20),
		BP_LIVER    = list(/obj/item/organ/internal/liver,      25),
		BP_STOMACH  = list(/obj/item/organ/internal/stomach,    25),
		BP_L_ARM    = list(/obj/item/organ/external/arm,        65),
		BP_R_ARM    = list(/obj/item/organ/external/arm/right,  65),
		BP_L_LEG    = list(/obj/item/organ/external/leg,        65),
		BP_R_LEG    = list(/obj/item/organ/external/leg/right,  65),
		BP_L_FOOT   = list(/obj/item/organ/external/foot,       40),
		BP_R_FOOT   = list(/obj/item/organ/external/foot/right, 40),
		BP_L_HAND   = list(/obj/item/organ/external/hand,       40),
		BP_R_HAND   = list(/obj/item/organ/external/hand/right, 40),
		BP_CELL		= list(/obj/item/organ/internal/cell, 25),
		BP_COOLING	= list(/obj/item/organ/internal/cooling_system, 25),
		)


/mob/living/carbon/human/Stat()
	. = ..()
	if(statpanel("Status"))
		var/obj/item/organ/internal/cell/potato = internal_organs_by_name[BP_CELL]
		var/obj/item/organ/internal/cooling_system/coolant = internal_organs_by_name[BP_COOLING]
		if(potato && potato.cell)
			stat("Coolant remaining:","[coolant.get_coolant_remaining()]/[coolant.refrigerant_max]")

/obj/item/organ/internal/cell/Process()
	..()
	var/cost = get_power_drain()
	if(!checked_use(cost) && owner.isSynthetic())
		if(owner.species.name == SPECIES_IPC)
			owner.species.passive_temp_gain = 0
	if(owner.species.name == SPECIES_IPC)
		var/obj/item/organ/internal/cooling_system/Cooling = owner.internal_organs_by_name[BP_COOLING]
		if(!(owner.internal_organs_by_name[BP_COOLING]))
			if(owner.bodytemperature > 950 CELSIUS)
				owner.species.passive_temp_gain = 0
			else
				owner.species.passive_temp_gain = 30
		else
			owner.species.passive_temp_gain = Cooling.get_tempgain()
