/obj/item/storage/firstaid/brute
	name = "brute first-aid kit"
	desc = "Use it when your hands will be broken... Or worse."
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/advanced/bruise_pack = 4,
		/obj/item/stack/medical/splint = 2
		)

/obj/item/storage/firstaid/fire/special
	name = "scorch first-aid kit"
	desc = "When standart ointment is not enough."
	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/advanced/ointment = 4,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/paracetamol
		)

/obj/item/storage/firstaid/combat/special
	startswith = list(
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/dermaline,
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/storage/pill_bottle/dexalin_plus,
		/obj/item/storage/pill_bottle/inaprovaline,
		/obj/item/storage/pill_bottle/dylovene,
		/obj/item/storage/pill_bottle/nanoblood
		)


/obj/item/storage/pill_bottle/nanoblood
	name = "pill bottle (Nanoblood)"
	desc = "Contains pills used to treat cases of blood loss."
	startswith = list(/obj/item/reagent_containers/pill/nanoblood = 14)
	wrapper_color = COLOR_BLUE

/obj/item/reagent_containers/pill/nanoblood
	name = "Nanoblood (15u)"
	desc = "Used to restore blood."
	icon_state = "pill1"

/obj/item/reagent_containers/pill/nanoblood/New()
	..()
	reagents.add_reagent(/datum/reagent/nanoblood, 15)
	color = reagents.get_color()

/obj/item/storage/pill_bottle/hyronalin
	name = "pill bottle (Hyronalin)"
	desc = "Contains pills used to treat radiation effects."
	startswith = list(/obj/item/reagent_containers/pill/hyronalin = 14)
	wrapper_color = COLOR_YELLOW
