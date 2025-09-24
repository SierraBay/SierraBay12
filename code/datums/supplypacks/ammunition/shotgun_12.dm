/singleton/hierarchy/supply_pack/ammunition/sg12_lethal_shell
	name = "Ammunition - 12g shotgun, shells, 32x"
	contains = list(
		/obj/item/ammobox/shotgun = 1
	)
	cost = 20
	containername = "12g shotgun shells (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_ELEVATED


/singleton/hierarchy/supply_pack/ammunition/sg12_lethal_slug
	name = "Ammunition - 12g shotgun, slugs, 32x"
	contains = list(
		/obj/item/ammobox/shotgun/slug = 1
	)
	cost = 20
	containername = "12g shotgun slugs (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_HIGH


/singleton/hierarchy/supply_pack/ammunition/sg12_ltl
	name = "Ammunition - 12g shotgun, LTL, 64x"
	contains = list(
		/obj/item/ammobox/shotgun/beanbag = 2
	)
	cost = 30
	containername = "12g shotgun LTL (WARNING: LIVE AMMUNITION)"


/singleton/hierarchy/supply_pack/ammunition/sg12_blank
	name = "Ammunition - 12g shotgun, blank, 64x"
	contains = list(
		/obj/item/ammobox/shotgun/blank = 2
	)
	cost = 30
	containername = "12g shotgun blank (WARNING: LIVE AMMUNITION)"



/singleton/hierarchy/supply_pack/ammunition/sg12_mag
	name = "Magazines - 12g shotgun shell holders, 8x"
	contains = list(
		/obj/item/ammo_magazine/shotholder/empty = 8
	)
	cost = 10
	containername = "12g shotgun shell holders"
