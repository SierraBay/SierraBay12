// TRADE: scanners are available to cargo technicians without changing other maps.
/obj/structure/closet/secure_closet/decktech/Initialize(mapload)
	. = ..()
	if(GLOB.using_map.path == "sierra")
		new /obj/item/device/scanner/price(src)
