/singleton/hierarchy/supply_pack/atmospherics/canister_chlorine
	name = "Gas - Chlorine canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/chlorine)
	cost = 25
	containername = "chlorine canister crate"
	containertype = /obj/structure/closet/crate/secure/large

/singleton/hierarchy/supply_pack/atmospherics/canister_helium
	name = "Gas - Helium canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/helium)
	cost = 20
	containername = "helium canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_methylbromide
	name = "Gas - Methyl bromide gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/methyl_bromide)
	cost = 35
	containername = "methyl bromide canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_co
	name = "Gas - Carbon oxide gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/co)
	cost = 10
	containername = "carbon oxide canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_no2
	name = "Gas - Nitrogen dioxide gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/no2)
	cost = 20
	containername = "nitrogen dioxide canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_no
	name = "Gas - Nitric oxide gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/no)
	cost = 20
	containername = "nitric oxide canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_methane
	name = "Gas - Methane canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/methane)
	cost = 30
	containername = "methane canister crate"
	containertype = /obj/structure/closet/crate/secure/large

/singleton/hierarchy/supply_pack/atmospherics/canister_deuterium
	name = "Gas - Deuterium canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/deuterium)
	cost = 45
	containername = "deuterium canister crate"
	containertype = /obj/structure/closet/crate/secure/large

/singleton/hierarchy/supply_pack/atmospherics/canister_tritium
	name = "Gas - Tritium canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/tritium)
	cost = 45
	containername = "tritium canister crate"
	containertype = /obj/structure/closet/crate/secure/large

/singleton/hierarchy/supply_pack/atmospherics/canister_argon
	name = "Gas - Argon canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/argon)
	cost = 25
	containername = "argon canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_krypton
	name = "Gas - Krypton canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/krypton)
	cost = 25
	containername = "krypton canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_xenon
	name = "Gas - Xenon canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/xenon)
	cost = 25
	containername = "xenon canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_neon
	name = "Gas - Neon canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/neon)
	cost = 25
	containername = "neon canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_ammonia
	name = "Gas - Ammonia canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/ammonia)
	cost = 20
	containername = "ammonia canister crate"
	containertype = /obj/structure/largecrate

/singleton/hierarchy/supply_pack/atmospherics/canister_sulfurdioxide
	name = "Gas - Sulfur dioxide gas canister"
	contains = list(/obj/machinery/portable_atmospherics/canister/sulfurdioxide)
	cost = 30
	containername = "sulfur dioxide canister crate"
	containertype = /obj/structure/closet/crate/secure/large

/obj/machinery/portable_atmospherics/canister/co
	name = "\improper Canister \[CO\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/co/New()
	..()
	src.air_contents.adjust_gas(GAS_CO, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/no2
	name = "\improper Canister \[NO2\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/no2/New()
	..()
	src.air_contents.adjust_gas(GAS_NO2, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/no
	name = "\improper Canister \[NO\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/no/New()
	..()
	src.air_contents.adjust_gas(GAS_NO, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/methane
	name = "\improper Canister \[Methane\]"
	icon_state = "purple"
	canister_color = "purple"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/methane/New()
	..()
	src.air_contents.adjust_gas(GAS_METHANE, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/deuterium
	name = "\improper Canister \[Deuterium\]"
	icon_state = "purple"
	canister_color = "purple"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/deuterium/New()
	..()
	src.air_contents.adjust_gas(GAS_DEUTERIUM, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/tritium
	name = "\improper Canister \[Tritium\]"
	icon_state = "purple"
	canister_color = "purple"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/tritium/New()
	..()
	src.air_contents.adjust_gas(GAS_TRITIUM, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/argon
	name = "\improper Canister \[Argon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/argon/New()
	..()
	src.air_contents.adjust_gas(GAS_ARGON, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/krypton
	name = "\improper Canister \[Krypton\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/krypton/New()
	..()
	src.air_contents.adjust_gas(GAS_KRYPTON, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/xenon
	name = "\improper Canister \[Xenon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/xenon/New()
	..()
	src.air_contents.adjust_gas(GAS_XENON, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/neon
	name = "\improper Canister \[Neon\]"
	icon_state = "yellow"
	canister_color = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/neon/New()
	..()
	src.air_contents.adjust_gas(GAS_NEON, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/ammonia
	name = "\improper Canister \[NH3\]"
	icon_state = "lightyellow"
	canister_color = "lightyellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/ammonia/New()
	..()
	src.air_contents.adjust_gas(GAS_AMMONIA, MolesForPressure())
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sulfurdioxide
	name = "\improper Canister \[SO2\]"
	icon_state = "lightyellow"
	canister_color = "lightyellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/sulfurdioxide/New()
	..()
	src.air_contents.adjust_gas(GAS_SULFUR, MolesForPressure())
	src.update_icon()
	return 1
