/obj/item/device/electronic_assembly
	var/magnetized = 0

/obj/item/device/electronic_assembly/attack_hand(mob/user)
	if(magnetized && istype(src.loc, /turf/simulated/floor))
		attack_self(user)
		return
	..()

/obj/item/device/electronic_assembly/proc/loading(obj/item/I, mob/living/user)
	var/list/icomponents = list()
	var/list/ircomponents = list()
	if(istype(I, /obj/item/gun/energy))
		for (var/obj/item/integrated_circuit/manipulation/weapon_firing/P in assembly_components)
			if(!P.installed_gun)
				icomponents+=P.displayed_name
				ircomponents+=P
	else if(istype(I, /obj/item/grenade))
		for (var/obj/item/integrated_circuit/manipulation/grenade/P in assembly_components)
			if(!P.attached_grenade)
				icomponents+=P.displayed_name
				ircomponents+=P
	else
		var/obj/item/card = I
		var/mob/living/L = locate(/mob/living) in card.contents
		if(L && L.key)
			for (var/obj/item/integrated_circuit/manipulation/ai/P in assembly_components)
				if(!P.controlling)
					icomponents+=P.displayed_name
					ircomponents+=P
	var/component_choice = input("Please choose a component to insert the [I].","[src]") as null|anything in icomponents
	if(component_choice)
		var/obj/item/integrated_circuit/circuit = ircomponents[icomponents.Find(component_choice)]
		if(in_range(user, circuit) && get_dist(I, user) < 1)
			circuit.use_tool(I, user)

/obj/item/device/electronic_assembly/use_tool(obj/item/I, mob/user, list/click_params)
	if(is_type_in_list(I, list(/obj/item/gun/energy, /obj/item/grenade, /obj/item/aicard, /obj/item/device/paicard, /obj/item/device/mmi, /obj/item/organ/internal/posibrain)) && opened)
		loading(I,user)
		return TRUE
	..()