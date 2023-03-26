

/obj/structure/closet/emcloset/anchored
	name = "anchored emergency closet"
	desc = "It's a storage unit for emergency breathmasks and o2 tanks."
	closet_appearance = /singleton/closet_appearance/oxygen
	anchored = TRUE

/obj/structure/closet/emcloset/anchored/WillContain()
	return list(/obj/item/tank/oxygen_emergency = 2,
				/obj/item/clothing/mask/breath = 2,
				/obj/item/storage/toolbox/emergency,
				/obj/item/inflatable/wall = 2,
				/obj/item/device/oxycandle,
				/obj/item/storage/med_pouch/oxyloss = 2,
				/obj/item/clothing/suit/space/emergency,
				/obj/item/clothing/head/helmet/space/emergency
	)
