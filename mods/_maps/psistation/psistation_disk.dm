/obj/item/stock_parts/computer/hard_drive/portable/psistation_tech
	name = "server data disk"
	desc = "A strange data disk covered in unfamiliar markings."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "harddisk"
	w_class = ITEM_SIZE_TINY

/obj/item/stock_parts/computer/hard_drive/portable/psistation_tech/Initialize(mapload, ...)
	. = ..()
	var/datum/design/entry = pick(SSresearch.all_designs)
	var/datum/computer_file/binary/design/design_file = entry.file
	create_file(design_file)

	name = "computer disk: ([entry.name])"
	desc = "[initial(desc)] The label reads: \"[entry.name]\"."
	if(entry.desc)
		desc += " [entry.desc]"
