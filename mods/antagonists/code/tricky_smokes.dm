/obj/item/storage/box/syndie_kit/cigarette
	name = "tricky smokes"
	desc = "Smokes so good, you'd think it was a trick!"
	startswith = list(
		/obj/item/flame/lighter/zippo = 1,
		/obj/item/storage/fancy/smokable/killthroat/flash = 2,
		/obj/item/storage/fancy/smokable/jerichos/smoke = 2,
		/obj/item/storage/fancy/smokable/carcinomas/mindbreaker = 1,
		/obj/item/storage/fancy/smokable/menthols/ticordrazine = 1
	)

/obj/item/storage/fancy/smokable/carcinomas/mindbreaker
	name = "pack of Carcinoma Angels"
	desc = "This unknown brand was slated for the chopping block, until they were publicly endorsed by an old Earthling gonzo journalist. The rest is history. They sell a variety for cats, too. Yes, actual cats. 'MB' has been scribbled on it."
	icon_state = "CApacket"
	item_state = "Dpacket"
	startswith = list(
		/obj/item/clothing/mask/smokable/cigarette/carcinomas/mindbreaker = 6
	)

/obj/item/clothing/mask/smokable/cigarette/carcinomas/mindbreaker
	filling = list(/datum/reagent/drugs/mindbreaker = 5)

/obj/item/storage/fancy/smokable/killthroat/flash
	name = "pack of Acme Co. cigarettes"
	desc = "A packet of six Acme Company cigarettes. For those who somehow want to obtain the record for the most amount of cancerous tumors. 'F' has been scribbled on it."
	icon_state = "Bpacket"
	startswith = list(
		/obj/item/clothing/mask/smokable/cigarette/killthroat/flash = 6
	)

/obj/item/clothing/mask/smokable/cigarette/killthroat/flash
	filling = list(
		/datum/reagent/aluminium = 2,
		/datum/reagent/potassium = 2,
		/datum/reagent/sulfur = 2
	)

/obj/item/storage/fancy/smokable/menthols/ticordrazine
	desc = "With a sharp and natural organic menthol flavor, these Temperamentos are a favorite of NDV crews. Hardly anyone knows they make 'em in non-menthol! 'T' has been scribbled on it."
	startswith = list(
		/obj/item/clothing/mask/smokable/cigarette/menthol/ticordrazine = 6
	)

/obj/item/clothing/mask/smokable/cigarette/menthol/ticordrazine
	filling = list(/datum/reagent/tricordrazine = 5)

/obj/item/storage/fancy/smokable/jerichos/smoke
	desc = "Typically seen dangling from the lips of Martian soldiers and border world hustlers. Tastes like hickory smoke, feels like warm liquid death down your lungs. 'S' has been scribbled on it."
	startswith = list(
		/obj/item/clothing/mask/smokable/cigarette/jerichos/smoke = 6
	)

/obj/item/clothing/mask/smokable/cigarette/jerichos/smoke
	filling = list(
		/datum/reagent/potassium = 3,
		/datum/reagent/sugar = 3,
		/datum/reagent/phosphorus = 3
	)
