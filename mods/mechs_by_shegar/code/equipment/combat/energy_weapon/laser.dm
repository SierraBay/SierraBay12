/obj/item/mech_equipment/mounted_system/taser/laser
	name = "\improper CH-PS \"SUNLIGHT\" laser-heat weapon"
	desc = "An mech-mounted laser rifle. Handle with care."
	icon_state = "mech_lasercarbine"
	holding_type = /obj/item/gun/energy/apex/mech
	heat_generation = 50

/obj/item/mech_equipment/mounted_system/taser/laser/need_combat_skill()
	return TRUE

///Лазерное оружие из Апекса, которое нужно удерживать на цели
/obj/item/gun/energy/apex
	//С помощью этой штуки мы показываем куда должен направляться лазер
	var/obj/laser_pointer
	var/datum/beam
	var/currently_fire = FALSE
	can_autofire = TRUE
	fire_sound = null
	///Второстепенный снаряд
	var/second_projectile_type
	///Звук долгого выстрела (Зажима)
	var/long_sound = 'mods/mechs_by_shegar/sounds/static_sound_laser.ogg'
	///Звук выстрела (конечный)
	var/short_sound = 'mods/mechs_by_shegar/sounds/laser_final.ogg'
	var/apex_cooldown = 4 SECONDS
	var/last_started_apex
	var/client/remembered_mouse_move_client
	///У всех апекс оружий должен быть владелец. Просчитывается при каждом выстреле
	var/mob/living/owner
	var/apex_mode = TRUE
	var/atom/current_shoot_target

/obj/item/gun/energy/apex/Initialize()
	. = ..()
	laser_pointer = new(src)

/obj/item/gun/energy/apex/mech
	name = "mounted laser cannon"
	self_recharge = TRUE
	use_external_power = TRUE
	has_safety = FALSE
	var/obj/item/mech_equipment/mounted_system/holder
	recharge_time = 10
	accuracy = 0
	///Второстепенный снаряд
	second_projectile_type = /obj/item/projectile/beam/weak_apex_laser
	///Основной снаряд
	projectile_type = /obj/item/projectile/beam/midlaser/heavy_apex
	fire_delay = 10
	accuracy = 2
	firemodes = list(
		list("mode_name" = "standard mode", "projectile_type" =  /obj/item/projectile/beam/incendiary_laser, apex_mode = FALSE),
		list("mode_name" = "APEX-mode", "projectile_type" =  /obj/item/projectile/beam/midlaser/heavy_apex, apex_mode = TRUE),
		)


/obj/item/gun/energy/apex/mech/Initialize()
	. = ..()
	holder = loc

/obj/item/gun/energy/apex/mech/handle_post_fire(mob/user, atom/target, pointblank, reflex, obj/projectile)
	. = ..()
	holder.owner.add_heat(holder.heat_generation)

/obj/item/projectile/beam/incendiary_laser/mech
	damage = 25
	armor_penetration = 0
	mech_armor_damage = 40
	agony = 0

///Слабый и промежуточный лазер
/obj/item/projectile/beam/weak_apex_laser
	fire_sound = null
	//Лазер должен быть невидим, он технический
	icon_state = null
	muzzle_type = null
	tracer_type = null
	impact_type = null
	//Так ещё и тихим
	silenced = TRUE
	impact_sounds = list(BULLET_IMPACT_MEAT = SOUNDS_LASER_MEAT)
	damage = 2.6
	mech_armor_damage = 2 //30 армор урона от одного заряда апекса


//Сильный конечный снаряд
/obj/item/projectile/beam/midlaser/heavy_apex
	fire_sound = null
	icon_state = "beam_heavy"
	mech_armor_damage = 30 //И ещё 30 урона. И того, 5 полных попаданий апекса.
	muzzle_type = /obj/projectile/laser/heavy/muzzle
	tracer_type = /obj/projectile/laser/heavy/tracer/apex
	impact_type = /obj/projectile/laser/heavy/impact


/obj/projectile/laser/heavy/tracer/apex
	icon = 'mods/mechs_by_shegar/icons/projectiles.dmi'
	icon_state = "beam_apex"






/obj/item/gun/energy/apex/Fire(atom/target, mob/living/user, clickparams, pointblank=0, reflex=0, called_by_apex)
	if(!power_supply.check_charge(1))
		return
	if(called_by_apex || !apex_mode)
		.=..()
		return
	if(currently_fire)
		update_apex(target)
		return
	if(last_started_apex > world.time)
		return
	start_apex(target)

/obj/item/gun/energy/apex/proc/update_owner()
	if(isliving(loc))
		owner = loc
	else
		owner = loc.loc

/obj/item/gun/energy/apex/proc/start_apex(atom/target)
	currently_fire = TRUE
	playsound(get_turf(src), long_sound, 100, 0)
	projectile_type = second_projectile_type
	laser_pointer.Move(get_turf(target))
	current_shoot_target = target
	update_owner()
	setup_mouse_mover()
	///Промежуточный огонь ничего не тратит
	process_shot()
	beam = owner.Beam(laser_pointer, icon_state = "beam_apex_weak", icon= 'mods/mechs_by_shegar/icons/projectiles.dmi',time = 1.5 SECONDS)
	addtimer(new Callback(src, PROC_REF(stop_apex)), 1.5 SECONDS)

/obj/item/gun/energy/apex/proc/process_shot()
	if(!currently_fire)
		return
	var/obj/item/projectile/beam = new second_projectile_type(get_turf(src))
	beam.launch(current_shoot_target)
	//В сумме, выполнится 15 выстрелов имитирующие постоянный луч. 2.6 * 15 примерно равно 40 урона.
	addtimer(new Callback(src, PROC_REF(process_shot)), 0.1 SECONDS)

/obj/item/gun/energy/apex/proc/update_apex(target)
	laser_pointer.Move(get_turf(target))

/obj/item/gun/energy/apex/proc/stop_apex()
	currently_fire = FALSE
	last_started_apex = world.time + apex_cooldown
	projectile_type = initial(projectile_type)
	desetup_mouse_mover()
	playsound(get_turf(src), short_sound, 150, 0)
	Fire(current_shoot_target, owner, called_by_apex = TRUE)
	laser_pointer.forceMove(src)



///Отслеживание мыши
/obj/item/gun/energy/apex/update_current_mouse_position(atom/input_mouse_postion)
	var/turf/new_turf = get_turf(input_mouse_postion)
	current_shoot_target = input_mouse_postion
	if(!new_turf || !current_shoot_target)
		return
	laser_pointer.Move(new_turf)

/obj/item/gun/energy/apex/proc/setup_mouse_mover()
	remembered_mouse_move_client = usr.client
	LAZYADD(remembered_mouse_move_client.mouse_move_handlers, src)

/obj/item/gun/energy/apex/proc/desetup_mouse_mover()
	LAZYREMOVE(remembered_mouse_move_client.mouse_move_handlers, src)
