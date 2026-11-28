/obj/machinery/power/apc/hand
	req_access = list(access_away_hand)

/obj/machinery/power/apc/hand/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/hand/critical
	is_critical = 1

/obj/machinery/power/apc/hand/critical/high
	is_critical = 1
	cell_type = /obj/item/cell/high

/obj/machinery/power/smes/buildable/preset/hand
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_capacity = 1,
		/obj/item/stock_parts/smes_coil = 1
	)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

	///////////
	//CLOSETS//
	///////////

/obj/structure/closet/wardrobe/hand
	name = "PMC attire closet"
	closet_appearance = /singleton/closet_appearance/tactical


/obj/structure/closet/wardrobe/hand/saare
	name = "SAARE attire closet"
	closet_appearance = /singleton/closet_appearance/tactical

/obj/structure/closet/wardrobe/hand/saare/WillContain()
	return list(
	/obj/item/clothing/suit/armor/pcarrier/green/heavy_saare = 6,
	/obj/item/clothing/under/rank/security/saarecombat = 5,
	/obj/item/clothing/under/saare,
	/obj/item/clothing/head/beret/sec/corporate/saare = 6,
	/obj/item/clothing/accessory/helmet_cover/saare = 6,
	/obj/item/clothing/shoes/jackboots = 6,
	)

/obj/structure/closet/wardrobe/hand/pcrc
	name = "PCRC attire closet"
	closet_appearance = /singleton/closet_appearance/tactical

/obj/structure/closet/wardrobe/hand/pcrc/WillContain()
	return list(
	/obj/item/clothing/under/pcrc  = 5,
	/obj/item/clothing/under/pcrcsuit,
	/obj/item/clothing/head/beret/pcrc = 6,
	/obj/item/clothing/accessory/helmet_cover/pcrc = 6,
	/obj/item/clothing/accessory/armor_tag/pcrc = 6,
	/obj/item/clothing/shoes/jackboots = 6,
	)

/obj/structure/closet/wardrobe/hand/zpci
	name = "ZPCI attire closet"
	closet_appearance = /singleton/closet_appearance/tactical

/obj/structure/closet/wardrobe/hand/zpci/WillContain()
	return list(
	/obj/item/clothing/under/zpci_uniform  = 6,
	/obj/item/clothing/head/beret/sec/corporate/zpci = 6,
	/obj/item/clothing/accessory/armor_tag/zpci = 6,
	/obj/item/clothing/shoes/jackboots = 6,
	)
