/datum/design/autolathe/arms_ammo
	name = "syringe gun cartridge"
	build_path = /obj/item/syringe_cartridge
	category = list("Arms and Ammunition")
	access = list(access_security)
	time = 5


/datum/design/autolathe/arms_ammo/net_shell
	name = "ammunition (net shell)"
	build_path = /obj/item/net_shell

/datum/design/autolathe/arms_ammo/shotgun_holder
	build_path = /obj/item/ammo_magazine/shotholder/empty

/datum/design/autolathe/arms_ammo/shotgun_blanks
	name = "ammunition (shotgun blank)"
	build_path = /obj/item/ammo_casing/shotgun/blank

/datum/design/autolathe/arms_ammo/flaregun
	name = "flare launcher"
	build_path = /obj/item/gun/projectile/flare

/datum/design/autolathe/arms_ammo/hidden
	name = "fabricated machete"
	build_path = /obj/item/material/hatchet/machete/steel
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/shotgun
	name = "ammunition (shotgun beanbag)"
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	hidden = TRUE

/datum/design/autolathe/arms_ammo/shotgun_flash
	name = "ammunition (shotgun flash)"
	build_path = /obj/item/ammo_casing/shotgun/flash

/datum/design/autolathe/arms_ammo/hidden/flamethrower
	name = "flamethrower"
	build_path = /obj/item/flamethrower/full
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/speedloader
	build_path = /obj/item/ammo_magazine/speedloader
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/speedloader_small
	build_path = /obj/item/ammo_magazine/speedloader/small
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/speedloader_magnum
	build_path = /obj/item/ammo_magazine/speedloader/magnum
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_pistol
	build_path = /obj/item/ammo_magazine/pistol
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_pistol_double
	build_path = /obj/item/ammo_magazine/pistol/double
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_small
	build_path = /obj/item/ammo_magazine/pistol/small
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_magnum
	build_path = /obj/item/ammo_magazine/magnum
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_smg
	build_path = /obj/item/ammo_magazine/smg
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_smg_nt
	build_path = /obj/item/ammo_magazine/smg_nt
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_uzi
	build_path = /obj/item/ammo_magazine/machine_pistol
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_smg_topmounted
	build_path = /obj/item/ammo_magazine/smg_top
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_arifle
	build_path = /obj/item/ammo_magazine/rifle
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/magazine_bullpupheavy
	build_path = /obj/item/ammo_magazine/mil_rifle/heavy
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/shotgun
	name = "ammunition (slug shotgun)"
	build_path = /obj/item/ammo_casing/shotgun
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/shotgun_pellet
	name = "ammunition (shell shotgun)"
	build_path = /obj/item/ammo_casing/shotgun/pellet
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/tacknife
	name = "combat knife"
	build_path = /obj/item/material/knife/combat
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/stunshell
	name = "ammunition (stun cartridge shotgun)"
	build_path = /obj/item/ammo_casing/shotgun/stunshell
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/flechette
	name = "ammunition (flechette rifle)"
	build_path = /obj/item/magnetic_ammo
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/skrellian_rifle_flechette
	name = "ammunition (skrellian rifle flechette)"
	build_path = /obj/item/magnetic_ammo/skrell
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/skrellian_rifle_slug
	name = "ammunition (skrellian rifle slug)"
	build_path = /obj/item/magnetic_ammo/skrell/slug
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/stripperclip
	build_path = /obj/item/ammo_magazine/speedloader/clip
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/pistolstripperclip
	build_path = /obj/item/ammo_magazine/speedloader/pclip
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/broomstickstripperclip
	build_path = /obj/item/ammo_magazine/speedloader/hpclip
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/rifleinternalclip
	build_path = /obj/item/ammo_magazine/iclipr
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/beandrum
	build_path = /obj/item/ammo_magazine/shotgunmag/beanbag
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/nt10mag
	build_path = /obj/item/ammo_magazine/n10mm
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/shotgun_flechette
	name = "ammunition (flechette shotgun)"
	build_path = /obj/item/ammo_casing/shotgun/flechette
	hidden = TRUE

/datum/design/autolathe/arms_ammo/hidden/electrode_low
	name = "ammunition (neutralizer electrode)"
	build_path = /obj/item/ammo_casing/battery

/datum/design/autolathe/arms_ammo/hidden/electrode_high
	name = "ammunition (HP neutralizer electrode)"
	build_path = /obj/item/ammo_casing/battery/high

/// A magazine design shows the magazine kind, its caliber and the label of its rounds.
/datum/design/autolathe/arms_ammo/take_item_sample(obj/item/sample)
	..()
	if(!istype(sample, /obj/item/ammo_magazine))
		return
	// The sample is not initialized yet, so its name has no caliber. Read the type values.
	var/obj/item/ammo_magazine/magazine = sample
	set_design_name("[initial(magazine.name)] ([get_caliber_text(magazine.caliber, magazine.ammo_type)])")

/datum/design/autolathe/arms_ammo/proc/set_design_name(new_name)
	name = new_name
	item_name = new_name
	shortname = capitalize(new_name)

/// Gives "caliber" or "caliber, label", as a magazine name shows them.
/datum/design/autolathe/arms_ammo/proc/get_caliber_text(caliber, obj/item/ammo_casing/casing_type)
	var/label = initial(casing_type.label)
	return label ? "[caliber], [label]" : caliber

/*
	COMBAT_EXTENDED: boxes of loose rounds. A printed magazine is empty, so a box is the source of
	rounds. Cost is the rounds in the box times `steel_per_round`. FMJ uses a tenth of the steel for
	one round of the core magazines of that caliber. AP costs 5/3 of FMJ, as the 9x19 AP magazine
	does. HP and rubber cost the same as FMJ.
*/
/datum/design/autolathe/arms_ammo/hidden/ammobox
	build_path = null
	/// Steel for one round in the box.
	var/steel_per_round = 0

/// The name shows the caliber and the round type, as a magazine name does.
/datum/design/autolathe/arms_ammo/hidden/ammobox/take_item_sample(obj/item/sample)
	..()
	var/obj/item/ammobox/box = sample
	materials = list(MATERIAL_STEEL = box.ammo_count * steel_per_round)
	var/obj/item/ammo_casing/casing = box.ammo_type
	set_design_name("ammo box ([get_caliber_text(initial(casing.caliber), casing)])")

/datum/design/autolathe/arms_ammo/hidden/ammobox/pistol
	build_path = /obj/item/ammobox/pistol
	steel_per_round = 7.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/pistol_ap
	build_path = /obj/item/ammobox/pistol/ap
	steel_per_round = 12.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/pistol_hp
	build_path = /obj/item/ammobox/pistol/hp
	steel_per_round = 7.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/pistol_rubber
	build_path = /obj/item/ammobox/pistol/rubber
	steel_per_round = 7.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/small
	build_path = /obj/item/ammobox/pistol/small
	steel_per_round = 6

/datum/design/autolathe/arms_ammo/hidden/ammobox/small_ap
	build_path = /obj/item/ammobox/pistol/small_ap
	steel_per_round = 10

/datum/design/autolathe/arms_ammo/hidden/ammobox/small_hp
	build_path = /obj/item/ammobox/pistol/small_hp
	steel_per_round = 6

/datum/design/autolathe/arms_ammo/hidden/ammobox/small_rubber
	build_path = /obj/item/ammobox/pistol/small_rubber
	steel_per_round = 6

/datum/design/autolathe/arms_ammo/hidden/ammobox/magnum
	build_path = /obj/item/ammobox/magnum
	steel_per_round = 24

/datum/design/autolathe/arms_ammo/hidden/ammobox/magnum_ap
	build_path = /obj/item/ammobox/magnum/ap
	steel_per_round = 40

/datum/design/autolathe/arms_ammo/hidden/ammobox/magnum_hp
	build_path = /obj/item/ammobox/magnum/hp
	steel_per_round = 24

/datum/design/autolathe/arms_ammo/hidden/ammobox/nt41
	build_path = /obj/item/ammobox/nt41
	steel_per_round = 7.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/nt41_ap
	build_path = /obj/item/ammobox/nt41/ap
	steel_per_round = 12.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/nt41_hp
	build_path = /obj/item/ammobox/nt41/hp
	steel_per_round = 7.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/rifle
	build_path = /obj/item/ammobox/rifle
	steel_per_round = 9

/datum/design/autolathe/arms_ammo/hidden/ammobox/rifle_ap
	build_path = /obj/item/ammobox/rifle/ap
	steel_per_round = 15

/datum/design/autolathe/arms_ammo/hidden/ammobox/military
	build_path = /obj/item/ammobox/rifle/military
	steel_per_round = 10

/datum/design/autolathe/arms_ammo/hidden/ammobox/military_ap
	build_path = /obj/item/ammobox/rifle/military/ap
	steel_per_round = 16.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/flechette
	build_path = /obj/item/ammobox/flechette
	steel_per_round = 5

/datum/design/autolathe/arms_ammo/hidden/ammobox/flechette_ap
	build_path = /obj/item/ammobox/flechette/ap
	steel_per_round = 8.5

/datum/design/autolathe/arms_ammo/hidden/ammobox/flechette_hp
	build_path = /obj/item/ammobox/flechette/hp
	steel_per_round = 5
