/obj/item/fd/data
	name = "old datamine disk (TIER 0 - ENGINEERING)"
	desc = "Disk that holds various info - from old-state tech blueprints to astronomical maps."
	icon = 'mods/fd_assets/icons/obj/items/disk.dmi'
	icon_state = "datadisk0"
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)

/obj/item/fd/data/New()
	..()
	icon_state = "datadisk[rand(0, 22)]"

/obj/item/fd/data/weapons
	name = "old datamine disk (TIER 1 - WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2, TECH_POWER = 2, TECH_MAGNET = 2)

//TIER 2

/obj/item/fd/data/weapons/lvl2/kinetic
	name = "old datamine disk (TIER 2 - KINETIC WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 6)

/obj/item/fd/data/weapons/lvl2/energy
	name = "old datamine disk (TIER 2 - ENERGY WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 4, TECH_POWER = 5)

/obj/item/fd/data/weapons/lvl2/magnetic
	name = "old datamine disk (TIER 2 - MAGNETIC WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 4, TECH_MAGNET = 5)

/obj/item/fd/data/weapons/lvl2/special
	name = "old datamine disk (TIER 2 - EXPERIMENTAL WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 4, TECH_ESOTERIC = 5, TECH_BIO = 5)

//TIER 3

/obj/item/fd/data/weapons/lvl3/kinetic
	name = "old datamine disk (TIER 3 - KINETIC WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 9)

/obj/item/fd/data/weapons/lvl3/energy
	name = "old datamine disk (TIER 3 - ENERGY WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_POWER = 7)

/obj/item/fd/data/weapons/lvl3/magnetic
	name = "old datamine disk (TIER 3 - MAGNETIC WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_MAGNET = 7)

/obj/item/fd/data/weapons/lvl3/special
	name = "old datamine disk (TIER 3 - EXPERIMENTAL WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_ESOTERIC = 8, TECH_BIO = 7)

/obj/item/fd/data/weapons/lvl3/secret
	name = "old datamine disk (TIER 3 - SECRET WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_BLUESPACE = 5, TECH_PHORON = 5)

//TIER 4

/obj/item/fd/data/weapons/lvl4/kinetic
	name = "old datamine disk (TIER 4 - KINETIC WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 12, TECH_MATERIAL = 10)

/obj/item/fd/data/weapons/lvl4/energy
	name = "old datamine disk (TIER 4 - ENERGY WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 7, TECH_POWER = 9)

/obj/item/fd/data/weapons/lvl4/magnetic
	name = "old datamine disk (TIER 4 - MAGNETIC WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 7, TECH_MAGNET = 7)

/obj/item/fd/data/weapons/lvl4/special
	name = "old datamine disk (TIER 4 - EXPERIMENTAL WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 7, TECH_ESOTERIC = 10, TECH_BIO = 9)

/obj/item/fd/data/weapons/lvl4/secret
	name = "old datamine disk (TIER 4 - SECRET WEAPONRY)"
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 7, TECH_BLUESPACE = 8, TECH_PHORON = 7)

///

/obj/item/fd/data/engineering
	name = "old datamine disk (TIER 1 - ENGINEERING)"
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2, TECH_POWER = 2)

//TIER 2

/obj/item/fd/data/engineering/lvl2
	name = "old datamine disk (TIER 2 - ENGINEERING)"
	origin_tech = list(TECH_MATERIAL = 7, TECH_ENGINEERING = 5, TECH_POWER = 5, TECH_PHORON = 3)

//TIER 3

/obj/item/fd/data/engineering/lvl3
	name = "old datamine disk (TIER 3 - ENGINEERING)"
	origin_tech = list(TECH_MATERIAL = 10, TECH_ENGINEERING = 8, TECH_POWER = 8, TECH_PHORON = 5)

//TIER 4

/obj/item/fd/data/engineering/lvl4
	name = "old datamine disk (TIER 4 - ENGINEERING)"
	origin_tech = list(TECH_MATERIAL = 14, TECH_ENGINEERING = 12, TECH_POWER = 12, TECH_PHORON = 9)

///

/obj/item/fd/data/science
	name = "old datamine disk (TIER 1 - SCIENCE)"
	origin_tech = list(TECH_BLUESPACE = 2, TECH_DATA = 2, TECH_BIO = 2)

//TIER 2

/obj/item/fd/data/science/lvl2
	name = "old datamine disk (TIER 2 - SCIENCE)"
	origin_tech = list(TECH_BLUESPACE = 7, TECH_DATA = 5, TECH_BIO = 7)

//TIER 3

/obj/item/fd/data/science/lvl3
	name = "old datamine disk (TIER 3 - SCIENCE)"
	origin_tech = list(TECH_BLUESPACE = 10, TECH_DATA = 8, TECH_BIO = 10, TECH_ESOTERIC = 6)

//TIER 4

/obj/item/fd/data/science/lvl4
	name = "old datamine disk (TIER 4 - SCIENCE)"
	origin_tech = list(TECH_BLUESPACE = 14, TECH_DATA = 12, TECH_BIO = 14, TECH_ESOTERIC = 10)
