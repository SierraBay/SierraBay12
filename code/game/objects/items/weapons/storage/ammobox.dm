/obj/item/ammobox
	name = "ammo box"
	icon = 'icons/obj/weapons/ammo_boxes.dmi'
	icon_state = "ammo"
	desc = "A sturdy metal box with several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."

	/// Path (Subtypes of `/obj/item/ammo_casing`). The ammo type this ammo box holds. Generally, you should not modify directly. See `set_ammo_type()`
	var/obj/item/ammo_casing/ammo_type

	/// Boolean. Whether or not the box is carrying spent or unspent rounds.
	var/ammo_spent = FALSE

	/// Positive Integer. The amount on ammunition currently in this box. Generally, you should not modify directly. See `insert_casing()` and `remove_casing()`.
	var/ammo_count

	/// Positive Integer. The maximum amount of ammunition this box can hold.
	var/ammo_max = 100


/obj/item/ammobox/pistol
	ammo_type = /obj/item/ammo_casing/pistol
	ammo_count = 100


/obj/item/ammobox/Initialize(mapload)
	. = ..()
	if (. == INITIALIZE_HINT_QDEL || QDELETED(src))
		return

	if (!ammo_count)
		ammo_type = null
		ammo_spent = null

	update_name()


/obj/item/ammobox/examine(mob/user, distance, is_adjacent)
	. = ..()

	if (!ammo_count)
		to_chat(user, SPAN_NOTICE("It is empty."))
	else
		var/remaining_space = ammo_max - ammo_count
		to_chat(user, SPAN_NOTICE("It is currently holding [ammo_count] [initial(ammo_type.name)]\s and has room for [remaining_space] more."))


/obj/item/ammobox/attack_hand(mob/user)
	if (user.get_inactive_hand() != src)
		return ..()
	if (!ammo_count)
		USE_FEEDBACK_FAILURE("\The [src] is empty.")
		return TRUE
	if (!do_after(user, 0.25 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src))
		return TRUE
	var/obj/item/ammo_casing/casing = remove_casing(user, get_turf(user))
	user.put_in_hands(casing)
	user.visible_message(
		SPAN_NOTICE("\The [user] removes \a [casing] from \a [src]."),
		SPAN_NOTICE("You remove \a [casing.get_ammo_casing_name()] from \the [src]. [ammo_count ? "It now holds [ammo_count] more." : "It is not empty."]")
	)
	return TRUE



/obj/item/ammobox/attack_self(mob/living/user)
	if (!ammo_count)
		USE_FEEDBACK_FAILURE("\The [src] is empty.")
		return
	var/confirm = alert(user, "Dump \the [src]'s contents on the floor?" , name, "Yes", "No")
	if (confirm != "Yes" || !user.use_sanity_check(src))
		return
	var/turf/target = get_turf(user)
	while (ammo_count)
		var/obj/item/ammo_casing/ammo_casing = remove_casing(user, target)
		ammo_casing.set_dir(pick(GLOB.alldirs))
	user.visible_message(
		SPAN_NOTICE("\The [user] dumps \a [src] all over the floor."),
		SPAN_NOTICE("You dump \the [src] all over the floor.")
	)


/obj/item/ammobox/use_tool(obj/item/tool, mob/living/user, list/click_params)
	// Ammo Box - Transfer contents
	if (istype(tool, /obj/item/ammobox))
		var/obj/item/ammobox/donor_box = tool
		if (!donor_box.ammo_count)
			USE_FEEDBACK_FAILURE("\The [donor_box] is empty.")
			return TRUE

		if (ammo_count >= ammo_max)
			USE_FEEDBACK_FAILURE("\The [src] is full.")
			return TRUE

		if (ammo_count && (donor_box.ammo_type != ammo_type || donor_box.ammo_spent != ammo_spent))
			USE_FEEDBACK_FAILURE("\The [donor_box]'s contents can't be mixed with the rounds already in \the [src].")
			return TRUE

		user.visible_message(
			SPAN_NOTICE("\The [user] starts dumping \a [tool] into \a [src]."),
			SPAN_NOTICE("You start dumping \the [tool] into \the [src].")
		)

		var/partial = FALSE // Alters the visible message to say "partially" if there was a casing that halted the loop
		while (donor_box.ammo_count > 0 && ammo_count < ammo_max)
			if (!do_after(user, 0.5 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool))
				partial = TRUE
				break
			if (!insert_casing(new donor_box.ammo_type(src, donor_box.ammo_spent)))
				partial = TRUE
				break
			donor_box.remove_casing()

		user.visible_message(
			SPAN_NOTICE("\The [user] [partial ? "partially " : null]dumps \a [tool] into \a [src]."),
			SPAN_NOTICE("You [partial ? "partially " : null]dump \the [tool] into \the [src]. The target box now holds [ammo_count] round\s. [partial ? "The donor box has [donor_box.ammo_count] round\s remaining." : null]")
		)
		return TRUE


	// Ammo Casing - Attempt to add to the box.
	if (istype(tool, /obj/item/ammo_casing))
		if (!can_insert_casing(tool, user))
			return TRUE
		if (!do_after(user, 0.5 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool))
			return TRUE
		if (!insert_casing(tool, user))
			return TRUE
		var/obj/item/ammo_casing/ammo_casing = tool
		user.visible_message(
			SPAN_NOTICE("\The [user] adds \a [tool] to \a [src]."),
			SPAN_NOTICE("You add \a [ammo_casing.get_ammo_casing_name()] to \the [src]. It now holds [ammo_count] round\s.")
		)
		return TRUE


	// Ammo Magazine - Attempt to feed the rounds to the box.
	if (istype(tool, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/magazine = tool
		if (!length(magazine.stored_ammo))
			USE_FEEDBACK_FAILURE("\The [tool] is empty.")
			return TRUE

		if (ammo_count >= ammo_max)
			USE_FEEDBACK_FAILURE("\The [src] is full.")
			return TRUE

		var/obj/item/ammo_casing/casing = magazine.stored_ammo[length(magazine.stored_ammo)]
		if (!can_insert_casing(casing, user))
			return TRUE

		user.visible_message(
			SPAN_NOTICE("\The [user] starts emptying \a [tool] into \a [src]."),
			SPAN_NOTICE("You start emptying \the [tool] into \the [src].")
		)

		var/partial = FALSE // Alters the visible message to say "partially" if there was a casing that halted the loop
		while (length(magazine.stored_ammo))
			casing = magazine.stored_ammo[length(magazine.stored_ammo)]
			if (!can_insert_casing(casing, user))
				partial = TRUE
				break
			if (!do_after(user, 0.25 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool))
				partial = TRUE
				break
			casing = magazine.remove_casing(user, src)
			if (!casing)
				partial = TRUE
				break
			insert_casing(casing)

		user.visible_message(
			SPAN_NOTICE("\The [user] [partial ? "partially " : null]empties \a [tool] into \a [src]."),
			SPAN_NOTICE("You [partial ? "partially " : null]empty \the [tool] into \the [src].")
		)
		return TRUE


	return ..()


/obj/item/ammobox/use_after(atom/target, mob/living/user, click_parameters)
	// Magazine - Load magazine
	if (istype(target, /obj/item/ammo_magazine))
		if (!ammo_count)
			USE_FEEDBACK_FAILURE("\The [src] is empty.")
			return TRUE
		var/obj/item/ammo_magazine/magazine = target
		if (magazine.caliber != initial(ammo_type.caliber))
			USE_FEEDBACK_FAILURE("\The [src]'s ammunition does not fit into \the [target].")
			return TRUE
		if (length(magazine.stored_ammo) >= magazine.max_ammo)
			USE_FEEDBACK_FAILURE("\The [target] is full.")
			return TRUE

		user.visible_message(
			SPAN_NOTICE("\The [user] starts loading \a [target] from \a [src]."),
			SPAN_NOTICE("You start loading \the [target] from \the [src].")
		)
		var/partial = FALSE
		var/count = 0
		while (ammo_count > 0 && length(magazine.stored_ammo) < magazine.max_ammo)
			if (!do_after(user, 0.5 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(target, src))
				partial = TRUE
				break
			if (length(magazine.stored_ammo) >= magazine.max_ammo)
				partial = TRUE
				break
			var/casing = remove_casing(user, magazine)
			if (!casing)
				partial = TRUE
				break
			count++
			magazine.load_casing(casing, user)

		if (!count)
			user.visible_message(
				SPAN_NOTICE("\The [user] fails to load any rounds from \a [src] to \a [target]."),
				SPAN_WARNING("You fail to load any rounds from \the [src] to \the [target].")
			)
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] [partial ? "partially " : null]loads \a [target] with \a [src]."),
			SPAN_NOTICE("You [partial ? "partially " : null]load \the [target] with [count] round\s from \the [src].<br />\The [src] now has [ammo_count] round\s remaining.<br />\The [target] now has [length(magazine.stored_ammo)] round\s loaded.")
		)
		return TRUE


	// Try to scoop bullets up
	var/obj/item/ammo_casing/clicked
	var/turf/target_turf
	var/obj/item/ammo_casing/target_type
	var/target_spent = FALSE
	if (isturf(target))
		target_turf = target
	else if (istype(target, /obj/item/ammo_casing) && isturf(target.loc))
		clicked = target
		target_turf = target.loc
		target_type = target.type
		target_spent = !clicked.BB
	else
		return ..()

	if (ammo_count >= ammo_max)
		USE_FEEDBACK_FAILURE("\The [src] is full.")
		return TRUE

	if (ammo_count && target_type)
		if (target_type != ammo_type || ammo_spent != !clicked.BB)
			USE_FEEDBACK_FAILURE("The [clicked.get_ammo_casing_name()] can't be mixed with the rounds already in \the [src].")
			return TRUE

	var/list/candidates = list()
	for (var/obj/item/ammo_casing/ammo_casing in target_turf)
		if (!ammo_count)
			target_type = ammo_casing.type
			target_spent = !ammo_casing.BB
		else if (ammo_count && (ammo_casing.type != target_type || target_spent != !ammo_casing.BB))
			continue
		candidates += ammo_casing

	if (!length(candidates))
		USE_FEEDBACK_FAILURE("There are no bullets \the [src] can hold here.")
		return TRUE

	user.visible_message(
		SPAN_NOTICE("\The [user] starts loading \a [src] with loose rounds."),
		SPAN_NOTICE("You start loading \the [src] with loose rounds.")
	)
	var/count = 0
	for (var/obj/item/ammo_casing/ammo_casing as anything in candidates)
		if (ammo_casing.loc != target_turf)
			continue
		if (ammo_count && (ammo_casing.type != ammo_type || ammo_spent != ammo_casing.BB))
			continue
		if (!do_after(user, 0.25 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, ammo_casing, SANITY_CHECK_DEFAULT & ~SANITY_CHECK_TOOL_IN_HAND))
			break
		if (!insert_casing(ammo_casing, user))
			break
		count++

	if (!count)
		user.visible_message(
			SPAN_NOTICE("\The [user] fails to load \a [src] with loose rounds."),
			SPAN_WARNING("You fail to load \the [src] with loose rounds.")
		)
		return TRUE
	user.visible_message(
		SPAN_NOTICE("\The [user] loads \a [src] with loose rounds."),
		SPAN_NOTICE("You load \the [src] with loose rounds.")
	)
	return TRUE


/obj/item/ammobox/get_mechanics_info()
	return "<p>A specialized box dedicated to holding loose ammunition. These boxes can only hold a single type of ammunition at a time.</p>"


/obj/item/ammobox/get_interactions_info()
	. = ..()
	.["Ammo Box"] = "Transfers the contents of the held box to the clicked box, if the ammo types match."
	.["Bullet Casing"] = "Adds the bullet casing to the box, if the ammo types match."
	.["Magazine"] = "Transfers the contents of the magazine to the box, if the ammo types match."


/**
 * Sets the box's `ammo_type` to the given type, updating its name in the process.
 *
 * **Parameters**:
 * - `new_ammo_type` (Path - Subtype of `obj/item/ammo_casing`).
 * - `casing_spent` (Boolean). Only used if `new_ammo_type` is a path. Whether or not the casing is considered spent.
 *
 * Has no return value.
 */
/obj/item/ammobox/proc/set_ammo_type(obj/item/ammo_casing/new_ammo_type, casing_spent = FALSE)
	if (istom(new_ammo_type))
		if (!istype(new_ammo_type))
			return
		casing_spent = !new_ammo_type.BB
		new_ammo_type = new_ammo_type.type

	if (!ispath(new_ammo_type, /obj/item/ammo_casing))
		return

	if (ammo_type == new_ammo_type)
		return

	ammo_type = new_ammo_type
	ammo_spent = casing_spent
	update_name()


/**
 * Checks if the casing can be added to the box.
 *
 * Provides user feedback messages on failure.
 *
 * **Parameters**:
 * - `ammo_casing` (Object or path. Subtypes of `/obj/item/ammo_casing`) - The casing to insert. Has to be the same type as `ammo_type`, unless `ammo_count` is `0`.
 * - `user` - The mob attempting to insert the casing. Used for feedback messages. If not set, no feedback messages are sent.
 * - `casing_spent` (Boolean). Only used if `ammo_casing` is a path. Whether or not the casing is considered spent.
 *
 * Returns boolean. `TRUE` if the casing was successfully inserted, `FALSE` otherwise.
 */
/obj/item/ammobox/proc/can_insert_casing(obj/item/ammo_casing/ammo_casing, mob/user, casing_spent = FALSE)
	var/obj/item/ammo_casing/casing_type
	var/casing_name = _get_ammo_casing_name(ammo_casing, casing_spent)
	if (ispath(ammo_casing))
		casing_type = ammo_casing
	else
		casing_type = ammo_casing.type
		casing_spent = !ammo_casing.BB

	if (!ispath(casing_type, /obj/item/ammo_casing))
		if (user)
			USE_FEEDBACK_FAILURE("\The [src] isn't designed to hold \the [casing_name].")
		return FALSE

	if (ammo_count && (ammo_type != casing_type || ammo_spent != casing_spent))
		if (user)
			USE_FEEDBACK_FAILURE("\The [casing_name] can't be mixed with the rounds already in \the [src].")
		return FALSE

	if (ammo_count >= ammo_max)
		if (user)
			USE_FEEDBACK_FAILURE("\The [src] is full.")
		return FALSE

	return TRUE



/**
 * Adds `ammo_casing` to the ammo box's inventory. Checks `can_insert_casing()`.
 *
 * **Parameters**:
 * - `ammo_casing` - The casing to insert. Has to be the same type as `ammo_type`, unless `ammo_count` is `0`.
 * - `user` - The mob attempting to insert the casing. Used for feedback messages. If not set, no feedback messages are sent.
 * - `skip_check` (Boolean, default `FALSE`) - If set, skips `can_insert_casing()` checks. Useful if you're already checking outside this proc, or simply want to force a casing.
 * 		**Be warned this will also force update the ammoboxe's ammo type to the new casing.**
 *
 * Returns boolean. `TRUE` if the casing was successfully inserted, `FALSE` otherwise.
 */
/obj/item/ammobox/proc/insert_casing(obj/item/ammo_casing/ammo_casing, mob/user, skip_check = FALSE)
	if (!skip_check && !can_insert_casing(ammo_casing, user))
		return FALSE
	ammo_count++
	if (ammo_type != ammo_casing.type)
		set_ammo_type(ammo_casing.type)
	playsound(src, 'sound/weapons/guns/interaction/bullet_insert.ogg', 10, TRUE)
	qdel(ammo_casing)
	return TRUE


/**
 * Removes a casing and places it in `target`.
 *
 * Provides user feedback messages on failure.
 *
 * **Parameters**:
 * - `user` - The mob removing the casing. If not set, there will be no feedback messages.
 * - `target` - The atom to place the casing in. If not set, the casing is not spawned and the round is simply removed.
 *
 * Returns the removed casing if one was created or `null`.
 */
/obj/item/ammobox/proc/remove_casing(mob/user, atom/target)
	RETURN_TYPE(/obj/item/ammo_casing)
	if (!ammo_count)
		if (user)
			USE_FEEDBACK_FAILURE("\The [src] is empty.")
		return

	var/obj/item/ammo_casing/casing
	ammo_count--
	if (target)
		casing = new ammo_type(target, ammo_spent)
		. = casing

	if (casing && isturf(target))
		playsound(src, pick(casing.fall_sounds), 10, TRUE)
	else if (ismob(target))
		playsound(src, 'sound/weapons/guns/interaction/bullet_insert.ogg', 10, TRUE)
	// Any other target type, i.e. magazine, already has its own sound effect

	if (!ammo_count)
		ammo_type = null
		ammo_spent = null
		update_name()


/obj/item/ammobox/proc/update_name()
	if (!ammo_count)
		SetName("empty [initial(name)]")
		return
	SetName("[initial(name)] - [get_ammo_casing_name()]")


/obj/item/ammobox/proc/get_ammo_casing_name()
	return _get_ammo_casing_name(ammo_type, ammo_spent)
