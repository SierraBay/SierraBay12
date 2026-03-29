var/static/list/body_part_coords = list(
	BP_CHEST = list(16, 17),
	BP_GROIN = list(16, 11),
	BP_HEAD  = list(16, 25),
	BP_L_ARM = list(21, 18),
	BP_R_ARM = list(11, 18),
	BP_L_LEG = list(19, 5),
	BP_R_LEG = list(13, 5),
	BP_L_HAND = list(23, 15),
	BP_R_HAND = list(9, 15),
	BP_L_FOOT = list(19, 2),
	BP_R_FOOT = list(13, 2)
)

// Global lists to track persistent hitmarks
var/global/list/clothing_scorch_data = list() // Key: clothing item, Value: list of scorch objects
var/global/list/skin_scorch_data = list()     // Key: human mob, Value: list of skin scorch objects

// Maps body parts to clothing protection flags
/proc/def_zone_to_flag_scorch(def_zone)
	switch(def_zone)
		if(BP_HEAD) return HEAD
		if(BP_CHEST) return (UPPER_TORSO | LOWER_TORSO)
		if(BP_GROIN) return (UPPER_TORSO | LOWER_TORSO)
		if(BP_L_ARM) return ARM_LEFT
		if(BP_R_ARM) return ARM_RIGHT
		if(BP_L_LEG) return LEG_LEFT
		if(BP_R_LEG) return LEG_RIGHT
		if(BP_L_HAND) return HAND_LEFT
		if(BP_R_HAND) return HAND_RIGHT
		if(BP_L_FOOT) return FOOT_LEFT
		if(BP_R_FOOT) return FOOT_RIGHT
	return 0

/proc/get_outermost_clothing_scorch(mob/living/carbon/human/H, def_zone)
	var/flag = def_zone_to_flag_scorch(def_zone)
	if(!flag) return null

	if(H.wear_suit && (H.wear_suit.body_parts_covered & flag)) return H.wear_suit
	if(H.head && (H.head.body_parts_covered & flag)) return H.head
	if(H.shoes && (H.shoes.body_parts_covered & flag)) return H.shoes
	if(H.gloves && (H.gloves.body_parts_covered & flag)) return H.gloves
	if(H.w_uniform && (H.w_uniform.body_parts_covered & flag)) return H.w_uniform
	return null

// Add modular hooks for item
/obj/item/clothing/equipped(mob/user, slot)
	. = ..()
	var/is_worn = FALSE
	if(ishuman(user))
		if(slot == slot_w_uniform || slot == slot_wear_suit || slot == slot_head || slot == slot_shoes || slot == slot_gloves)
			is_worn = TRUE

	if(clothing_scorch_data[src] && is_worn)
		var/mob/living/carbon/human/H = user
		for(var/obj/effect/overlay/laser_scorch/scorch in clothing_scorch_data[src])
			if(scorch.loc != H)
				scorch.loc = H
				GLOB.dir_set_event.register(H, scorch, TYPE_PROC_REF(/obj/effect/overlay/laser_scorch, check_visibility))
				H.vis_contents += scorch
				scorch.check_visibility(H, H.dir, H.dir)

	// Hide skin scorches if we just covered them
	if(is_worn && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(skin_scorch_data[H])
			for(var/obj/effect/overlay/laser_scorch/scorch in skin_scorch_data[H])
				scorch.check_visibility(H, H.dir, H.dir)

/obj/item/clothing/dropped(mob/user)
	. = ..()
	if(clothing_scorch_data[src] && ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/effect/overlay/laser_scorch/scorch in clothing_scorch_data[src])
			if(scorch.loc == H)
				GLOB.dir_set_event.unregister(H, scorch, TYPE_PROC_REF(/obj/effect/overlay/laser_scorch, check_visibility))
				H.vis_contents -= scorch
				scorch.loc = null

	// Show skin scorches if we just uncovered them
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(skin_scorch_data[H])
			spawn(1) // Wait 1 tick for the unequip to finish taking off the item
				for(var/obj/effect/overlay/laser_scorch/scorch in skin_scorch_data[H])
					scorch.check_visibility(H, H.dir, H.dir)

// Prevent memory leaks when clothing is destroyed
/obj/item/clothing/Destroy()
	if(clothing_scorch_data[src])
		for(var/obj/effect/overlay/laser_scorch/scorch in clothing_scorch_data[src])
			if(scorch.loc && ishuman(scorch.loc))
				var/mob/living/carbon/human/H = scorch.loc
				H.vis_contents -= scorch
			qdel(scorch)
		clothing_scorch_data -= src
	return ..()

// Prevent memory leaks when a human is destroyed
/mob/living/carbon/human/Destroy()
	if(skin_scorch_data[src])
		for(var/obj/effect/overlay/laser_scorch/scorch in skin_scorch_data[src])
			qdel(scorch)
		skin_scorch_data -= src
	return ..()

// Modular hook via projectile on_hit.
/obj/item/projectile/beam/on_hit(atom/target, blocked = 0, def_zone = null)
	. = ..()
	if(ishuman(target) && (blocked < 100))
		var/mob/living/carbon/human/H = target
		H.handle_laser_scorch(src, def_zone)
	return .

/obj/effect/overlay/laser_scorch
	name = ""
	desc = ""
	icon = 'mods/utility_items/icons/effects.dmi'
	icon_state = "laser_scorch_static" // The final frame of the burn!
	mouse_opacity = 0
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	var/visible_dir = SOUTH
	var/def_zone = ""       // The hit body part

/obj/effect/overlay/laser_scorch/Destroy()
	// Unregister any leftover events securely
	GLOB.dir_set_event.unregister(loc, src, TYPE_PROC_REF(/obj/effect/overlay/laser_scorch, check_visibility))
	return ..()

// Cleanly hides the hitmark if the mob turns away from the wound angle, OR if covered by clothing
/obj/effect/overlay/laser_scorch/proc/check_visibility(mob/living/carbon/human/H, old_dir, new_dir)
	var/simplified_new_dir = new_dir
	if(new_dir & SOUTH) simplified_new_dir = SOUTH
	else if(new_dir & NORTH) simplified_new_dir = NORTH
	else if(new_dir & EAST) simplified_new_dir = EAST
	else if(new_dir & WEST) simplified_new_dir = WEST

	var/failed = FALSE
	if(simplified_new_dir != visible_dir)
		failed = TRUE

	// Clothing coverage logic (ONLY for skin scorches)
	if(!failed)
		if(H && skin_scorch_data[H] && (src in skin_scorch_data[H]))
			var/obj/item/clothing/outer = get_outermost_clothing_scorch(H, def_zone)
			if(outer)
				failed = TRUE // Covered by clothing!

	if(failed)
		invisibility = 101
	else
		invisibility = 0

/proc/get_wound_visible_dir(initial_mob_dir, impact_source)
	var/sim_impact = impact_source
	if(sim_impact & SOUTH) sim_impact = SOUTH
	else if(sim_impact & NORTH) sim_impact = NORTH
	else if(sim_impact & EAST) sim_impact = EAST
	else if(sim_impact & WEST) sim_impact = WEST

	var/sim_initial = initial_mob_dir
	if(sim_initial & SOUTH) sim_initial = SOUTH
	else if(sim_initial & NORTH) sim_initial = NORTH
	else if(sim_initial & EAST) sim_initial = EAST
	else if(sim_initial & WEST) sim_initial = WEST

	switch(sim_impact)
		if(SOUTH) return sim_initial
		if(NORTH) return turn(sim_initial, 180)
		if(EAST)
			switch(sim_initial)
				if(SOUTH) return WEST
				if(NORTH) return EAST
				if(EAST) return SOUTH
				if(WEST) return NORTH
		if(WEST)
			switch(sim_initial)
				if(SOUTH) return EAST
				if(NORTH) return WEST
				if(EAST) return NORTH
				if(WEST) return SOUTH
	return sim_initial

/mob/living/carbon/human/proc/handle_laser_scorch(obj/item/projectile/P, def_zone)
	def_zone = check_zone(def_zone)
	var/list/coords = body_part_coords[def_zone]
	if(!coords) return

	var/obj/item/organ/external/O = get_organ(def_zone)
	if(!O || O.is_stump()) return

	var/hit_dir_world = turn(P.dir, 180)

	var/obj/effect/overlay/laser_scorch/scorch = new(src)
	scorch.vis_flags &= ~VIS_INHERIT_DIR
	scorch.pixel_x = (coords[1] - 16) + rand(-4, 4)
	scorch.pixel_y = (coords[2] - 16) + rand(-4, 4)
	scorch.pixel_z = src.pixel_z + 0.1
	scorch.dir = hit_dir_world
	scorch.def_zone = def_zone
	scorch.visible_dir = get_wound_visible_dir(src.dir, hit_dir_world)

	// Flick the animation, then stay statically burned
	flick("laser_scorch", scorch)

	var/icon/mask_icon = icon(species.damage_mask, O.icon_name)
	scorch.filters += filter(type="alpha", icon=mask_icon, x = -(scorch.pixel_x), y = -(scorch.pixel_y))

	GLOB.dir_set_event.register(src, scorch, TYPE_PROC_REF(/obj/effect/overlay/laser_scorch, check_visibility))

	vis_contents += scorch
	scorch.check_visibility(src, src.dir, src.dir) // Initial check

	// Determine if we attach to clothing or skin
	var/obj/item/clothing/outer = get_outermost_clothing_scorch(src, def_zone)
	if(outer)
		if(!clothing_scorch_data[outer])
			clothing_scorch_data[outer] = list()
		// Prevent infinite lag if machinegunned
		if(length(clothing_scorch_data[outer]) >= 5)
			var/obj/oldest = clothing_scorch_data[outer][1]
			clothing_scorch_data[outer] -= oldest
			vis_contents -= oldest
			qdel(oldest)

		clothing_scorch_data[outer] += scorch
		// Stays perfectly attached to this EXACT jacket item forever!
	else
		if(!skin_scorch_data[src])
			skin_scorch_data[src] = list()
		if(length(skin_scorch_data[src]) >= 5)
			var/obj/oldest = skin_scorch_data[src][1]
			skin_scorch_data[src] -= oldest
			vis_contents -= oldest
			qdel(oldest)

		skin_scorch_data[src] += scorch
		spawn_skin_healing_loop(scorch)

/mob/living/carbon/human/proc/spawn_skin_healing_loop(obj/effect/overlay/laser_scorch/scorch)
	spawn()
		// Cheap 2-second check loop to see if the wound is fully healed or limb lost
		while(src && scorch && (scorch in skin_scorch_data[src]))
			var/obj/item/organ/external/O = get_organ(scorch.def_zone)
			if(!O || O.is_stump() || O.burn_dam <= 0)
				// Healed completely or limb chopped off!
				vis_contents -= scorch
				skin_scorch_data[src] -= scorch
				qdel(scorch)
				break
			sleep(20)
