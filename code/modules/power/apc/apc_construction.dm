/obj/machinery/power/apc/components_are_accessible(path)
	. = opened
	if(ispath(path, /obj/item/stock_parts/power/terminal))
		. = min(., (has_electronics != 2))

//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return attack_robot(user)
	if(istype(W, /obj/item/inducer))
		return FALSE // inducer.dm use_after handles this

	if(isCrowbar(W))
		if(opened)
			if (has_electronics == 1)
				if (terminal())
					to_chat(user, SPAN_WARNING("Disconnect the wires first."))
					return TRUE
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "You are trying to remove the power control board...")

				if(do_after(user, (W.toolspeed * 5) SECONDS, src, DO_REPAIR_CONSTRUCT) && opened && (has_electronics == 1) && !terminal())
					has_electronics = 0
					if (MACHINE_IS_BROKEN(src))
						user.visible_message(\
							SPAN_WARNING("\The [user] has broken the power control board inside \the [src]!"),\
							SPAN_NOTICE("You break the charred power control board and remove the remains."),\
							"You hear a crack!")
					else
						user.visible_message(\
							SPAN_WARNING("\The [user] has removed the power control board from \the [src]!"),\
							SPAN_NOTICE("You remove the power control board."))
						new /obj/item/module/power_control(loc)
				return TRUE

			else if (opened != 2)
				opened = 0
				user.visible_message(SPAN_NOTICE("\The [user] pries the cover shut on \the [src]."), SPAN_NOTICE("You pry the cover shut."))
				update_icon()
				return TRUE

		if(MACHINE_IS_BROKEN(src) || hacker && !hacker.hacked_apcs_hidden)
			if (opened == 2)
				to_chat(user, SPAN_WARNING("The cover of \the [src] is broken!"))
			else
				to_chat(user, SPAN_WARNING("The cover  of \the [src] appears stuck. You need to bash it off!"))
			return TRUE
		if(coverlocked && !(GET_FLAGS(stat, MACHINE_STAT_MAINT)))
			to_chat(user, SPAN_WARNING("The cover is locked and cannot be opened."))
			return TRUE
		opened = 1
		user.visible_message(SPAN_NOTICE("\The [user] pries the cover open on \the [src]."), SPAN_NOTICE("You pry the cover open."))
		update_icon()
		return TRUE

	if(isScrewdriver(W))
		if(opened)
			if (get_cell())
				to_chat(user, SPAN_WARNING("Either close the cover or remove the cell first."))
				return TRUE
			switch(has_electronics)
				if(1)
					if(!terminal())
						to_chat(user, SPAN_WARNING("You must attach a wire connection first!"))
						return TRUE
					has_electronics = 2
					set_stat(MACHINE_STAT_MAINT, FALSE)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					to_chat(user, "You screw the circuit electronics into place.")
					update_icon()
				if(2)
					has_electronics = 1
					set_stat(MACHINE_STAT_MAINT, TRUE)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					to_chat(user, "You unfasten the electronics.")
					update_icon()
				if(0)
					to_chat(user, SPAN_WARNING("There is no power control board to secure!"))
			return TRUE
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
		update_icon()
		return TRUE

	if (istype(W, /obj/item/card/id)||istype(W, /obj/item/modular_computer))
		if(emagged)
			to_chat(user, "The interface is broken.")
		else if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel")
		else if(MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
			to_chat(user, "Nothing happens.")
		else if(hacker && !hacker.hacked_apcs_hidden)
			to_chat(user, SPAN_WARNING("Access denied."))
		else
			if(has_access(req_access, user.GetAccess()) && !isWireCut(APC_WIRE_IDSCAN))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				update_icon()
			else
				to_chat(user, SPAN_WARNING("Access denied."))
		return TRUE

	if(istype(W, /obj/item/module/power_control))
		if(MACHINE_IS_BROKEN(src))
			to_chat(user, SPAN_WARNING("You cannot put the board inside, the frame is damaged."))
			return TRUE
		if(!opened)
			to_chat(user, SPAN_WARNING("You must first open the cover."))
			return TRUE
		if(has_electronics != 0)
			to_chat(user, SPAN_WARNING("There is already a power control board inside."))
			return TRUE
		user.visible_message(SPAN_WARNING("\The [user] inserts the power control board into \the [src]."), \
							"You start to insert the power control board into the frame...")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 1 SECOND, src, DO_REPAIR_CONSTRUCT) && has_electronics == 0 && opened && !MACHINE_IS_BROKEN(src))
			has_electronics = 1
			reboot()
			to_chat(user, SPAN_NOTICE("You place the power control board inside the frame."))
			qdel(W)
		return TRUE

	if(isWelder(W))
		if(!opened)
			to_chat(user, SPAN_WARNING("You must first open the cover."))
			return TRUE
		if(has_electronics != 0)
			to_chat(user, SPAN_WARNING("You must first remove the power control board inside."))
			return TRUE
		if(terminal())
			to_chat(user, SPAN_WARNING("The wire connection is in the way."))
			return TRUE
		var/obj/item/weldingtool/WT = W
		if (!WT.can_use(3, user))
			return TRUE
		user.visible_message(SPAN_WARNING("\The [user] begins to weld \the [src]."), \
							"You start welding the APC frame...", \
							"You hear welding.")
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, (W.toolspeed * 5) SECONDS, src, DO_REPAIR_CONSTRUCT) && opened && has_electronics == 0 && !terminal())
			if(!WT.remove_fuel(3, user))
				return TRUE
			if (emagged || MACHINE_IS_BROKEN(src) || opened==2)
				new /obj/item/stack/material/steel(loc)
				user.visible_message(\
					SPAN_WARNING("\The [src] has been cut apart by \the [user] with \the [WT]."),\
					SPAN_NOTICE("You disassembled the broken APC frame."),\
					"You hear welding.")
			else
				new /obj/item/frame/apc(loc)
				user.visible_message(\
					SPAN_WARNING("\The [src] has been cut from the wall by \the [user] with \the [WT]."),\
					SPAN_NOTICE("You cut the APC frame from the wall."),\
					"You hear welding.")
			qdel(src)
			return TRUE

	if (istype(W, /obj/item/frame/apc))
		if(!opened)
			to_chat(user, SPAN_WARNING("You must first open the cover."))
			return TRUE
		if(emagged)
			emagged = FALSE
			if(opened==2)
				opened = 1
			user.visible_message(\
				SPAN_WARNING("[user.name] has replaced the damaged APC frontal panel with a new one."),\
				SPAN_NOTICE("You replace the damaged APC frontal panel with a new one."))
			qdel(W)
			update_icon()
			return TRUE

		if(MACHINE_IS_BROKEN(src) || (hacker && !hacker.hacked_apcs_hidden))
			if (has_electronics)
				to_chat(user, SPAN_WARNING("You cannot repair this APC until you remove the electronics still inside."))
				return TRUE

			user.visible_message(SPAN_WARNING("[user.name] replaces the damaged APC frame with a new one."),\
								"You begin to replace the damaged APC frame...")
			if(do_after(user, 5 SECONDS, src, DO_REPAIR_CONSTRUCT) && opened && !has_electronics && (MACHINE_IS_BROKEN(src) || (hacker && !hacker.hacked_apcs_hidden)))
				user.visible_message(\
					SPAN_NOTICE("[user.name] has replaced the damaged APC frame with new one."),\
					"You replace the damaged APC frame with new one.")
				qdel(W)
				revive_health()
				set_broken(FALSE)
				if(hacker && hacker.hacked_apcs && (src in hacker.hacked_apcs))
					hacker.hacked_apcs -= src
					hacker = null
				if (opened==2)
					opened = 1
				queue_icon_update()
			return TRUE

	if((. = ..()))
		return

	if (istype(user, /mob/living/silicon))
		return attack_robot(user)
	if (!opened && wiresexposed && (isMultitool(W) || isWirecutter(W) || istype(W, /obj/item/device/assembly/signaler)))
		return wires.Interact(user)

	return ..()

/obj/machinery/power/apc/post_health_change(health_mod, prior_health, damage_type)
	. = ..()
	var/damage_percentage = get_damage_percentage()
	if (health_mod >= 0)
		return
	if ((damage_percentage >= 50 || (hacker && !hacker.hacked_apcs_hidden)) && opened != 2 && prob(20))
		visible_message(SPAN_DANGER("The lid on \the [src] is knocked down"))
		coverlocked = FALSE
		opened = 2
		queue_icon_update()
		return

	if (!health_dead())
		if (damage_percentage >= 25 && locked && prob(20))
			locked = FALSE
			visible_message(SPAN_DANGER("The interface lock on \the [src] malfunctions!"), range = 1)
		if (damage_percentage >= 75 && prob(20))
			kill_health()

/obj/machinery/power/apc/emag_act(remaining_charges, mob/user)
	if (!(emagged || (hacker && !hacker.hacked_apcs_hidden)))
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel first")
		else if(MACHINE_IS_BROKEN(src) || GET_FLAGS(stat, MACHINE_STAT_MAINT))
			to_chat(user, "Nothing happens.")
		else
			flick("apc-spark", src)
			if (do_after(user,6,src))
				if(prob(50))
					emagged = TRUE
					req_access.Cut()
					locked = 0
					to_chat(user, SPAN_NOTICE("You emag the APC interface."))
					update_icon()
				else
					to_chat(user, SPAN_WARNING("You fail to [ locked ? "unlock" : "lock"] the APC interface."))
				return 1
