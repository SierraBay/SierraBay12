/obj/item/gun/projectile/rocket
	name = "RPG-7"
	desc = "Old rocket launcher"
	icon = 'mods/rocket_launchers/icons/launchers.dmi'
	item_icons = list(
		slot_l_hand_str = 'mods/rocket_launchers/icons/lefthand_guns.dmi',
		slot_r_hand_str = 'mods/rocket_launchers/icons/righthand_guns.dmi',
		slot_back_str = 'mods/rocket_launchers/icons/onmob_back.dmi'
		)
	icon_state = "rocket-hel"
	item_state = "rocket-hel"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	bulk = GUN_BULK_HEAVY_RIFLE
	force = 5
	fire_delay = 5 SECONDS
	origin_tech = list(TECH_COMBAT = 8, TECH_ESOTERIC = 8)
	ammo_type = /obj/item/ammo_casing/rpg_rocket
	handle_casings = CLEAR_CASINGS
	combustion = 1
	caliber = CALIBER_ROCKET_HEL
	load_method = SINGLE_CASING
	accuracy = 4
	scoped_accuracy = 8
	one_hand_penalty = 20
	scope_zoom = 1
	accuracy_power = 8
	starts_loaded = 0
	load_sound = 'mods/rocket_launchers/sounds/insert_rocket.ogg'
	max_shells = 1
	var/slowdown_held = 2
	var/slowdown_worn = 1

/obj/item/gun/projectile/rocket/hel
	name = "MRL-94 \"Vyun\""
	desc = "The MRL-94 “Vyun” is a fourth-generation reusable rocket launcher developed by HelTek Arms, a major military contractor for the ICCGN. Designed for harsh colonial environments, orbital combat, and anti-tech engagements, it serves as the standard portable anti-armor system among ICCGN ground forces and orbital response units."
	ammo_type = /obj/item/ammo_casing/rpg_rocket/hel

/obj/item/gun/projectile/rocket/hel/on_update_icon()
	. = ..()

	var/mob/living/M = loc
	if(length(loaded))
		for(var/obj/item/ammo_casing/rpg_rocket/hel/rocket in loaded)
			if(istype(rocket, /obj/item/ammo_casing/rpg_rocket/hel/frag))
				icon_state = "[initial(icon_state)]-frag"
				item_state = is_held_twohanded(M) ? "[initial(item_state)]-armed-in" : "[initial(item_state)]-in"
			else if(istype(rocket, /obj/item/ammo_casing/rpg_rocket/hel/heat))
				icon_state = "[initial(icon_state)]-heat"
				item_state = is_held_twohanded(M) ? "[initial(item_state)]-armed-in" : "[initial(item_state)]-in"
			else if(istype(rocket, /obj/item/ammo_casing/rpg_rocket/hel/tandem))
				icon_state = "[initial(icon_state)]-tandem"
				item_state = is_held_twohanded(M) ? "[initial(item_state)]-armed-in" : "[initial(item_state)]-in"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)

/obj/item/gun/projectile/rocket/aussec
	name = "AXR-11 \"Talon\""
	desc = "The AXR-11 “Talon” is a lightweight, modular recoilless launcher system developed by Aussec Armory for the Sol Central Government’s expeditionary forces. Designed for rapid-deployment squads and orbital infantry, it emphasizes accuracy, low recoil, and tactical versatility."
	icon_state = "rocket-aussec"
	item_state = "rocket-aussec"
	caliber = CALIBER_ROCKET_AUSSEC
	ammo_type = /obj/item/ammo_casing/rpg_rocket/aussec

/obj/item/gun/projectile/rocket/aussec/on_update_icon()
	. = ..()

	var/mob/living/M = loc
	if(length(loaded) && is_held_twohanded(M))
		item_state = "[initial(item_state)]-armed"
	else
		item_state = initial(item_state)

/obj/item/gun/projectile/rocket/Initialize()
	slowdown_per_slot[slot_l_hand] =  slowdown_held
	slowdown_per_slot[slot_r_hand] =  slowdown_held
	slowdown_per_slot[slot_back] =    slowdown_worn
	slowdown_per_slot[slot_belt] =    slowdown_worn
	slowdown_per_slot[slot_s_store] = slowdown_worn

	. = ..()

/obj/item/gun/projectile/rocket/attack_self(mob/user as mob)
	toggle_scope(user, 1.5) // override to use scope

/obj/item/gun/projectile/rocket/handle_post_fire(mob/user, atom/target, pointblank = 0, reflex = 0, obj/projectile)
	. = ..()
	var/turf/simulated/T = get_turf(get_step(loc, reverse_direction(get_dir(user, target))))
	if(!T.density)
		for(var/mob/living/M in T)
			M.apply_damage(30, DAMAGE_BURN) // don't stay behind the launcher
		new /obj/temp_visual/launch_smoke(T)

	if(!user.skill_check(SKILL_HAULING, SKILL_TRAINED)) // athletic skill check
		if(!user.has_gravity())
			return

		if(user.buckled)
			return

		user.stop_pulling()
		user.Weaken(3)

// Helldivers mechanic
/mob/living/carbon/human/use_tool(obj/item/tool, mob/user, list/click_params)
	. = ..()
	if(istype(tool, /obj/item/ammo_casing/rpg_rocket))
		if(istype(r_hand, /obj/item/gun/projectile/rocket))
			var/obj/item/gun/projectile/rocket/launcher = r_hand
			launcher.load_ammo(tool, user, 1)
		else if(istype(l_hand, /obj/item/gun/projectile/rocket))
			var/obj/item/gun/projectile/rocket/launcher = l_hand
			launcher.load_ammo(tool, user, 1)

#define EXP_TAC_RELOAD 1 SECOND
#define PROF_TAC_RELOAD 0.5 SECONDS
#define EXP_SPD_RELOAD 0.5 SECONDS
#define PROF_SPD_RELOAD 0.25 SECONDS

// Override load ammo proc
/obj/item/gun/projectile/rocket/load_ammo(obj/item/A, mob/user, delay = 3 SECONDS)
	if(!can_reload)
		return
	if(istype(A, /obj/item/ammo_magazine))
		. = TRUE
		var/obj/item/ammo_magazine/AM = A
		if (((istext(caliber) && caliber != AM.caliber) || (islist(caliber) && !is_type_in_list(AM.caliber, caliber))))
			return //incompatible
		else if (load_method == SINGLE_CASING && AM.mag_type == SPEEDLOADER && world.time >= recentload)
			if (length(AM.stored_ammo))
				var/C = AM.stored_ammo[1]
				if (length(loaded) >= max_shells)
					to_chat(user, SPAN_WARNING("[src] is full!"))
					return
				if (!user.unEquip(C, src))
					return
				loaded.Insert(1, C) //add to the head of the list
				AM.stored_ammo -= C
				user.visible_message("[user] inserts \a [C] into [src].", SPAN_NOTICE("You insert \a [C] into [src]."))
				playsound(loc, load_sound, 50, 1)
				recentload = world.time + 0.5 SECONDS
			AM.update_icon()
			update_icon()
			return
		else if (!(load_method & AM.mag_type))
			return //incompatible

		switch(AM.mag_type)
			if(MAGAZINE)
				if((ispath(allowed_magazines) && !istype(A, allowed_magazines)) || (islist(allowed_magazines) && !is_type_in_list(A, allowed_magazines)) || (ispath(banned_magazines) && istype(A, banned_magazines)) || (islist(banned_magazines) && is_type_in_list(A, banned_magazines)))
					to_chat(user, SPAN_WARNING("\The [A] won't fit into [src]."))
					return
				if(ammo_magazine)
					if(user.a_intent == I_HELP || user.a_intent == I_DISARM || !user.skill_check(SKILL_WEAPONS, SKILL_EXPERIENCED))
						to_chat(user, SPAN_WARNING("[src] already has a magazine loaded."))//already a magazine here
						return
					else
						if(user.a_intent == I_GRAB) //Tactical reloading
							if(!can_special_reload)
								to_chat(user, SPAN_WARNING("You can't tactically reload this gun!"))
								return
							if(!user.unEquip(AM, src))
								return
							//Experienced gets a 1 second delay, master gets a 0.5 second delay
							if(do_after(user, user.get_skill_value(SKILL_WEAPONS) == SKILL_MASTER ? PROF_TAC_RELOAD : EXP_TAC_RELOAD, src, DO_DEFAULT | DO_BOTH_UNIQUE_ACT))
								if(jam_chance && (!(ammo_magazine.type == magazine_type)))
									jam_chance -= 20
								ammo_magazine.update_icon()
								user.put_in_hands(ammo_magazine)
								user.visible_message(
									SPAN_WARNING("\The [user] reloads \the [src] with \the [AM]!"),
									SPAN_WARNING("You tactically reload \the [src] with \the [AM]!")
								)
						else //Speed reloading
							if(!can_special_reload)
								to_chat(user, SPAN_WARNING("You can't speed reload with this gun!"))
								return
							if(!user.unEquip(AM, src))
								return
							//Experienced gets a 0.5 second delay, master gets a 0.25 second delay
							if(do_after(user, user.get_skill_value(SKILL_WEAPONS) == SKILL_MASTER ? PROF_SPD_RELOAD : EXP_SPD_RELOAD, src, DO_DEFAULT | DO_BOTH_UNIQUE_ACT))
								if(jam_chance && istype(ammo_magazine, magazine_type))
									jam_chance -= 10
								ammo_magazine.update_icon()
								ammo_magazine.dropInto(user.loc)
								user.visible_message(
									SPAN_WARNING("\The [user] reloads \the [src] with \the [AM]!"),
									SPAN_WARNING("You speed reload \the [src] with \the [AM]!")
								)
					ammo_magazine = AM
					playsound(loc, mag_insert_sound, 75, 1)
					update_icon()
					AM.update_icon()
					if(!istype(AM, magazine_type))
						jam_chance += 10
					return
				ammo_magazine = AM
				if(!user.unEquip(AM, src))
					ammo_magazine = null
					return
				user.visible_message("[user] inserts [AM] into [src].", SPAN_NOTICE("You insert [AM] into [src]."))
				playsound(loc, mag_insert_sound, 50, 1)
				if(!istype(AM, magazine_type))
					jam_chance += 10
			if(SPEEDLOADER)
				if(length(loaded) >= max_shells)
					to_chat(user, SPAN_WARNING("[src] is full!"))
					return
				var/count = 0
				for(var/obj/item/ammo_casing/C in AM.stored_ammo)
					if(length(loaded) >= max_shells)
						break
					if(C.caliber == caliber)
						C.forceMove(src)
						loaded += C
						AM.stored_ammo -= C //should probably go inside an ammo_magazine proc, but I guess less proc calls this way...
						count++
				if(count)
					user.visible_message("[user] reloads [src].", SPAN_NOTICE("You load [count] round\s into [src]."))
					playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
		AM.update_icon()
	else if(istype(A, /obj/item/ammo_casing))
		. = TRUE
		var/obj/item/ammo_casing/C = A
		if(!(load_method & SINGLE_CASING) || caliber != C.caliber)
			return //incompatible
		if(length(loaded) >= max_shells)
			to_chat(user, SPAN_WARNING("[src] is full."))
			return
		playsound(loc, load_sound, 50, 1)
		if(delay)
			if(!do_after(user, delay * user.skill_delay_mult(SKILL_HAULING) * user.skill_delay_mult(SKILL_WEAPONS), src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER))
				return
		if(!user.unEquip(C, src))
			return
		loaded.Insert(1, C) //add to the head of the list
		user.visible_message("[user] inserts \a [C] into [src].", SPAN_NOTICE("You insert \a [C] into [src]."))

	update_icon()

#undef EXP_TAC_RELOAD
#undef PROF_TAC_RELOAD
#undef EXP_SPD_RELOAD
#undef PROF_SPD_RELOAD
