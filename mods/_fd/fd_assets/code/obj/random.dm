/obj/random/cash/can_spawn_nothing
	spawn_nothing_percentage = 50

/obj/random/intel_console //Large objects to block things off in maintenance
	name = "intel terminal"
	desc = "This is a terminal spawn."
	icon = 'mods/_fd/fd_assets/icons/overmap_eris.dmi'
	icon_state = "field"
	spawn_nothing_percentage = 50

/obj/random/intel_console/spawn_choices()
	return list(/obj/structure/fd/intel_console)

/obj/random/relic
	name = "random relique"
	desc = "This is a random relique spawn."
	icon = 'mods/_fd/fd_assets/icons/overmap_eris.dmi'
	icon_state = "relic"
	spawn_nothing_percentage = 80

/obj/random/relic/spawn_choices()
	return list(/obj/item/fd/ancient_items/psionic,
				/obj/item/fd/ancient_items/zippo,
				/obj/item/fd/ancient_items/corrupted_radio,
				/obj/item/fd/ancient_items/energy_container,
				/obj/item/fd/ancient_items/teddy_bear,
				/obj/item/fd/ancient_items/gold_necklace,
				/obj/item/fd/ancient_items/jap_neko,
				/obj/item/fd/ancient_items/starmap,
				/obj/item/fd/ancient_items/phone,
				/obj/item/fd/ancient_items/skull,
				/obj/item/fd/ancient_items/emerald,
				/obj/item/fd/ancient_items/corrupted_crowbar,
				/obj/item/fd/ancient_items/lighting_staff,
				/obj/item/fd/ancient_items/eye_of_the_maw
				)

/obj/random/ship_ammo_autocannon
	name = "random autocannon ammunition"
	desc = "This is a random ship ammunition."
	icon = 'icons/obj/machines/disperser.dmi'
	icon_state = "ammocrate_autocannon_he"
	spawn_nothing_percentage = 40

/obj/random/ship_ammo_autocannon/spawn_choices()
	return list(/obj/item/ammo_magazine/ammobox/autocannon/anti_hull,
				/obj/item/ammo_magazine/ammobox/autocannon/aphe,
				/obj/item/ammo_magazine/ammobox/autocannon/armour_piercing,
				/obj/item/ammo_magazine/ammobox/autocannon/high_explosive)

/obj/random/ship_ammo_ofd
	name = "random OFD ammunition"
	desc = "This is a random OFD ammunition."
	icon = 'icons/obj/munitions.dmi'
	icon_state = "slug"
	spawn_nothing_percentage = 40

/obj/random/ship_ammo_ofd/spawn_choices()
	return list(/obj/structure/ship_munition/disperser_charge/mining,
				/obj/structure/ship_munition/disperser_charge/emp,
				/obj/structure/ship_munition/disperser_charge/explosive,
				/obj/structure/ship_munition/disperser_charge/fire)

//				W			There are too much			==============
//					O					CIRCUITBOARDS	==============
//						W			INCREDIBLE			==============

/obj/random/circuitboard
	name = "random circuitboard"
	desc = "This is a random circuitboard."

/obj/random/circuitboard/spawn_choices()
	return list(/obj/random/circuitboard/ship_guns,
				/obj/random/circuitboard/research,
				/obj/random/circuitboard/cooking,
				/obj/random/circuitboard/mining,
				/obj/random/circuitboard/shuttle,
				/obj/random/circuitboard/telecomms,
				/obj/random/circuitboard/engineering,
				/obj/random/circuitboard/medical,
				/obj/random/circuitboard/other)

/obj/random/circuitboard/ship_guns
	name = "random ship guns circuitboard"
	icon_state = "tech-red"

/obj/random/circuitboard/ship_guns/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/autocannon,
				/obj/item/stock_parts/circuitboard/autocannon_back,
				/obj/item/stock_parts/circuitboard/autocannon_middle,
				/obj/item/stock_parts/circuitboard/autocannon_front,
				/obj/item/stock_parts/circuitboard/beamcannon,
				/obj/item/stock_parts/circuitboard/beamcannon_back,
				/obj/item/stock_parts/circuitboard/beamcannon_middle,
				/obj/item/stock_parts/circuitboard/beamcannon_front,
				/obj/item/stock_parts/circuitboard/disperser,
				/obj/item/stock_parts/circuitboard/disperserback,
				/obj/item/stock_parts/circuitboard/disperserfront,
				/obj/item/stock_parts/circuitboard/dispersermiddle,
				/obj/item/stock_parts/circuitboard/disruptor,
				/obj/item/stock_parts/circuitboard/disruptor_back,
				/obj/item/stock_parts/circuitboard/disruptor_front,
				/obj/item/stock_parts/circuitboard/disruptor_middle,
				/obj/item/stock_parts/circuitboard/harpoon,
				/obj/item/stock_parts/circuitboard/harpoonfront,
				/obj/item/stock_parts/circuitboard/harpoonmiddle,
				/obj/item/stock_parts/circuitboard/harpoonback,
				/obj/item/stock_parts/circuitboard/heavymg,
				/obj/item/stock_parts/circuitboard/heavymg_back,
				/obj/item/stock_parts/circuitboard/heavymg_front,
				/obj/item/stock_parts/circuitboard/heavymg_middle,
				/obj/item/stock_parts/circuitboard/minigun,
				/obj/item/stock_parts/circuitboard/minigun_back,
				/obj/item/stock_parts/circuitboard/minigun_front,
				/obj/item/stock_parts/circuitboard/minigun_middle,
				/obj/item/stock_parts/circuitboard/missiles)

/obj/random/circuitboard/research
	name = "random RnD circuitboard"
	icon_state = "tech-blue"

/obj/random/circuitboard/research/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/rdconsole,
				/obj/item/stock_parts/circuitboard/protolathe,
				/obj/item/stock_parts/circuitboard/mechfab,
				/obj/item/stock_parts/circuitboard/mech_recharger,
				/obj/item/stock_parts/circuitboard/kinetic_harvester,
				/obj/item/stock_parts/circuitboard/circuit_imprinter,
				/obj/item/stock_parts/circuitboard/autolathe,
				/obj/item/stock_parts/circuitboard/destructive_analyzer)

/obj/random/circuitboard/cooking
	name = "random cooking circuitboard"
	icon_state = "tech-grey"

/obj/random/circuitboard/cooking/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/biogenerator,
				/obj/item/stock_parts/circuitboard/bioprinter,
				/obj/item/stock_parts/circuitboard/cooker,
				/obj/item/stock_parts/circuitboard/gibber,
				/obj/item/stock_parts/circuitboard/honey,
				/obj/item/stock_parts/circuitboard/juicer,
				/obj/item/stock_parts/circuitboard/microwave,
				/obj/item/stock_parts/circuitboard/reagentgrinder,
				/obj/item/stock_parts/circuitboard/replicator,
				/obj/item/stock_parts/circuitboard/vending,
				/obj/item/stock_parts/circuitboard/tray)

/obj/random/circuitboard/mining
	name = "random mining circuitboard"
	icon_state = "tech-orange"

/obj/random/circuitboard/mining/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/miningdrillbrace,
				/obj/item/stock_parts/circuitboard/miningdrill,
				/obj/item/stock_parts/circuitboard/mining_unloader,
				/obj/item/stock_parts/circuitboard/mining_stacker,
				/obj/item/stock_parts/circuitboard/mining_processor,
				/obj/item/stock_parts/circuitboard/mineral_processing)

/obj/random/circuitboard/shuttle
	name = "random shuttle circuitboard"
	icon_state = "tech-black"

/obj/random/circuitboard/shuttle/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/engine,
				/obj/item/stock_parts/circuitboard/engine/ion,
				/obj/item/stock_parts/circuitboard/helm,
				/obj/item/stock_parts/circuitboard/nav,
				/obj/item/stock_parts/circuitboard/sensors,
				/obj/item/stock_parts/circuitboard/shield_diffuser,
				/obj/item/stock_parts/circuitboard/shield_generator,
				/obj/item/stock_parts/circuitboard/shuttle_console/explore,
				/obj/item/stock_parts/circuitboard/unary_atmos/engine,
				/obj/item/stock_parts/circuitboard/pointdefense,
				/obj/item/stock_parts/circuitboard/pointdefense_control)

/obj/random/circuitboard/telecomms
	name = "random telecomms circuitboard"
	icon_state = "ai-blue"

/obj/random/circuitboard/telecomms/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/telecomms/server,
				/obj/item/stock_parts/circuitboard/telecomms/broadcaster,
				/obj/item/stock_parts/circuitboard/telecomms/bus,
				/obj/item/stock_parts/circuitboard/telecomms/hub,
				/obj/item/stock_parts/circuitboard/telecomms/processor,
				/obj/item/stock_parts/circuitboard/telecomms/receiver,
				/obj/item/stock_parts/circuitboard/radio_beacon,
				/obj/item/stock_parts/circuitboard/message_monitor,
				/obj/item/stock_parts/circuitboard/comm_server,
				/obj/item/stock_parts/circuitboard/comm_monitor)

/obj/random/circuitboard/medical
	name = "random medical circuitboard"
	icon_state = "tech-blue"

/obj/random/circuitboard/medical/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/sleeper,
				/obj/item/stock_parts/circuitboard/cryo_cell,
				/obj/item/stock_parts/circuitboard/body_scanconsole,
				/obj/item/stock_parts/circuitboard/bodyscanner,
				/obj/item/stock_parts/circuitboard/crew,
				/obj/item/stock_parts/circuitboard/optable,
				/obj/item/stock_parts/circuitboard/roboprinter,
				/obj/item/stock_parts/circuitboard/vitals_monitor)

/obj/random/circuitboard/engineering
	name = "random engineering circuitboard"
	icon_state = "tech-blue"

/obj/random/circuitboard/engineering/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/aicore,
				/obj/item/stock_parts/circuitboard/air_management,
				/obj/item/stock_parts/circuitboard/area_atmos,
				/obj/item/stock_parts/circuitboard/atmos_alert,
				/obj/item/stock_parts/circuitboard/atmoscontrol,
				/obj/item/stock_parts/circuitboard/autolathe,
				/obj/item/stock_parts/circuitboard/floodlight,
				/obj/item/stock_parts/circuitboard/fusion/core_control,
				/obj/item/stock_parts/circuitboard/fusion_core,
				/obj/item/stock_parts/circuitboard/fusion_fuel_compressor,
				/obj/item/stock_parts/circuitboard/fusion_fuel_control,
				/obj/item/stock_parts/circuitboard/fusion_injector,
				/obj/item/stock_parts/circuitboard/guestpass,
				/obj/item/stock_parts/circuitboard/gyrotron,
				/obj/item/stock_parts/circuitboard/gyrotron_control,
				/obj/item/stock_parts/circuitboard/kinetic_harvester,
				/obj/item/stock_parts/circuitboard/mech_recharger,
				/obj/item/stock_parts/circuitboard/oxyregenerator,
				/obj/item/stock_parts/circuitboard/pacman,
				/obj/item/stock_parts/circuitboard/pacman/mrs,
				/obj/item/stock_parts/circuitboard/pacman/super,
				/obj/item/stock_parts/circuitboard/pacman/super/potato/reactor,
				/obj/item/stock_parts/circuitboard/pipedispensor,
				/obj/item/stock_parts/circuitboard/pipedispensor/disposal,
				/obj/item/stock_parts/circuitboard/portable_scrubber,
				/obj/item/stock_parts/circuitboard/portable_scrubber/pump,
				/obj/item/stock_parts/circuitboard/powermonitor,
				/obj/item/stock_parts/circuitboard/rcon_console,
				/obj/item/stock_parts/circuitboard/recharge_station,
				/obj/item/stock_parts/circuitboard/shield_diffuser,
				/obj/item/stock_parts/circuitboard/smes,
				/obj/item/stock_parts/circuitboard/batteryrack,
				/obj/item/stock_parts/circuitboard/solar_control,
				/obj/item/stock_parts/circuitboard/stationalert,
				/obj/item/stock_parts/circuitboard/sublimator,
				/obj/item/stock_parts/circuitboard/suspension_gen,
				/obj/item/stock_parts/circuitboard/tele_beacon,
				/obj/item/stock_parts/circuitboard/teleporter,
				/obj/item/stock_parts/circuitboard/turbine_control,
				/obj/item/stock_parts/circuitboard/unary_atmos/cooler,
				/obj/item/stock_parts/circuitboard/unary_atmos/heater,
				)

/obj/random/circuitboard/other
	name = "random other circuitboard"
	icon_state = "tech-grey-low"

/obj/random/circuitboard/other/spawn_choices()
	return list(/obj/item/stock_parts/circuitboard/arcade,
				/obj/item/stock_parts/circuitboard/washer,
				/obj/item/stock_parts/circuitboard/vending,
				/obj/item/stock_parts/circuitboard/tray,
				/obj/item/stock_parts/circuitboard/prisoner,
				/obj/item/stock_parts/circuitboard/drone_control,
				)

//������ ������� ��� ��������������(������)

/obj/random/flora
	name = "random flora spawn"
	desc = "This is a random flora spawner."
	icon_state = "trees"
	spawn_nothing_percentage = 50

/obj/random/flora/spawn_choices()
	return list(/obj/structure/flora/tree/jungle,
				/obj/structure/flora/tree/jungle/small,
				/obj/structure/flora/ausbushes/brflowers,
				/obj/structure/flora/ausbushes/fullgrass,
				/obj/structure/flora/ausbushes/grassybush,
				/obj/structure/flora/ausbushes/lavendergrass,
				/obj/structure/flora/ausbushes/ppflowers,
				/obj/structure/flora/ausbushes/sparsegrass,
				/obj/structure/flora/ausbushes/ywflowers,
				/obj/structure/flora/ausbushes/genericbush,
				/obj/structure/flora/ausbushes/sunnybush,
				/obj/structure/flora/tropic/rock,
				/obj/structure/flora/jungle/bush)

/obj/random/flora/snow
	name = "random flora spawn"
	desc = "This is a random flora spawner."
	icon_state = "trees"
	spawn_nothing_percentage = 60

/obj/random/flora/snow/spawn_choices()
	return list(/obj/structure/flora/tree/pine,
				/obj/structure/flora/tree/dead,
				/obj/structure/flora/ausbushes/brflowers,
				/obj/structure/flora/ausbushes/pointybush,
				/obj/structure/flora/ausbushes/grassybush,
				/obj/structure/flora/ausbushes/ppflowers,
				/obj/item/reagent_containers/food/snacks/grown/berries,
				/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
				/obj/structure/flora/grass/brown,
				/obj/structure/flora/grass/green,
				/obj/structure/flora/grass/both,
				/obj/structure/flora/bush)
