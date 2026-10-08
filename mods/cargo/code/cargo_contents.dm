/// Only declared cargo is appraised and unloaded independently of its owner.
/atom/movable/var/cargo_contents_type = null

/atom/movable/Initialize()
	. = ..()
	if(ispath(cargo_contents_type, /datum/component/cargo_contents))
		AddComponent(cargo_contents_type)

/obj/structure/closet
	cargo_contents_type = /datum/component/cargo_contents

/obj/item/storage
	cargo_contents_type = /datum/component/cargo_contents

/obj/item/clothingbag
	cargo_contents_type = /datum/component/cargo_contents

/obj/item/evidencebag
	cargo_contents_type = /datum/component/cargo_contents/evidence

/obj/machinery
	cargo_contents_type = /datum/component/cargo_contents/machinery

/obj/machinery/portable_atmospherics
	cargo_contents_type = /datum/component/cargo_contents/slot/portable_atmospherics

/obj/structure/bigDelivery
	cargo_contents_type = /datum/component/cargo_contents/slot/large_parcel

/obj/item/smallDelivery
	cargo_contents_type = /datum/component/cargo_contents/slot/small_parcel

/obj/item/collector
	cargo_contents_type = /datum/component/cargo_contents/slot/collector

/obj/item/clothing
	cargo_contents_type = /datum/component/cargo_contents/clothing

/obj/structure/janitorialcart
	cargo_contents_type = /datum/component/cargo_contents/janitorialcart

/datum/component/cargo_contents
	dupe_mode = COMPONENT_DUPE_UNIQUE
	dupe_type = /datum/component/cargo_contents
	can_transfer = FALSE
	var/required_parent_type = /atom/movable

/datum/component/cargo_contents/Initialize()
	if(!istype(parent, required_parent_type))
		return COMPONENT_INCOMPATIBLE

/// Returns a fresh list; referenced cargo is validated before the sale completes.
/datum/component/cargo_contents/proc/GetContents()
	var/atom/movable/owner = parent
	return owner.contents.Copy()

/datum/component/cargo_contents/proc/ValidateOwnership()
	for(var/atom/movable/child as anything in GetContents())
		if(!istype(child) || QDELETED(child) || !Owns(child))
			return FALSE
	return TRUE

/datum/component/cargo_contents/proc/Owns(atom/movable/child)
	return child.loc == parent

/// Internal storage is packaging, while its contents and removable accessories are cargo.
/datum/component/cargo_contents/clothing
	required_parent_type = /obj/item/clothing

/datum/component/cargo_contents/clothing/GetContents()
	var/list/cargo = list()
	var/obj/item/clothing/clothing = parent
	for(var/atom/movable/child as anything in clothing.contents)
		if(istype(child, /obj/item/storage/internal))
			cargo |= child.contents
		else if(istype(child, /obj/item/clothing/accessory))
			cargo |= child
	return cargo

/datum/component/cargo_contents/clothing/Owns(atom/movable/child)
	var/obj/item/storage/internal/storage = child.loc
	return ..() || (istype(storage) && !QDELETED(storage) && storage.loc == parent && storage.master_item == parent)

/datum/component/cargo_contents/clothing/ValidateOwnership()
	var/obj/item/clothing/clothing = parent
	for(var/obj/item/clothing/accessory/accessory as anything in clothing.accessories)
		if(QDELETED(accessory) || !Owns(accessory) || accessory.parent != clothing)
			return FALSE
	return ..()

/datum/component/cargo_contents/clothing/Detach(atom/movable/child)
	if(istype(child, /obj/item/clothing/accessory))
		var/obj/item/clothing/clothing = parent
		clothing.remove_accessory(null, child)

/datum/component/cargo_contents/janitorialcart
	required_parent_type = /obj/structure/janitorialcart

/datum/component/cargo_contents/janitorialcart/ValidateOwnership()
	var/obj/structure/janitorialcart/cart = parent
	for(var/atom/movable/child as anything in list(cart.mybag, cart.mymop, cart.myspray, cart.myreplacer))
		if(child && (QDELETED(child) || !Owns(child)))
			return FALSE
	return ..()

/datum/component/cargo_contents/janitorialcart/Detach(atom/movable/child)
	var/obj/structure/janitorialcart/cart = parent
	if(cart.mybag == child)
		cart.mybag = null
	if(cart.mymop == child)
		cart.mymop = null
	if(cart.myspray == child)
		cart.myspray = null
	if(cart.myreplacer == child)
		cart.myreplacer = null
	if(istype(child, /obj/item/caution))
		cart.signs = max(0, cart.signs - 1)
	cart.update_icon()

/// Clears owner references without moving or deleting the child.
/datum/component/cargo_contents/proc/Detach(atom/movable/child)
	return

/datum/component/cargo_contents/machinery
	required_parent_type = /obj/machinery

/datum/component/cargo_contents/machinery/GetContents()
	var/obj/machinery/machine = parent
	return machine.contents - machine.component_parts

/datum/component/cargo_contents/evidence
	required_parent_type = /obj/item/evidencebag

/datum/component/cargo_contents/evidence/ValidateOwnership()
	var/obj/item/evidencebag/bag = parent
	return ..() && (!bag.stored_item || (!QDELETED(bag.stored_item) && bag.stored_item.loc == bag))

/datum/component/cargo_contents/evidence/Detach(atom/movable/child)
	var/obj/item/evidencebag/bag = parent
	if(bag.stored_item == child)
		bag.empty()

/datum/component/cargo_contents/slot/GetContents()
	var/atom/movable/child = GetStoredCargo()
	return child ? list(child) : list()

/datum/component/cargo_contents/slot/proc/GetStoredCargo()
	return null

/datum/component/cargo_contents/slot/large_parcel
	required_parent_type = /obj/structure/bigDelivery

/datum/component/cargo_contents/slot/large_parcel/GetStoredCargo()
	var/obj/structure/bigDelivery/parcel = parent
	return parcel.wrapped

/datum/component/cargo_contents/slot/large_parcel/Detach(atom/movable/child)
	var/obj/structure/bigDelivery/parcel = parent
	if(parcel.wrapped == child)
		parcel.wrapped = null

/datum/component/cargo_contents/slot/small_parcel
	required_parent_type = /obj/item/smallDelivery

/datum/component/cargo_contents/slot/small_parcel/GetStoredCargo()
	var/obj/item/smallDelivery/parcel = parent
	return parcel.wrapped

/datum/component/cargo_contents/slot/small_parcel/Detach(atom/movable/child)
	var/obj/item/smallDelivery/parcel = parent
	if(parcel.wrapped == child)
		parcel.wrapped = null

/datum/component/cargo_contents/slot/portable_atmospherics
	required_parent_type = /obj/machinery/portable_atmospherics

/datum/component/cargo_contents/slot/portable_atmospherics/GetStoredCargo()
	var/obj/machinery/portable_atmospherics/machine = parent
	return machine.holding

/datum/component/cargo_contents/slot/portable_atmospherics/Detach(atom/movable/child)
	var/obj/machinery/portable_atmospherics/machine = parent
	if(machine.holding == child)
		machine.holding = null

/datum/component/cargo_contents/slot/collector
	required_parent_type = /obj/item/collector

/datum/component/cargo_contents/slot/collector/GetStoredCargo()
	var/obj/item/collector/collector = parent
	return collector.stored_artefact

/datum/component/cargo_contents/slot/collector/Detach(atom/movable/child)
	var/obj/item/collector/collector = parent
	if(collector.stored_artefact == child)
		collector.stored_artefact = null
		collector.update_icon()

/atom/movable/proc/MatchesExportConfiguration(atom/movable/offer_type)
	return TRUE

/obj/item/reagent_containers/MatchesExportConfiguration(obj/item/reagent_containers/offer_type)
	if(!ispath(offer_type, /obj/item/reagent_containers))
		return ..()
	for(var/list/expected as anything in SSsupply.GetExportReagentRecipes(offer_type))
		if(SSsupply.MatchExportReagents(reagents, expected))
			return ..()
	return FALSE

/// Called only on a temporary reference item to describe its valid factory fillings.
/obj/item/reagent_containers/proc/GetExportReagentRecipes()
	return list(SSsupply.DescribeExportReagents(reagents))

/obj/item/reagent_containers/food/snacks/donkpocket/GetExportReagentRecipes()
	if(!length(filling_options))
		return ..()
	var/list/recipes = list()
	for(var/option in filling_options)
		reagents.clear_reagents()
		reagents.add_reagent(/datum/reagent/nutriment, nutriment_amt, nutriment_desc)
		SetInitialReagents(list(option))
		recipes.Add(list(SSsupply.DescribeExportReagents(reagents)))
	return recipes

/obj/item/ammo_magazine/MatchesExportConfiguration(obj/item/ammo_magazine/offer_type)
	if(!ispath(offer_type, /obj/item/ammo_magazine))
		return ..()
	var/expected_count = initial(offer_type.initial_ammo)
	if(isnull(expected_count))
		expected_count = initial(offer_type.max_ammo)
	if(length(stored_ammo) != expected_count)
		return FALSE
	for(var/obj/item/ammo_casing/casing as anything in stored_ammo)
		if(QDELETED(casing) || casing.loc != src || casing.type != initial(offer_type.ammo_type) || QDELETED(casing.BB))
			return FALSE
	return ..()

/obj/item/ammobox/MatchesExportConfiguration(obj/item/ammobox/offer_type)
	if(!ispath(offer_type, /obj/item/ammobox))
		return ..()
	return ..() && ammo_count == initial(offer_type.ammo_count) && ammo_type == initial(offer_type.ammo_type) && ammo_spent == initial(offer_type.ammo_spent)

/obj/item/defibrillator/MatchesExportConfiguration(obj/item/defibrillator/offer_type)
	if(!ispath(offer_type, /obj/item/defibrillator))
		return ..()
	if(QDELETED(paddles) || !istype(paddles, /obj/item/shockpaddles/linked) || paddles.loc != src)
		return FALSE
	var/obj/item/cell/expected_cell = initial(offer_type.bcell)
	if(ispath(expected_cell))
		return !QDELETED(bcell) && bcell.loc == src && bcell.type == expected_cell
	return !bcell
