
#define MECHFAB_HACK_WIRE    1
#define MECHFAB_SHOCK_WIRE   2
#define MECHFAB_DISABLE_WIRE 4

/datum/wires/robotics_fabricator

	holder_type = /obj/machinery/robotics_fabricator
	wire_count = 6
	descriptions = list(
		new /datum/wire_description(MECHFAB_HACK_WIRE, "This wire appears to lead to an auxiliary data storage unit.", "Access"),
		new /datum/wire_description(MECHFAB_SHOCK_WIRE, "This wire seems to be carrying a heavy current.", "Shock"),
		new /datum/wire_description(MECHFAB_DISABLE_WIRE, "This wire is connected to the power switch.", "Power", SKILL_EXPERIENCED)
	)

/datum/wires/robotics_fabricator/GetInteractWindow(mob/user)
	var/obj/machinery/robotics_fabricator/A = holder
	. += ..()
	. += "<BR>The red light is [(A.fab_status_flags & FAB_DISABLED) ? "off" : "on"]."
	. += "<BR>The green light is [(A.fab_status_flags & FAB_SHOCKED) ? "off" : "on"]."
	. += "<BR>The blue light is [(A.fab_status_flags & FAB_HACKED) ? "off" : "on"].<BR>"

/datum/wires/robotics_fabricator/CanUse()
	var/obj/machinery/robotics_fabricator/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/robotics_fabricator/UpdateCut(index, mended)
	var/obj/machinery/robotics_fabricator/A = holder
	switch(index)
		if(MECHFAB_HACK_WIRE)
			if(mended)
				A.fab_status_flags &= ~FAB_HACKED
			else
				A.fab_status_flags |= FAB_HACKED
		if(MECHFAB_SHOCK_WIRE)
			if(mended)
				A.fab_status_flags &= ~FAB_SHOCKED
			else
				A.fab_status_flags |= FAB_SHOCKED
		if(MECHFAB_DISABLE_WIRE)
			if(mended)
				A.fab_status_flags &= ~FAB_DISABLED
			else
				A.fab_status_flags |= FAB_DISABLED

/datum/wires/robotics_fabricator/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/robotics_fabricator/A = holder
	switch(index)
		if(MECHFAB_HACK_WIRE)
			if(A.fab_status_flags & FAB_HACKED)
				A.fab_status_flags &= ~FAB_HACKED
			else
				A.fab_status_flags |= FAB_HACKED
			spawn(50)
				if(A && !IsIndexCut(index))
					A.fab_status_flags &= ~FAB_HACKED
					Interact(usr)
		if(MECHFAB_SHOCK_WIRE)
			if(A.fab_status_flags & FAB_SHOCKED)
				A.fab_status_flags &= ~FAB_SHOCKED
			else
				A.fab_status_flags |= FAB_SHOCKED
			spawn(50)
				if(A && !IsIndexCut(index))
					A.fab_status_flags &= ~FAB_SHOCKED
					Interact(usr)
		if(MECHFAB_DISABLE_WIRE)
			if(A.fab_status_flags & FAB_DISABLED)
				A.fab_status_flags &= ~FAB_DISABLED
			else
				A.fab_status_flags |= FAB_DISABLED
			spawn(50)
				if(A && !IsIndexCut(index))
					A.fab_status_flags &= ~FAB_DISABLED
					Interact(usr)

#undef MECHFAB_HACK_WIRE
#undef MECHFAB_SHOCK_WIRE
#undef MECHFAB_DISABLE_WIRE
