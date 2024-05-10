/mob/living/MouseDrop(atom/over)
	if(usr == src && usr != over)
		if(istype(over, /mob/living/exosuit))
			var/mob/living/exosuit/exosuit = over
			if(exosuit.body)
				if(usr.mob_size >= exosuit.body.min_pilot_size && usr.mob_size <= exosuit.body.max_pilot_size \
				&& !issilicon(usr))
					if(exosuit.enter(src,FALSE,TRUE,FALSE))
						return
				else
					to_chat(usr, SPAN_WARNING("You cannot pilot a exosuit of this size."))
					return
	return ..()

/mob/living/exosuit/MouseDrop_T(atom/dropping, mob/user)
	var/obj/machinery/portable_atmospherics/canister/C = dropping
	if(istype(C))
		body.MouseDrop_T(dropping, user)
	else . = ..()

/mob/living/exosuit/MouseDrop(mob/living/carbon/human/over_object) //going from assumption none of previous options are relevant to exosuit
	if(body)
		if(!body.MouseDrop(over_object))
			return ..()

/mob/living/exosuit/RelayMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	if(user && (user in pilots) && user.loc == src)
		return OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, user)
	return ..()

/mob/living/exosuit/OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	if(!user || incapacitated() || user.incapacitated())
		return FALSE

	if(!(user in pilots) && user != src)
		return FALSE

	//This is handled at active module level really, it is the one who has to know if it's supposed to act
	if(selected_system)
		return selected_system.MouseDragInteraction(src_object, over_object, src_location, over_location, src_control, over_control, params, user)

/datum/click_handler/default/mech/OnClick(atom/A, params)
	var/mob/living/exosuit/E = user.loc
	if(!istype(E))
		//If this happens something broke tbh
		user.RemoveClickHandler(src)
		return
	if(E.hatch_closed)
		return E.ClickOn(A, params, user)
	else return ..()

/datum/click_handler/default/mech/OnDblClick(atom/A, params)
	OnClick(A, params)

/mob/living/exosuit/allow_click_through(atom/A, params, mob/user)
	if(LAZYISIN(pilots, user) && !hatch_closed)
		return TRUE
	. = ..()

//UI distance checks
/mob/living/exosuit/contents_nano_distance(src_object, mob/living/user)
	. = ..()
	if(!hatch_closed)
		return max(shared_living_nano_distance(src_object), .) //Either visible to mech(outside) or visible to user (inside)


/mob/living/exosuit/ClickOn(atom/A, params, mob/user)
	if(!user || incapacitated() || user.incapacitated())
		return
//MODDED
	var/arms_chosen = FALSE
	var/body_chosen = FALSE
	if(selected_hardpoint == HARDPOINT_LEFT_HAND || selected_hardpoint == HARDPOINT_RIGHT_HAND)
		arms_chosen = TRUE
		body_chosen = FALSE
	else if(selected_hardpoint == HARDPOINT_BACK || selected_hardpoint == HARDPOINT_HEAD || selected_hardpoint == HARDPOINT_LEFT_SHOULDER || selected_hardpoint == HARDPOINT_RIGHT_SHOULDER)
		arms_chosen = FALSE
		body_chosen = TRUE
//MODDED

	if(!loc) return
	var/adj = A.Adjacent(src) // Why in the fuck isn't Adjacent() commutative.

	var/modifiers = params2list(params)
	if(modifiers["shift"])
		examinate(user, A)
		return

	if(modifiers["ctrl"])
		if(istype(A, /obj/item/mech_equipment))
			for(var/hardpoint in hardpoints)
				if(A == hardpoints[hardpoint])
					A.CtrlClick(user)
					setClickCooldown(3)
					return

	if(modifiers["alt"])
		if(istype(A, /obj/item/mech_equipment))
			for(var/hardpoint in hardpoints)
				if(A == hardpoints[hardpoint])
					A.AltClick(user)
					setClickCooldown(3)
					return

	if(!(user in pilots) && user != src)
		return

	if(!canClick())
		return

	// Are we facing the target?
	if(A.loc != src && !(get_dir(src, A) & dir))
		return

	if(!arms && arms_chosen)
		to_chat(user, SPAN_WARNING("\The [src] has no manipulators!"))
		setClickCooldown(3)
		return

	if((!arms.motivator || !arms.motivator.is_functional()) && arms_chosen)
		to_chat(user, SPAN_WARNING("Your motivators are damaged! You can't use your manipulators!"))
		setClickCooldown(15)
		return

	if((!body || body.total_damage >= body.max_damage) && body_chosen)
		to_chat(user, SPAN_WARNING("Your cockpit too damaged, additional hardpoints control system damaged, you can't use this module!"))
		setClickCooldown(15)
		return

	if(!get_cell()?.checked_use(arms.power_use * CELLRATE))
		to_chat(user, power == MECH_POWER_ON ? SPAN_WARNING("Error: Power levels insufficient.") :  SPAN_WARNING("\The [src] is powered off."))
		return

	// User is not necessarily the exosuit, or the same person, so update intent.
	if(user != src)
		a_intent = user.a_intent
		if(user.zone_sel)
			zone_sel.set_selected_zone(user.zone_sel.selecting)
		else
			zone_sel.set_selected_zone(BP_CHEST)
	// You may attack the target with your exosuit FIST if you're malfunctioning.
	var/atom/movable/AM = A
	var/fail_prob = (user != src && istype(AM) && AM.loc != src) ? (user.skill_check(SKILL_MECH, HAS_PERK) ? 0: 15 ) : 0
	var/failed = FALSE
	if(prob(fail_prob))
		to_chat(user, SPAN_DANGER("Your incompetence leads you to target the wrong thing with the exosuit!"))
		failed = TRUE
	else if(emp_damage > EMP_ATTACK_DISRUPT && prob(emp_damage*2))
		to_chat(user, SPAN_DANGER("The wiring sparks as you attempt to control the exosuit!"))
		failed = TRUE

	if(!failed)
		if(istype(A, /obj/item/mech_equipment))
			for(var/hardpoint in hardpoints)
				if(A == hardpoints[hardpoint])
					var/obj/item/mech_equipment/mech_equipment = A
					mech_equipment.attack_self(user)
					setClickCooldown(5)
					return
		if(selected_system)
			// Mounted non-exosuit systems have some hacky loc juggling
			// to make sure that they work.
			var/system_moved = FALSE
			var/obj/item/temp_system
			var/obj/item/mech_equipment/ME
			if(istype(selected_system, /obj/item/mech_equipment))
				ME = selected_system
				temp_system = ME.get_effective_obj()
				if(temp_system in ME)
					system_moved = 1
					temp_system.forceMove(src)
			else
				temp_system = selected_system

			// Slip up and attack yourself maybe.
			failed = FALSE
			if(prob(fail_prob))
				to_chat(user, SPAN_DANGER("You artlessly shove the exosuit controls the wrong way!"))
				failed = TRUE
			else if(emp_damage>EMP_MOVE_DISRUPT && prob(10))
				failed = TRUE

			if(failed)
				var/list/other_atoms = orange(1, A)
				A = null
				while(LAZYLEN(other_atoms))
					var/atom/picked = pick_n_take(other_atoms)
					if(istype(picked) && picked.simulated)
						A = picked
						break
				if(!A)
					A = src
				adj = A.Adjacent(src)

			var/resolved

			if(adj) resolved = temp_system.resolve_attackby(A, src, params)
			if(!resolved && A && temp_system)
				var/mob/ruser = src
				if(!system_moved) //It's more useful to pass along clicker pilot when logic is fully mechside
					ruser = user
				temp_system.afterattack(A,ruser,adj,params)
			if(system_moved) //We are using a proxy system that may not have logging like mech equipment does
				admin_attack_log(user, A, "Attacked using \a [temp_system] (MECH)", "Was attacked with \a [temp_system] (MECH)", "used \a [temp_system] (MECH) to attack")
			//Mech equipment subtypes can add further click delays
			var/extra_delay = 0
			if(!isnull(selected_system))
				ME = selected_system
				extra_delay = ME.equipment_delay
			setClickCooldown(arms ? arms.action_delay + extra_delay : 15 + extra_delay)
			if(system_moved)
				temp_system.forceMove(selected_system)
			return

	if(A == src)
		setClickCooldown(5)
		return attack_self(user)
	else if(adj && user.a_intent == I_HURT && arms.motivator) //Prevents accidental slams.
		setClickCooldown(arms ? arms.action_delay : 7) // You've already commited to applying fist, don't turn and back out now!
		playsound(src.loc, legs.mech_step_sound, 60, 1)
		var/arms_local_damage = arms.melee_damage
		src.visible_message(SPAN_DANGER("\The [src] steps back, preparing for a strike!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
		if (do_after(src, 1.2 SECONDS, get_turf(src), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && user)
		//additional actions with objects!

			//emergency airlock open
			if(istype(A, /obj/machinery/door/firedoor) )
				var/obj/machinery/door/firedoor/FD = A
				if(!FD.blocked)
					setClickCooldown(arms ? arms.action_delay : 7)
					addtimer(CALLBACK(FD, /obj/machinery/door/firedoor.proc/toggle, TRUE), 0)
					return
			//emergency airlock open

			//door open
			else if((istype(A, /obj/machinery/door)))
				var/obj/machinery/door/airlock/FD = A
				if(FD.inoperable() || !FD.is_powered())
					setClickCooldown(arms ? arms.action_delay : 7)
					addtimer(CALLBACK(FD, /obj/machinery/door/.proc/toggle, TRUE), 0)
					return
				arms_local_damage = arms_local_damage * 2
			//door open

			//blast open
			else if((istype(A, /obj/machinery/door/blast)))
				var/obj/machinery/door/blast/FD = A
				if(FD.inoperable() || !FD.is_powered())
					setClickCooldown(arms ? arms.action_delay : 7)
					addtimer(CALLBACK(FD, /obj/machinery/door/blast.proc/force_toggle, TRUE), 0)
					return
				arms_local_damage = arms_local_damage * 2
			//blast open

			//heavy blast open
			else if(istype(A,/obj/machinery/door/blast/regular))
				var/obj/machinery/door/blast/FD = A
				if(FD.inoperable() || !FD.is_powered())
					setClickCooldown(arms ? arms.action_delay : 7)
					addtimer(CALLBACK(FD, /obj/machinery/door/blast.proc/force_toggle, TRUE), 0)
					return
				to_chat(user, SPAN_NOTICE("This structure too reinforced for being damaged by [src]!"))
				return
			//heavy blast open
			//Now - attack
			A.attack_generic(src, arms_local_damage, "strikes", DAMAGE_BRUTE) //"Punch" would be bad since vehicles without arms could be a thing //No
			var/turf/T = get_turf(A)
			if(istype(T))
				do_attack_effect(T, "smash")
			playsound(src.loc, arms.punch_sound, 50, 1)
	else if(istype(A, /obj/structure/ladder))
		var/obj/structure/ladder/L = A
		L.climb(src) //Those are some real sturdy ladders.
	return

/mob/living/exosuit/proc/set_hardpoint(hardpoint_tag)
	clear_selected_hardpoint()
	if(hardpoints[hardpoint_tag])
		// Set the new system.
		selected_system = hardpoints[hardpoint_tag]
		selected_hardpoint = hardpoint_tag
		return 1 // The element calling this proc will set its own icon.
	return 0

/mob/living/exosuit/proc/clear_selected_hardpoint()

	if(selected_hardpoint)
		for(var/hardpoint in hardpoints)
			if(hardpoint != selected_hardpoint)
				continue
			var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
			if(istype(H))
				H.icon_state = "hardpoint"
				break
		selected_system = null
	selected_hardpoint = null

/mob/living/exosuit/proc/check_enter(mob/user, silent = FALSE, check_incap = TRUE)
	if(!user || (check_incap && user.incapacitated()))
		return FALSE
	if (user.buckled)
		if (!silent)
			to_chat(user, SPAN_WARNING("You are currently buckled to \the [user.buckled]."))
		return FALSE
	if(!(user.mob_size >= body.min_pilot_size && user.mob_size <= body.max_pilot_size))
		if(!silent)
			to_chat(user, SPAN_WARNING("You cannot pilot an exosuit of this size."))
		return FALSE
	if(!user.Adjacent(src))
		return FALSE
	if(hatch_locked)
		if(!check_passenger(user))
			return
		if(!silent)
			to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
		return FALSE
	if(hatch_closed)
		if(!check_passenger(user))
			return
		if(!silent)
			to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is closed."))
		return FALSE
	if(LAZYLEN(pilots) >= LAZYLEN(body.pilot_positions))
		if(!silent)
			to_chat(user, SPAN_WARNING("\The [src] is occupied to capacity."))
		return FALSE
	return TRUE

/mob/living/exosuit/proc/enter(mob/user, silent = FALSE, check_incap = TRUE, instant = FALSE)
	if(!check_enter(user, silent, check_incap))
		return FALSE
	if(!istype(user, /mob/living/carbon))
		to_chat(user, SPAN_WARNING("You cant pilot exosuits"))
		return
	to_chat(user, SPAN_NOTICE("You start climbing into \the [src]..."))
	if(!body)
		return FALSE
	if(!instant && !do_after(user, body.climb_time, src, DO_PUBLIC_UNIQUE))
		return FALSE
	if(!check_enter(user, silent, check_incap))
		return FALSE
	if(!silent)
		to_chat(user, SPAN_NOTICE("You climb into \the [src]."))
		playsound(src, 'sound/machines/airlock_heavy.ogg', 60, 1)
	add_pilot(user)
	return TRUE

/mob/living/exosuit/proc/check_passenger(mob/user) // Выбираем желаемое место, проверяем можно ли его занять, стартуем прок занятия
	var/local_dir = get_dir(src, user)
	if(local_dir != turn(dir, 90) && local_dir != turn(dir, -90) && local_dir != turn(dir, -135) && local_dir != turn(dir, 135) && local_dir != turn(dir, 180))
	// G G G
	// G M G  ↓ (Mech dir, look on SOUTH)
	// B B B
	// M - mech, B - cant climb ON mech from this side, G - can climb ON mech from this side
		to_chat(user, SPAN_WARNING("You cant climb in passenger place of [src ] from this side."))
		return FALSE
	var/choose
	var/choosed_place = input(usr, "Choose passenger place which you want to take.", name, choose) as null|anything in passenger_places
	if(!user.Adjacent(src)) // <- Мех рядом?
		return FALSE
	if(user.r_hand != null || user.l_hand != null)
		to_chat(user,SPAN_NOTICE("You need two free hands to take [choosed_place]."))
		return
	if(user.mob_size > MOB_MEDIUM)
		to_chat(user,SPAN_NOTICE("Looks like you too big to take [choosed_place]."))
		return
	if(choosed_place == "Back")
		if(LAZYLEN(passenger_compartment.back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(body.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [body.name]"))
			return 0
	else if(choosed_place == "Left back")
		if(LAZYLEN(passenger_compartment.left_back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(arms.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [arms.name]"))
			return 0
	else if(choosed_place == "Right back")
		if(LAZYLEN(passenger_compartment.right_back_passengers) > 0)
			to_chat(user,SPAN_NOTICE("[choosed_place] is busy"))
			return 0
		else if(arms.allow_passengers == FALSE)
			to_chat(user,SPAN_NOTICE("[choosed_place] not able with [arms.name]"))
			return 0
	else if(choosed_place == null)
		return 0
	if(check_hardpoint_passengers(choosed_place,user) == TRUE)
		enter_passenger(user,choosed_place)

/mob/living/exosuit/proc/check_hardpoint_passengers(place,mob/user)// Данный прок проверяет, доступна ли часть тела для занятия её пассажиром в данный момент
	var/obj/item/mech_equipment/checker
	if(place == "Back" && hardpoints["back"] != null)
		checker = hardpoints["back"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	else if(place == "Left back" && hardpoints["left shoulder"] != null)
		checker = hardpoints["left shoulder"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	else if(place == "Right back" && hardpoints["right shoulder"] != null)
		checker = hardpoints["right shoulder"]
		if(checker.disturb_passengers == TRUE)
			to_chat(user,SPAN_NOTICE("[place] covered by [checker] and cant be taked."))
			return FALSE
	return TRUE

/mob/living/exosuit/proc/enter_passenger(mob/user,place)// Пытается пихнуть на пассажирское место пассажира, перед этим ещё раз проверяя их
	//Проверка спины
	src.visible_message(SPAN_NOTICE(" [user] starts climb on the [place] of [src]!"))
	if(do_after(user, 2 SECONDS, get_turf(src),DO_SHOW_PROGRESS|DO_FAIL_FEEDBACK|DO_USER_CAN_TURN| DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		if(user.r_hand != null || user.l_hand != null)
			to_chat(user,SPAN_NOTICE("You need two free hands to clim on[place] of [src]."))
			return
		if(place == "Back" && LAZYLEN(passenger_compartment.back_passengers) == 0)
			user.forceMove(passenger_compartment)
			LAZYDISTINCTADD(passenger_compartment.back_passengers,user)
			user.pinned += src
		else if(place == "Left back" && LAZYLEN(passenger_compartment.left_back_passengers) == 0)
			user.forceMove(passenger_compartment)
			LAZYDISTINCTADD(passenger_compartment.left_back_passengers,user)
			user.pinned += src
		else if(place == "Right back" && LAZYLEN(passenger_compartment.right_back_passengers) == 0)
			user.forceMove(passenger_compartment)
			LAZYDISTINCTADD(passenger_compartment.right_back_passengers,user)
			user.pinned += src
		else
			to_chat(user,SPAN_NOTICE("Looks like [place] is busy!"))
			return 0
		src.visible_message(SPAN_NOTICE(" [user] climbed on [place] of [src]!"))
		passenger_compartment.count_passengers()
		update_passengers()
		return

// будет использоваться Life() дабы исключить моменты, когда по какой-то причине пассажир слез с меха, лежа на полу. Life вызовется, обработается pinned, всем в кайф.
/mob/living/exosuit/proc/leave_passenger(mob/user)// Пассажир сам покидает меха
	src.visible_message(SPAN_NOTICE("[user] jump off [src]!"))
	user.dropInto(loc)
	user.pinned -= src
	user.Life()
	if(user in passenger_compartment.back_passengers)
		LAZYREMOVE(passenger_compartment.back_passengers,user)
	else if(user in passenger_compartment.left_back_passengers)
		LAZYREMOVE(passenger_compartment.left_back_passengers,user)
	else if(user in passenger_compartment.right_back_passengers)
		LAZYREMOVE(passenger_compartment.right_back_passengers,user)
	passenger_compartment.count_passengers()
	update_passengers()

/mob/living/exosuit/proc/forced_leave_passenger(place,mode,author)// Нечто внешнее насильно опустошает Одно/все места пассажиров
// mode 1 - полный выгруз, mode 2 - рандомного одного, mode 0(Отсутствие мода) - ручной скид пассажира мехводом
	if(mode == MECH_DROP_ALL_PASSENGER) // Полная разгрузка
		if(LAZYLEN(passenger_compartment.back_passengers)>0)
			for(var/mob/i in passenger_compartment.back_passengers)
				LAZYREMOVE(passenger_compartment.back_passengers,i)
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				passenger_compartment.count_passengers()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
		if(LAZYLEN(passenger_compartment.left_back_passengers)>0)
			for(var/mob/i in passenger_compartment.left_back_passengers)
				LAZYREMOVE(passenger_compartment.left_back_passengers,i)
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				passenger_compartment.count_passengers()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
		if(LAZYLEN(passenger_compartment.right_back_passengers) > 0)
			for(var/mob/i in passenger_compartment.right_back_passengers)
				LAZYREMOVE(passenger_compartment.right_back_passengers,i)
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				passenger_compartment.count_passengers()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
		update_passengers()

	else if(mode == MECH_DROP_ANY_PASSENGER) // Сброс по приоритету спина - левый бок - правый бок.
		if(LAZYLEN(passenger_compartment.back_passengers) > 0)
			for(var/mob/i in passenger_compartment.back_passengers)
				LAZYREMOVE(passenger_compartment.back_passengers,i)
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				passenger_compartment.count_passengers()
				update_passengers()
				return
		else if(LAZYLEN(passenger_compartment.left_back_passengers)>0)
			for(var/mob/i in passenger_compartment.left_back_passengers)
				LAZYREMOVE(passenger_compartment.left_back_passengers,i)
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				passenger_compartment.count_passengers()
				update_passengers()
				return
		else if(LAZYLEN(passenger_compartment.right_back_passengers)>0)
			for(var/mob/i in passenger_compartment.right_back_passengers)
				LAZYREMOVE(passenger_compartment.right_back_passengers,i)
				i.dropInto(loc)
				i.pinned -= src
				i.Life()
				i.Life()
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				passenger_compartment.count_passengers()
				update_passengers()
				return

	else // <- Опустошается определённое место
		if(place == "Back")
			for(var/mob/i in passenger_compartment.back_passengers)
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]"))
				i.dropInto(loc)
				i.pinned -= src
				LAZYREMOVE(passenger_compartment.back_passengers,i)
		else if(place == "Left back")
			for(var/mob/i in passenger_compartment.left_back_passengers)
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]!"))
				i.dropInto(loc)
				i.pinned -= src
				LAZYREMOVE(passenger_compartment.left_back_passengers,i)
		else if(place == "Right back")
			for(var/mob/i in passenger_compartment.right_back_passengers)
				src.visible_message(SPAN_WARNING("[i] was forcelly removed from [src] by [author]!"))
				i.dropInto(loc)
				i.pinned -= src
				LAZYREMOVE(passenger_compartment.right_back_passengers,i)
		passenger_compartment.count_passengers()
		update_passengers()
/// Adds a mob to the pilots list and destroyed event handlers.
/mob/living/exosuit/proc/add_pilot(mob/user)
	if (LAZYISIN(pilots, user))
		return
	user.forceMove(src)
	user.PushClickHandler(/datum/click_handler/default/mech)
	if (user.client)
		user.client.screen |= hud_elements
	LAZYADD(pilots, user)
	LAZYDISTINCTADD(user.additional_vision_handlers, src)
	GLOB.destroyed_event.register(user, src, PROC_REF(remove_pilot))
	sync_access()
	update_pilots()

/// Removes a mob from the pilots list and destroyed event handlers. Called by the destroyed event.
/mob/living/exosuit/proc/remove_pilot(mob/user)
	if (!LAZYISIN(pilots, user))
		return
	user.RemoveClickHandler(/datum/click_handler/default/mech)
	if (!QDELETED(user))
		user.dropInto(loc)
	if (user.client)
		user.client.screen -= hud_elements
		user.client.screen -= menu_hud_elements
		user.client.eye = user
	LAZYREMOVE(user.additional_vision_handlers, src)
	LAZYREMOVE(pilots, user)
	GLOB.destroyed_event.unregister(user, src, PROC_REF(remove_pilot))
	sync_access()
	update_pilots()

/mob/living/exosuit/proc/sync_access()
	access_card.access = saved_access.Copy()
	if(sync_access)
		for(var/mob/pilot in pilots)
			access_card.access |= pilot.GetAccess()
			to_chat(pilot, SPAN_NOTICE("Security access permissions synchronized."))

/mob/living/exosuit/proc/eject(mob/user, silent)
	if(!user || !(user in src.contents))
		return
	if(hatch_closed)
		if(hatch_locked)
			if(!silent)
				to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
			return
		hud_open.toggled()
		if(!silent)
			to_chat(user, SPAN_NOTICE("You open the hatch and climb out of \the [src]."))
	else
		if(!silent)
			to_chat(user, SPAN_NOTICE("You climb out of \the [src]."))

	remove_pilot(user)
	return 1


/mob/living/exosuit/use_tool(obj/item/tool, mob/user, list/click_params)
	// Cable Coil - Repair burn damage
	if (isCoil(tool))
		if (!getFireLoss())
			USE_FEEDBACK_FAILURE("\The [src] has no electrical damage to repair.")
			return TRUE
		var/list/damaged_parts = list()
		for (var/obj/item/mech_component/component in list(arms, legs, body, head))
			if (component?.burn_damage)
				damaged_parts += component
		var/obj/item/mech_component/input_fix = input(user, "Which component would you like to fix?", "\The [src] - Fix Component") as null|anything in damaged_parts
		if (!input_fix || !user.use_sanity_check(src, tool))
			return TRUE
		if (!input_fix.burn_damage)
			USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] no longer needs repair.")
			return TRUE
		input_fix.repair_burn_generic(tool, user)
		return TRUE

	// Crowbar - Force open closed cockpick (NOT LOCKED)
	else if (isCrowbar(tool))
		if (!body)
			USE_FEEDBACK_FAILURE("\The [src] has no cockpit to force.")
			return FALSE
		if(hatch_locked)
			USE_FEEDBACK_FAILURE("\The [src]'s cockpit locked by cockpit security bolts. You need saw or welder.")
			return FALSE
		var/delay = 4 SECONDS
		visible_message(SPAN_NOTICE("\The [user] starts forcing the \the [src]'s emergency [body.hatch_descriptor] release using \the [tool]."))
		if(!do_after(user, delay, src, DO_DEFAULT | DO_PUBLIC_PROGRESS))
			return
		playsound(src, 'sound/machines/bolts_up.ogg', 25, TRUE)
		hatch_closed = !hatch_closed
		hud_open.update_icon()
		update_icon()
		return TRUE

	//Saw/welder - destroy mech security bolts
	else if( ((istype(tool, /obj/item/circular_saw)) || (isWelder(tool))) && user.a_intent == I_HURT)
		if (!body)
			USE_FEEDBACK_FAILURE("\The [src] has no cockpit to force.")
			return FALSE
		if (!hatch_locked)
			USE_FEEDBACK_FAILURE("\The [src]'s cockpit isn't locked, you can't reach cockpit security bolts.")
			return FALSE
		var/delay = min(100 * user.skill_delay_mult(SKILL_DEVICES), 100 * user.skill_delay_mult(SKILL_EVA))
		visible_message(SPAN_NOTICE("\The [user] starts destroing the \the [src]'s [body.name] security bolts "))
		if(!do_after(user, delay, src, DO_DEFAULT | DO_PUBLIC_PROGRESS))
			return
		playsound(src, 'sound/machines/bolts_up.ogg', 25, TRUE)
		hatch_locked = FALSE
		body.hatch_bolts_status = BOLTS_DESTROYED
		hud_open.update_icon()
		update_icon()
		return TRUE

	// Exosuit Customization Kit - Customize the exosuit
	else if (istype(tool, /obj/item/device/kit/mech))
		var/obj/item/device/kit/mech/paint = tool
		for (var/obj/item/mech_component/component in list(arms, legs, head, body))
			component.decal = paint.current_decal
		if(paint.new_icon_file)
			icon = paint.new_icon_file
		update_icon()
		user.visible_message(
			SPAN_NOTICE("\The [user] opens \the [tool] and spends some quality time customising \the [src]."),
			SPAN_NOTICE("You open \the [tool] and spend some quality time customising \the [src].")
		)
		return TRUE

	// Mech Equipment - Install equipment
	else if (istype(tool, /obj/item/mech_equipment))
		if (hardpoints_locked)
			USE_FEEDBACK_FAILURE("\The [src]'s hardpoint system is locked.")
			return TRUE
		var/obj/item/mech_equipment/mech_equipment = tool
		if (mech_equipment.owner)
			USE_FEEDBACK_FAILURE("\The [tool] is already owned by \the [mech_equipment.owner]. This might be a bug.")
			return TRUE
		var/free_hardpoints = list()
		for (var/hardpoint in hardpoints)
			if (isnull(hardpoints[hardpoint]) && (!length(mech_equipment.restricted_hardpoints) || (hardpoint in mech_equipment.restricted_hardpoints)))
				free_hardpoints += hardpoint
		if (!length(free_hardpoints))
			USE_FEEDBACK_FAILURE("\The [src] has no free hardpoints for \the [tool].")
			return TRUE
		var/input = input(user, "Where would you like to install \the [tool]?", "\The [src] - Hardpoint Installation") as null|anything in free_hardpoints
		if (!input || !user.use_sanity_check(src, tool, SANITY_CHECK_DEFAULT | SANITY_CHECK_TOOL_UNEQUIP))
			return TRUE
		if (hardpoints[input] != null)
			USE_FEEDBACK_FAILURE("\The [input] slot on \the [src] is no longer free. It has \a [hardpoints[input]] attached.")
			return TRUE
		install_system(tool, input, user)
		return TRUE

	// Multitool - Remove component
	else if (isMultitool(tool))
		if (hardpoints_locked)
			USE_FEEDBACK_FAILURE("\The [src]'s hardpoint system is locked.")
			return TRUE
		var/list/parts = list()
		for (var/hardpoint in hardpoints)
			if (hardpoints[hardpoint])
				parts += hardpoint
		var/input = input(user, "Which component would you like to remove?", "\The [src] - Remove Hardpoint") as null|anything in parts
		if (!input || !user.use_sanity_check(src, tool))
			return TRUE
		if (isnull(hardpoints[input]))
			USE_FEEDBACK_FAILURE("\The [src] not longer has a component in the [input] slot.")
			return TRUE
		remove_system(input, user)
		return TRUE

	// Power Cell - Install cell
	else if (istype(tool, /obj/item/cell))
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to install \the [tool].")
			return TRUE
		if (body?.cell)
			USE_FEEDBACK_FAILURE("\The [src] already has \a [body.cell] installed.")
			return TRUE
		if (!user.unEquip(tool, body))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		body.cell = tool
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("\The [user] installs \a [tool] into \the [src]."),
			SPAN_NOTICE("You install \the [tool] into \the [src].")
		)
		return TRUE

	// Screwdriver - Remove cell
	else if (isScrewdriver(tool))
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to access the power cell.")
			return TRUE
		if (!body?.cell)
			USE_FEEDBACK_FAILURE("\The [src] has no power cell to remove.")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts removing \the [src]'s power cell with \a [tool]."),
			SPAN_NOTICE("You start removing \the [src]'s power cell with \the [tool].")
		)
		if (!user.do_skilled((tool.toolspeed * 2) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
			return
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to access the power cell.")
			return TRUE
		if (!body?.cell)
			USE_FEEDBACK_FAILURE("\The [src] has no power cell to remove.")
			return TRUE
		user.put_in_hands(body.cell)
		power = MECH_POWER_OFF
		hud_power_control.update_icon()
		body.cell = null
		user.visible_message(
			SPAN_NOTICE("\The [user] removes \the [src]'s power cell with \a [tool]."),
			SPAN_NOTICE("You remove \the [src]'s power cell with \the [tool].")
		)
		return TRUE

	// Welding Tool - Repair physical damage
	else if (isWelder(tool))
		if (!getBruteLoss())
			USE_FEEDBACK_FAILURE("\The [src] has no physical damage to repair.")
			return TRUE
		var/list/damaged_parts = list()
		for (var/obj/item/mech_component/component in list(arms, legs, body, head))
			if (component?.brute_damage)
				damaged_parts += component
		var/obj/item/mech_component/input_fix = input(user, "Which component would you like to fix?", "\The [src] - Fix Component") as null|anything in damaged_parts
		if (!input_fix || !user.use_sanity_check(src, tool))
			return TRUE
		if (!input_fix.brute_damage)
			USE_FEEDBACK_FAILURE("\The [src]'s [input_fix.name] no longer needs repair.")
			return TRUE
		input_fix.repair_brute_generic(tool, user)
		return TRUE

	// Wrench - Toggle securing bolts
	else if (isWrench(tool))
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to access the securing bolts.")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts removing \the [src]'s securing bolts with \a [tool]."),
			SPAN_NOTICE("You start removing \the [src]'s securing bolts with \the [tool].")
		)
		if (!user.do_skilled((tool.toolspeed * 6) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
			return TRUE
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to access the securing bolts.")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] removes \the [src]'s securing bolts with \a [tool], dismantling it."),
			SPAN_NOTICE("You remove \the [src]'s securing bolts with \the [tool], dismantling it.")
		)
		dismantle()
		return TRUE

	return ..()


/mob/living/exosuit/attack_hand(mob/user)
	// Drag the pilot out if possible.
	if(user.a_intent == I_HURT)
		if(passengers_ammount > 0 && hatch_closed)// Стянуть пассажира с меха рукой!
			forced_leave_passenger(null,2,user)
			return
		if(!LAZYLEN(pilots))
			to_chat(user, SPAN_WARNING("There is nobody inside \the [src]."))
		else if(!hatch_closed)
			var/mob/pilot = pick(pilots)
			user.visible_message(SPAN_DANGER("\The [user] is trying to pull \the [pilot] out of \the [src]!"))
			if(do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE) && user.Adjacent(src) && (pilot in pilots) && !hatch_closed)
				user.visible_message(SPAN_DANGER("\The [user] drags \the [pilot] out of \the [src]!"))
				eject(pilot, silent=1)
		else if(hatch_closed)
			if(MUTATION_FERAL in user.mutations)
				attack_generic(user, 5, "slams")
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*2)
		return
	return

/mob/living/exosuit/attack_generic(mob/user, damage, attack_message = "strikes")
	..()
	if(damage)
		playsound(loc, body.damage_sound, 40, 1)

/mob/living/exosuit/proc/attack_self(mob/user)
	return visible_message("\The [src] pokes itself.")

/mob/living/exosuit/proc/rename(mob/user)
	if(user != src && !(user in pilots))
		return
	var/new_name = sanitize(input("Enter a new exosuit designation.", "Exosuit Name") as text|null, max_length = MAX_NAME_LEN)
	if(!new_name || new_name == name || (user != src && !(user in pilots)))
		return
	SetName(new_name)
	to_chat(user, SPAN_NOTICE("You have redesignated this exosuit as \the [name]."))

/mob/living/exosuit/get_inventory_slot(obj/item/I)
	for(var/h in hardpoints)
		if(hardpoints[h] == I)
			return h
	return 0
