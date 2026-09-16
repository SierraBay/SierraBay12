// Atmospherics Trading Station and Portable Canister definitions.

/obj/machinery/portable_atmospherics/canister/co
	name = "\improper Canister \[CO\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/co/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_CO, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/no2
	name = "\improper Canister \[NO2\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/no2/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_NO2, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/no
	name = "\improper Canister \[NO\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/no/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_NO, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/methane
	name = "\improper Canister \[Methane\]"
	icon_state = "purple"
	canister_color = "purple"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/methane/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_METHANE, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/deuterium
	name = "\improper Canister \[Deuterium\]"
	icon_state = "purple"
	canister_color = "purple"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/deuterium/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_DEUTERIUM, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/tritium
	name = "\improper Canister \[Tritium\]"
	icon_state = "purple"
	canister_color = "purple"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/tritium/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_TRITIUM, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/argon
	name = "\improper Canister \[Argon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/argon/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_ARGON, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/krypton
	name = "\improper Canister \[Krypton\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/krypton/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_KRYPTON, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/xenon
	name = "\improper Canister \[Xenon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/xenon/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_XENON, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/neon
	name = "\improper Canister \[Neon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/neon/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_NEON, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/ammonia
	name = "\improper Canister \[NH3\]"
	icon_state = "lightyellow"
	canister_color = "lightyellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/ammonia/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_AMMONIA, MolesForPressure())
	update_icon()

/obj/machinery/portable_atmospherics/canister/sulfurdioxide
	name = "\improper Canister \[SO2\]"
	icon_state = "lightyellow"
	canister_color = "lightyellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/sulfurdioxide/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(GAS_SULFUR, MolesForPressure())
	update_icon()

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
	inventory = list(
		TRADE_CAT_GAS = list(
			/obj/machinery/portable_atmospherics/canister/oxygen = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/nitrogen = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/carbon_dioxide = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/phoron = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/sleeping_agent = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/helium = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/co = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/no2 = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/no = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/methane = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/deuterium = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/tritium = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/argon = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/krypton = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/xenon = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/neon = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/ammonia = GOODS_DEFAULT,
			/obj/machinery/portable_atmospherics/canister/sulfurdioxide = GOODS_DEFAULT
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
