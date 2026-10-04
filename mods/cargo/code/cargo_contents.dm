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
		if(!istype(child) || QDELETED(child) || child.loc != parent)
			return FALSE
	return TRUE

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

/obj/item/defibrillator/MatchesExportConfiguration(obj/item/defibrillator/offer_type)
	if(!ispath(offer_type, /obj/item/defibrillator))
		return ..()
	if(QDELETED(paddles) || !istype(paddles, /obj/item/shockpaddles/linked) || paddles.loc != src)
		return FALSE
	var/obj/item/cell/expected_cell = initial(offer_type.bcell)
	if(ispath(expected_cell))
		return !QDELETED(bcell) && bcell.loc == src && bcell.type == expected_cell
	return !bcell
