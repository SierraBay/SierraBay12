// Alien clothing

// Skrell clothing

// Коммент от Колеса: если по какой-то причине у вас не отображается вещь в нужной вкладке лодаута, почекайте
// её в других вкладках. Если отображается не там, где нужно, поищите в коркоде определенные флаги сортировки.
// У меня например пришлось брать из коркода sort_category = "Xenowear"
/datum/gear/suit/skrell/skrell_robe
	display_name = "(Skrell) Skrellian robe"
	path = /obj/item/clothing/suit/skrell_robe
	sort_category = "Xenowear"
	cost = 1
	slot = slot_wear_suit

/datum/gear/suit/skrell_clothes
	display_name = "(Skrell) Skrell clothes selection"
	path = /obj/item/clothing/under/
	sort_category = "Xenowear"

/datum/gear/suit/skrell_clothes/New()
	..()
	var/skrell_clothes = list()
	skrell_clothes["Talum-Katish blue dress"] = /obj/item/clothing/under/uniform/skrell_talum_bluedress
	skrell_clothes["Talum-Katish green waist cloak"] = /obj/item/clothing/under/uniform/skrell_talum_greenwaistcloak
	skrell_clothes["Raskinta-Katish navy clothes"] = /obj/item/clothing/under/uniform/skrell_raskinta_navyclothes
	skrell_clothes["Malish-Katish blue office suit"] = /obj/item/clothing/under/uniform/skrell_malish_officesuit
	skrell_clothes["Talum-Katish white and red dress"] = /obj/item/clothing/under/uniform/skrell_talum_whitereddress
	skrell_clothes["Malish-Katish office suit with tie"] = /obj/item/clothing/under/uniform/skrell_malish_greentiedsuit
	skrell_clothes["Kanin-Katish sand-blue turtleneck"] = /obj/item/clothing/under/uniform/skrell_kanin_sandblueturtleneck
	skrell_clothes["Kanin-Katish orange-cyan uniform"] = /obj/item/clothing/under/uniform/skrell_kanin_orangecyanuniform
	skrell_clothes["Kanin-Katish yellow-black costume"] = /obj/item/clothing/under/uniform/skrell_kanin_yellowblackcostume
	skrell_clothes["Malish-Katish green office suit with suspenders"] = /obj/item/clothing/under/uniform/skrell_malish_greenofficesuit
	skrell_clothes["Raskinta-Katish red clothes"] = /obj/item/clothing/under/uniform/skrell_raskinta_redclothes
	skrell_clothes["Skrellian diving suit"] = /obj/item/clothing/under/uniform/skrell_skrellian_divingsuit
	gear_tweaks += new/datum/gear_tweak/path(skrell_clothes)

