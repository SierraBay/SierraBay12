///////////////////////////////ВАЖНО//////////////////////////////////////////////////////////
//ЦЕНЫ ВЫСТАВЛЯЕМ С УЧЕТОМ ТОГО ЧТО ОНО БУДЕТ УМНОЖЕНО НА 15, Т.Е. КОНВЕРТИРОВАНО В ТАЛЛЕР.	//
////////////////////////////////////////////////////////////////////////////////////////////////

/singleton/hierarchy/supply_pack/prosthesis
	name = "Prosthetics"
	containertype = /obj/structure/closet/crate/medical
	containername = "prosthetics crate"
	var/manufacturer
	var/select_part = FALSE
	var/list/part_options = list(
		"Left arm" = /obj/item/organ/external/arm,
		"Right arm" = /obj/item/organ/external/arm/right,
		"Left hand" = /obj/item/organ/external/hand,
		"Right hand" = /obj/item/organ/external/hand/right,
		"Left leg" = /obj/item/organ/external/leg,
		"Right leg" = /obj/item/organ/external/leg/right,
		"Left foot" = /obj/item/organ/external/foot,
		"Right foot" = /obj/item/organ/external/foot/right,
		"Head" = /obj/item/organ/external/head,
		"Torso" = /obj/item/organ/external/chest,
		"Groin" = /obj/item/organ/external/groin
	)
	contains = list(
		/obj/item/organ/external/arm,
		/obj/item/organ/external/arm/right,
		/obj/item/organ/external/leg,
		/obj/item/organ/external/leg/right,
		/obj/item/organ/external/head,
		/obj/item/organ/external/chest,
		/obj/item/organ/external/groin
	)

/singleton/hierarchy/supply_pack/prosthesis/proc/get_part_name(part_path)
	for (var/part_name in part_options)
		if (part_options[part_name] == part_path)
			return part_name

/singleton/hierarchy/supply_pack/prosthesis/proc/spawn_branded_part(part_path, location)
	var/obj/item/organ/external/organ = new part_path(location)
	organ.robotize(manufacturer)
	organ.status |= ORGAN_CUT_AWAY
	return organ

/singleton/hierarchy/supply_pack/prosthesis/setup()
	if (!select_part)
		return ..()
	num_contained = 1
	var/list/lines = list("<ul>")
	for (var/part_name in part_options)
		lines += "<li>[part_name]</li>"
	lines += "</ul>"
	manifest = jointext(lines, null)

/singleton/hierarchy/supply_pack/prosthesis/spawn_contents(location, datum/supply_order/order)
	if (!location)
		return
	if (select_part)
		if (!ispath(order?.ordered_item, /obj/item/organ/external))
			return
		return list(spawn_branded_part(order.ordered_item, location))
	. = list()
	for (var/entry in contains)
		for (var/i = 1 to max(1, contains[entry]))
			. += spawn_branded_part(entry, location)

/singleton/hierarchy/supply_pack/prosthesis/nanotrasen
	name = "Prosthetics - NanoTrasen (full set)"
	containername = "NanoTrasen prosthetics crate"
	manufacturer = "NanoTrasen"
	cost = 120

/singleton/hierarchy/supply_pack/prosthesis/nanotrasen/single
	name = "Prosthetics - NanoTrasen (single part)"
	containername = "NanoTrasen prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 32

/singleton/hierarchy/supply_pack/prosthesis/xion_econ
	name = "Prosthetics - Xion Econ (full set)"
	containername = "Xion Econ prosthetics crate"
	manufacturer = "Xion Econ"
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/xion_econ/single
	name = "Prosthetics - Xion Econ (single part)"
	containername = "Xion Econ prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 32

/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi_econ
	name = "Prosthetics - Ward-Takahashi Econ (full set)"
	containername = "Ward-Takahashi Econ prosthetics crate"
	manufacturer = "Ward-Takahashi Econ."
	cost = 100

/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi_econ/single
	name = "Prosthetics - Ward-Takahashi Econ (single part)"
	containername = "Ward-Takahashi Econ prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 32

/singleton/hierarchy/supply_pack/prosthesis/xion
	name = "Prosthetics - Xion (full set)"
	containername = "Xion prosthetics crate"
	manufacturer = "Xion"
	cost = 200

/singleton/hierarchy/supply_pack/prosthesis/xion/single
	name = "Prosthetics - Xion (single part)"
	containername = "Xion prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 48

/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi
	name = "Prosthetics - Ward-Takahashi (full set)"
	containername = "Ward-Takahashi prosthetics crate"
	manufacturer = "Ward-Takahashi"
	cost = 220

/singleton/hierarchy/supply_pack/prosthesis/wardtakahashi/single
	name = "Prosthetics - Ward-Takahashi (single part)"
	containername = "Ward-Takahashi prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 48

/singleton/hierarchy/supply_pack/prosthesis/morpheus
	name = "Prosthetics - Morpheus (full set)"
	containername = "Morpheus prosthetics crate"
	manufacturer = "Morpheus"
	cost = 200

/singleton/hierarchy/supply_pack/prosthesis/morpheus/single
	name = "Prosthetics - Morpheus (single part)"
	containername = "Morpheus prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 48

/singleton/hierarchy/supply_pack/prosthesis/morpheus_mantis
	name = "Prosthetics - Morpheus Mantis (full set)"
	containername = "Morpheus Mantis prosthetics crate"
	manufacturer = "Morpheus Mantis"
	cost = 240

/singleton/hierarchy/supply_pack/prosthesis/morpheus_mantis/single
	name = "Prosthetics - Morpheus Mantis (single part)"
	containername = "Morpheus Mantis prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 56

/singleton/hierarchy/supply_pack/prosthesis/hephaestus
	name = "Prosthetics - Hephaestus Industries (full set)"
	containername = "Hephaestus prosthetics crate"
	manufacturer = "Hephaestus Industries"
	cost = 280

/singleton/hierarchy/supply_pack/prosthesis/hephaestus/single
	name = "Prosthetics - Hephaestus Industries (single part)"
	containername = "Hephaestus prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 64

/singleton/hierarchy/supply_pack/prosthesis/shellguard
	name = "Prosthetics - Shellguard (full set)"
	containername = "Shellguard prosthetics crate"
	manufacturer = "Shellguard"
	cost = 280

/singleton/hierarchy/supply_pack/prosthesis/shellguard/single
	name = "Prosthetics - Shellguard (single part)"
	containername = "Shellguard prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 64

/singleton/hierarchy/supply_pack/prosthesis/zenghu
	name = "Prosthetics - Zeng-Hu (full set)"
	containername = "Zeng-Hu prosthetics crate"
	manufacturer = "Zeng-Hu"
	cost = 280

/singleton/hierarchy/supply_pack/prosthesis/zenghu/single
	name = "Prosthetics - Zeng-Hu (single part)"
	containername = "Zeng-Hu prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 64

/singleton/hierarchy/supply_pack/prosthesis/zenghu_spirit
	name = "Prosthetics - Zeng-Hu Spirit (full set)"
	containername = "Zeng-Hu Spirit prosthetics crate"
	manufacturer = "Zeng-Hu Spirit"
	cost = 280

/singleton/hierarchy/supply_pack/prosthesis/zenghu_spirit/single
	name = "Prosthetics - Zeng-Hu Spirit (single part)"
	containername = "Zeng-Hu Spirit prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 64

/singleton/hierarchy/supply_pack/prosthesis/hephaestus_titan
	name = "Prosthetics - Hephaestus Titan (full set)"
	containername = "Hephaestus Titan prosthetics crate"
	manufacturer = "Hephaestus Titan"
	cost = 400

/singleton/hierarchy/supply_pack/prosthesis/hephaestus_titan/single
	name = "Prosthetics - Hephaestus Titan (single part)"
	containername = "Hephaestus Titan prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 88

/singleton/hierarchy/supply_pack/prosthesis/resomi
	name = "Prosthetics - Small (Resomi) (full set)"
	containername = "small prosthetics crate"
	manufacturer = "Small prosthetic"
	cost = 160

/singleton/hierarchy/supply_pack/prosthesis/resomi/single
	name = "Prosthetics - Small (Resomi) (single part)"
	containername = "small prosthetic kit crate"
	select_part = TRUE
	contains = list()
	cost = 40

/datum/nano_module/program/supply/generate_order_contents(order_ref)
	var/singleton/hierarchy/supply_pack/prosthesis/sp = locate(order_ref) in SSsupply.master_supply_list
	if (istype(sp) && sp.select_part)
		showing_contents_of_ref = order_ref
		contents_of_order.Cut()
		return TRUE
	return ..()
