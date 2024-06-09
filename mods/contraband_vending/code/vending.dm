/obj/machinery/vending/antag/contraband
	product_ads = {"\
		Only the finest!;\
		Have some tools.;\
		The most robust equipment.;\
		The finest gear in space!\
	"}
	products = list(
			/obj/item/device/assembly/prox_sensor = 5,
			/obj/item/device/assembly/signaler = 4,
			/obj/item/device/assembly/infra = 4,
			/obj/item/handcuffs = 8,
			/obj/item/device/flash = 4,
			/obj/item/clothing/glasses/sunglasses = 4
		)
	prices = list(
			/obj/item/device/assembly/prox_sensor = 400,
			/obj/item/device/assembly/signaler = 200,
			/obj/item/device/assembly/infra = 200,
			/obj/item/handcuffs = 200,
			/obj/item/device/flash = 400,
			/obj/item/clothing/glasses/sunglasses = 600
	)

/obj/machinery/vending/boozeomat/contraband
	name = "Old Booze-O-Mat"
	desc = "A refrigerated vending unit for alcoholic beverages and alcoholic beverage accessories."
	icon_state = "fridge_dark"
	icon_deny = "fridge_dark-deny"
	base_type = /obj/machinery/vending/boozeomat
	req_access = list()
	product_ads = {"
		Drink up!;\
		Booze is good for you!;\
		Alcohol is humanity's best friend.;\
		Quite delighted to serve you!;\
		Care for a nice, cold beer?;\
		Nothing cures you like booze!;\
		Have a sip!;\
		Have a drink!;\
		Have a beer!;\
		Beer is good for you!;\
		Only the finest alcohol!;\
		Best quality booze since 2053!;\
		Award-winning wine!;\
		Maximum alcohol!;\
		Man loves beer.;\
		A toast for progress!\
	"}
	product_slogans = {"\
		Drink away the pain of living under SolGov!;\
		Vodka is the only acceptable drink!;\
		Is this the best you can serve, bartender? This swill?!;\
		These drinks are as tasteless as Sol's people!;\
		Who are you kidding? You knew you were about to drink piss the second you stepped in here.;\
		Drinking on the job is socially acceptable for executives, why not for you?\
	"}
	products = list(
		/obj/item/reagent_containers/food/drinks/glass2/square = 5,
		/obj/item/reagent_containers/food/drinks/flask/barflask = 3,
		/obj/item/reagent_containers/food/drinks/flask/vacuumflask = 3,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe = 2,
		/obj/item/reagent_containers/food/drinks/bottle/baijiu = 2,
		/obj/item/reagent_containers/food/drinks/bottle/blackstrap = 2,
		/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = 2,
		/obj/item/reagent_containers/food/drinks/bottle/cachaca = 2,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 1,
		/obj/item/reagent_containers/food/drinks/bottle/cognac = 2,
		/obj/item/reagent_containers/food/drinks/bottle/gin = 2,
		/obj/item/reagent_containers/food/drinks/bottle/herbal = 2,
		/obj/item/reagent_containers/food/drinks/bottle/jagermeister = 2,
		/obj/item/reagent_containers/food/drinks/bottle/kahlua = 2,
		/obj/item/reagent_containers/food/drinks/bottle/melonliquor = 2,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
		/obj/item/reagent_containers/food/drinks/bottle/prosecco = 2,
		/obj/item/reagent_containers/food/drinks/bottle/rakia = 2,
		/obj/item/reagent_containers/food/drinks/bottle/rum = 2,
		/obj/item/reagent_containers/food/drinks/bottle/sake = 2,
		/obj/item/reagent_containers/food/drinks/bottle/soju = 2,
		/obj/item/reagent_containers/food/drinks/bottle/tequilla = 2,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 2,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth = 2,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 2,
		/obj/item/reagent_containers/food/drinks/bottle/llanbrydewhiskey = 1,
		/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey = 1,
		/obj/item/reagent_containers/food/drinks/bottle/wine = 2,
		/obj/item/reagent_containers/food/drinks/bottle/small/beer = 10,
		/obj/item/reagent_containers/food/drinks/bottle/small/alcoholfreebeer = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/ale = 10,
		/obj/item/reagent_containers/food/drinks/bottle/small/hellshenpa = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/lager = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/gingerbeer = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/dandelionburdock = 5,
		/obj/item/reagent_containers/food/drinks/cans/rootbeer = 10,
		/obj/item/reagent_containers/food/drinks/cans/speer = 5,
		/obj/item/reagent_containers/food/drinks/cans/ale = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/cola = 10,
		/obj/item/reagent_containers/food/drinks/bottle/small/space_up = 10,
		/obj/item/reagent_containers/food/drinks/bottle/small/space_mountain_wind = 10,
		/obj/item/reagent_containers/food/drinks/cans/cola_diet = 5,
		/obj/item/reagent_containers/food/drinks/cans/ionbru = 3,
		/obj/item/reagent_containers/food/drinks/cans/beastenergy = 2,
		/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 2,
		/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 2,
		/obj/item/reagent_containers/food/drinks/bottle/limejuice = 2,
		/obj/item/reagent_containers/food/drinks/bottle/lemonjuice = 2,
		/obj/item/reagent_containers/food/drinks/bottle/unathijuice = 2,
		/obj/item/reagent_containers/food/drinks/bottle/maplesyrup = 2,
		/obj/item/reagent_containers/food/drinks/cans/tonic = 5,
		/obj/item/reagent_containers/food/drinks/bottle/cream = 4,
		/obj/item/reagent_containers/food/drinks/cans/sodawater = 5,
		/obj/item/reagent_containers/food/drinks/bottle/grenadine = 5,
		/obj/item/reagent_containers/food/drinks/bottle/thoom = 2,
		/obj/item/reagent_containers/food/condiment/mint = 1,
		/obj/item/reagent_containers/food/drinks/ice = 10,
		/obj/item/glass_extra/stick = 15,
		/obj/item/glass_extra/straw = 15
	)
	contraband = list(
		/obj/item/reagent_containers/food/drinks/bottle/premiumwine = 1,
		/obj/item/reagent_containers/food/drinks/bottle/premiumvodka = 1,
		/obj/item/reagent_containers/food/drinks/bottle/patron = 1,
		/obj/item/reagent_containers/food/drinks/bottle/goldschlager = 1,
		/obj/item/reagent_containers/food/drinks/bottle/tadmorwine = 1,
		/obj/item/reagent_containers/food/drinks/bottle/brandy = 1,
		/obj/item/storage/secure/briefcase/money/fake = 1,
		/obj/item/reagent_containers/glass/bottle/dye/polychromic/strong = 0,
		/obj/item/storage/pill_bottle/tramadol = 0
	)
	rare_products = list(
		/obj/item/reagent_containers/glass/bottle/dye/polychromic/strong = 80,
		/obj/item/storage/pill_bottle/tramadol = 80
	)
	prices = list(
		/obj/item/reagent_containers/food/drinks/bottle/absinthe = 200,
		/obj/item/reagent_containers/food/drinks/bottle/baijiu = 200,
		/obj/item/reagent_containers/food/drinks/bottle/blackstrap = 200,
		/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = 200,
		/obj/item/reagent_containers/food/drinks/bottle/cachaca = 200,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 500,
		/obj/item/reagent_containers/food/drinks/bottle/cognac = 200,
		/obj/item/reagent_containers/food/drinks/bottle/gin = 200,
		/obj/item/reagent_containers/food/drinks/bottle/herbal = 200,
		/obj/item/reagent_containers/food/drinks/bottle/jagermeister = 200,
		/obj/item/reagent_containers/food/drinks/bottle/kahlua = 200,
		/obj/item/reagent_containers/food/drinks/bottle/melonliquor = 200,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 150,
		/obj/item/reagent_containers/food/drinks/bottle/prosecco = 200,
		/obj/item/reagent_containers/food/drinks/bottle/rakia = 200,
		/obj/item/reagent_containers/food/drinks/bottle/rum = 200,
		/obj/item/reagent_containers/food/drinks/bottle/sake = 200,
		/obj/item/reagent_containers/food/drinks/bottle/soju = 200,
		/obj/item/reagent_containers/food/drinks/bottle/tequilla = 200,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 150,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth = 200,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 200,
		/obj/item/reagent_containers/food/drinks/bottle/llanbrydewhiskey = 300,
		/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey = 400,
		/obj/item/reagent_containers/food/drinks/bottle/wine = 250,
		/obj/item/reagent_containers/food/drinks/bottle/small/beer = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/alcoholfreebeer = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/ale = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/hellshenpa = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/lager = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/gingerbeer = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/dandelionburdock = 5,
		/obj/item/reagent_containers/food/drinks/cans/rootbeer = 5,
		/obj/item/reagent_containers/food/drinks/cans/speer = 5,
		/obj/item/reagent_containers/food/drinks/cans/ale = 5,
		/obj/item/reagent_containers/food/drinks/bottle/small/cola = 2,
		/obj/item/reagent_containers/food/drinks/bottle/small/space_up = 2,
		/obj/item/reagent_containers/food/drinks/bottle/small/space_mountain_wind = 2,
		/obj/item/reagent_containers/food/drinks/cans/cola_diet = 2,
		/obj/item/reagent_containers/food/drinks/cans/ionbru = 5,
		/obj/item/reagent_containers/food/drinks/cans/beastenergy = 5,
		/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 20,
		/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 20,
		/obj/item/reagent_containers/food/drinks/bottle/limejuice = 20,
		/obj/item/reagent_containers/food/drinks/bottle/lemonjuice = 20,
		/obj/item/reagent_containers/food/drinks/bottle/unathijuice = 20,
		/obj/item/reagent_containers/food/drinks/bottle/maplesyrup = 20,
		/obj/item/reagent_containers/food/drinks/bottle/cream = 20,
		/obj/item/reagent_containers/food/drinks/cans/sodawater = 1,
		/obj/item/reagent_containers/food/drinks/bottle/grenadine = 50,
		/obj/item/reagent_containers/food/drinks/bottle/thoom = 20,
		/obj/item/reagent_containers/food/condiment/mint = 20,
		/obj/item/reagent_containers/food/drinks/bottle/premiumwine = 2000,
		/obj/item/reagent_containers/food/drinks/bottle/premiumvodka = 1000,
		/obj/item/reagent_containers/food/drinks/bottle/patron = 1500,
		/obj/item/reagent_containers/food/drinks/bottle/goldschlager = 2000,
		/obj/item/reagent_containers/food/drinks/bottle/tadmorwine = 2000,
		/obj/item/reagent_containers/food/drinks/bottle/brandy = 1600,
		/obj/item/storage/secure/briefcase/money/fake = 4000,
		/obj/item/reagent_containers/glass/bottle/dye/polychromic/strong = 500,
		/obj/item/storage/pill_bottle/tramadol = 1000
	)

/obj/machinery/vending/engivend/contraband
	name = "Old Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	icon_vend = "engivend-vend"
	base_type = /obj/machinery/vending/engivend
	req_access = list()
	product_slogans = {"\
		Equipment only 75% guaranteed to not blow up in your face!;\
		This vendor proudly supplied the electronics for 9 out of 10 ships involved in crashes!;\
		With electronics like this, is it a surprise the mortality rate in this dump is so high?\
	"}
	products = list(
		/obj/item/clothing/glasses/meson = 2,
		/obj/item/device/multitool = 3,
		/obj/item/device/geiger = 3,
		/obj/item/airlock_electronics = 4,
		/obj/item/intercom_electronics = 4,
		/obj/item/module/power_control = 4,
		/obj/item/airalarm_electronics = 4,
		/obj/item/cell/standard = 4,
		/obj/item/cell/high = 1,
		/obj/item/clamp = 4
	)
	prices = list(
		/obj/item/clothing/glasses/meson = 850,
		/obj/item/device/multitool = 400,
		/obj/item/device/geiger = 300,
		/obj/item/airlock_electronics = 250,
		/obj/item/intercom_electronics = 250,
		/obj/item/module/power_control = 300,
		/obj/item/airalarm_electronics = 100,
		/obj/item/cell/standard = 100,
		/obj/item/cell/high = 200,
		/obj/item/clamp = 200,
		/obj/item/device/uplink_service/fake_ion_storm = 1000,
		/obj/item/device/uplink_service/fake_crew_announcement = 1500,
		/obj/item/device/uplink_service/fake_rad_storm = 2000
	)
	rare_products = list(
		/obj/item/device/uplink_service/fake_crew_announcement = 80,
		/obj/item/device/uplink_service/fake_rad_storm = 40
	)
	contraband = list(
		/obj/item/device/uplink_service/fake_ion_storm = 1,
		/obj/item/device/uplink_service/fake_crew_announcement = 0,
		/obj/item/device/uplink_service/fake_rad_storm = 0
	)
	premium = list(
		/obj/item/storage/belt/utility = 3
	)

/obj/machinery/vending/phoronresearch/contraband
	name = "Toximate 2999"
	desc = "All the fine parts you need in one vending machine!"
	base_type = /obj/machinery/vending/phoronresearch
	product_slogans = {"\
		Dirty money for your dirty deed.;\
		Make an explosive first impression!\
	"}
	products = list(
		/obj/item/clothing/suit/bio_suit = 6,
		/obj/item/clothing/head/bio_hood = 6,
		/obj/item/device/transfer_valve = 6,
		/obj/item/device/assembly/timer = 6,
		/obj/item/device/assembly/signaler = 6,
		/obj/item/device/assembly/prox_sensor = 6,
		/obj/item/device/assembly/igniter = 6
	)
	rare_products = list(
		/obj/item/plastique = 70
	)
	contraband = list(
		/obj/item/storage/secure/briefcase/money/fake = 1,
		/obj/item/plastique = 0
	)
	prices = list(
		/obj/item/clothing/suit/bio_suit = 100,
		/obj/item/clothing/head/bio_hood = 100,
		/obj/item/device/transfer_valve = 400,
		/obj/item/device/assembly/timer = 100,
		/obj/item/device/assembly/signaler = 200,
		/obj/item/device/assembly/prox_sensor = 200,
		/obj/item/device/assembly/igniter = 200,
		/obj/item/storage/secure/briefcase/money/fake = 4000,
		/obj/item/plastique = 600
	)

/obj/machinery/vending/tool/contraband
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	icon_vend = "tool-vend"
	base_type = /obj/machinery/vending/tool
	antag_slogans = {"\

	"}
	products = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/crowbar = 5,
		/obj/item/weldingtool = 3,
		/obj/item/wirecutters = 5,
		/obj/item/wrench = 5,
		/obj/item/device/scanner/gas = 5,
		/obj/item/device/t_scanner = 5,
		/obj/item/screwdriver = 5,
		/obj/item/device/flashlight/flare/glowstick = 3,
		/obj/item/device/flashlight/flare/glowstick/red = 3,
		/obj/item/tape_roll = 8
	)
	rare_products = list(
		/obj/item/device/augment_implanter/engineering_toolset  = 50
	)
	contraband = list(
		/obj/item/weldingtool/hugetank = 2,
		/obj/item/clothing/gloves/insulated = 1
	)
	premium = list(
		/obj/item/clothing/gloves/insulated/cheap = 2
	)
	antag = list(
		/obj/item/storage/toolbox/syndicate = 1,
		/obj/item/device/augment_implanter/engineering_toolset  = 0
	)
