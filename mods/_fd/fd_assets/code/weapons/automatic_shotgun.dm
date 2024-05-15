/obj/item/gun/projectile/automatic/shotgun
	name = "automatic shotgun"
	desc = "A shotgun with automatic feeding of cartridges into the barrel 'Tavor AS87' made by Hephaestus Industries is usually used by special units for quick cleaning of buildings and special operations, as well as in some armed conflicts."
	icon = 'icons/obj/guns/shotguns.dmi'
	icon_state = "cshotgun"
	item_state = "cshotgun"
	max_shells = 12
	w_class = ITEM_SIZE_HUGE
	force = 15
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	caliber = CALIBER_SHOTGUN
	origin_tech = list(TECH_COMBAT = 7, TECH_MATERIAL = 3)
	load_method = SINGLE_CASING
	ammo_type = /obj/item/ammo_casing/shotgun
	handle_casings = EJECT_CASINGS
	one_hand_penalty = 8
	bulk = GUN_BULK_RIFLE + 2
	load_sound = 'sound/weapons/guns/interaction/shotgun_instert.ogg'

	firemodes = list(
			list(mode_name="full auto", can_autofire=1, burst=1, fire_delay=1, one_hand_penalty=12, burst_accuracy = list(0,-1,-1,-2,-2,-2,-3,-3), dispersion = list(1.0, 1.0, 1.0, 1.0, 1.2)),
			SEMI_AUTO_NODELAY,
			BURST_3_ROUND
		)
