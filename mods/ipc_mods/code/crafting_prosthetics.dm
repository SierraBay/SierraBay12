/obj/item/robolimb_component
	var/limb_type
	var/processed = FALSE

/singleton/crafting_stage/prosthetic_crafting
	consume_completion_trigger = FALSE

/obj/item/robolimb_component/mechanism
	name = "Prosthetic mechanism"
	desc = "A mechanical component used in prosthetic manufacturing."
	icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	icon_state = "crafting"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 100)

/obj/item/robolimb_component/mechanism/examine(mob/user)
	. = ..()
	if(processed)
		to_chat(user, SPAN_NOTICE("It looks fully assembled and ready for installation."))
	else
		to_chat(user, SPAN_WARNING("It looks incomplete. The wiring needs to be trimmed."))

/obj/item/robolimb_component/control_board
	name = "Prosthetic control board"
	desc = "A control board used in prosthetic manufacturing."
	icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	icon_state = "crafting"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 50)

/obj/item/robolimb_component/control_board/examine(mob/user)
	. = ..()
	if(processed)
		to_chat(user, SPAN_NOTICE("It looks fully assembled and ready for installation."))
	else
		to_chat(user, SPAN_WARNING("It looks incomplete. The contact points need trimming."))

/obj/item/robolimb_component/prosthetic_shell
	name = "Prosthetic shell"
	desc = "A shell for a prosthetic limb. Needs adjustment with a wrench."
	icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	icon_state = "crafting"
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 500)


// Crafting stages for resomi prosthetic

// Stage 1: Start with any prosthetic (/obj/item/organ/external with robotic limb)
// First step: Welding to break down the prosthetic
/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_disassemble
	begins_with_object_type = /obj/item/organ/external
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A prosthetic with cut welding seams. Bolts need unscrewing."
	progress_message = "You cut the welding seams of the prosthetic."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_disassemble)

/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_disassemble/is_appropriate_tool(obj/item/thing, mob/user)
	var/obj/item/weldingtool/T = thing
	. = istype(T) && T.remove_fuel(2, user) && T.isOn()

/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_disassemble/can_begin_with(obj/item/thing)
	. = ..()
	if(.)
		var/obj/item/organ/external/organ = thing
		// Only allow arm, leg, hand and foot prosthetics
		if(!BP_IS_ROBOTIC(organ))
			. = FALSE
			return
		// Check if it's an arm, leg, hand or foot
		if(!(organ.organ_tag in list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT)))
			. = FALSE
			return

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_disassemble
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "Disassembled prosthetic components. Mechanism needs wiring trim."
	progress_message = "You unscrew the bolts and disassemble the prosthetic into components."

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_disassemble/is_appropriate_tool(obj/item/thing)
	. = isScrewdriver(thing)

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_disassemble/get_product(obj/item/work)
	var/obj/item/organ/external/organ = locate() in work
	var/limb_type = organ ? organ.type : null

	var/turf/T = get_turf(work)
	new /obj/item/cell/standard(T)

	var/obj/item/robolimb_component/mechanism/mech = new(T)
	mech.limb_type = limb_type

	var/obj/item/robolimb_component/control_board/board = new(T)
	board.limb_type = limb_type

	var/obj/item/robolimb_component/prosthetic_shell/shell = new(T)
	shell.limb_type = limb_type

	qdel(work)


// Stage 2: Process mechanism
// Requires: Wirecutters, Welding, Screwdriver
/singleton/crafting_stage/prosthetic_crafting/wirecutters/mechanism_process
	begins_with_object_type = /obj/item/robolimb_component/mechanism
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A mechanism with trimmed wiring. Components need welding."
	progress_message = "You cut the excess connections of the mechanism."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/welding/mechanism_process)

/singleton/crafting_stage/prosthetic_crafting/wirecutters/mechanism_process/is_appropriate_tool(obj/item/thing)
	. = isWirecutter(thing)

/singleton/crafting_stage/prosthetic_crafting/welding/mechanism_process
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A welded mechanism. Screws need tightening."
	progress_message = "You weld the components of the mechanism."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/screwdriver/mechanism_process)

/singleton/crafting_stage/prosthetic_crafting/welding/mechanism_process/is_appropriate_tool(obj/item/thing, mob/user)
	var/obj/item/weldingtool/T = thing
	. = istype(T) && T.remove_fuel(1, user) && T.isOn()

/singleton/crafting_stage/prosthetic_crafting/screwdriver/mechanism_process
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A fully assembled mechanism ready for installation."
	progress_message = "You finish assembling the mechanism."
	product = /obj/item/robolimb_component/mechanism

/singleton/crafting_stage/prosthetic_crafting/screwdriver/mechanism_process/is_appropriate_tool(obj/item/thing)
	. = isScrewdriver(thing)

/singleton/crafting_stage/prosthetic_crafting/screwdriver/mechanism_process/get_product(obj/item/work)
	var/obj/item/robolimb_component/mechanism/mech = locate() in work
	// Mark as processed and move out of the crafting holder
	mech.processed = TRUE
	mech.forceMove(get_turf(work))
	return mech


// Stage 3: Process control board
// Requires: Wirecutters, 2 cables, 2 cables
/singleton/crafting_stage/prosthetic_crafting/wirecutters/control_board_process
	begins_with_object_type = /obj/item/robolimb_component/control_board
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A control board with trimmed contacts. Cables need to be connected."
	progress_message = "You cut the excess contacts on the board."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process)

/singleton/crafting_stage/prosthetic_crafting/wirecutters/control_board_process/is_appropriate_tool(obj/item/thing)
	. = isWirecutter(thing)

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process
	consume_completion_trigger = FALSE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A partially wired control board. More cables needed."
	progress_message = "You add cables to the board."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process2)

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process/is_appropriate_tool(obj/item/thing)
	. = isCoil(thing)

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process/consume(mob/user, obj/item/thing, obj/item/target)
	if(!isCoil(thing))
		return FALSE
	var/obj/item/stack/cable_coil/coil = thing
	if(coil.amount < 2)
		on_insufficient_material(user, thing)
		return FALSE
	coil.use(2)
	return TRUE

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process2
	consume_completion_trigger = FALSE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A fully assembled control board ready for installation."
	progress_message = "You complete the cable connections."

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process2/is_appropriate_tool(obj/item/thing)
	. = isCoil(thing)

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process2/consume(mob/user, obj/item/thing, obj/item/target)
	if(!isCoil(thing))
		return FALSE
	var/obj/item/stack/cable_coil/coil = thing
	if(coil.amount < 2)
		on_insufficient_material(user, thing)
		return FALSE
	coil.use(2)
	return TRUE

/singleton/crafting_stage/prosthetic_crafting/wiring/control_board_process2/get_product(obj/item/work)
	var/obj/item/robolimb_component/control_board/board = locate() in work
	// Mark as processed and move out of the crafting holder
	board.processed = TRUE
	board.forceMove(get_turf(work))
	return board


// Stage 4: Assemble prosthetic shell
// Requires: Wrench, Welding, Cables, Mechanism, Wrench, Control board, Screwdriver, Cables, Device Cell, Wrench, Welding, Screwdriver
/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell
	begins_with_object_type = /obj/item/robolimb_component/prosthetic_shell
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "An adjusted prosthetic shell. Seams need welding."
	progress_message = "You prepare the prosthetic shell."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_shell)

/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell/is_appropriate_tool(obj/item/thing)
	. = isWrench(thing)

/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_shell
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A welded shell. Wiring needs to be installed."
	progress_message = "You weld the prosthetic shell."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell)

/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_shell/is_appropriate_tool(obj/item/thing, mob/user)
	var/obj/item/weldingtool/T = thing
	. = istype(T) && T.remove_fuel(1, user) && T.isOn()

/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell
	consume_completion_trigger = FALSE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A wired shell. Mechanism needs installation."
	progress_message = "You install the wiring in the prosthetic shell."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/mechanism/prosthetic_shell)

/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell/is_appropriate_tool(obj/item/thing)
	. = isCoil(thing)

/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell/consume(mob/user, obj/item/thing, obj/item/target)
	if(!isCoil(thing))
		return FALSE
	var/obj/item/stack/cable_coil/coil = thing
	if(coil.amount < 2)
		on_insufficient_material(user, thing)
		return FALSE
	coil.use(2)
	return TRUE

/singleton/crafting_stage/prosthetic_crafting/mechanism/prosthetic_shell
	consume_completion_trigger = TRUE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A shell with installed mechanism. Needs wrench tightening."
	progress_message = "You install the mechanism."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell2)
	completion_trigger_type = /obj/item/robolimb_component/mechanism

/singleton/crafting_stage/prosthetic_crafting/mechanism/prosthetic_shell/is_appropriate_tool(obj/item/thing, mob/user)
	. = istype(thing, completion_trigger_type)
	if(.)
		var/obj/item/robolimb_component/mechanism/mech = thing
		if(!mech.processed)
			to_chat(user, SPAN_WARNING("This mechanism looks incomplete. It needs more work before installation."))
			. = FALSE

/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell2
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A shell with secured mechanism. Control board needs installation."
	progress_message = "You secure the mechanism."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/control_board/prosthetic_shell)

/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell2/is_appropriate_tool(obj/item/thing)
	. = isWrench(thing)

/singleton/crafting_stage/prosthetic_crafting/control_board/prosthetic_shell
	consume_completion_trigger = TRUE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A shell with installed board. Screws need tightening."
	progress_message = "You install the control board."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell)
	completion_trigger_type = /obj/item/robolimb_component/control_board

/singleton/crafting_stage/prosthetic_crafting/control_board/prosthetic_shell/is_appropriate_tool(obj/item/thing, mob/user)
	. = istype(thing, completion_trigger_type)
	if(.)
		var/obj/item/robolimb_component/control_board/board = thing
		if(!board.processed)
			to_chat(user, SPAN_WARNING("This control board looks incomplete. It needs more work before installation."))
			. = FALSE

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A shell with secured board. Additional wiring needed."
	progress_message = "You secure the control board."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell2)

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell/is_appropriate_tool(obj/item/thing)
	. = isScrewdriver(thing)

/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell2
	consume_completion_trigger = FALSE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A wired shell. It is missing a device power cell."
	progress_message = "You add additional wiring."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/cell/prosthetic_shell)

/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell2/is_appropriate_tool(obj/item/thing)
	. = isCoil(thing)

/singleton/crafting_stage/prosthetic_crafting/wiring/prosthetic_shell2/consume(mob/user, obj/item/thing, obj/item/target)
	if(!isCoil(thing))
		return FALSE
	var/obj/item/stack/cable_coil/coil = thing
	if(coil.amount < 2)
		on_insufficient_material(user, thing)
		return FALSE
	coil.use(2)
	return TRUE

/singleton/crafting_stage/prosthetic_crafting/cell/prosthetic_shell
	consume_completion_trigger = TRUE
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A shell with installed cell. Needs wrench tightening."
	progress_message = "You install the power cell."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell3)
	completion_trigger_type = /obj/item/cell/device

/singleton/crafting_stage/prosthetic_crafting/cell/prosthetic_shell/is_appropriate_tool(obj/item/thing, mob/user)
	. = istype(thing, completion_trigger_type)
	if(.)
		var/obj/item/cell/device/cell = thing
		if(cell.charge < 100)
			to_chat(user, SPAN_WARNING("The [cell] needs to be fully charged!"))
			. = FALSE

/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell3
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A shell with secured cell. Final seams need welding."
	progress_message = "You secure the power cell."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_shell2)

/singleton/crafting_stage/prosthetic_crafting/wrench/prosthetic_shell3/is_appropriate_tool(obj/item/thing)
	. = isWrench(thing)

/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_shell2
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A welded shell. Final screws need tightening."
	progress_message = "You weld the final seams."
	next_stages = list(/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell2)

/singleton/crafting_stage/prosthetic_crafting/welding/prosthetic_shell2/is_appropriate_tool(obj/item/thing, mob/user)
	var/obj/item/weldingtool/T = thing
	. = istype(T) && T.remove_fuel(1, user) && T.isOn()

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell2
	item_icon = 'mods/ipc_mods/icons/crafting_stages.dmi'
	item_icon_state = "crafting"
	item_desc = "A fully assembled prosthetic limb ready for installation."
	progress_message = "You complete the assembly of the prosthetic shell."

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell2/is_appropriate_tool(obj/item/thing)
	. = isScrewdriver(thing)

/singleton/crafting_stage/prosthetic_crafting/screwdriver/prosthetic_shell2/get_product(obj/item/work)
	var/limb_type

	// Try to get limb_type from any component in the crafting holder
	for(var/obj/item/robolimb_component/component in work)
		if(component.limb_type)
			limb_type = component.limb_type
			break

	// Spawn the original limb type and robotize it
	var/obj/item/organ/external/limb
	if(limb_type)
		limb = new limb_type(get_turf(work))
	else
		// Default to left arm if no limb type stored
		limb = new /obj/item/organ/external/arm(get_turf(work))

	if(limb)
		limb.robotize("Small prosthetic")
		limb.update_icon()

	return limb
