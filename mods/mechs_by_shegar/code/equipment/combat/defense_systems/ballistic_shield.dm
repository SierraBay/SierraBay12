//Ballistic shield
/obj/item/mech_equipment/ballistic_shield
	name = "mech ballistic shield"
	desc = "The Hephaestus Bulwark is a formidable line of defense that sees widespread use in planetary peacekeeping operations and military formations alike."
	icon_state = "mech_shield" //Rendering is handled by aura due to layering issues: TODO, figure out a better way to do this
	var/obj/aura/mech_ballistic/aura = null
	///Последняя лобовая атака щитом
	var/last_push = 0
	//Шанс отбить атаку
	var/chance = 80
	///Последнее время когда был разложен щит
	var/last_block = 0
	///Блокируемый щитом урон
	var/max_block = 60 // Should block most things
	///Щит находится в разложенном состоянии
	var/blocking = FALSE
	///Может ли щит пассивно блокировать входящий урон
	var/can_block_when_undeployed = FALSE
	///Требуется ли пилот в сознании для блокировки урона. Если пилота нет, то шансов сильно меньше
	var/need_active_pilot_for_blocking = TRUE
	///Текущее ХП у щита
	var/current_health
	///В активированном состоянии мешает меху двигаться
	var/disturb_movement = TRUE
	///Максимальное возможное ХП у щита
	var/max_health = 500
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)

/obj/item/mech_equipment/ballistic_shield/need_combat_skill()
	return TRUE

/obj/item/mech_equipment/ballistic_shield/have_specific_melee_attack()
	return TRUE

/obj/item/mech_equipment/ballistic_shield/can_be_repaired()
	return TRUE

/obj/item/mech_equipment/ballistic_shield/Initialize()
	. = ..()
	current_health = max_health

///Задача функции - отключить все железные щиты
/mob/living/exosuit/proc/undeploy_all_shields()
	for(var/obj/item/mech_equipment/ballistic_shield/shield in movement_blocked_by_shield)
		shield.undeploy_shield()

/obj/item/mech_equipment/ballistic_shield/installed(mob/living/exosuit/_owner)
	. = ..()
	aura = new(owner, src)

/obj/item/mech_equipment/ballistic_shield/uninstalled()
	QDEL_NULL(aura)
	if(blocking)
		undeploy_shield()
	. = ..()


/obj/item/mech_equipment/ballistic_shield/get_hardpoint_maptext()
	var/text
	if(blocking)
		text += "[SPAN_GOOD("DEPLOYED")], "
	else
		text += "[SPAN_BAD("UNDEPLOYED")], "
	text += "[round(current_health)]/[max_health] 🛡️"
	return text


/obj/item/mech_equipment/ballistic_shield/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if (!.)
		return
	if (user.a_intent == I_HURT )
		owner.visible_message(SPAN_WARNING("\The [owner] retracts \the [src], preparing to push with it!"), blind_message = SPAN_WARNING("You hear the whine of hydraulics and feel a rush of air!"))
		owner.setClickCooldown(1.5 SECONDS)
		last_push = world.time
		if (!do_after(owner, 1 SECONDS, get_turf(owner), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && owner)
			return
		owner.visible_message(SPAN_WARNING("\The [owner] slams the area in front \the [src]!"), blind_message = SPAN_WARNING("You hear a loud hiss and feel a strong gust of wind!"))
		playsound(src ,'sound/effects/bang.ogg',35,1)
		var/list/turfs = list()
		var/front = get_step(get_turf(owner), owner.dir)
		turfs += front
		turfs += get_step(front, turn(owner.dir, -90))
		turfs += get_step(front, turn(owner.dir,  90))
		for(var/turf/T in turfs)
			do_attack_effect(T, "smash")
			for(var/mob/living/M in T)
				if (!M.Adjacent(owner))
					continue
				M.attack_generic(owner, (owner.active_arm.melee_damage * 0.2), "slammed")
				M.throw_at(target = get_edge_target_turf(owner ,owner.dir), range = 3, speed = 2)





/obj/item/mech_equipment/ballistic_shield/attack_self(mob/user)
	. = ..()
	if (.) //FORM A SHIELD WALL!
		if (last_block + 2 SECONDS > world.time)
			to_chat(usr, SPAN_WARNING("Слишком рано."))
			return
		if(blocking)
			undeploy_shield()
		else
			deploy_shield()

/obj/item/mech_equipment/ballistic_shield/proc/deploy_shield()
	owner.visible_message(SPAN_WARNING("\The [owner] raises \the [src], locking it in place!"), blind_message = SPAN_WARNING("You hear the whir of motors and scratching metal!"))
	playsound(src ,'sound/effects/bamf.ogg',35,1)
	owner.setClickCooldown(1 SECONDS)
	blocking = TRUE
	if(disturb_movement)
		LAZYADD(owner.movement_blocked_by_shield, src)
	aura.update_visual()
	last_block = world.time


/obj/item/mech_equipment/ballistic_shield/proc/undeploy_shield()
	owner.visible_message(SPAN_WARNING("\The [owner] up [src]!"), blind_message = SPAN_WARNING("You hear the whir of motors and scratching metal!"))
	playsound(src ,'sound/effects/bamf.ogg',35,1)
	owner.setClickCooldown(1 SECONDS)
	if(disturb_movement)
		LAZYREMOVE(owner.movement_blocked_by_shield, src)
	blocking = FALSE
	aura.update_visual()
	last_block = world.time

/obj/item/mech_equipment/ballistic_shield/proc/damage_shield(ammout)
	current_health = clamp(current_health - ammout, 0, max_health)
	if(current_health == 0)
		destroy_shield()

/obj/item/mech_equipment/ballistic_shield/use_tool(obj/item/item, mob/living/user, list/click_params)
	. = ..()
	if(isWelder(item))
		try_repair_module(item, user)

/obj/item/mech_equipment/ballistic_shield/try_repair_module(obj/item/tool, mob/user)
	if(current_health == max_health)
		to_chat(user, SPAN_GOOD("Ремонт не требуется"))
		return
	if(!isWelder(tool))
		to_chat(user, SPAN_BAD("Нужна сварка."))
		return
	var/obj/item/weldingtool/welder = tool
	//Топлива не хватит
	if(!welder.can_use(amount = 5, user = user))
		return FALSE
	if(!do_after(user, 5 SECONDS, owner))
		return
	if(!welder.remove_fuel(amount = 5, M = user))
		return
	to_chat(user, SPAN_BAD("Вы заварили дыры и повреждения в броне щита."))
	current_health = clamp(current_health+50, 0, max_health)

/obj/item/mech_equipment/ballistic_shield/proc/destroy_shield()
	new /obj/decal/cleanable/blood/gibs/robot(get_turf(owner))
	owner.remove_system(src, force = TRUE)
	qdel(src)

/obj/item/mech_equipment/ballistic_shield/proc/block_chance(damage, pen, atom/source, mob/attacker)
	if (damage > max_block || pen > max_block)
		return 0
	var/effective_block = chance

	//Если пилота нет/без сознания
	if(need_active_pilot_for_blocking)
		effective_block *= 0.5
		for (var/mob/living/pilot in owner.pilots)
			if (pilot.incapacitated())
				effective_block *= 2 //Нашли пилота - вернём в изначальное состояние
				break

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



































/obj/aura/mech_ballistic
	icon = 'mods/mechs_by_shegar/icons/ballistic_shield.dmi'
	name = "mech_ballistic_shield"
	icon_state = "mech_shield"
	var/obj/item/mech_equipment/ballistic_shield/shield = null
	layer = MECH_UNDER_LAYER
	plane = GAME_PLANE_FOV_HIDDEN
	mouse_opacity = 0

/obj/aura/mech_ballistic/Initialize(maploading, obj/item/mech_equipment/ballistic_shield/holder)
	. = ..()
	shield = holder
	update_visual()

/obj/aura/mech_ballistic/proc/update_visual()
	//Get where we are attached so we know what icon to use
	if(!shield || !shield.owner)
		return
	ClearOverlays()
	var/hardpoint = shield.owner.get_hardpoint_by_equipment(shield)
	//Рисуем спрайт блокирования
	if (shield.blocking)
		icon_state = "mech_shield_deployed_[hardpoint]"
	//Не рисуем спрайт блокирования
	else
		icon_state = "mech_shield_[hardpoint]"
	var/image/I = image(icon, "[icon_state]_over")
	I.layer = ABOVE_HUMAN_LAYER
	AddOverlays(I)


/obj/aura/mech_ballistic/added_to(mob/living/target)
	. = ..()
	target.add_vis_contents(src)
	set_dir()
	GLOB.dir_set_event.register(user, src, /obj/aura/mech_ballistic/proc/update_dir)

/obj/aura/mech_ballistic/proc/update_dir(user, old_dir, dir)
	set_dir(dir)

/obj/aura/mech_ballistic/Destroy()
	if (user)
		GLOB.dir_set_event.unregister(user, src, /obj/aura/mech_ballistic/proc/update_dir)
		user.remove_vis_contents(src)
	shield = null
	. = ..()

/obj/aura/mech_ballistic/aura_check_bullet(obj/item/projectile/proj, def_zone)
	. = ..()
	if(!shield.blocking && !shield.can_block_when_undeployed)
		return //не блочим
	if (shield && prob(shield.block_chance(proj.damage, proj.armor_penetration, source = proj)))
		user.visible_message(SPAN_WARNING("\The [proj] is blocked by \the [user]'s [shield]."))
		shield.damage_shield(proj.damage)
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
		shield.damage_shield(weapon.force)
		playsound(user.loc, 'sound/weapons/Genhit.ogg', 50, TRUE)
		return AURA_FALSE|AURA_CANCEL
