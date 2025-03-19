/obj/aura/mechshield
	icon = 'mods/mechs_by_shegar/icons/energy_shield.dmi'
	name = "mechshield"
	var/obj/item/mech_equipment/shields/shields = null
	var/active = 0
	layer = ABOVE_HUMAN_LAYER
	var/north_layer = MECH_UNDER_LAYER
	plane = DEFAULT_PLANE
	pixel_x = 8
	pixel_y = 4
	mouse_opacity = 0

/obj/aura/mechshield/Initialize(maploading, obj/item/mech_equipment/shields/holder)
	. = ..()
	shields = holder

/obj/aura/mechshield/added_to(mob/living/target)
	. = ..()
	target.vis_contents += src
	set_dir()
	GLOB.dir_set_event.register(user, src, /obj/aura/mechshield/proc/update_dir)

/obj/aura/mechshield/proc/update_dir(user, old_dir, dir)
	set_dir(dir)

/obj/aura/mechshield/set_dir(new_dir)
	. = ..()
	if(dir == NORTH)
		layer = north_layer
	else layer = initial(layer)

/obj/aura/mechshield/Destroy()
	if(user)
		GLOB.dir_set_event.unregister(user, src, /obj/aura/mechshield/proc/update_dir)
		user.vis_contents -= src
	shields = null
	. = ..()

/obj/aura/mechshield/proc/toggle()
	active = !active

	update_icon()

	if(active)
		flick("shield_raise", src)
	else
		if(shields.charge == 0)
			flick("shield_die",src)
		else
			flick("shield_drop", src)

/obj/aura/mechshield/on_update_icon()
	if(active)
	//Спрайт энергощита меняется в зависимости от состояния щита
		var/percentrage = shields.charge/shields.max_charge * 100
		if(percentrage < 25)
			icon_state = "shield_25"
		else if(percentrage < 50)
			icon_state = "shield_50"
		else if(percentrage < 75)
			icon_state = "shield_75"
		else if(percentrage > 75)
			icon_state = "shield"
	else
		icon_state = "shield_null"

/obj/aura/mechshield/aura_check_bullet(obj/item/projectile/proj, def_zone)
	if (active && shields?.charge)
		proj.damage = shields.stop_damage(proj.damage)
		user.visible_message(SPAN_WARNING("\The [shields.owner]'s shields flash and crackle."))
		flick("shield_impact", src)
		playsound(user,'sound/effects/basscannon.ogg',35,1)
		new /obj/effect/smoke/illumination(user.loc, 5, 4, 1, "#ffffff")
		if (proj.damage <= 0)
			return AURA_FALSE|AURA_CANCEL

		var/datum/effect/spark_spread/spark_system = new /datum/effect/spark_spread()
		spark_system.set_up(5, 0, user)
		spark_system.start()
		playsound(loc, "sparks", 25, 1)
	return EMPTY_BITFIELD

//ЭМИ атака по щиту
/obj/aura/mechshield/proc/emp_attack(severity)
	if(shields)
		if(shields.charge)
			if(severity == 1)
				var/emp_damage = severity * 125
				shields.stop_damage(emp_damage)
			if(severity == 2)
				var/emp_damage = severity * 75
				shields.stop_damage(emp_damage)
			user.visible_message(SPAN_WARNING("\The [shields.owner]'s shilds craks, flashs and covers with sparks and energy strikes."))
			flick("shield_impact", src)

/obj/aura/mechshield/aura_check_thrown(atom/movable/thrown_atom, datum/thrownthing/thrown_datum)
	. = ..()
	if (active && shields?.charge && thrown_datum.speed <= 5)
		user.visible_message(SPAN_WARNING("\The [shields.owner]'s shields flash briefly as they deflect \the [thrown_atom]."))
		flick("shield_impact", src)
		playsound(user, 'sound/effects/basscannon.ogg', 10, TRUE)
		return AURA_FALSE|AURA_CANCEL
