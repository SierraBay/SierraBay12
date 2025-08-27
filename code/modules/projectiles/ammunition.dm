/**
 * Determines the full descriptive name for an ammo casing.
 *
 * Global proc so it also functions with uninitialized type paths.
 *
 * **Parameters**:
 * - `ammo_casing` (Object or path).
 * - `spent` (Boolean, default `FALSE`). Only used if `ammo_casing` is a path. Whether the casing is considered spent or not. Otherwise, this is defined based on the presence of `ammo_casing.BB`.
 *
 * Returns string.
 */
/proc/_get_ammo_casing_name(obj/item/ammo_casing/ammo_casing, spent = FALSE)
	if (!ammo_casing)
		return
	var/name
	var/caliber
	var/label
	if (ispath(ammo_casing))
		name = initial(ammo_casing.name)
		caliber = initial(ammo_casing.caliber)
		label = initial(ammo_casing.label)
	else
		name = ammo_casing.name
		caliber = ammo_casing.caliber
		spent = !ammo_casing.BB
		label = ammo_casing.label

	. = "[caliber] [name]"
	if (spent)
		. = "spent [.]"
	if (label)
		. = "[.] ([label])"



/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "pistolcasing"
	randpixel = 10
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 1
	w_class = ITEM_SIZE_TINY

	var/leaves_residue = TRUE
	var/caliber = ""					//Which kind of guns it can be loaded into
	/// String. Additional label used for `_get_ammo_casing_name()`. Should be things like 'practice', 'blank', 'AP', 'FMJ', etc.
	var/label
	var/projectile_type					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null	//The loaded bullet - make it so that the projectiles are created only when needed?
	var/spent_icon = "pistolcasing-spent"
	var/fall_sounds = list('sound/weapons/guns/casingfall1.ogg','sound/weapons/guns/casingfall2.ogg','sound/weapons/guns/casingfall3.ogg')


/obj/item/ammo_casing/Initialize(mapload, spawn_empty = FALSE)
	if (ispath(projectile_type) && !spawn_empty)
		BB = new projectile_type(src)
	if (spawn_empty)
		update_icon()
	if(randpixel)
		pixel_x = rand(-randpixel, randpixel)
		pixel_y = rand(-randpixel, randpixel)
	. = ..()


//removes the projectile from the ammo casing
/obj/item/ammo_casing/proc/expend()
	. = BB
	BB = null
	set_dir(pick(GLOB.alldirs)) //spin spent casings

	// Aurora forensics port, gunpowder residue.
	if(leaves_residue)
		leave_residue()

	update_icon()


/obj/item/ammo_casing/proc/leave_residue()
	var/mob/living/carbon/human/H = get_holder_of_type(src, /mob/living/carbon/human)
	var/obj/item/gun/G = get_holder_of_type(src, /obj/item/gun)
	put_residue_on(G)
	if(H)
		var/zone
		if(H.l_hand == G)
			zone = BP_L_HAND
		else if(H.r_hand == G)
			zone = BP_R_HAND
		if(zone)
			var/target = H.get_covering_equipped_item_by_zone(zone)
			if(!target)
				target = H.get_organ(zone)
			put_residue_on(target)
	if(prob(30))
		put_residue_on(get_turf(src))


/obj/item/ammo_casing/proc/put_residue_on(atom/A)
	if(A)
		LAZYDISTINCTADD(A.gunshot_residue, caliber)


/obj/item/ammo_casing/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isScrewdriver(W))
		if(!BB)
			to_chat(user, SPAN_WARNING("There is no bullet in the casing to inscribe anything into."))
			return TRUE

		var/tmp_label = ""
		var/label_text = sanitizeSafe(input(user, "Inscribe some text into \the [initial(BB.name)]","Inscription",tmp_label), MAX_NAME_LEN)
		if(length(label_text) > 20)
			to_chat(user, SPAN_WARNING("The inscription can be at most 20 characters long."))
		else if(!label_text)
			to_chat(user, SPAN_NOTICE("You scratch the inscription off of [initial(BB)]."))
			BB.SetName(initial(BB.name))
		else
			to_chat(user, SPAN_NOTICE("You inscribe \"[label_text]\" into \the [initial(BB.name)]."))
			BB.SetName("[initial(BB.name)] (\"[label_text]\")")
		return TRUE

	return ..()


/obj/item/ammo_casing/on_update_icon()
	if(spent_icon && !BB)
		icon_state = spent_icon


/obj/item/ammo_casing/examine(mob/user)
	. = ..()
	if(caliber)
		to_chat(user, "Its caliber is [caliber].")
	if (!BB)
		to_chat(user, "This one is spent.")


/obj/item/ammo_casing/proc/get_ammo_casing_name()
	return _get_ammo_casing_name(src)


//An item that holds casings and can be used to put them inside guns
/obj/item/ammo_magazine
	name = "magazine"
	desc = "A magazine for some kind of gun."
	icon_state = "357"
	icon = 'icons/obj/weapons/ammo.dmi'
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	matter = list(MATERIAL_STEEL = 500)
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 10

	var/list/stored_ammo = list()
	var/mag_type = SPEEDLOADER //ammo_magazines can only be used with compatible guns. This is not a bitflag, the load_method var on guns is.
	var/caliber = "357"
	var/max_ammo = 7

	var/ammo_type = /obj/item/ammo_casing //ammo type that is initially loaded
	var/initial_ammo = null

	var/multiple_sprites = 0
	var/list/labels						//If something should be added to name on spawn aside from caliber
	//because BYOND doesn't support numbers as keys in associative lists
	var/list/icon_keys = list()		//keys
	var/list/ammo_states = list()	//values


/obj/item/ammo_magazine/box
	w_class = ITEM_SIZE_NORMAL


/obj/item/ammo_magazine/Initialize()
	. = ..()
	if(multiple_sprites)
		initialize_magazine_icondata(src)

	if(isnull(initial_ammo))
		initial_ammo = max_ammo

	if(initial_ammo)
		for(var/i in 1 to initial_ammo)
			stored_ammo += new ammo_type(src)
	if(caliber)
		LAZYINSERT(labels, caliber, 1)
	if(LAZYLEN(labels))
		SetName("[name] ([english_list(labels, and_text = ", ")])")
	update_icon()


/obj/item/ammo_magazine/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if (istype(tool, /obj/item/ammo_casing))
		if (!do_after(user, 0.25 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool) || !load_casing(tool, user, TRUE))
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] loads \a [tool] into \a [src]."),
			SPAN_NOTICE("You load \the [tool] into \the [src].")
		)
		return TRUE


	if (istype(tool, /obj/item/ammo_magazine))
		if (length(stored_ammo) >= max_ammo)
			USE_FEEDBACK_FAILURE("\The [src] is full.")
			return TRUE
		var/obj/item/ammo_magazine/donor_magazine = tool
		if (length(donor_magazine.stored_ammo) <= 0)
			USE_FEEDBACK_FAILURE("\The [donor_magazine] is empty.")
			return TRUE
		if (donor_magazine.caliber != caliber)
			USE_FEEDBACK_FAILURE("\The [donor_magazine]'s ammunition does not fit \the [src].")
			return TRUE

		user.visible_message(
			SPAN_NOTICE("\The [user] starts transferring bullets from \a [tool] to \a [src]."),
			SPAN_NOTICE("You start transferring bullets from \the [tool] to \the [src].")
		)
		var/partial = FALSE
		var/count = 0
		while (length(donor_magazine.stored_ammo))
			if (!do_after(user, 0.5 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool))
				partial = TRUE
				break
			if (length(donor_magazine.stored_ammo) <= 0)
				USE_FEEDBACK_FAILURE("\The [donor_magazine] is empty.")
				partial = TRUE
				break
			var/obj/item/ammo_casing/ammo_casing = donor_magazine.stored_ammo[length(donor_magazine.stored_ammo)]
			if (!load_casing(ammo_casing))
				partial = TRUE
				break
			donor_magazine.stored_ammo -= ammo_casing
			donor_magazine.update_icon()
			count++

		if (!count)
			user.visible_message(
				SPAN_NOTICE("\The [user] fails to transfer any bullets from \a [tool] to \a [src]."),
				SPAN_NOTICE("Your fail to transfer any bullets from \the [tool] to \the [src].")
			)
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] [partial ? "partially " : null]transfers bullets from \a [tool] to \a [src]."),
			SPAN_NOTICE("You [partial ? "partially " : null]transfer bullets from \the [tool] to \the [src].")
		)
		update_icon()
		donor_magazine.update_icon()
		return TRUE


	return ..()


/obj/item/ammo_magazine/use_after(atom/target, mob/living/user, click_parameters)
	// Try to scoop bullets up
	var/turf/target_turf
	if (isturf(target))
		target_turf = target
	else if (istype(target, /obj/item/ammo_casing) && isturf(target.loc))
		target_turf = target.loc
	if (!target_turf)
		return ..()

	var/list/candidates = list()
	for (var/obj/item/ammo_casing/ammo_casing in target_turf)
		if (ammo_casing.caliber != caliber)
			continue
		candidates += ammo_casing

	if (!length(candidates))
		USE_FEEDBACK_FAILURE("There are no bullets \the [src] can hold here.")
		return TRUE
	if (length(stored_ammo) >= max_ammo)
		USE_FEEDBACK_FAILURE("\The [src] is full.")
		return TRUE

	user.visible_message(
		SPAN_NOTICE("\The [user] starts loading \a [src] with loose bullets."),
		SPAN_NOTICE("You start loading \the [src] with loose bullets.")
	)
	var/count = 0
	for (var/obj/item/ammo_casing/ammo_casing as anything in candidates)
		if (!do_after(user, 0.25 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, ammo_casing, SANITY_CHECK_DEFAULT & ~SANITY_CHECK_TOOL_IN_HAND))
			break
		if (!load_casing(ammo_casing, user))
			break
		count++

	if (!count)
		user.visible_message(
			SPAN_NOTICE("\The [user] fails to load \a [src] with loose bullets."),
			SPAN_WARNING("You fail to load \the [src] with loose bullets.")
		)
		return TRUE
	user.visible_message(
		SPAN_NOTICE("\The [user] loads \a [src] with loose bullets."),
		SPAN_NOTICE("You load \the [src] with loose bullets.")
	)
	return TRUE



/**
 * Checks if the casing can be loaded into this magazine. Provides user feedback messages on failure.
 *
 * Does not include unequip checks by default, as this is intended to be usable in cases those checks would be invalid.
 *
 * **Parameters**:
 * - `ammo_casing` - The ammo casing to check.
 * - `user` - The mob performing the action. If not set, feedback messages are skipped.
 *
 * Returns boolean.
 */
/obj/item/ammo_magazine/proc/can_load_casing(obj/item/ammo_casing/ammo_casing, mob/living/user)
	if (!istype(ammo_casing) || ammo_casing.caliber != caliber)
		if (user)
			USE_FEEDBACK_FAILURE("\The [ammo_casing] does not fit in \the [src].")
		return FALSE

	if (length(stored_ammo) >= max_ammo)
		if (user)
			USE_FEEDBACK_FAILURE("\The [src] is full.")
		return FALSE

	return TRUE


/**
 * Attempts to load the ammo casing into this magazine. Provides user feedback on failure.
 *
 * Checks `can_load_casing()`.
 *
* **Parameters**:
 * - `ammo_casing` - The ammo casing to load.
 * - `user` - The mob performing the action. If not set, feedback messages are skipped.
 * - `unequip_check` (Boolean, default `FALSE`) - If set, includes a `user.unEquip(ammo_casing, src)` check.
 *
 * Returns boolean. Indicates whether the casing was loaded or not.
 */
/obj/item/ammo_magazine/proc/load_casing(obj/item/ammo_casing/ammo_casing, mob/living/user, unequip_check = FALSE)
	if (!can_load_casing(ammo_casing, user, unequip_check))
		return FALSE

	if (unequip_check && !user?.unEquip(ammo_casing, src))
		FEEDBACK_UNEQUIP_FAILURE(user, ammo_casing)
		return FALSE

	playsound(src, 'sound/weapons/guns/interaction/shotgun_instert.ogg', 10, TRUE)
	ammo_casing.forceMove(src)
	stored_ammo += ammo_casing
	update_icon()
	return TRUE


/**
 * Removes the last casing from the magazine. Provides user feedback on failure.
 *
 * Either `user` or `target` can be provided, the proc will function either way.
 *
 * **Parameters**:
 * - `user` - The mob performing the action.
 * - `target` (Default `user`, if set) - The target atom to move the casing to. If a mob, attempts to place it in hands.
 *
 * Returns the removed casing.
 */
/obj/item/ammo_magazine/proc/remove_casing(mob/living/user, atom/target = user)
	if (!user && !target)
		crash_with("`remove_casing()` requires either user or target, or both, to be provided. Neither were provided.")
		return FALSE

	if (!length(stored_ammo))
		if (user)
			USE_FEEDBACK_FAILURE("\The [src] is empty.")
		return FALSE

	var/obj/item/ammo_casing/ammo_casing = stored_ammo[length(stored_ammo)]
	stored_ammo -= ammo_casing
	update_icon()

	if (ismob(target))
		var/mob/target_mob = target
		target_mob.put_in_hands(ammo_casing)
	else
		ammo_casing.forceMove(target)
	playsound(src, 'sound/weapons/guns/interaction/bullet_insert.ogg', 10, TRUE)

	return ammo_casing


/**
 * Attempts to dump all casings into `target`. Provides user feedback on failure.
 *
 * **Parameters**:
 * - `user` - The mob performing the action.
 * - `target` (Default `get_turf(src)`) - The target atom to move the casings to.
 *
 * Returns a list of the removed casings, or `FALSE`.
 */
/obj/item/ammo_magazine/proc/dump_all_casings(mob/living/user, atom/target = get_turf(src))
	RETURN_TYPE(/list)
	if (!length(stored_ammo))
		if (user)
			USE_FEEDBACK_FAILURE("\The [src] is empty.")
		return FALSE

	var/list/removed = list()
	for (var/obj/item/ammo_casing/ammo_casing in stored_ammo)
		playsound(src, pick(ammo_casing.fall_sounds), 10, TRUE)
		ammo_casing.forceMove(target)
		ammo_casing.set_dir(pick(GLOB.alldirs))
		removed += ammo_casing

	stored_ammo.Cut()
	update_icon()

	return removed


/obj/item/ammo_magazine/attack_self(mob/user)
	if (!dump_all_casings(user, user.loc))
		return
	user.visible_message(
		SPAN_WARNING("\The [user] ejects \a [src]'s contents on the ground."),
		SPAN_WARNING("You eject \the [src]'s contents on the ground.")
	)


/obj/item/ammo_magazine/attack_hand(mob/user)
	if (user.get_inactive_hand() == src)
		if (!length(stored_ammo))
			USE_FEEDBACK_FAILURE("\The [src] is empty.")
			return TRUE
		if (!do_after(user, 0.25 SECONDS, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src))
			return TRUE
		var/atom/removed_casing = remove_casing(user)
		if (!removed_casing)
			return
		user.visible_message(
			SPAN_NOTICE("\The [user] removes \a [removed_casing] from \a [src]."),
			SPAN_NOTICE("You remove \a [removed_casing] from \the [src].")
		)
		return

	..()


/obj/item/ammo_magazine/on_update_icon()
	ClearOverlays()

	if (ammo_type == /obj/item/ammo_casing/pistol/rubber)
		AddOverlays(image(icon, "[initial(icon_state)]_r"))
	else if (ammo_type == /obj/item/ammo_casing/pistol/practice)
		AddOverlays(image(icon, "[initial(icon_state)]_p"))

	else if (ammo_type == /obj/item/ammo_casing/pistol/small/rubber)
		AddOverlays(image(icon, "[initial(icon_state)]_r"))
	else if (ammo_type == /obj/item/ammo_casing/pistol/small/practice)
		AddOverlays(image(icon, "[initial(icon_state)]_p"))

	else if (ammo_type == /obj/item/ammo_casing/rifle/military/practice)
		AddOverlays(image(icon, "[initial(icon_state)]_p"))

	else
		icon_state = initial(icon_state)

	if(multiple_sprites)
		//find the lowest key greater than or equal to length(stored_ammo)
		var/new_state = null
		for(var/idx in 1 to length(icon_keys))
			var/ammo_count = icon_keys[idx]
			if (ammo_count >= length(stored_ammo))
				new_state = ammo_states[idx]
				break
		icon_state = (new_state)? new_state : initial(icon_state)


/obj/item/ammo_magazine/examine(mob/user)
	. = ..()
	to_chat(user, "There [(length(stored_ammo) == 1)? "is" : "are"] [length(stored_ammo)] round\s left!")


//magazine icon state caching
var/global/list/magazine_icondata_keys = list()
var/global/list/magazine_icondata_states = list()


/proc/initialize_magazine_icondata(obj/item/ammo_magazine/M)
	var/typestr = "[M.type]"
	if(!(typestr in magazine_icondata_keys) || !(typestr in magazine_icondata_states))
		magazine_icondata_cache_add(M)

	M.icon_keys = magazine_icondata_keys[typestr]
	M.ammo_states = magazine_icondata_states[typestr]


/proc/magazine_icondata_cache_add(obj/item/ammo_magazine/M)
	var/list/icon_keys = list()
	var/list/ammo_states = list()
	var/list/states = icon_states(M.icon)
	for(var/i = 0, i <= M.max_ammo, i++)
		var/ammo_state = "[M.icon_state]-[i]"
		if(ammo_state in states)
			icon_keys += i
			ammo_states += ammo_state


	magazine_icondata_keys["[M.type]"] = icon_keys
	magazine_icondata_states["[M.type]"] = ammo_states
