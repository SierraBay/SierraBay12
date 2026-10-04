/datum/controller/subsystem/supply/proc/FindExportOfferByPath(datum/trading_station/station, path)
	while(path && path != /atom/movable)
		var/datum/trade_offer/offer = station.commodity_by_path?[path]
		if(istype(offer))
			return offer
		path = type2parent(path)
	return null

/datum/controller/subsystem/supply/proc/GetExportCargoContents(atom/movable/item)
	var/list/cargo = list()
	var/datum/component/cargo_contents/component = item.GetComponent(/datum/component/cargo_contents)
	if(!component)
		return cargo
	for(var/atom/movable/child as anything in component.GetContents())
		if(istype(child) && !QDELETED(child) && child.loc == item)
			cargo += child
	return cargo

/datum/controller/subsystem/supply/proc/GetExportMaterialAmount(obj/item/stack/material/item, obj/item/stack/material/offer_type, pack_size)
	ASSERT(istype(item))
	if(item.material?.name != initial(offer_type.default_type) || item.reinf_material?.name != initial(offer_type.default_reinf_type))
		return 0
	var/offer_volume = pack_size * initial(offer_type.matter_multiplier)
	return offer_volume > 0 ? item.get_amount() * item.matter_multiplier / offer_volume : 0

/datum/controller/subsystem/supply/proc/GetExportCanisterGas(obj/machinery/portable_atmospherics/canister/offer_type)
	if(ispath(offer_type, /obj/machinery/portable_atmospherics/canister/prefilled))
		var/obj/machinery/portable_atmospherics/canister/prefilled/prefilled = offer_type
		return initial(prefilled.fill_gas)
	return GetStandardExportCanisterGas(offer_type)

/datum/controller/subsystem/supply/proc/GetStandardExportCanisterGas(offer_type)
	var/list/gases = list(
		/obj/machinery/portable_atmospherics/canister/phoron = GAS_PHORON,
		/obj/machinery/portable_atmospherics/canister/oxygen = GAS_OXYGEN,
		/obj/machinery/portable_atmospherics/canister/nitrogen = GAS_NITROGEN,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = GAS_CO2,
		/obj/machinery/portable_atmospherics/canister/sleeping_agent = GAS_N2O,
		/obj/machinery/portable_atmospherics/canister/helium = GAS_HELIUM,
		/obj/machinery/portable_atmospherics/canister/hydrogen = GAS_HYDROGEN,
		/obj/machinery/portable_atmospherics/canister/boron = GAS_BORON)
	for(var/path in gases)
		if(ispath(offer_type, path))
			return gases[path]
	return null

/datum/controller/subsystem/supply/proc/GetExportCanisterAmount(obj/machinery/portable_atmospherics/canister/item, obj/machinery/portable_atmospherics/canister/offer_type)
	ASSERT(istype(item))
	if(ispath(offer_type, /obj/machinery/portable_atmospherics/canister/empty))
		return item.air_contents?.total_moles > 0 ? 0 : 1
	var/gas_id = GetExportCanisterGas(offer_type)
	var/list/expected = gas_id ? list() : null
	if(gas_id)
		expected[gas_id] = 1
	if(ispath(offer_type, /obj/machinery/portable_atmospherics/canister/air))
		expected = list(GAS_OXYGEN = O2STANDARD, GAS_NITROGEN = N2STANDARD)
	if(!islist(expected) || !item.air_contents || item.air_contents.total_moles <= 0)
		return 0
	var/reference_moles = initial(offer_type.start_pressure) * initial(offer_type.volume) / (R_IDEAL_GAS_EQUATION * T20C)
	return MatchExportGasMixture(item.air_contents, expected, reference_moles)

/datum/controller/subsystem/supply/proc/MatchExportGasMixture(datum/gas_mixture/mixture, list/expected, reference_moles)
	if(reference_moles <= 0)
		return 0
	for(var/gas_id in mixture.gas)
		if(mixture.gas[gas_id] > 0 && !(gas_id in expected))
			return 0
	for(var/gas_id in expected)
		var/actual_fraction = (mixture.gas[gas_id] || 0) / mixture.total_moles
		if(abs(actual_fraction - expected[gas_id]) > 0.00001)
			return 0
	return min(1, mixture.total_moles / reference_moles)

/datum/controller/subsystem/supply/proc/GetExportCanisterLegacyPrice(obj/machinery/portable_atmospherics/canister/item)
	var/amount = GetExportCanisterAmount(item, item.type)
	if(amount <= 0 || istype(item, /obj/machinery/portable_atmospherics/canister/empty))
		return MACHINE_IS_BROKEN(item) ? 200 : 400
	return round(get_value(item.type) * amount, 0.01)

/datum/controller/subsystem/supply/proc/GetExportBundleRecipe(atom/movable/item, atom/movable/offer_type)
	if(istype(item, /obj/structure/closet))
		if(item.type != offer_type)
			return null
		var/obj/structure/closet/closet = item
		return closet.WillContain() || list()
	if(ispath(offer_type, /obj/item/storage))
		if(ispath(offer_type, /obj/item/storage/box/glasses))
			return GetExportGlassRecipe(offer_type)
		var/obj/item/storage/storage_type = offer_type
		return initial(storage_type.startswith) || list()
	return list()

/datum/controller/subsystem/supply/proc/GetExportGlassRecipe(obj/item/storage/box/glasses/offer_type)
	var/list/glasses = list()
	glasses[initial(offer_type.glass_type)] = 7
	return glasses

/datum/controller/subsystem/supply/proc/IsCompleteExportBundle(atom/movable/item, atom/movable/offer_type, list/seen = null)
	if(!item.MatchesExportConfiguration(offer_type))
		return FALSE
	if(!islist(seen))
		seen = list()
	if(seen[item])
		return FALSE
	seen[item] = TRUE
	var/list/remaining = GetExportCargoContents(item)
	if(istype(item, /obj/structure/closet))
		var/obj/item/paper/manifest/rnd_invoice/invoice = FindRnDInvoice(item)
		remaining -= invoice
	var/list/recipe = GetExportBundleRecipe(item, offer_type)
	if(!islist(recipe) || !ConsumeExportRecipe(remaining, recipe, seen))
		return FALSE
	return MatchExportBundleExtras(remaining, offer_type)

/datum/controller/subsystem/supply/proc/ConsumeExportRecipe(list/remaining, list/recipe, list/seen)
	for(var/path in recipe)
		var/configuration = recipe[path]
		var/list/arguments = islist(configuration) ? configuration : null
		var/count = arguments ? arguments[1] : (configuration || 1)
		for(var/i in 1 to count)
			var/atom/movable/child = FindExportRecipeChild(remaining, path, arguments, seen)
			if(!child)
				return FALSE
			remaining -= child
	return TRUE

/datum/controller/subsystem/supply/proc/FindExportRecipeChild(list/remaining, atom/movable/path, list/arguments, list/seen)
	for(var/atom/movable/child as anything in remaining)
		if(child.type != path || !MatchExportRecipeStack(child, path, arguments))
			continue
		if(!IsCompleteExportBundle(child, path, seen.Copy()))
			continue
		return child
	return null

/datum/controller/subsystem/supply/proc/MatchExportRecipeStack(atom/movable/item, obj/item/stack/path, list/arguments)
	if(!isstack(item))
		return TRUE
	var/obj/item/stack/stack = item
	var/expected_amount = arguments && length(arguments) >= 2 ? arguments[2] : initial(path.amount)
	if(stack.get_amount() != expected_amount)
		return FALSE
	if(istype(stack, /obj/item/stack/material))
		return GetExportMaterialAmount(stack, path, expected_amount) == 1
	return TRUE

/datum/controller/subsystem/supply/proc/MatchExportBundleExtras(list/remaining, offer_type)
	if(offer_type == /obj/item/storage/toolbox/emergency)
		if(length(remaining) != 1)
			return FALSE
		var/atom/movable/light = remaining[1]
		return light.type in list(/obj/item/device/flashlight, /obj/item/device/flashlight/flare, /obj/item/device/flashlight/flare/glowstick/red)
	if(offer_type == /obj/item/storage/toolbox/electrical)
		return MatchExportElectricalTools(remaining)
	return !length(remaining)

/datum/controller/subsystem/supply/proc/MatchExportElectricalTools(list/remaining)
	var/cable_amount = 0
	var/gloves = 0
	for(var/atom/movable/child as anything in remaining)
		if(istype(child, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/cable = child
			cable_amount += cable.get_amount()
		else if(child.type == /obj/item/clothing/gloves/insulated)
			gloves++
		else
			return FALSE
	return (cable_amount == 90 && !gloves) || (cable_amount == 60 && gloves == 1)

/datum/controller/subsystem/supply/proc/GetExportCommodityAmount(atom/movable/item, atom/movable/path, pack_size)
	if(istype(item, /obj/item/stack/material))
		return ispath(path, /obj/item/stack/material) ? GetExportMaterialAmount(item, path, pack_size) : 0
	if(!istype(item, path))
		return 0
	if(!item.MatchesExportConfiguration(path))
		return 0
	if(istype(item, /obj/machinery/portable_atmospherics/canister))
		return GetExportCanisterAmount(item, path)
	if(istype(item, /obj/item/storage) || istype(item, /obj/structure/closet))
		return item.type == path && IsCompleteExportBundle(item, path) ? 1 : 0
	if(length(GetExportCargoContents(item)))
		return 0
	return GetExportStackAmount(item) / pack_size
