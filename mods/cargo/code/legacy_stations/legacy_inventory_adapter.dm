/**
 * Legacy supply pack adapter for trading stations.
 * Translates upstream singleton/hierarchy/supply_pack structures into the modular goods format.
 */

/datum/trading_station/proc/BuildLegacyInventory()
	var/list/root_types = legacy_supply_roots
	if(!LAZYLEN(root_types) && legacy_station_group_type)
		var/datum/legacy_station_group/group_type = legacy_station_group_type
		if(ispath(group_type, /datum/legacy_station_group))
			root_types = initial(group_type.root_categories)
	if(!LAZYLEN(root_types))
		return
	for(var/root_type in root_types)
		var/list/pack_map = GET_SINGLETON_SUBTYPE_MAP(root_type)
		for(var/pack_type in pack_map)
			if(pack_type == root_type)
				continue
			var/singleton/hierarchy/supply_pack/supply_pack = pack_map[pack_type]
			if(!istype(supply_pack) || !length(supply_pack.contains) || !supply_pack.sec_available())
				continue
			var/item_count = GetLegacyPackItemCount(supply_pack)
			var/category_name = GetLegacyPackCategoryName(supply_pack, root_type)
			var/list/target_inventory = (supply_pack.hidden || supply_pack.contraband) ? hidden_inventory : inventory
			for(var/item_path in supply_pack.contains)
				RegisterLegacyPackItem(target_inventory, category_name, item_path, supply_pack, item_count)

/datum/trading_station/proc/GetLegacyPackItemCount(singleton/hierarchy/supply_pack/supply_pack)
	if(!istype(supply_pack))
		return 1
	if(isnum(supply_pack.num_contained) && supply_pack.num_contained > 0)
		return supply_pack.num_contained
	. = 0
	for(var/item_path in supply_pack.contains)
		. += max(1, supply_pack.contains[item_path])
	return max(1, .)

/datum/trading_station/proc/GetLegacyPackCategoryName(singleton/hierarchy/supply_pack/supply_pack, root_type)
	var/root_name = GetLegacyRootName(root_type)
	if(!istype(supply_pack) || !supply_pack.name)
		return root_name
	var/separator = findtext(supply_pack.name, " - ")
	if(separator > 1)
		return copytext(supply_pack.name, 1, separator)
	return root_name

/datum/trading_station/proc/GetLegacyRootName(root_type)
	var/list/path_bits = splittext("[root_type]", "/")
	if(!length(path_bits))
		return "Legacy"
	var/root_name = path_bits[length(path_bits)]
	root_name = replacetext(root_name, "_", " ")
	if(length(root_name) <= 1)
		return uppertext(root_name)
	return "[uppertext(copytext(root_name, 1, 2))][copytext(root_name, 2)]"

/datum/trading_station/proc/GetLegacyGoodName(singleton/hierarchy/supply_pack/supply_pack, item_path, item_count)
	if(istype(supply_pack) && length(supply_pack.contains) == 1 && supply_pack.name)
		return supply_pack.name

	var/specific_name = ResolveSpecificItemName(item_path)
	if(specific_name)
		return specific_name

	if(istype(supply_pack) && item_count == 1 && supply_pack.name)
		return supply_pack.name

	var/atom/movable/item_type = item_path
	return ispath(item_path, /atom/movable) ? initial(item_type.name) : null

/datum/trading_station/proc/ResolveSpecificItemName(item_path)
	if(!ispath(item_path, /atom/movable))
		return null

	if(ispath(item_path, /obj/item/reagent_containers/chem_disp_cartridge))
		return ResolveCartridgeName(item_path)
	if(ispath(item_path, /obj/item/seeds))
		return ResolveSeedName(item_path)
	if(ispath(item_path, /obj/item/ammobox))
		return ResolveAmmoBoxName(item_path)
	if(ispath(item_path, /obj/item/ammo_magazine))
		return ResolveMagazineName(item_path)
	return null

/datum/trading_station/proc/ResolveCartridgeName(item_path)
	var/obj/item/reagent_containers/chem_disp_cartridge/cartridge = item_path
	var/datum/reagent/reagent_type = initial(cartridge.spawn_reagent)
	if(ispath(reagent_type, /datum/reagent))
		return "[initial(cartridge.name)] ([initial(reagent_type.name)])"
	return null

/datum/trading_station/proc/ResolveSeedName(item_path)
	if(item_path == /obj/item/seeds/random)
		return "packet of random seeds"
	var/obj/item/seeds/seed_item = item_path
	var/seed_key = initial(seed_item.seed_type)
	if(!seed_key)
		return null
	var/datum/seed/seed_datum = SSplants?.seeds?[seed_key]
	if(seed_datum?.seed_name && seed_datum?.seed_noun)
		var/prefix = (seed_datum.seed_noun in list(SEED_NOUN_SEEDS, SEED_NOUN_PITS, SEED_NOUN_NODES)) ? "packet" : "sample"
		return "[prefix] of [seed_datum.seed_name] [seed_datum.seed_noun]"
	return "packet of [seed_key] seeds"

/datum/trading_station/proc/ResolveAmmoBoxName(item_path)
	var/obj/item/ammobox/box_item = item_path
	var/obj/item/ammo_casing/casing = initial(box_item.ammo_type)
	if(!ispath(casing, /obj/item/ammo_casing))
		return null
	var/casing_desc = _get_ammo_casing_name(casing)
	if(casing_desc)
		return "[initial(box_item.name)] - [casing_desc]"
	if(initial(casing.name))
		return "[initial(casing.name)] box"
	return null

/datum/trading_station/proc/ResolveMagazineName(item_path)
	var/obj/item/ammo_magazine/mag_item = item_path
	var/list/labels = initial(mag_item.labels)
	if(length(labels))
		return "[initial(mag_item.name)] ([jointext(labels, ", ")])"
	return null

/datum/trading_station/proc/RegisterLegacyPackItem(list/target_inventory, category_name, item_path, singleton/hierarchy/supply_pack/supply_pack, item_count)
	if(!islist(target_inventory) || !istext(category_name) || !istype(supply_pack) || !ispath(item_path, /atom/movable))
		return
	if(!islist(target_inventory[category_name]))
		target_inventory[category_name] = list()
	var/list/category = target_inventory[category_name]
	var/legacy_cost = isnum(supply_pack.cost) ? supply_pack.cost * CARGO_POINT_TO_THALLER : get_value(item_path)
	var/unit_price = max(1, round(legacy_cost / max(1, item_count)))
	var/name_override = GetLegacyGoodName(supply_pack, item_path, item_count)
	var/list/good_packet = GOODS_DATA(name_override, null, unit_price)
	good_packet["item_path"] = item_path
	category[GenerateGoodOfferId()] = good_packet
