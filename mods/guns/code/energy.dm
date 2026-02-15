/obj/item/gun/energy/laser
	name = "G40E laser carbine"
	icon = 'mods/guns/icons/obj/laser_carbine.dmi'

/obj/item/gun/energy/retro
	name = "G21E laser pistol"
	icon = 'mods/guns/icons/obj/retro_laser.dmi'

/obj/item/gun/energy/lasercannon
	icon = 'mods/guns/icons/obj/laser_cannon.dmi'

/obj/item/gun/energy/xray
	name = "G56E x-ray carbine"
	icon = 'mods/guns/icons/obj/xray.dmi'

/obj/item/gun/energy/xray/pistol
	name = "G56E-s x-ray pistol"
	icon = 'mods/guns/icons/obj/xray_pistol.dmi'

/obj/item/gun/energy/sniperrifle
	name = "9E marksman energy rifle"
	icon = 'mods/guns/icons/obj/laser_sniper.dmi'
	icon_state = "sniper"
	item_state = "laser"
	wielded_item_state = "sniper-wielded"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_sniper.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_sniper.dmi'
		)


/obj/item/gun/energy/pulse_rifle
	wielded_item_state = "pulsecarbine-wielded"
	icon = 'mods/guns/icons/obj/pulse_rifle.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns.dmi'
		)

/obj/item/gun/energy/pulse_rifle/carbine
	icon = 'mods/guns/icons/obj/pulse_carbine.dmi'
	wielded_item_state = null

/obj/item/gun/energy/pulse_rifle/pistol
	icon = 'mods/guns/icons/obj/pulse_pistol.dmi'
	wielded_item_state = null

/obj/item/gun/energy/ionrifle
	name = "NT Mk60 ion rifle"
	icon = 'mods/guns/icons/obj/ion_rifle.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns.dmi'
		)

/obj/item/gun/energy/ionrifle/small
	name = "NT Mk72 ion pistol"
	wielded_item_state = null

/obj/item/gun/energy/ionrifle/small/sec
	name = "NT Mk72 ion pistol"
	desc = "The NT Mk72 EW Preston is a personal defense weapon designed to disable mechanical threats. This one clad in white frame."
	icon = 'mods/guns/icons/obj/ion_pistol_nt.dmi'

/obj/item/gun/energy/incendiary_laser
	icon = 'mods/guns/icons/obj/incendiary_laser.dmi'

/obj/item/gun/energy/taser
	name = "NT Mk30 electrolaser"
	icon = 'mods/guns/icons/obj/taser.dmi'

/obj/item/gun/energy/taser/carbine
	name = "NT Mk44 electrolaser carabine"
	icon = 'mods/guns/icons/obj/taser_carbine.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns.dmi'
		)

/obj/item/gun/energy/gun
	name = "LAEP90 Perun energy gun"

/obj/item/gun/energy/gun/small
	name = "LAEP90-C Strigoi energy gun"

/obj/item/gun/energy/gun/small/secure
	name = "LAEP90-CS Strigoi smartgun"

/obj/item/gun/energy/gun/secure
	name = "LAEP90-S Perun smartgun"

/obj/item/gun/energy/stunrevolver
	name = "A&M X6 Zeus stun revolver"
	icon = 'mods/guns/icons/obj/stunrevolver.dmi'

/obj/item/gun/energy/stunrevolver/rifle
	name = "A&M X10 Thor stun rifle"
	icon = 'mods/guns/icons/obj/stunrifle.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns.dmi',
		)

/obj/item/gun/energy/laser/secure
	name = "G40E laser carbine"
	icon = 'mods/guns/icons/obj/laser_carbine.dmi'
	req_access = list(list(access_brig, access_bridge))

/obj/item/gun/energy/confuseray/secure
	name = "disorientator"
	desc = "The W-T Mk. 6 Disorientator fitted with an NT1017 secure fire chip. It has a NanoTrasen logo on the grip."
	icon = 'icons/obj/guns/confuseray.dmi'
	item_icons = list(
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns_cadet.dmi',
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns_cadet.dmi',
		)
	icon_state = "confuseray"
	item_state = "confuseray"
	req_access = list(list(access_brig, access_bridge))

/obj/item/gun/energy/stunrevolver/secure
	name = "A&M X8 smart revolver"
	desc = "A&M X8 Tessub. Next level in personal security with three diffirent firing modes. This one is fitted with an NT1019 chip which allows remote authorization of weapon functionality. It has an NT emblem on the grip."
	icon = 'mods/guns/icons/obj/stunrevolver_secure.dmi'
	projectile_type = /obj/item/projectile/beam/stun
	firemodes = list(
		list("mode_name" = "stun", "projectile_type" = /obj/item/projectile/beam/stun, "modifystate" = "energyrevolverstun"),
		list("mode_name" = "shock", "projectile_type" = /obj/item/projectile/beam/stun/shock, "modifystate" = "energyrevolvershock"),
		list("mode_name" = "kill", "projectile_type" = /obj/item/projectile/beam, "modifystate" = "energyrevolverkill")
		)
	req_access = list(list(access_brig, access_heads))

/obj/item/gun/energy/plasmastun
	item_icons = list(
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_plasmastun.dmi',
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_plasmastun.dmi'
		)
