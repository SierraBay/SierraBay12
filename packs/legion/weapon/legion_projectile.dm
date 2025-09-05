// Base legion projectile
/obj/item/projectile/beam/legion
	name = "legion beam"
	damage_flags = DAMAGE_FLAG_LASER | DAMAGE_FLAG_SHARP

	muzzle_type = /obj/projectile/legion/muzzle
	tracer_type = /obj/projectile/legion/tracer
	impact_type = /obj/projectile/legion/impact


/obj/item/projectile/beam/legion/bellator
	damage = 80
	armor_penetration = 20
	fire_sound = 'packs/legion/sounds/legion_basic_shot.ogg'


/obj/projectile/legion
	light_color = COLOR_INDIGO


/obj/projectile/legion/tracer
	icon_state = "beam_darkb"


/obj/projectile/legion/muzzle
	icon_state = "muzzle_darkb"


/obj/projectile/legion/impact
	icon_state = "impact_darkb"
