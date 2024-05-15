/obj/item/reagent_containers/hypospray/autoinjector/brute
	name = "autoinjector (anti-injury)"
	band_color = COLOR_RED
	starts_with = list(/datum/reagent/bicaridine = 5)

/obj/item/reagent_containers/hypospray/autoinjector/burn
	name = "autoinjector (anti-burn)"
	band_color = COLOR_DARK_ORANGE
	starts_with = list(/datum/reagent/kelotane = 5)

/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline
	name = "autoinjector (inaprovaline)"
	band_color = COLOR_CYAN
	starts_with = list(/datum/reagent/inaprovaline = 5)

//Personal firstaid kit, from infinity

/obj/item/storage/firstaid/individual
	name = "master kit"
	icon = 'mods/_fd/fd_assets/icons/obj/firstaid_indiv.dmi'
	icon_state = "survivalmed"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	storage_slots  = 10
	contents_allowed = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical/advanced,
		/obj/item/reagent_containers/syringe,
		/obj/item/bodybag/
		)

/obj/item/storage/firstaid/individual/all
	name = "individual medical kit"
	desc = "A small box decorated in warning colors that contains a limited supply of medical reagents."
	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment
		)

/obj/item/storage/firstaid/individual/military
	name = "military individual medical kit"
	desc = "A small box decorated in dark colors that contains a limited supply of medical reagents."
	icon_state = "survivalmilmed"
	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector/burn = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/brute = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/pain,
		/obj/item/reagent_containers/hypospray/autoinjector/detox,
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline,
		/obj/item/reagent_containers/hypospray/autoinjector/antirad,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment
		)

/obj/item/storage/firstaid/individual/military/exp
	name = "expeditionary individual medical kit"
	desc = "A small box decorated in warning colors that contains a limited supply of medical reagents."
	icon_state = "survivalexp"
	storage_slots  = 7
	startswith = list(
		/obj/item/reagent_containers/hypospray/autoinjector/burn,
		/obj/item/reagent_containers/hypospray/autoinjector/brute,
		/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/dexalin,
		/obj/item/reagent_containers/hypospray/autoinjector/pain = 2,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment
		)
