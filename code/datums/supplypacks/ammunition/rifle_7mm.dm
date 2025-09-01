/singleton/hierarchy/supply_pack/ammunition/r7_lethal
	name = "Ammunition - 7mm rifle, lethal, 100x"
	contains = list(
		/obj/item/ammobox/rifle/military = 1
	)
	cost = 20
	containername = "7mm rifle rounds (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_HIGH


/singleton/hierarchy/supply_pack/ammunition/r7_lethal_light
	name = "Ammunition - 7mm rifle low-power, lethal, 100x"
	contains = list(
		/obj/item/ammobox/rifle/military/light = 1
	)
	cost = 15
	containername = "7mm rifle low-power rounds (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_HIGH


/singleton/hierarchy/supply_pack/ammunition/r7_blank
	name = "Ammunition - 7mm rifle, blank, 100x"
	contains = list(
		/obj/item/ammobox/rifle/military/practice = 1
	)
	cost = 15
	containername = "7mm rifle blank rounds (WARNING: LIVE AMMUNITION)"


/singleton/hierarchy/supply_pack/ammunition/r7_heavy_mag
	name = "Magazines - 7mm heavy rifle, 6x"
	contains = list(
		/obj/item/ammo_magazine/mil_rifle/heavy/empty = 6
	)
	cost = 10
	containername = "7mm heavy rifle magazines"


/singleton/hierarchy/supply_pack/ammunition/r7_light_mag
	name = "Magazines - 7mm light rifle, 6x"
	contains = list(
		/obj/item/ammo_magazine/mil_rifle/light/empty = 6
	)
	cost = 10
	containername = "7mm light rifle magazines"
