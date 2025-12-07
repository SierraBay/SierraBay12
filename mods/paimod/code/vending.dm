/obj/machinery/vending/paimod
	name = "IntelligenceTech"
	desc = "A pai modification vendor. Inside of showcase you see many of circuits, devices and etc."
	icon = 'packs/infinity/icons/obj/vending.dmi'
	density = TRUE
	icon_state = "pai"
	products = list(/obj/item/device/paicard = 2,
					/obj/item/paimod/special/advanced_holo	=	3,
					/obj/item/paimod/holoskins/paiwoman		=	3,
					/obj/item/paimod/memory/standard			=	5,
					/obj/item/paimod/memory/advanced			=	3,
					/obj/item/paimod/memory/lambda			=	1
					)
	prices = list(/obj/item/device/paicard = 500,
					/obj/item/paimod/special/advanced_holo		=	150,
					/obj/item/paimod/holoskins/paiwoman		=	50,
					/obj/item/paimod/memory/standard			=	120,
					/obj/item/paimod/memory/advanced			=	260,
					/obj/item/paimod/memory/lambda			=	500,
					/obj/item/paimod/special/hack_camo		=	450,
					/obj/item/paimod/hack_speed/standard		=	250,
					/obj/item/paimod/hack_speed/advanced		=	500
					)
	contraband = list(/obj/item/paimod/special/hack_camo		=	2,
					/obj/item/paimod/hack_speed/standard		=	2,
					/obj/item/paimod/hack_speed/advanced		=	1)
