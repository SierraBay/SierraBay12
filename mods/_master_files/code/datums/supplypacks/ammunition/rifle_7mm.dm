// COMBAT_EXTENDED: caliber names, see code/__defines/~mods/combat_extended.dm
/singleton/hierarchy/supply_pack/ammunition/r7_lethal
	name = "Ammunition - 5.56 rifle, lethal, 100x"
	containername = "5.56 rifle rounds (WARNING: LIVE AMMUNITION)"

/singleton/hierarchy/supply_pack/ammunition/r7_lethal_light
	name = "Ammunition - 5.56 rifle low-power, lethal, 100x"
	containername = "5.56 rifle low-power rounds (WARNING: LIVE AMMUNITION)"

/singleton/hierarchy/supply_pack/ammunition/r7_blank
	name = "Ammunition - 5.56 rifle, blank, 100x"
	containername = "5.56 rifle blank rounds (WARNING: LIVE AMMUNITION)"

/singleton/hierarchy/supply_pack/ammunition/r7_heavy_mag
	name = "Magazines - 5.56 rifle, 6x"
	containername = "5.56 rifle magazines"

// The mod stops the light magazine, see mods/combat_extended/code/items/guns/magazines.dm. Only
// a hacked console shows this pack. Only a core edit can remove a pack, so this one sells the
// standard magazine.
/singleton/hierarchy/supply_pack/ammunition/r7_light_mag
	name = "Magazines - 5.56 rifle, 6x"
	contains = list(
		/obj/item/ammo_magazine/mil_rifle/heavy/empty = 6
	)
	containername = "5.56 rifle magazines"
