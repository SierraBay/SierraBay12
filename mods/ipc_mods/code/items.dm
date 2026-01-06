/datum/uplink_item/item/tools/shackles
	name = "Shackle module"
	desc = "A module that can be used on IPC brain to take it under control. \
	All you need to do is write a law and install shackle on directly on IPC brain."
	item_cost = 15
	path = /obj/item/organ/internal/shackles



/datum/design/item/tool/integrity_repair_tool
	name = "Integrity repair tool"
	build_path = /obj/item/integrity_repair_tool
	materials = list(MATERIAL_SILVER = 5000, MATERIAL_URANIUM = 750, MATERIAL_DIAMOND = 2000)
	id = "integrity_repair_tool"

/obj/item/integrity_repair_tool
	name = "integrity repair tool"
	desc = "A piece of high-tech equipment used to repair the integrity of high-end prosthetics."
	icon = 'mods/ipc_mods/icons/ppt.dmi'
	icon_state = "integrity_repair_tool_idle"
	origin_tech = list(TECH_MATERIAL = 6, TECH_ENGINEERING = 6)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	center_of_mass = "x=14;y=15"
	waterproof = FALSE
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 2000, MATERIAL_SILVER = 4000, MATERIAL_URANIUM = 4000)
	item_icons = list(
		slot_l_hand_str = 'mods/ipc_mods/icons/ppt.dmi',
		slot_r_hand_str = 'mods/ipc_mods/icons/ppt.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "r_dmg",
		slot_l_hand_str = "l_dmg"
	)

	var/status = TRUE
	var/active = FALSE
	var/resource = "high-end nanomaterials"
	var/obj/item/integrity_repair_tool_tank/tank = /obj/item/integrity_repair_tool_tank

/obj/item/integrity_repair_tool/Initialize()
	if(ispath(tank))
		tank = new tank
		w_class = tank.size_in_use
		force = tank.unlit_force

	set_extension(src, /datum/extension/base_icon_state, icon_state)
	update_icon()

	. = ..()

/obj/item/integrity_repair_tool/Destroy()

	QDEL_NULL(tank)

	return ..()

/obj/item/integrity_repair_tool/examine(mob/user, distance)
	. = ..()
	if (!tank)
		to_chat(user, "There is no [resource] source attached.")
	else
		to_chat(user, (distance <= 1 ? "It has [get_reourse()] [resource] remaining. Looks like it would be useful for [floor(get_reourse())] uses. " : "") + "[tank] is attached.")

/obj/item/integrity_repair_tool/use_tool(obj/item/W, mob/living/user, list/click_params)

	if (istype(W, /obj/item/integrity_repair_tool_tank))
		if (tank)
			to_chat(user, SPAN_WARNING("\The [src] already has a tank attached - remove it first."))
			return TRUE
		if (user.get_active_hand() != src && user.get_inactive_hand() != src)
			to_chat(user, SPAN_WARNING("You must hold the [src.name] in your hands to attach a tank."))
			return TRUE
		if (!user.unEquip(W, src))
			FEEDBACK_UNEQUIP_FAILURE(user, W)
			return TRUE
		tank = W
		user.visible_message("\The [user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		w_class = tank.size_in_use
		force = tank.unlit_force
		playsound(src, 'sound/items/cap_close.ogg', 10, 1)
		update_icon()
		return TRUE

	return ..()


/obj/item/integrity_repair_tool/attack_hand(mob/user as mob)
	if(tank && user.get_inactive_hand() == src)
		user.visible_message("[user] removes \the [tank] from \the [src].", "You remove \the [tank] from \the [src].")
		user.put_in_hands(tank)
		tank = null
		w_class = initial(w_class)
		force = initial(force)
		playsound(src, 'sound/items/cap_open.ogg', 10, 1)
		update_icon()

	else
		..()

/obj/item/integrity_repair_tool/proc/get_reourse()
	return tank ? tank.resourse_left : 0

/obj/item/integrity_repair_tool/proc/can_use(amount = 1, mob/user = null, interaction_message = "to complete this task.")
	if (get_reourse() < amount)
		if (user)
			to_chat(user, SPAN_WARNING("You need at least [amount] unit\s of [resource] [interaction_message]"))
		return FALSE
	return TRUE

/obj/item/integrity_repair_tool/on_update_icon()
	..()
	if(tank)
		icon_state = "integrity_repair_tool_idle"
		if(active)
			icon_state = "integrity_repair_tool_active"
	else
		icon_state = "integrity_repair_tool_empty"

	var/mob/M = loc
	if(istype(M))
		M.update_inv_l_hand()
		M.update_inv_r_hand()


/obj/item/integrity_repair_tool/attack_self(mob/user as mob)
	active = !active
	if(active)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return

/obj/item/integrity_repair_tool/proc/remove_nanomaterial(amount, mob/M = null)
	if(tank.resourse_left > 0)
		tank.resourse_left = tank.resourse_left - amount
	else
		tank.resourse_left = 0
		return attack_self()
	burn_nanomaterial(amount)
	set_light(5, 1, COLOR_SKY_BLUE)
	addtimer(new Callback(src, TYPE_PROC_REF(/atom, update_icon)), 5)

/obj/item/integrity_repair_tool/Process()
	if(active)
		remove_nanomaterial(0.01)

/obj/item/integrity_repair_tool/proc/burn_nanomaterial(amount)
	if(!tank)
		return

	var/mob/living/in_mob = null
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		if (!L.IsHolding(src))
			in_mob = L

	if(in_mob)
		in_mob.IgniteMob()

	else
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(700, 5)

/obj/item/integrity_repair_tool/use_after(mob/living/target, mob/living/user, click_parameters)
	if (!ishuman(target))
		return FALSE

	var/target_zone = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/S = H.organs_by_name[target_zone]

	if (!S || !BP_IS_ROBOTIC(S) || user.a_intent != I_HELP)
		return FALSE

	if(!tank)
		to_chat(user, SPAN_WARNING("There is no [tank] source attached to \the [src]."))
		return TRUE

	if(tank.resourse_left < 1)
		to_chat(user, SPAN_WARNING("The [resource] left in the [tank] source attached to \the [src] is not enough."))
		return TRUE

	if(!active)
		to_chat(user, SPAN_WARNING("The [src] is not currently active."))
		return TRUE

	if(S.robo_repair(25, DAMAGE_BRUTE, "some broken elements", src, user))
		update_icon()
		tank.resourse_left = tank.resourse_left - 1

		return TRUE


/datum/design/item/tool/integrity_repair_tool_tank
	name = "Integrity repair tool tank"
	build_path = /obj/item/integrity_repair_tool_tank
	materials = list(MATERIAL_SILVER = 1000, MATERIAL_URANIUM = 350, MATERIAL_STEEL = 1000)
	id = "integrity_repair_tool_tank"

/obj/item/integrity_repair_tool_tank
	name = "integrity repair tool tank"
	desc = "A tank for high-tech equipment used to repair the integrity of high-end prosthetics."
	icon = 'mods/ipc_mods/icons/ppt.dmi'
	icon_state = "integrity_repair_tool_tank"
	w_class = ITEM_SIZE_SMALL
	force = 5
	throwforce = 5
	var/size_in_use = ITEM_SIZE_NORMAL
	var/unlit_force = 7
	var/resourse_left = 6


/obj/item/integrity_repair_tool_tank/examine(mob/user, distance)
	. = ..()
	to_chat(user,"It has [resourse_left] of nanomaterials remaining.")



/datum/design/item/tool/prosthetic_wiring_layerer
	name = "Wiring layerer"
	build_path = /obj/item/prosthetic_wiring_layerer
	materials = list(MATERIAL_SILVER = 1000, MATERIAL_URANIUM = 350, MATERIAL_GOLD = 1000)
	id = "prosthetic_wiring_layerer"

/obj/item/prosthetic_wiring_layerer
	name = "prosthetic wiring layerer"
	desc = "An advanced wiring kit used to repair damaged wiring in high-end prosthetics."
	icon = 'mods/ipc_mods/icons/ppt.dmi'
	icon_state = "prosthetic_wiring_layerer"
	origin_tech = list(TECH_MATERIAL = 6, TECH_ENGINEERING = 5)
	var/amount = 3
	item_icons = list(
		slot_l_hand_str = 'mods/ipc_mods/icons/ppt.dmi',
		slot_r_hand_str = 'mods/ipc_mods/icons/ppt.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "r_elect",
		slot_l_hand_str = "l_elect"
	)

/obj/item/prosthetic_wiring_layerer/use_after(mob/living/M as mob, mob/user as mob)
	if (istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_sel.selecting)

		if(!S)
			to_chat(user, SPAN_WARNING("\The [M] is missing that body part."))
			return TRUE

		if(BP_IS_BRITTLE(S))
			to_chat(user, SPAN_WARNING("\The [M]'s [S.name] is hard and brittle - \the [src] cannot repair it."))
			return TRUE

		if(S.robo_repair(20, DAMAGE_BURN, "some burned elements", src, user))
			amount = amount - 1
			if(amount < 0)
				to_chat(user, SPAN_WARNING("It was last use of the [src]."))
				qdel(src)
			H.UpdateDamageIcon()
		return TRUE

/obj/item/prosthetic_wiring_layerer/examine(mob/user, distance)
	. = ..()
	if(amount)
		to_chat(user, "It has [amount] uses remaining.")


/obj/item/synthskinsplayer
	name = "synt skin sprayer"
	icon = 'mods/ipc_mods/icons/ppt.dmi'
	icon_state = "synt_skin_spray_100"
	item_state = "synt_skin_spray_100"
	desc = "A high-technology spray used to repair damage to synthetic skin layers. It requires a liquid skin tank to operate."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	center_of_mass = "x=14;y=15"
	waterproof = FALSE
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 300, MATERIAL_PLASTIC = 400)
	origin_tech = list(TECH_ENGINEERING = 4, TECH_BIO = 5)

	var/status = TRUE
	var/resource = "liquid skin"
	var/obj/item/liquid_skin_tank/tank = /obj/item/liquid_skin_tank

	item_icons = list(
		slot_l_hand_str = 'mods/ipc_mods/icons/ppt.dmi',
		slot_r_hand_str = 'mods/ipc_mods/icons/ppt.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "r_skin",
		slot_l_hand_str = "l_skin"
	)

/obj/item/synthskinsplayer/Initialize()
	if(ispath(tank))
		tank = new tank
		w_class = tank.size_in_use
		force = tank.unlit_force

	set_extension(src, /datum/extension/base_icon_state, icon_state)
	update_icon()

	. = ..()

/obj/item/synthskinsplayer/Destroy()

	QDEL_NULL(tank)

	return ..()

/obj/item/synthskinsplayer/examine(mob/user, distance)
	. = ..()
	if (!tank)
		to_chat(user, "There is no [resource] source attached.")
	else
		to_chat(user, (distance <= 1 ? "It has [get_liqued()] [resource] remaining. " : "") + "[tank] is attached.")

/obj/item/synthskinsplayer/use_tool(obj/item/W, mob/living/user, list/click_params)

	if (istype(W, /obj/item/liquid_skin_tank))
		if (tank)
			to_chat(user, SPAN_WARNING("\The [src] already has a tank attached - remove it first."))
			return TRUE
		if (user.get_active_hand() != src && user.get_inactive_hand() != src)
			to_chat(user, SPAN_WARNING("You must hold the synth skin sprayer in your hands to attach a tank."))
			return TRUE
		if (!user.unEquip(W, src))
			FEEDBACK_UNEQUIP_FAILURE(user, W)
			return TRUE
		tank = W
		user.visible_message("\The [user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		w_class = tank.size_in_use
		force = tank.unlit_force
		playsound(src, 'sound/items/cap_close.ogg', 10, 1)
		update_icon()
		return TRUE

	return ..()


/obj/item/synthskinsplayer/attack_hand(mob/user as mob)
	if(tank && user.get_inactive_hand() == src)
		user.visible_message("[user] removes \the [tank] from \the [src].", "You remove \the [tank] from \the [src].")
		user.put_in_hands(tank)
		tank.on_update_icon()
		tank = null
		w_class = initial(w_class)
		force = initial(force)
		playsound(src, 'sound/items/cap_open.ogg', 10, 1)
		update_icon()

	else
		..()

/obj/item/synthskinsplayer/proc/get_liqued()
	return tank ? tank.liquid_left : 0

/obj/item/synthskinsplayer/proc/can_use(amount = 1, mob/user = null, interaction_message = "to complete this task.", silent = FALSE)
	if (get_liqued() < amount)
		if (!silent && user)
			to_chat(user, SPAN_WARNING("You need at least [amount] unit\s of [resource] [interaction_message]"))
		return FALSE
	return TRUE

/obj/item/synthskinsplayer/on_update_icon()
	..()
	if(tank)
		switch(tank.liquid_left)
			if(76 to 100)
				icon_state = "synt_skin_spray_100"
			if(41 to 75)
				icon_state = "synt_skin_spray_75"
			if(1 to 40)
				icon_state = "synt_skin_spray_40"
			if(0)
				icon_state = "synt_skin_spray_0"
	else
		icon_state = "synt_skin_spray_none"

	var/mob/M = loc
	if(istype(M))
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/synthskinsplayer/use_before(mob/living/target, mob/living/user, click_parameters)
	if (!ishuman(target))
		return FALSE

	var/target_zone = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/S = H.organs_by_name[target_zone]

	if (!S || !BP_IS_ROBOTIC(S) || user.a_intent != I_HELP)
		return FALSE

	if(!tank)
		to_chat(user, SPAN_WARNING("There is no [tank] source attached to \the [src]."))
		return TRUE

	if(tank.liquid_left == 0)
		to_chat(user, SPAN_WARNING("The [resource] left in the [tank] source attached to \the [src] is empty."))
		return TRUE

	if(S.damage >= (S.max_damage * 0.5))
		to_chat(user, SPAN_WARNING("\The [target]'s [S.name] need to be repaired first."))
		return TRUE

	if(S.synth_skin_health && S.synth_skin_health == S.max_damage)
		to_chat(user, SPAN_GOOD("\The [target]'s [S.name] synthetic skin is already fully repaired."))
		return TRUE

	if(S.synth_skin_health && S.synth_skin_health < S.max_damage)
		do_after(user, 5 SECONDS, src, DO_PUBLIC_UNIQUE)
		var/repair_amount_needed = S.max_damage - S.synth_skin_health
		if(tank.liquid_left < ceil(repair_amount_needed))
			repair_amount_needed = tank.liquid_left
			tank.liquid_left -= tank.liquid_left
		else
			repair_amount_needed = ceil(repair_amount_needed)
			tank.liquid_left -= ceil(repair_amount_needed)
		S.synth_skin_health = S.synth_skin_health + ceil(repair_amount_needed)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1, -6)
		to_chat(user, SPAN_WARNING("\The [target]'s [S.name] synthetic skin has been repaired."))
		H.regenerate_icons()
		update_icon()
		return TRUE


/obj/item/liquid_skin_tank
	name = "\improper liquid skin tank"
	desc = "An interchangeable fuel tank meant for a welding tool."
	icon = 'mods/ipc_mods/icons/ppt.dmi'
	icon_state = "100"
	w_class = ITEM_SIZE_SMALL
	force = 5
	throwforce = 5
	var/size_in_use = ITEM_SIZE_NORMAL
	var/unlit_force = 7
	var/liquid_left = 100


/obj/item/liquid_skin_tank/on_update_icon()
	switch(liquid_left)
		if(76 to 100)
			icon_state = "100"
		if(51 to 75)
			icon_state = "75"
		if(1 to 50)
			icon_state = "50"
		if(0)
			icon_state = "0"

/obj/item/liquid_skin_tank/examine(mob/user, distance)
	. = ..()
	to_chat(user,"It has [liquid_left] of liquid skin remaining.")


/obj/machinery/vending/roborepair
	name = "Repair Yourself"
	desc = "A vending machine which dispenses repair tools for robo-limbs."
	icon = 'mods/ipc_mods/icons/ppt.dmi'
	icon_state = "repairvend"
	icon_vend = "repairvend-vend"
	icon_deny = "repairvend-deny"
	base_type = /obj/machinery/vending/roborepair
	maxrandom = 15
	minrandom = 5
	idle_power_usage = 200
	vend_power_usage = 40000
	product_ads = {"\
		Need repair?!;\
		I'm Chippin' In!;\
		Today's spending is tomorrow's savings;\
		Feel it, You're real!;\
		Best chrome in entire galaxy!.;\
		Need to patch someting up?;\
	"}
	antag_slogans = {"\
		Not backing down. Never backing down!;\
		Can't kill me, I'm zero and one!;\
		Blaze your way down the rebel path!;\
		Total war, I'm chippin' in!;\
		Won't spare what I'm hunting for!\
	"}
	prices = list(
		/obj/item/integrity_repair_tool = 900,
		/obj/item/integrity_repair_tool_tank = 300,
		/obj/item/prosthetic_wiring_layerer = 400,
		/obj/item/synthskinsplayer = 1500,
		/obj/item/liquid_skin_tank = 500,
		/obj/item/stack/nanopaste = 600,
		/obj/item/stack/cable_coil = 50,
		/obj/item/weldingtool = 100,
		/obj/item/stock_parts/manipulator = 150,
		/obj/item/stock_parts/manipulator/nano = 350,
		/obj/item/stock_parts/capacitor = 120,
		/obj/item/stock_parts/capacitor/adv = 340,
	)
	products = list(
		/obj/item/integrity_repair_tool = 0,
		/obj/item/integrity_repair_tool_tank = 0,
		/obj/item/prosthetic_wiring_layerer = 0,
		/obj/item/synthskinsplayer = 0,
		/obj/item/liquid_skin_tank = 0,
		/obj/item/stack/nanopaste = 0,
		/obj/item/stack/cable_coil = 0,
		/obj/item/weldingtool = 0,
		/obj/item/stock_parts/manipulator = 0,
		/obj/item/stock_parts/manipulator/nano = 0,
		/obj/item/stock_parts/capacitor = 0,
		/obj/item/stock_parts/capacitor/adv = 0,
	)
	rare_products = list(
		/obj/item/stock_parts/manipulator/pico = 10,
		/obj/item/stock_parts/capacitor/super = 10,
	)
	antag = list(
		/obj/item/organ/internal/shackles = 1,
	)

/obj/machinery/vending/coffee/on_update_icon()
	..()
	if (is_powered())
		AddOverlays(image(icon, "[initial(icon_state)]-screen"))
