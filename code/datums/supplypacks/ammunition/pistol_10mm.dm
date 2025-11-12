/singleton/hierarchy/supply_pack/ammunition/p10_lethal
	name = "Ammunition - 10mm pistol, lethal, 100x"
	contains = list(
		/obj/item/ammobox/pistol = 1
	)
	cost = 20
	containername = "10mm pistol rounds (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_ELEVATED


/singleton/hierarchy/supply_pack/ammunition/p10_ltl
	name = "Ammunition - 10mm pistol, LTL, 100x"
	contains = list(
		/obj/item/ammobox/pistol/rubber = 1
	)
	cost = 20
	containername = "10mm pistol LTL rounds (WARNING: LIVE AMMUNITION)"


/singleton/hierarchy/supply_pack/ammunition/p10_blank
	name = "Ammunition - 10mm pistol, blank, 100x"
	contains = list(
		/obj/item/ammobox/pistol/practice = 1
	)
	cost = 20
	containername = "10mm pistol blank rounds (WARNING: LIVE AMMUNITION)"


/singleton/hierarchy/supply_pack/ammunition/p10_mag_light
	name = "Magazines - 10mm light pistol, 8x"
	contains = list(
		/obj/item/ammo_magazine/pistol/empty = 8
	)
	cost = 10
	containername = "10mm light pistol magazines"


/singleton/hierarchy/supply_pack/ammunition/p10_mag_heavy
	name = "Magazines - 10mm heavy pistol, 8x"
	contains = list(
		/obj/item/ammo_magazine/pistol/double/empty = 8
	)
	cost = 10
	containername = "10mm heavy pistol magazines"
