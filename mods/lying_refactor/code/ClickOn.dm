//КЛИИК
/mob/ClickOn(atom/A, params)

	if(world.time <= next_click) // Hard check, before anything else, to avoid crashing
		return

	next_click = world.time + 1

	var/list/modifiers = params2list(params)
	if (modifiers["ctrl"] && modifiers["alt"] && modifiers["shift"])
		if (CtrlAltShiftClickOn(A))
			return
	else if (modifiers["shift"] && modifiers["ctrl"])
		if (CtrlShiftClickOn(A))
			return
	else if (modifiers["ctrl"] && modifiers["alt"])
		if (CtrlAltClickOn(A))
			return
	else if (modifiers["shift"] && modifiers["alt"])
		if (AltShiftClickOn(A))
			return
	else if (modifiers["middle"])
		if (MiddleClickOn(A))
			return
	else if (modifiers["shift"])
		if (ShiftClickOn(A))
			return
	else if (modifiers["alt"])
		if (AltClickOn(A))
			return
	else if (modifiers["ctrl"])
		if (CtrlClickOn(A))
			return

	if(stat || paralysis || stunned || sleeping)
		return

	// Do not allow player facing change in fixed chairs
	if(!istype(buckled) || buckled.buckle_movable)
		face_atom(A) // change direction to face what you clicked on

	if(!canClick()) // in the year 2000...
		return

	if(restrained())
		setClickCooldown(10)
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		if(isturf(A) || isturf(A.loc))
			throw_item(A)
			trigger_aiming(TARGET_CAN_CLICK)
			return
		throw_mode_off()

	var/obj/item/W = get_active_hand()

	if(W == A) // Handle attack_self
		W.attack_self(src)
		trigger_aiming(TARGET_CAN_CLICK)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)
		return

	//Atoms on your person
	// A is your location but is not a turf; or is on you (backpack); or is on something on you (box in backpack); sdepth is needed here because contents depth does not equate inventory storage depth.
	var/sdepth = A.storage_depth(src)
	if((!isturf(A) && A == loc) || (sdepth != -1 && sdepth <= 1))
		if(W)
			var/resolved = W.resolve_attackby(A, src, modifiers)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, modifiers) // 1 indicates adjacency
		else
			if(ismob(A)) // No instant mob attacking
				setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			UnarmedAttack(A, 1)

		trigger_aiming(TARGET_CAN_CLICK)
		return

	if(!loc.allow_click_through(A, modifiers, src)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	//Atoms on turfs (not on your person)
	// A is a turf or is on a turf, or in something on a turf (pen in a box); but not something in something on a turf (pen in a box in a backpack)
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				// Return TRUE in resolve_attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = W.resolve_attackby(A,src, modifiers)
				if(!resolved && A && W)
					W.afterattack(A, src, 1, modifiers) // 1: clicking something Adjacent
			else
				if(ismob(A)) // No instant mob attacking
					setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				UnarmedAttack(A, 1)

			trigger_aiming(TARGET_CAN_CLICK)
			return
		else // non-adjacent click
			if(W) //Стрелять лёжа плохо
				if(istype(W, /obj/item/gun) && lying)
					to_chat(src, SPAN_BAD("I can't use weapon in this position"))
					return
				W.afterattack(A, src, 0, modifiers) // 0: not Adjacent
			else
				RangedAttack(A, modifiers)

			trigger_aiming(TARGET_CAN_CLICK)
	return
