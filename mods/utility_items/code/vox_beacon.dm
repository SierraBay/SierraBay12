/obj/structure/closet/crate/vox_sierra
	name = "Vox crate"
	desc = "Fashion box"

/obj/structure/closet/crate/vox_sierra/New()
	..()
	new /obj/item/clothing/head/caphat/formal(src)
	new /obj/item/clothing/head/caphat/cap(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/suit/captunic/capjacket(src)
	new /obj/item/clothing/suit/storage/toggle/captain_parade(src)
	new /obj/item/clothing/suit/storage/toggle/captain_parade/female(src)
	new /obj/item/clothing/gloves/captain(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/dress/dress_cap(src)
	new /obj/item/clothing/under/captainformal(src)
	new /obj/item/clothing/under/captain_parade(src)
	new /obj/item/clothing/under/captain_parade/female(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/shoes/dressheels(src)

/obj/structure/closet/crate/vox_iccg
	name = "Vox crate"
	desc = "Fashion box"

/obj/structure/closet/crate/vox_iccg/New()
	..()
	new /obj/item/clothing/suit/iccgn/dress_command(src)
	new /obj/item/clothing/head/iccgn/service_command(src)
	new /obj/item/clothing/under/iccgn/service_command(src)
	new /obj/item/clothing/suit/iccgn/utility(src)
	new /obj/item/clothing/under/iccgn/utility(src)
	new /obj/item/clothing/suit/iccgn/dress_officer(src)
	new /obj/item/clothing/head/iccgn/service(src)

/obj/structure/closet/crate/vox_wizardry
	name = "Vox crate"
	desc = "Fashion box"

/obj/structure/closet/crate/vox_wizardry/New()
	..()
	new /obj/item/clothing/suit/wizrobe
	new /obj/item/clothing/head/wizard
	new /obj/item/clothing/suit/wizrobe/marisa
	new /obj/item/clothing/head/wizard/marisa

/obj/structure/closet/crate/vox_scg
	name = "Vox crate"
	desc = "Fashion box"

/obj/structure/closet/crate/vox_scg/New()
	..()
	new /obj/item/clothing/under/scga/service(src)
	new /obj/item/clothing/head/scga/service/wheel(src)
	new /obj/item/clothing/suit/scga/service(src)
	new /obj/item/clothing/under/scga/dress(src)
	new /obj/item/clothing/head/scga/dress/wheel(src)
	new /obj/item/clothing/suit/scga/dress_command(src)

/obj/structure/voxuplink/vox_ship
	rewards = list(
		"Request equipment from Shoal - 1" = list(1, /obj/random/loot),
		"Request medical supplies from Shoal - 1" = list(1, /obj/random/firstaid),
		"Makeshift Armored Vest - 1" = list(1, /obj/item/clothing/suit/armor/vox_scrap),
		"Protein Source - 1" = list(1, /mob/living/simple_animal/passive/meatbeast),
		"Door hacker - 1" = list(1, /obj/item/device/multitool/hacktool),
		"Сlothes Sierra - 1" = list(1, /obj/structure/closet/crate/vox_sierra),
		"Clothes ICCG - 1" = list(1, /obj/structure/closet/crate/vox_iccg),
		"Clothes SCG - 1" = list(1, /obj/structure/closet/crate/vox_scg),
		"Nanoblood - 1" = list(1, /obj/item/reagent_containers/ivbag/nanoblood),
		"Advanced Tools - 2" = list(2, /obj/item/swapper/power_drill, /obj/item/swapper/jaws_of_life),
		"Slug Launcher - 2" = list(2, /obj/item/gun/launcher/alien/slugsling),
		"Soundcannon - 2" = list(2, /obj/item/gun/energy/sonic),
		"Dart gun - 2" = list(2, /obj/item/gun/projectile/dartgun/vox/raider),
		"Jetpack - 2" = list(2, /obj/item/tank/jetpack),
		"Carapace Suit - 3" = list(3, /obj/item/clothing/head/helmet/space/vox/carapace, /obj/item/clothing/suit/space/vox/carapace),
		"Pressure Suit - 3" = list(3, /obj/item/clothing/head/helmet/space/vox/pressure, /obj/item/clothing/suit/space/vox/pressure),
		"Stealth Suit - 3" = list(3, /obj/item/clothing/head/helmet/space/vox/stealth, /obj/item/clothing/suit/space/vox/stealth),
		"Biotech Suit" = list(3, /obj/item/clothing/head/helmet/space/vox/medic, /obj/item/clothing/suit/space/vox/medic),
		"Stimpack - 3" = list(3, /obj/item/reagent_containers/hypospray/autoinjector/stimpack),
		"Combat Stimulant - 3" = list(3, /obj/item/reagent_containers/hypospray/autoinjector/combatstim),
		"C4 - 3" = list(3, /obj/item/plastique),
		"Flux Cannon - 4" = list(4, /obj/item/gun/energy/darkmatter),
		"Hack ID - 4" = list(4, /obj/item/card/id/syndicate),
		"Combat medpack - 4" = list(4, /obj/item/storage/firstaid/combat),
		"Sleepy pen - 4" = list(4, /obj/item/pen/reagent/sleepy),
		"NVG - 4" = list(4, /obj/item/clothing/glasses/night),
		"Raider Suit - 6" = list(6, /obj/item/clothing/head/helmet/space/vox/raider, /obj/item/clothing/suit/space/vox/raider),
		"Thermals - 6" = list(6, /obj/item/clothing/glasses/thermal/plain/monocle),
		"Net projector - 6" = list(6, /obj/item/rig_module/fabricator/energy_net),
		"Energy shield - 8" = list(8, /obj/item/shield/energy),
		"Arkmade Hardsuit - 8" = list(8, /obj/item/rig/vox),
		"Emag - 8" = list(8, /obj/item/card/emag),
		"Railgun - 8" = list(8, /obj/item/gun/magnetic/railgun),
		"Flechette gun - 8" = list(8, /obj/item/gun/magnetic/railgun/flechette),
		"Cutlass - 12" = list(12, /obj/item/melee/energy/sword/pirate),
		"MIU - 15" = list(15, /obj/item/clothing/mask/ai),
		"New Body - 30" = list(30, /mob/living/carbon/human/vox)
	)

/obj/structure/voxuplink/vox_ship/use_tool(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/stack/material/steel/fifty))
		var/obj/item/stack/material/steel/fifty/H = I
		favors += 1
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/stack/material/gold/ten))
		var/obj/item/stack/material/gold/ten/H = I
		favors += 1
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/stock_parts/circuitboard))
		var/obj/item/stock_parts/circuitboard/H = I
		favors += 1
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/gun/energy/pulse_rifle/skrell))
		var/obj/item/gun/energy/pulse_rifle/skrell/H = I
		favors += 3
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/gun/projectile/shotgun))
		var/obj/item/gun/projectile/shotgun/H = I
		favors += 2
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/gun/projectile/pistol))
		var/obj/item/gun/projectile/pistol/H = I
		favors += 1
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/clothing/suit/armor/pcarrier))
		var/obj/item/clothing/suit/armor/pcarrier/H = I
		favors += 1
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
	if(istype(I, /obj/item/spacecash/bundle/c1000))
		var/obj/item/spacecash/bundle/c1000/H = I
		favors += 1
		qdel(H)
		user.visible_message(
			SPAN_NOTICE("\The [user] inserts \a [H] into \the [src]."),
		)
		return 1
