/obj/machinery/disease2/antibodyanalyser
	name = "antibody analyser"
	desc = "An advanced machine that analyses pure antibody samples and stores the structure of them on the ExoNet in exchange for cargo points."
	icon = 'mods/virusology/icons/virology.dmi'
	icon_state = "analyser"
	density = TRUE

	var/scanning = 0
	var/pause = 0
	var/list/known_antibodies = list()

	var/obj/item/reagent_containers/container = null

/obj/machinery/disease2/antibodyanalyser/on_update_icon()
	if(scanning)
		icon_state = "analyser_processing"
	else
		icon_state = "analyser"

/obj/machinery/disease2/antibodyanalyser/use_tool(obj/item/I, mob/living/user, list/click_params)
	. = ..()
	if(istype(I,/obj/item/reagent_containers))
		if(!container && user.unEquip(I))
			container = I
			I.forceMove(src)
			user.visible_message("[user] adds a sample to \the [src]!", "You add a sample to \the [src]!")
		return

/obj/machinery/disease2/antibodyanalyser/Process()
	if(stat & (MACHINE_STAT_NOPOWER|MACHINE_IS_BROKEN(src)))
		return

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			if(!container.reagents.has_reagent(/datum/reagent/antibodies)) //if there are no antibody reagents, return false
				return 0

			else
				var/list/data = container.reagents.get_data(/datum/reagent/antibodies) //now that we know there are antibody reagents, get the data
				var/list/given_antibodies = data["antibodies"] //now check what specific antibodies it's holding
				var/list/common_antibodies = known_antibodies & given_antibodies
				var/list/unknown_antibodies = common_antibodies ^ given_antibodies
				if(LAZYLEN(unknown_antibodies))
					var/payout = LAZYLEN(unknown_antibodies) * 45
					SSsupply.add_points_from_source(payout, "virology_antibodies")
					ping("\The [src] pings, \"Successfully uploaded new antibodies to the ExoNet.\"")
					known_antibodies |= unknown_antibodies //Add the new antibodies to list
				else
					src.state("\The [src] buzzes, \"Failed to identify any new antibodies.\"")

			container.dropInto(loc)
			container = null

			on_update_icon()

	else if(container && !scanning && !pause)
		if(container.reagents.has_reagent(/datum/reagent/antibodies))
			scanning = 5
			on_update_icon()
		else
			container.dropInto(loc)
			container = null

			src.state("\The [src] buzzes, \"Failed to identify a pure sample of antibodies in the solution.\"")
	return

/obj/machinery/disease2/antibodyanalyser/Destroy()
	QDEL_NULL(container)
	. = ..()
