/obj/projectile/smoke_tracer
	name = "smoke tracer"
	icon = 'mods/utility_items/icons/smoke_trail.dmi'
	icon_state = "smoke_trail"
	color = "#ffffff"
	alpha = 150
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	layer = BEAM_PROJECTILE_LAYER
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	light_range = 0
	light_power = 0

/obj/projectile/smoke_tracer/Initialize()
	. = ..()
	// Анимация исчезновения дыма
	animate(src, alpha = 0, time = 25, easing = SINE_EASING)
	QDEL_IN(src, 26)

/obj/item/projectile/bullet/rifle/shell/smoke_tracer
	name = "sniper bullet"
	tracer_type = /obj/projectile/smoke_tracer
	hitscan = TRUE // Хитскан для эффекта трассера в виде дыма
	invisibility = INVISIBILITY_ABSTRACT
	fire_sound = 'mods/utility_items/sounds/sniper.ogg'
	penetrating = 0

/obj/item/projectile/bullet/rifle/shell/smoke_tracer/muzzle_effect()
	if(silenced)
		return

	if(ispath(muzzle_type))
		var/obj/projectile/M = new muzzle_type(get_turf(src))

		if(istype(M))
			var/matrix/M_rot = matrix().Update(rotation = round(-trajectory.angle, 0.1))
			M.SetTransform(others = M_rot)
			M.pixel_x = round(location.pixel_x, 1)
			M.pixel_y = round(location.pixel_y, 1)
			if(!hitscan)
				QDEL_IN(M, 1)
			else
				segments += M

		tracer_effect()

/obj/item/projectile/bullet/rifle/shell/smoke_tracer/tracer_effect()
	if(ispath(tracer_type))
		var/obj/projectile/P = new tracer_type(location.loc)

		if(istype(P))
			var/matrix/M = matrix().Update(scale_y = 0.6, others = effect_transform)

			P.SetTransform(others = M)
			P.pixel_x = round(location.pixel_x, 1)
			P.pixel_y = round(location.pixel_y, 1)

/obj/item/ammo_casing/shell/smoke_tracer
	name = "tracer shell casing"
	desc = "An antimaterial shell casing with a tracer."
	projectile_type = /obj/item/projectile/bullet/rifle/shell/smoke_tracer

/obj/item/storage/box/ammo/sniperammo/tracer
	name = "box of sniper tracer shells"
	startswith = list(/obj/item/ammo_casing/shell/smoke_tracer = 7)
