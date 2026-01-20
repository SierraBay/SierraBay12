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
		"Biotech Suit - 3" = list(3, /obj/item/clothing/head/helmet/space/vox/medic, /obj/item/clothing/suit/space/vox/medic),
		"Stimpack - 3" = list(3, /obj/item/reagent_containers/hypospray/autoinjector/stimpack),
		"Combat Stimulant - 3" = list(3, /obj/item/reagent_containers/hypospray/autoinjector/combatstim),
		"C4 - 3" = list(3, /obj/item/plastique),
		"Flux Cannon - 4" = list(4, /obj/item/gun/energy/darkmatter),
		"Spike Thrower - 4" = list(4, /obj/item/gun/launcher/alien/spikethrower),
		"Hack ID - 4" = list(4, /obj/item/card/id/syndicate),
		"Combat medpack - 4" = list(4, /obj/item/storage/firstaid/combat),
		"Sleepy pen - 4" = list(4, /obj/item/pen/reagent/sleepy),
		"NVG - 4" = list(4, /obj/item/clothing/glasses/night),
		"Raider Suit - 6" = list(6, /obj/item/clothing/head/helmet/space/vox/raider, /obj/item/clothing/suit/space/vox/raider),
		"Net projector - 6" = list(6, /obj/item/rig_module/fabricator/energy_net),
		"Arkmade Hardsuit - 8" = list(8, /obj/item/rig/vox),
		"Emag - 8" = list(8, /obj/item/card/emag),
		"Thermals - 12" = list(12, /obj/item/clothing/glasses/thermal/plain/monocle),
		"MIU - 15" = list(15, /obj/item/clothing/mask/ai)
	)
	var/list/purchase_limits = list(
		"Thermals - 12" = 2,
		"Raider Suit - 6" = 1,
		"Arkmade Hardsuit - 8" = 1
	)

/obj/structure/voxuplink/vox_ship/proc/check_and_handle_limits(mob/user, choice)
	if(!(choice in purchase_limits))
		return TRUE

	if(purchase_limits[choice] <= 0)
		to_chat(user, SPAN_WARNING("[choice] are no longer available!"))
		return FALSE

	purchase_limits[choice]--
	return TRUE

/obj/structure/voxuplink/vox_ship/attack_hand(mob/living/carbon/human/user)
	if(!istype(user, SPECIES_VOX))
		to_chat(user, SPAN_WARNING("You don't know what to do with \the [src.name]."))
		return
	if(working)
		to_chat(user, SPAN_WARNING("\The [src.name] is still working!"))
		return
	var/choice = input(user, "What would you like to request from Apex? You have [favors] favors left!", "Shoal Beacon") as null|anything in rewards
	if(rewards[choice][1] > favors || !check_and_handle_limits(user, choice))
		return
	working = TRUE
	on_update_icon()
	to_chat(user, SPAN_NOTICE("The Apex rewards you with \the [choice]."))
	sleep(2 SECONDS)
	working = FALSE
	on_update_icon()
	favors -= rewards[choice][1]
	for(var/I in rewards[choice])
		if(!isnum(I))
			new I(get_turf(src))

/obj/structure/voxuplink/vox_ship/use_tool(obj/item/I, mob/user)
	..()
// Продажа только материалов
	var/price
	if(istype(I, /obj/item/stack/material))
		var/obj/item/stack/st = I
		if(istype(I, /obj/item/stack/material/steel))
			price = 0.02
		else if(istype(I, /obj/item/stack/material/aluminium))
			price = 0.02
		else if(istype(I, /obj/item/stack/material/plastic))
			price = 0.02
		else if(istype(I, /obj/item/stack/material/osmium))
			price = 0.02
		else if(istype(I, /obj/item/stack/material/glass))
			price = 0.01
		else if(istype(I, /obj/item/stack/material/wood))
			price = 0.01
		else if(istype(I, /obj/item/stack/material/silver))
			price = 0.03
		else if(istype(I, /obj/item/stack/material/plasteel))
			price = 0.03
		else if(istype(I, /obj/item/stack/material/ocp))
			price = 0.03
		else if(istype(I, /obj/item/stack/material/tritium))
			price = 0.03
		else if(istype(I, /obj/item/stack/material/deuterium))
			price = 0.03
		else if(istype(I, /obj/item/stack/material/titanium))
			price = 0.04
		else if(istype(I, /obj/item/stack/material/gold))
			price = 0.05
		else if(istype(I, /obj/item/stack/material/platinum))
			price = 0.05
		else if(istype(I, /obj/item/stack/material/uranium))
			price = 0.05
		else if(istype(I, /obj/item/stack/material/diamond))
			price = 0.07
		else if(istype(I, /obj/item/stack/material/phoron))
			price = 0.07
		favors += price * st.amount
// Продажа только оружия
	else if(istype(I, /obj/item/gun))
		if(istype(I, /obj/item/gun/energy/pulse_rifle/skrell))
			price = 3
		else if(istype(I, /obj/item/gun/projectile/shotgun))
			price = 2
		else if(istype(I, /obj/item/gun/projectile/automatic))
			price = 2
		else if(istype(I, /obj/item/gun/projectile/pistol))
			price = 1
		else if(istype(I, /obj/item/gun/energy/gun))
			price = 1
		favors += price
// Продажа только костюмов
	else if(istype(I, /obj/item/clothing/suit))
		if(istype(I, /obj/item/clothing/suit/armor/pcarrier))
			price = 1
		else if(istype(I, /obj/item/clothing/suit/space/void))
			price = 0.5
		else if(istype(I, /obj/item/clothing/head/helmet/space/void))
			price = 0.1
		favors += price
	if(!price)
		to_chat(user, "Это не требуется Апексам")
		return FALSE
	if(price)
		to_chat(user, "Вы обменяли [I] на валюту")
		qdel(I)
