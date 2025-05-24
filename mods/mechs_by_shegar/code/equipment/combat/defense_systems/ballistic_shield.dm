//Ballistic shield
/obj/item/mech_equipment/ballistic_shield
	name = "exosuit ballistic shield"
	desc = "The Hephaestus Bulwark is a formidable line of defense that sees widespread use in planetary peacekeeping operations and military formations alike."
	icon_state = "mech_shield" //Rendering is handled by aura due to layering issues: TODO, figure out a better way to do this
	var/obj/aura/mech_ballistic/aura = null
	var/last_push = 0
	var/chance = 60 //For attacks from the front, diminishing returns
	var/last_max_block = 0 //Blocking during a perfect block window resets this, else there is an anti spam
	var/max_block = 60 // Should block most things
	var/blocking = FALSE
	heat_generation = 15
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)

/obj/item/mech_equipment/ballistic_shield/need_combat_skill()
	return TRUE

/obj/item/mech_equipment/ballistic_shield/installed(mob/living/exosuit/_owner)
	. = ..()
	aura = new(owner, src)

/obj/item/mech_equipment/ballistic_shield/uninstalled()
	QDEL_NULL(aura)
	. = ..()

/obj/item/mech_equipment/ballistic_shield/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if (!.)
		return
	if (user.a_intent == I_HURT )
		if (last_push + 1.6 SECONDS < world.time)
			owner.visible_message(SPAN_WARNING("\The [owner] retracts \the [src], preparing to push with it!"), blind_message = SPAN_WARNING("You hear the whine of hydraulics and feel a rush of air!"))
			owner.setClickCooldown(0.7 SECONDS)
			last_push = world.time
			if (do_after(owner, 0.5 SECONDS, get_turf(owner), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && owner)
				owner.visible_message(SPAN_WARNING("\The [owner] slams the area in front \the [src]!"), blind_message = SPAN_WARNING("You hear a loud hiss and feel a strong gust of wind!"))
				playsound(src ,'sound/effects/bang.ogg',35,1)
				var/list/turfs = list()
				var/front = get_step(get_turf(owner), owner.dir)
				turfs += front
				turfs += get_step(front, turn(owner.dir, -90))
				turfs += get_step(front, turn(owner.dir,  90))
				for(var/turf/T in turfs)
					for(var/mob/living/M in T)
						if (!M.Adjacent(owner))
							continue
						M.attack_generic(owner, (owner.active_arm.melee_damage * 0.2), "slammed")
						M.throw_at(get_edge_target_turf(owner ,owner.dir),5, 2)
						do_attack_effect(T, "smash")

/obj/item/mech_equipment/ballistic_shield/attack_self(mob/user)
	. = ..()
	if (.) //FORM A SHIELD WALL!
		if (last_max_block + 2 SECONDS < world.time)
			owner.visible_message(SPAN_WARNING("\The [owner] raises \the [src], locking it in place!"), blind_message = SPAN_WARNING("You hear the whir of motors and scratching metal!"))
			playsound(src ,'sound/effects/bamf.ogg',35,1)
			owner.setClickCooldown(0.8 SECONDS)
			blocking = TRUE
			last_max_block = world.time
			do_after(owner, 0.75 SECONDS, get_turf(user), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS)
			blocking = FALSE
		else
			to_chat(user, SPAN_WARNING("You are not ready to block again!"))

/obj/item/mech_equipment/ballistic_shield/proc/block_chance(damage, pen, atom/source, mob/attacker)
	if (damage > max_block || pen > max_block)
		return 0
	else
		var/effective_block = blocking ? chance * 1.5 : chance

		var/conscious_pilot_exists = FALSE
		for (var/mob/living/pilot in owner.pilots)
			if (!pilot.incapacitated())
				conscious_pilot_exists = TRUE
				break

		if (!conscious_pilot_exists)
			effective_block *= 0.5 //Who is going to block anything?

		//Bit copypasta but I am doing something different from normal shields
		var/attack_dir = 0
		if (istype(source, /obj/item/projectile))
			var/obj/item/projectile/P = source
			attack_dir = get_dir(get_turf(src), P.starting)
		else if (attacker)
			attack_dir = get_dir(get_turf(src), get_turf(attacker))
		else if (source)
			attack_dir = get_dir(get_turf(src), get_turf(source))

		if (attack_dir == turn(owner.dir, -90) || attack_dir == turn(owner.dir, 90))
			effective_block *= 0.8
		else if (attack_dir == turn(owner.dir, 180))
			effective_block = 0

		return effective_block

/obj/item/mech_equipment/ballistic_shield/proc/on_block_attack()
	if (blocking)
		//Reset timer for maximum chainblocks
		last_max_block = 0

/obj/aura/mech_ballistic
	icon = 'mods/mechs_by_shegar/icons/ballistic_shield.dmi'
	name = "mech_ballistic_shield"
	var/obj/item/mech_equipment/ballistic_shield/shield = null
	layer = MECH_UNDER_LAYER
	plane = GAME_PLANE_FOV_HIDDEN
	mouse_opacity = 0

/obj/aura/mech_ballistic/Initialize(maploading, obj/item/mech_equipment/ballistic_shield/holder)
	. = ..()
	shield = holder

	//Get where we are attached so we know what icon to use
	if (holder && holder.owner)
		var/mob/living/exosuit/E = holder.owner
		for (var/hardpoint in E.hardpoints)
			var/obj/item/mech_equipment/hardpoint_object = E.hardpoints[hardpoint]
			if (holder == hardpoint_object)
				icon_state = "mech_shield_[hardpoint]"
				var/image/I = image(icon, "[icon_state]_over")
				I.layer = ABOVE_HUMAN_LAYER
				AddOverlays(I)

/obj/aura/mech_ballistic/added_to(mob/living/target)
	. = ..()
	target.vis_contents += src
	set_dir()
	GLOB.dir_set_event.register(user, src, /obj/aura/mech_ballistic/proc/update_dir)

/obj/aura/mech_ballistic/proc/update_dir(user, old_dir, dir)
	set_dir(dir)

/obj/aura/mech_ballistic/Destroy()
	if (user)
		GLOB.dir_set_event.unregister(user, src, /obj/aura/mech_ballistic/proc/update_dir)
		user.vis_contents -= src
	shield = null
	. = ..()

/obj/aura/mech_ballistic/aura_check_bullet(obj/item/projectile/proj, def_zone)
	. = ..()
	if (shield && prob(shield.block_chance(proj.damage, proj.armor_penetration, source = proj)))
		user.visible_message(SPAN_WARNING("\The [proj] is blocked by \the [user]'s [shield]."))
		user.bullet_impact_visuals(proj, def_zone, 0)
		return AURA_FALSE|AURA_CANCEL

/obj/aura/mech_ballistic/aura_check_thrown(atom/movable/thrown_atom, datum/thrownthing/thrown_datum)
	. = ..()
	if (shield)
		var/throw_damage = 0
		if (isobj(thrown_atom))
			var/obj/object = thrown_atom
			throw_damage = object.throwforce * (thrown_datum.speed / THROWFORCE_SPEED_DIVISOR)

		if (prob(shield.block_chance(throw_damage, 0, source = thrown_atom, attacker = thrown_datum.thrower)))
			user.visible_message(SPAN_WARNING("\The [thrown_atom] bounces off \the [user]'s [shield]."))
			playsound(user.loc, 'sound/weapons/Genhit.ogg', 50, 1)
			return AURA_FALSE|AURA_CANCEL

/obj/aura/mech_ballistic/aura_check_weapon(obj/item/weapon, mob/attacker, click_params)
	. = ..()
	if (shield && prob(shield.block_chance(weapon.force, weapon.armor_penetration, source = weapon, attacker = user)))
		user.visible_message(SPAN_WARNING("\The [weapon] is blocked by \the [user]'s [shield]."))
		playsound(user.loc, 'sound/weapons/Genhit.ogg', 50, TRUE)
		return AURA_FALSE|AURA_CANCEL
