///Ninja equipment loadouts. Placed here because author overrided them using Torch files. Now we overriding this again for some QoL stuff.
/obj/structure/closet/crate/ninja/sol
	name = "sol equipment crate"
	desc = "A tactical equipment crate."

/obj/structure/closet/crate/ninja/sol/New()
	..()
	new /obj/item/rig/light/ninja/sol(src)
	new /obj/item/gun/projectile/pistol/m22f(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/clothing/under/scga/utility/urban(src)
	new /obj/item/clothing/shoes/swat(src)
	new /obj/item/clothing/accessory/scga_rank/e6(src)
	new /obj/item/device/encryptionkey/away_scg_patrol(src)

/obj/structure/closet/crate/ninja/gcc
	name = "gcc equipment crate"
	desc = "A heavy equipment crate."

/obj/structure/closet/crate/ninja/gcc/New()
	..()
	new /obj/item/rig/light/ninja/gcc(src)
	new /obj/item/gun/projectile/pistol/optimus(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/ammo_magazine/box/minigun(src)
	new /obj/item/ammo_magazine/box/minigun(src)
	new /obj/item/clothing/under/iccgn/utility(src)
	new /obj/item/clothing/shoes/iccgn/utility(src)
	new /obj/item/clothing/accessory/iccgn_rank/or6(src)
	new /obj/item/device/encryptionkey/iccgn(src)

/obj/structure/closet/crate/ninja/corpo
	name = "corporate equipment crate"
	desc = "A patented equipment crate."

/obj/structure/closet/crate/ninja/corpo/New()
	..()
	new /obj/item/rig/light/ninja/corpo(src)
	new /obj/item/gun/energy/gun(src)
	new /obj/item/inducer(src)
	new /obj/item/clothing/under/rank/security/corp(src)
	new /obj/item/clothing/shoes/swat(src)
	new /obj/item/clothing/accessory/badge/holo(src)
	new /obj/item/storage/box/syndie_kit/jaunter(src)

/obj/structure/closet/crate/ninja/merc
	name = "mercenary equipment crate"
	desc = "A traitorous equipment crate."

/obj/structure/closet/crate/ninja/merc/New()
	..()
	new /obj/item/rig/merc/ninja(src)
	new /obj/item/gun/projectile/revolver/medium(src)
	new /obj/item/ammo_magazine/speedloader(src)
	new /obj/item/ammo_magazine/speedloader(src)
	new /obj/item/clothing/under/syndicate/combat(src)
	new /obj/item/clothing/shoes/swat(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/storage/backpack/dufflebag/syndie_kit/plastique(src)
	new /obj/item/storage/box/anti_photons(src)
	new /obj/item/device/encryptionkey/syndie_full(src)
	new /obj/item/card/emag(src)
