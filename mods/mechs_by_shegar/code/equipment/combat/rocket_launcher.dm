#define CALIBER_ROCKETS			"rockets"
//Ракетомёт
/obj/item/mech_equipment/mounted_system/taser/ballistic/launcher
	name = "\improper  \"GRA-D\" missle launcher system"
	desc = "dont read plz."
	icon_state = "mech_missilerack"
	holding_type = /obj/item/gun/projectile/automatic/rocket_launcher
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER, HARDPOINT_RIGHT_SHOULDER)

/obj/item/gun/projectile/automatic/rocket_launcher
	has_safety = FALSE
	ammo_type = /obj/item/ammo_casing/rocket/mech
	magazine_type = /obj/item/ammo_magazine/rockets_casing
	allowed_magazines = /obj/item/ammo_magazine/rockets_casing
	load_method = SINGLE_CASING|SPEEDLOADER
	caliber = CALIBER_ROCKETS
	max_shells = 12
	firemodes = list(
	mode_name="semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=0, burst_accuracy=null, dispersion=null,
	)

/obj/item/ammo_casing/rocket/mech
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets"
	caliber = CALIBER_ROCKETS
	projectile_type = /obj/item/projectile/bullet/rocket

/obj/item/ammo_magazine/rockets_casing
	name = "rockets casing"
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "rockets_casing"
	origin_tech = list(TECH_COMBAT = 4)
	mag_type = SPEEDLOADER
	caliber = CALIBER_ROCKETS
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/rocket/mech
	max_ammo = 6

/obj/item/projectile/bullet/rocket
	icon = 'mods/mechs_by_shegar/icons/ammo.dmi'
	icon_state = "missile"

	name = "minirocket"
	fire_sound = 'sound/effects/Explosion1.ogg'

/obj/item/projectile/bullet/rocket/on_hit(atom/target)
	explosion(target, 5, EX_ACT_HEAVY)
	..()
