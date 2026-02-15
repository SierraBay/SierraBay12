/singleton/psionic_power/energistics/zorch
	name =             "Zorch"
	cost =             20
	cooldown =         10
	use_ranged =       TRUE
	min_rank =         PSI_RANK_APPRENTICE
	use_description = "Выберите красный интент и верхнюю часть тела, чтобы по нажатию запустить в цель луч концентрированной энергии."
	use_sound = 'mods/psionics/sounds/energisticzorch.ogg'

/singleton/psionic_power/energistics/zorch/invoke(mob/living/user, mob/living/target)
	if(user.zone_sel.selecting != BP_CHEST)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(SPAN_DANGER("[user] испускает электромагнетический луч!"))

		var/user_rank = user.psi.get_rank(faculty)
		var/meta_rank = user.psi.get_rank(PSI_METAKINESIS)
		var/obj/item/projectile/pew

		switch(user_rank)
			if(PSI_RANK_GRANDMASTER)
				if(user.a_intent == I_HELP)
					if(meta_rank >= PSI_RANK_OPERANT)
						pew = new /obj/item/projectile/beam/psi/yellow/shock/heavy(get_turf(user))
					else
						pew = new /obj/item/projectile/beam/psi/stun(get_turf(user))
				if(user.a_intent == I_HURT)
					pew = new /obj/item/projectile/beam/psi/red/laser/heavy(get_turf(user))
			if(PSI_RANK_MASTER)
				if(user.a_intent == I_HELP)
					if(meta_rank >= PSI_RANK_OPERANT)
						pew = new /obj/item/projectile/beam/psi/yellow/shock(get_turf(user))
					else
						pew = new /obj/item/projectile/beam/psi/stun(get_turf(user))
				if(user.a_intent == I_HURT)
					pew = new /obj/item/projectile/beam/psi/red/laser(get_turf(user))
			if(PSI_RANK_OPERANT)
				if(user.a_intent == I_HELP)
					pew = new /obj/item/projectile/beam/psi/stun(get_turf(user))
				if(user.a_intent == I_HURT)
					pew = new /obj/item/projectile/beam/psi/red/midlaser(get_turf(user))
			if(PSI_RANK_APPRENTICE)
				pew = new /obj/item/projectile/beam/psi/stun/smalllaser(get_turf(user))

		if(istype(pew))
			pew.original = target
			pew.current = target
			pew.starting = get_turf(user)
			pew.shot_from = user
			pew.launch(target, user.zone_sel.selecting, (target.x-user.x), (target.y-user.y))
			return TRUE

// Лазеры
/obj/projectile/psi
	icon = 'mods/psionics/icons/effects/lasers.dmi'
	icon_state = "beam"
	light_color = COLOR_LUMINOL
	color = COLOR_LUMINOL

/obj/projectile/psi/muzzle
	icon_state = "muzzle"

/obj/projectile/psi/tracer
	icon_state = "beam"

/obj/projectile/psi/impact
	icon_state = "impact"

/obj/item/projectile/beam/psi
	muzzle_type = /obj/projectile/psi/muzzle
	tracer_type = /obj/projectile/psi/tracer
	impact_type = /obj/projectile/psi/impact


/obj/projectile/psi/red
	light_color = COLOR_RED_LIGHT
	color = COLOR_RED_LIGHT

/obj/projectile/psi/red/muzzle
	icon_state = "muzzle"

/obj/projectile/psi/red/tracer
	icon_state = "beam"

/obj/projectile/psi/red/impact
	icon_state = "impact"


/obj/projectile/psi/red/heavy
	light_color = COLOR_RED_LIGHT
	color = COLOR_RED_LIGHT

/obj/projectile/psi/red/heavy/muzzle
	icon_state = "heavymuzzle"

/obj/projectile/psi/red/heavy/tracer
	icon_state = "heavybeam"

/obj/projectile/psi/red/heavy/impact
	icon_state = "heavyimpact"


/obj/projectile/psi/yellow/shock
	light_color = COLOR_YELLOW
	color = COLOR_YELLOW

/obj/projectile/psi/yellow/shock/muzzle
	icon_state = "muzzle"

/obj/projectile/psi/yellow/shock/tracer
	icon_state = "beam"

/obj/projectile/psi/yellow/shock/impact
	icon_state = "impact"


/obj/projectile/psi/yellow/shock/heavy/muzzle
	icon_state = "heavymuzzle"

/obj/projectile/psi/yellow/shock/heavy/tracer
	icon_state = "heavybeam"

/obj/projectile/psi/yellow/shock/heavy/impact
	icon_state = "heavyimpact"


/obj/item/projectile/beam/psi/attack_mob(mob/living/target_mob, distance, special_miss_modifier)
	if(target_mob.disrupts_psionics())
		return 0
	..()

/obj/item/projectile/beam/psi/on_impact(atom/A)
	if(A.disrupts_psionics())
		impact_effect()
	else
		var/obj/item/cell/charging_cell = A.get_cell()
		if(istype(charging_cell))
			charging_cell.give(rand(damage * 0.5, damage))
		. = ..()

/obj/item/projectile/beam/psi/stun
	name = "mental high-intensity energy wave"
	icon_state = "stun"
	fire_sound = 'mods/psionics/sounds/energisticzorch.ogg'
	damage_flags = 0
	sharp = FALSE
	damage = 1
	damage_type = DAMAGE_BURN
	eyeblur = 1
	agony = 40
	distance_falloff = 1.5
	damage_falloff_list = list(
		list(3, 0.95),
		list(5, 0.90),
		list(7, 0.80),
	)

/obj/item/projectile/beam/psi/stun/smalllaser
	name = "mental thin high-intensity energy wave"
	distance_falloff = 2
	damage_falloff_list = list(
		list(3, 0.90),
		list(5, 0.80),
		list(7, 0.60),
	)

/obj/item/projectile/beam/psi/yellow/shock
	name = "mental high-intensity electric wave"
	icon_state = "stun"
	fire_sound = 'mods/psionics/sounds/energisticzorch.ogg'
	damage_flags = 0
	sharp = FALSE
	agony = 0
	damage = 15
	damage_type = DAMAGE_SHOCK
	distance_falloff = 1
	damage_falloff_list = list(
		list(3, 0.95),
		list(5, 0.90),
		list(7, 0.80),
	)

	muzzle_type = /obj/projectile/psi/yellow/shock/muzzle
	tracer_type = /obj/projectile/psi/yellow/shock/tracer
	impact_type = /obj/projectile/psi/yellow/shock/impact

/obj/item/projectile/beam/psi/yellow/shock/heavy
	name = "mental high-intensity wide electric wave"
	icon_state = "stun"
	fire_sound = 'mods/psionics/sounds/energisticzorch.ogg'
	damage_flags = 0
	sharp = FALSE
	damage = 30
	damage_type = DAMAGE_SHOCK
	distance_falloff = 1
	damage_falloff_list = list(
		list(3, 0.95),
		list(5, 0.90),
		list(7, 0.80),
	)

	muzzle_type = /obj/projectile/psi/yellow/shock/heavy/muzzle
	tracer_type = /obj/projectile/psi/yellow/shock/heavy/tracer
	impact_type = /obj/projectile/psi/yellow/shock/heavy/impact

/obj/item/projectile/beam/psi/red/midlaser
	name = "mental heatwave"
	damage = 40
	damage_flags = 0
	damage_type = DAMAGE_BURN
	sharp = FALSE
	armor_penetration = 10
	distance_falloff = 1
	damage_falloff_list = list(
		list(6, 0.98),
		list(8, 0.92),
	)
	mech_armor_penetration = 20
	mech_armor_damage = 30

	muzzle_type = /obj/projectile/psi/red/muzzle
	tracer_type = /obj/projectile/psi/red/tracer
	impact_type = /obj/projectile/psi/red/impact

/obj/item/projectile/beam/psi/red/laser
	name = "mental intense heatwave"
	damage = 45
	damage_flags = 0
	damage_type = DAMAGE_BURN
	sharp = FALSE
	armor_penetration = 20
	distance_falloff = 1
	damage_falloff_list = list(
		list(6, 0.98),
		list(8, 0.92),
	)
	mech_armor_penetration = 25
	mech_armor_damage = 35

	muzzle_type = /obj/projectile/psi/red/heavy/muzzle
	tracer_type = /obj/projectile/psi/red/heavy/tracer
	impact_type = /obj/projectile/psi/red/heavy/impact

/obj/item/projectile/beam/psi/red/laser/heavy
	name = "mental wide intense heatwave"
	damage = 55
	damage_flags = 0
	damage_type = DAMAGE_BURN
	sharp = FALSE
	armor_penetration = 30
	distance_falloff = 1
	damage_falloff_list = list(
		list(6, 0.98),
		list(8, 0.92),
	)
	mech_armor_penetration = 25
	mech_armor_damage = 35
