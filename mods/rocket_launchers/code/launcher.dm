/obj/item/gun/projectile/rocket
	name = "RPG-7"
	desc = "Old rocket launcher"
	icon = 'icons/obj/guns/launchers.dmi'
	icon_state = "rocket"
	item_state = "rocket"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	bulk = GUN_BULK_HEAVY_RIFLE
	force = 5
	fire_delay = 20
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

/obj/item/gun/projectile/rocket/ausec
	name = "AXR-11 \"Talon\""
	desc = "The AXR-11 “Talon” is a lightweight, modular recoilless launcher system developed by Aussec Armory for the Sol Central Government’s expeditionary forces. Designed for rapid-deployment squads and orbital infantry, it emphasizes accuracy, low recoil, and tactical versatility."
	caliber = CALIBER_ROCKET_AUSSEC
	ammo_type = /obj/item/ammo_casing/rpg_rocket/aussec

/obj/item/gun/projectile/rocket/Initialize()
	slowdown_per_slot[slot_l_hand] =  slowdown_held
	slowdown_per_slot[slot_r_hand] =  slowdown_held
	slowdown_per_slot[slot_back] =    slowdown_worn
	slowdown_per_slot[slot_belt] =    slowdown_worn
	slowdown_per_slot[slot_s_store] = slowdown_worn

	. = ..()

/obj/item/gun/projectile/rocket/attack_self(mob/user as mob)
	toggle_scope(user) // override to use scope

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
