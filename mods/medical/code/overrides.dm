/obj/structure/roller_bed
	w_class = ITEM_SIZE_SMALL

/obj/item/storage/wallet/Initialize()
	. = ..()
	contents_allowed |= list(
		/obj/item/storage/pill_bottle/blister
	)

/obj/item/storage/pill_bottle/Initialize()
	. = ..()
	contents_allowed |= list(
		/obj/item/storage/pill_bottle/blister
	)

/obj/item/storage/pill_bottle/assorted
	startswith = list(
		/obj/item/storage/pill_bottle/blister/inaprovaline,
		/obj/item/storage/pill_bottle/blister/dylovene,
		/obj/item/storage/pill_bottle/blister/two/sugariron,
		/obj/item/storage/pill_bottle/blister/two/tramadol,
		/obj/item/storage/pill_bottle/blister/two/dexalin,
		/obj/item/storage/pill_bottle/blister/two/kelotane,
		/obj/item/storage/pill_bottle/blister/two/hyronalin
	)
