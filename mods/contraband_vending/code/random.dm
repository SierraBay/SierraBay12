/obj/random/vendor/contraband

/obj/random/vendor/contraband/spawn_choices()
	return list(/obj/machinery/vending/antag/contraband,
				/obj/machinery/vending/boozeomat/contraband,
				/obj/machinery/vending/engivend/contraband,
				/obj/machinery/vending/phoronresearch/contraband,
				/obj/machinery/vending/tool/contraband
				)

/obj/random/vendor/contraband/maintenance

/obj/random/vendor/contraband/maintenance/spawn_choices()
	return list(/obj/random/vendor = 5,
				/obj/random/vendor/contraband = 1)
