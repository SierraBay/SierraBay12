// Atmospherics Trading Station and Portable Canister definitions.

/obj/machinery/portable_atmospherics/canister/prefilled
	can_label = 0
	var/fill_gas

/obj/machinery/portable_atmospherics/canister/prefilled/Initialize(mapload)
	. = ..()
	if(fill_gas)
		if(!air_contents.temperature)
			air_contents.temperature = T20C
		if(!air_contents.volume)
			air_contents.volume = volume
		air_contents.adjust_gas(fill_gas, MolesForPressure())
		update_icon()

/obj/machinery/portable_atmospherics/canister/co
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[CO\]"
	icon_state = "black"
	canister_color = "black"
	fill_gas = GAS_CO

/obj/machinery/portable_atmospherics/canister/no2
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[NO2\]"
	icon_state = "redws"
	canister_color = "redws"
	fill_gas = GAS_NO2

/obj/machinery/portable_atmospherics/canister/no
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[NO\]"
	icon_state = "redws"
	canister_color = "redws"
	fill_gas = GAS_NO

/obj/machinery/portable_atmospherics/canister/methane
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Methane\]"
	icon_state = "purple"
	canister_color = "purple"
	fill_gas = GAS_METHANE

/obj/machinery/portable_atmospherics/canister/deuterium
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Deuterium\]"
	icon_state = "purple"
	canister_color = "purple"
	fill_gas = GAS_DEUTERIUM

/obj/machinery/portable_atmospherics/canister/tritium
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Tritium\]"
	icon_state = "purple"
	canister_color = "purple"
	fill_gas = GAS_TRITIUM

/obj/machinery/portable_atmospherics/canister/argon
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Argon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	fill_gas = GAS_ARGON

/obj/machinery/portable_atmospherics/canister/krypton
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Krypton\]"
	icon_state = "yellow"
	canister_color = "yellow"
	fill_gas = GAS_KRYPTON

/obj/machinery/portable_atmospherics/canister/xenon
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Xenon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	fill_gas = GAS_XENON

/obj/machinery/portable_atmospherics/canister/neon
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[Neon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	fill_gas = GAS_NEON

/obj/machinery/portable_atmospherics/canister/ammonia
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[NH3\]"
	icon_state = "lightyellow"
	canister_color = "lightyellow"
	fill_gas = GAS_AMMONIA

/obj/machinery/portable_atmospherics/canister/sulfurdioxide
	parent_type = /obj/machinery/portable_atmospherics/canister/prefilled
	name = "\improper Canister \[SO2\]"
	icon_state = "lightyellow"
	canister_color = "lightyellow"
	fill_gas = GAS_SULFUR


/datum/trading_station/atmospherics
	name_pool = list(
		"FTB \"Blue Lung\"" = "Free Trade Beacon \"Blue Lung\": atmospherics gear, tanks, canisters, and emergency response stock.",
		"FTB \"Zephyr\"" = "Free Trade Beacon \"Zephyr\": pure breathing gas supplies and pressurized canister distribution.",
		"FTB \"Vortex Tank\"" = "Free Trade Beacon \"Vortex Tank\": atmospheric pump manifolds and high-pressure canister exchange.",
		"FTB \"Aero Hub\"" = "Free Trade Beacon \"Aero Hub\": life support gas filtration and environmental emergency units."
	)
	uid = "atmospherics"
	icon_states = list("atmospherics")
	unlock_favor = 4000
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	thematic_cores = list("Oxyta", "Spacer", "Voidstrider", "Airlock Zero", "Cold Drift", "Vacuum Verge", "Blue Lung", "Zephyr", "Vortex", "Aero Wells")
	role_summary = "extravehicular life support, void suits, and gas replenishment"
	inventory = list(
		TRADE_CAT_GAS = list(
			/obj/machinery/portable_atmospherics/canister/oxygen = CUSTOM_GOODS_PRICE(1000),
			/obj/machinery/portable_atmospherics/canister/nitrogen = CUSTOM_GOODS_PRICE(800),
			/obj/machinery/portable_atmospherics/canister/carbon_dioxide = CUSTOM_GOODS_PRICE(800),
			/obj/machinery/portable_atmospherics/canister/phoron = CUSTOM_GOODS_PRICE(3500),
			/obj/machinery/portable_atmospherics/canister/sleeping_agent = CUSTOM_GOODS_PRICE(1600),
			/obj/machinery/portable_atmospherics/canister/helium = CUSTOM_GOODS_PRICE(1500),
			/obj/machinery/portable_atmospherics/canister/co = CUSTOM_GOODS_PRICE(1000),
			/obj/machinery/portable_atmospherics/canister/no2 = CUSTOM_GOODS_PRICE(1100),
			/obj/machinery/portable_atmospherics/canister/no = CUSTOM_GOODS_PRICE(1100),
			/obj/machinery/portable_atmospherics/canister/methane = CUSTOM_GOODS_PRICE(1400),
			/obj/machinery/portable_atmospherics/canister/deuterium = CUSTOM_GOODS_PRICE(2500),
			/obj/machinery/portable_atmospherics/canister/tritium = CUSTOM_GOODS_PRICE(4000),
			/obj/machinery/portable_atmospherics/canister/argon = CUSTOM_GOODS_PRICE(1200),
			/obj/machinery/portable_atmospherics/canister/krypton = CUSTOM_GOODS_PRICE(2000),
			/obj/machinery/portable_atmospherics/canister/xenon = CUSTOM_GOODS_PRICE(2200),
			/obj/machinery/portable_atmospherics/canister/neon = CUSTOM_GOODS_PRICE(1200),
			/obj/machinery/portable_atmospherics/canister/ammonia = CUSTOM_GOODS_PRICE(1000),
			/obj/machinery/portable_atmospherics/canister/sulfurdioxide = CUSTOM_GOODS_PRICE(1000)
		),
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/tank/oxygen = GOODS_DEFAULT,
			/obj/item/tank/air = GOODS_DEFAULT,
			/obj/item/tank/oxygen_emergency = GOODS_DEFAULT,
			/obj/item/device/scanner/gas = GOODS_DEFAULT,
			/obj/item/rpd = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/powered/pump = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/powered/scrubber = GOODS_DEFAULT,
			/obj/structure/closet/firecloset = GOODS_DEFAULT,
			/obj/item/clothing/suit/fire = GOODS_DEFAULT,
			/obj/item/clothing/mask/gas = GOODS_DEFAULT
		)
	)
