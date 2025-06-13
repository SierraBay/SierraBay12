#define CALIBER_ROCKETS			"rockets"
//Ракетомёт
/obj/item/mech_equipment/mounted_system/taser/ballistic/launcher
	name = "\improper  \"GRA-D\" missle launcher system"
	desc = "Dangerous and load missle launcher system."
	icon_state = "mech_missilerack"
	holding_type = /obj/item/gun/projectile/automatic/rocket_launcher
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)

/obj/item/gun/projectile/automatic/rocket_launcher
	name = "GRAD"
	has_safety = FALSE
	ammo_type = /obj/item/ammo_casing/rocket/mech
	magazine_type = /obj/item/ammo_magazine/rockets_casing
	allowed_magazines = list(/obj/item/ammo_magazine/rockets_casing)
	load_method = SINGLE_CASING|SPEEDLOADER
	caliber = CALIBER_ROCKETS
	max_shells = 4
	starts_loaded = FALSE
	firemodes = list(
	mode_name="semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=0, burst_accuracy=null, dispersion=null,
	)
	//Если в списке что-то есть, то будет пускать только те патроны, которые есть в этом списке
	var/list/white_list_ammo_types = list()

/obj/item/gun/projectile/automatic/rocket_launcher/load_ammo(obj/item/A, mob/user)
	if(LAZYLEN(white_list_ammo_types))
		//Ткнули магазином снарядов
		if(ismagazine(A))
			for(var/obj/item/bullet in A.contents)
				if(!(bullet.type in white_list_ammo_types))
					to_chat(user, SPAN_BAD("Один из снарядов в магазине не совместим."))
					return
		//Ткнули сразу снарядом
		else
			if(!(A.type in white_list_ammo_types))
				to_chat(user, SPAN_BAD("Данный снаряд не совместим с этой установкой"))
				return
	. = ..()


/obj/item/ammo_magazine/rockets_casing/pepper

//Общий вид ракет
/obj/item/ammo_magazine/rockets_casing
	name = "rockets casing"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets_casing"
	origin_tech = list(TECH_COMBAT = 4)
	mag_type = SPEEDLOADER
	caliber = CALIBER_ROCKETS
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/rocket/mech
	max_ammo = 4

/obj/item/ammo_casing/rocket/mech
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets"
	caliber = CALIBER_ROCKETS
	projectile_type = /obj/item/projectile/bullet/rocket

/obj/item/projectile/bullet/rocket
	name = "GRAD rocket"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "missile"
	fire_sound = 'mods/mechs_by_shegar/sounds/mech_grad.ogg'
	damage = 0 //Ракеты не должны дамажить от прямой наводки

/obj/item/projectile/bullet/rocket/tracer_effect()
	new /obj/temp_visual/rocket_smoke (get_turf(src))


//сам дымок
/obj/temp_visual/rocket_smoke
	icon = 'mods/mechs_by_shegar/icons/mech_rocket_smoke.dmi'
	icon_state = "smoke"
	duration = 1.5 SECONDS

//Фугас
/obj/item/ammo_magazine/rockets_casing/fugas
	name = "explosive rockets casing"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets_casing"
	origin_tech = list(TECH_COMBAT = 4)
	mag_type = SPEEDLOADER
	caliber = CALIBER_ROCKETS
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/rocket/mech
	max_ammo = 4


/obj/item/ammo_casing/rocket/mech/fugas
	name = "explosive rocket"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets"
	caliber = CALIBER_ROCKETS
	projectile_type = /obj/item/projectile/bullet/rocket/fugas

/obj/item/projectile/bullet/rocket/fugas/on_hit(atom/target)
	explosion(src, 3, EX_ACT_LIGHT)
	..()



//Перчик
/obj/item/ammo_magazine/rockets_casing/pepper
	name = "pepper rockets pack"
	ammo_type = /obj/item/ammo_casing/rocket/mech/pepper

/obj/item/ammo_casing/rocket/mech/pepper
	name = "gas rocket"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets"
	caliber = CALIBER_ROCKETS
	projectile_type = /obj/item/projectile/bullet/rocket/pepper


/obj/item/projectile/bullet/rocket/pepper/on_impact(atom/A)
	var/obj/item/grenade/spawned_grenade = new /obj/item/grenade/chem_grenade/teargas(get_turf(src))
	spawned_grenade.detonate()





//Вспышка
/obj/item/ammo_magazine/rockets_casing/flashbang
	name = "flashbang rockets pack"
	ammo_type = /obj/item/ammo_casing/rocket/mech/flashbang

/obj/item/ammo_casing/rocket/mech/flashbang
	name = "flashbang rocket"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets"
	caliber = CALIBER_ROCKETS
	projectile_type = /obj/item/projectile/bullet/rocket/flashbang

/obj/item/projectile/bullet/rocket/flashbang/on_impact(atom/A)
	var/obj/item/grenade/spawned_grenade = new /obj/item/grenade/flashbang(get_turf(src))
	spawned_grenade.detonate()





//Зажигательная
/obj/item/ammo_magazine/rockets_casing/fire
	name = "incendiary rockets pack"
	ammo_type = /obj/item/ammo_casing/rocket/mech/fire

/obj/item/ammo_casing/rocket/mech/fire
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets"
	caliber = CALIBER_ROCKETS
	projectile_type = /obj/item/projectile/bullet/rocket/fire

/obj/item/projectile/bullet/rocket/fire/on_impact(atom/A)
	for(var/turf/T in get_turfs_in_range(get_turf(src), 1))
		new /obj/turf_fire/rocket_nalapm (T)
	playsound(get_turf(src), 'mods/mechs_by_shegar/sounds/mech_grad_fire.ogg', 100, 0)

/obj/turf_fire/rocket_nalapm
	fire_power = 50
	interact_with_atmos = FALSE
