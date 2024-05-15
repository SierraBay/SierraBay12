/obj/paint/red/dark
	color = "#420d0d"

/obj/machinery/door/airlock/multi_tile/ares
	door_color = COLOR_DARK_GUNMETAL
	stripe_color = COLOR_SILVER

/obj/machinery/door/airlock/ares
	door_color = COLOR_DARK_GUNMETAL
	stripe_color = COLOR_SILVER

/obj/machinery/door/airlock/glass/ares
	door_color = COLOR_DARK_GUNMETAL
	stripe_color = COLOR_SILVER

/obj/machinery/suit_storage_unit/mining/ares
	suit = /obj/item/clothing/suit/space/void/mining/rockanddrill
	helmet = /obj/item/clothing/head/helmet/space/void/mining/rockanddrill
	mask = /obj/item/clothing/mask/breath
	req_access = list(access_ares)

/obj/item/clothing/head/helmet/space/void/mining/rockanddrill
	name = "mining voidsuit helmet"
	desc = "A scuffed voidsuit helmet with yellow visor and internal communication system."
	icon_state = "rig0-rockanddrill"
	item_state = "onmob-rockanddrill"
	icon_override = 'mods/_fd/_maps/ares/icons/mining_helmet.dmi'
	icon = 'mods/_fd/_maps/ares/icons/mining_helmet.dmi'
	item_state_slots = list(
		slot_l_hand_str = "mining_helm",
		slot_r_hand_str = "mining_helm",
		)
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_MINOR
		)
	light_overlay = "helmet_light_dual_alt"
	max_pressure_protection = ENG_VOIDSUIT_MAX_PRESSURE

/obj/item/clothing/suit/space/void/mining/rockanddrill
	name = "lightweight mining voidsuit"
	desc = "Simple protective gear to work in the void."
	icon_state = "rig-rockanddrill"
	item_state = "onmob-rockanddrill"
	icon_override = 'mods/_fd/_maps/ares/icons/mining_suit.dmi'
	icon = 'mods/_fd/_maps/ares/icons/mining_suit.dmi'
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_MINOR
		)
	max_pressure_protection = ENG_VOIDSUIT_MAX_PRESSURE
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/stack/flag,/obj/item/device/suit_cooling_unit,/obj/item/storage/ore,/obj/item/device/t_scanner,/obj/item/pickaxe, /obj/item/rcd,/obj/item/rpd)

/obj/item/clothing/suit/space/void/mining/rockanddrill/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/mining/rockanddrill

/obj/structure/closet/secure_closet/miner/ares
	name = "miner's equipment"
	closet_appearance = /singleton/closet_appearance/secure_closet/mining
	req_access = list(access_ares)

/obj/structure/closet/secure_closet/miner/ares/WillContain()
	return list(
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/mask/gas/half,
		/obj/item/clothing/gloves/thick,
		/obj/item/clothing/shoes/workboots,
		/obj/item/device/flashlight/lantern,
		/obj/item/shovel,
		/obj/item/clothing/under/grayson,
		/obj/item/device/scanner/gas,
		/obj/item/pickaxe/jackhammer,
		/obj/item/pickaxe/drill,
		/obj/item/crowbar,
		/obj/item/wrench,
		/obj/item/storage/ore,
		/obj/item/device/scanner/mining,
		/obj/item/device/gps,
		/obj/item/device/radio,
		/obj/item/clothing/glasses/material,
		/obj/item/clothing/glasses/meson,
		new /datum/atom_creator/weighted(list(/obj/item/storage/backpack/industrial, /obj/item/storage/backpack/satchel/eng, /obj/item/storage/backpack/messenger/engi)),
		/obj/item/storage/backpack/dufflebag/eng
	)

/obj/structure/sign/gml
	name = "\improper GMLtd. sign"
	desc = "A sign which signifies who this vessel belongs to."
	icon = 'mods/_fd/_maps/ares/icons/gml-decals.dmi'
	icon_state = "gml"

/obj/machinery/vending/cigarette/noprice
	prices = null

/singleton/stock_part_preset/radio/receiver/vent_pump/ares
	frequency = 1997

/singleton/stock_part_preset/radio/event_transmitter/vent_pump/ares
	frequency = 1997

/obj/machinery/atmospherics/unary/vent_pump/high_volume/ares
	stock_part_presets = list(
		/singleton/stock_part_preset/radio/receiver/vent_pump/ares = 1,
		/singleton/stock_part_preset/radio/event_transmitter/vent_pump/ares = 1
	)

/singleton/stock_part_preset/radio/receiver/vent_scrubber/ares
	frequency = 1997

/singleton/stock_part_preset/radio/event_transmitter/vent_scrubber/ares
	frequency = 1997

/obj/machinery/atmospherics/unary/vent_scrubber/ares
	stock_part_presets = list(
		/singleton/stock_part_preset/radio/receiver/vent_scrubber/ares = 1,
		/singleton/stock_part_preset/radio/event_transmitter/vent_scrubber/ares = 1
	)

// Map template data.
/datum/map_template/ruin/away_site/ares
	name = "Ares"
	id = "awaysite_ares"
	description = "Active Grayson Manufactories Ltd. mining vessel."
	prefix = "mods/_fd/_maps/ares/maps/"
	suffixes = list("ares.dmm")
	spawn_cost = 3
	area_usage_test_exempted_root_areas = /area/ship/ares
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/ares)

/obj/overmap/visitable/sector/ares
	name = "Bluespace Residue"
	desc = "/ERROR/."
	icon_state = "event"
	hide_from_reports = TRUE
	sector_flags = OVERMAP_SECTOR_IN_SPACE | OVERMAP_SECTOR_UNTARGETABLE

/obj/submap_landmark/joinable_submap/ares
	name = "GM Ltd. mining vessel"
	archetype = /singleton/submap_archetype/ares
