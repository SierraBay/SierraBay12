/obj/machinery/telecomms/hub/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/receiver/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/bus/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/processor/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/server/map_preset/phobos
	preset_name = "phobos"
	preset_color = "#0026ff"

/obj/machinery/telecomms/broadcaster/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/radio/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/radio/intercom/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/encryptionkey/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/radio/headset/map_preset/phobos
	preset_name = "phobos"
	encryption_key = /obj/item/device/encryptionkey/map_preset/phobos

/* CARDS
 * ========
 */

/obj/item/card/id/phobos
	desc = "A card issued to Third Fleet staff."
	color = "#d3e3e1"
	color = "#ccecff"
	access = list(access_away_phobos)

/obj/item/card/id/phobos/commander
	desc = "A card issued to Third Fleet vessel CO's."
	detail_color = COLOR_COMMAND_BLUE
	extra_details = list("onegoldstripe")
	access = list(access_away_phobos, access_away_phobos_armory, access_away_phobos_security, access_away_phobos_bridge, access_away_phobos_commander)

/obj/item/card/id/phobos/security
	desc = "A card issued to Third Fleet security staff."
	color = COLOR_OFF_WHITE
	detail_color = "#e00000"
	access = list(access_away_phobos, access_away_phobos_security)

/obj/item/card/id/phobos/security/sergeant
	desc = "A card issued to Third Fleet senior security staff."
	color = COLOR_OFF_WHITE
	detail_color = "#e00000"
	extra_details = list("onegoldstripe")
	access = list(access_away_phobos, access_away_phobos_security, access_away_phobos_armory)

/obj/item/card/id/phobos/medical
	desc = "A card issued to Third Fleet medical staff."
	detail_color = COLOR_PALE_BLUE_GRAY
	access = list(access_away_phobos)

/obj/item/card/id/phobos/pilot
	desc = "A card issued to Third Fleet bridge staff."
	detail_color = COLOR_COMMAND_BLUE
	access = list(access_away_phobos, access_away_phobos_security, access_away_phobos_bridge)

/obj/item/card/id/phobos/engineer
	desc = "A card issued to engineering staff."
	job_access_type = /datum/job/engineer
	detail_color = COLOR_SUN
	access = list(access_away_phobos)

/* GUNS
 * ========
 */

/obj/item/gun/projectile/automatic/sol_smg
	name = "submachine gun"
	desc = "Mars Security Industries MSI-220 'Rapido'. Commonly used by Military Police, Sol Federal Police and other governmental paramilitary structures tied to MSI contracts."
	icon = 'mods/_maps/phobos/icons/smg_sol.dmi'
	icon_state = "solsmg"
	item_state = "c20r"
	safety_icon = "safety"
	w_class = ITEM_SIZE_LARGE
	force = 10
	caliber = CALIBER_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 8)
	slot_flags = SLOT_BELT|SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/smg_sol
	allowed_magazines = /obj/item/ammo_magazine/smg_sol
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	bulk = -1
	accuracy = 1
	one_hand_penalty = 4

	//SMG
	firemodes = list(
		list(mode_name="semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=4, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    one_hand_penalty=5, burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="short bursts",   burst=5, fire_delay=null, move_delay=4,    one_hand_penalty=6, burst_accuracy=list(0,-1,-1,-1,-2), dispersion=list(0.6, 0.6, 1.0, 1.0, 1.2)),
		)

/obj/item/gun/projectile/automatic/sol_smg/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "solsmg-[round(length(ammo_magazine.stored_ammo),5)]"
	else
		icon_state = "solsmg"

/obj/item/gun/projectile/automatic/sol_smg/empty
	starts_loaded = FALSE

/datum/fabricator_recipe/arms_ammo/hidden/magazine_smg_sol
	name = "ammunition (SOLMAG submachine gun)"
	path = /obj/item/ammo_magazine/smg_sol

/obj/item/ammo_magazine/smg_sol

/obj/item/ammo_magazine/smg_sol
	name = "SOLMAG magazine"
	icon = 'mods/_maps/phobos/icons/smg_sol.dmi'
	icon_state = "sol"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = CALIBER_PISTOL
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/smg_sol/empty
	initial_ammo = 0

/obj/item/storage/box/ammo/smg_sol
	name = "box of SOLMAG SMG magazines"
	startswith = list(/obj/item/ammo_magazine/smg_sol = 6)
