/datum/trade_appraisal
	var/list/items = list()
	var/list/sources = list()
	var/list/virus_strains = list()
	var/total = 0
	var/artefact_points = 0
	var/blocked = FALSE

/datum/trade_appraisal/Destroy()
	items.Cut()
	sources.Cut()
	virus_strains.Cut()
	return ..()

/datum/controller/subsystem/trade/proc/get_contents_tree(atom/movable/root)
	var/list/tree = list(root)
	for(var/index in 1 to TRADE_EXPORT_LIMIT)
		if(index > length(tree))
			return tree
		var/atom/movable/target = tree[index]
		if(istype(target, /obj/machinery/anomaly_container) || istype(target, /obj/machinery/stasis_cage))
			continue
		if(istype(target, /obj/item/collector))
			var/obj/item/collector/coll = target
			if(istype(coll.stored_artefact))
				tree |= coll.stored_artefact
		for(var/atom/movable/child as anything in target.contents)
			if(istype(child))
				tree |= child
	return length(tree) <= TRADE_EXPORT_LIMIT ? tree : list()

/datum/controller/subsystem/trade/proc/is_protected(atom/movable/target)
	if(ismob(target))
		var/mob/subject = target
		return subject.mind || subject.client || !istype(subject, /mob/living/simple_animal) || istype(subject, /mob/living/simple_animal/hostile/human) || !istype(subject.loc, /obj/machinery/stasis_cage)
	return istype(target, /obj/item/disk/nuclear) || istype(target, /obj/machinery/nuclearbomb) || istype(target, /obj/machinery/tele_beacon) || istype(target, /obj/machinery/trade_beacon)

/datum/controller/subsystem/trade/proc/is_class_a_nonexportable(atom/movable/item)
	if(!istype(item) || ismob(item) || is_protected(item))
		return TRUE
	if(item.anchored && !istype(item, /obj/machinery/stasis_cage) && !istype(item, /obj/machinery/anomaly_container))
		return TRUE
	if(TRADE_TAG_NONEXPORTABLE in item.trade_export_tags)
		return TRUE
	if(istype(item, /obj/item/paper) && !istype(item, /obj/item/paper/manifest))
		return TRUE
	if(istype(item, /obj/machinery/power/supermatter) || istype(item, /obj/structure/AIcore) || istype(item, /obj/item/aicard) || istype(item, /obj/item/aiModule))
		return TRUE
	if(istype(item, /obj/machinery/r_n_d) || istype(item, /obj/machinery/telecomms) || istype(item, /obj/machinery/gravity_generator) || istype(item, /obj/machinery/atm))
		return TRUE
	if(istype(item, /obj/machinery/computer) || istype(item, /obj/machinery/botany) || istype(item, /obj/machinery/vending) || istype(item, /obj/machinery/chemical_dispenser) || istype(item, /obj/machinery/fabricator))
		return TRUE
	if(istype(item, /obj/item/blueprints) || istype(item, /obj/item/cell/infinite) || istype(item, /obj/item/stock_parts/computer/battery_module/lambda))
		return TRUE
	if(istype(item, /obj/item/organ) || istype(item, /obj/item/prosthetic_kit) || istype(item, /obj/item/spacecash) || istype(item, /obj/item/card/id))
		return TRUE
	if(istype(item, /obj/item/reagent_containers) || istype(item, /obj/item/clothing/under) || istype(item, /obj/item/clothing/shoes) || istype(item, /obj/item/clothing/gloves/latex) || istype(item, /obj/item/clothing/mask/surgical))
		return TRUE
	if(istype(item, /obj/item/ore/iron) || istype(item, /obj/item/ore/glass) || istype(item, /obj/item/ore/slag) || istype(item, /obj/item/device/tankassemblyproxy) || istype(item, /obj/item/stack/tile))
		return TRUE
	if(istype(item, /obj/structure/closet/secure_closet/personal/trade))
		return TRUE
	return FALSE

/datum/controller/subsystem/trade/proc/get_export_price_multiplier(atom/target)
	if(!ismovable(target))
		return TRADE_NONEXPORTABLE
	var/atom/movable/item = target
	if(is_class_a_nonexportable(item))
		return TRADE_NONEXPORTABLE
	if(TRADE_TAG_JUNK in item.trade_export_tags)
		return TRADE_JUNK
	if(TRADE_TAG_HOCKABLE in item.trade_export_tags)
		return TRADE_HOCKABLE
	return TRADE_EXPORTABLE

/datum/controller/subsystem/trade/proc/appraise(atom/target)
	var/datum/trade_appraisal/quote = new
	if(!ismovable(target))
		return quote
	var/atom/movable/root = target
	var/list/tree = get_contents_tree(root)
	for(var/atom/movable/item as anything in tree)
		if(is_protected(item))
			quote.blocked = TRUE
			return quote
	for(var/atom/movable/item as anything in tree)
		if(is_class_a_nonexportable(item))
			continue
		var/value = get_legacy_value(item, quote)
		if(isnull(value))
			value = get_class_c_material_value(item, quote)
		if(isnull(value))
			value = get_class_d_salvage_value(item)
		if(value > 0)
			quote.items[item] = value
			quote.total += value
	quote.total = round(quote.total)
	return quote

/datum/controller/subsystem/trade/proc/get_condition_multiplier(atom/movable/item)
	// Native machinery Value() already accounts for broken machines.
	if(istype(item, /obj/machinery) || !item.get_max_health())
		return 1
	return clamp(item.get_current_health() / item.get_max_health(), 0, 1)

/datum/controller/subsystem/trade/proc/get_legacy_value(atom/movable/item, datum/trade_appraisal/quote)
	if(istype(item, /obj/item/disk/research_report))
		var/obj/item/disk/research_report/report = item
		return record_direct_reward_value(quote, "research_reports", report.cargo_value)
	if(istype(item, /obj/item/disk/survey))
		return record_reward_value(quote, "gep", round(item.Value() * 0.05))
	if(istype(item, /obj/item/artefact))
		var/obj/item/artefact/artefact = item
		quote.artefact_points += artefact.cargo_price
		return record_reward_value(quote, "artefacts", artefact.cargo_price)
	if(istype(item, /obj/item/collector))
		return 0
	if(istype(item, /obj/item/virusdish))
		return get_virus_value(item, quote)
	if(istype(item, /obj/item/paper/manifest))
		var/obj/item/paper/manifest/slip = item
		return record_reward_value(quote, "manifest", !slip.is_copy && length(slip.stamped) ? SSsupply.points_per_slip : 0)
	return get_legacy_container_value(item, quote)

/datum/controller/subsystem/trade/proc/get_legacy_container_value(atom/movable/item, datum/trade_appraisal/quote)
	if(istype(item, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = item
		return record_reward_value(quote, "crate", crate.points_per_crate)
	if(istype(item, /obj/structure/largecrate))
		return 0
	if(istype(item, /obj/machinery/stasis_cage))
		var/obj/machinery/stasis_cage/cage = item
		var/mob/living/simple_animal/animal = cage.contained
		if(!animal || is_protected(animal))
			return 0
		return record_reward_value(quote, "animal", get_animal_export_points(animal.type, animal.stat != DEAD))
	if(istype(item, /obj/machinery/anomaly_container))
		var/obj/machinery/anomaly_container/cage = item
		var/points = get_anomaly_value(cage)
		return record_reward_value(quote, "anomaly", points)
	return null

/datum/controller/subsystem/trade/proc/get_animal_export_points(animal_type, alive = TRUE)
	if(!ispath(animal_type, /mob/living/simple_animal) || ispath(animal_type, /mob/living/simple_animal/hostile/human))
		return 0
	var/points = 10 * (ispath(animal_type, /mob/living/simple_animal/hostile) ? 2 : 1) * (alive ? 2 : 1)
	if(ispath(animal_type, /mob/living/simple_animal/hostile/retaliate/beast))
		points *= 2
	return points

/datum/controller/subsystem/trade/proc/record_reward_value(datum/trade_appraisal/quote, source, points)
	points = max(0, points)
	var/thalers = points * TRADE_POINT_VALUE
	if(quote)
		quote.sources[source] += thalers
	return thalers

/datum/controller/subsystem/trade/proc/record_direct_reward_value(datum/trade_appraisal/quote, source, thalers)
	thalers = max(0, round(thalers))
	if(quote)
		quote.sources[source] += thalers
	return thalers

/datum/controller/subsystem/trade/proc/get_virus_value(obj/item/virusdish/dish, datum/trade_appraisal/quote)
	if(!dish.analysed || !dish.virus2?.uniqueID)
		return 0
	var/id = dish.virus2.uniqueID
	if((id in SSsupply.sold_virus_strains) || (quote && (id in quote.virus_strains)))
		return 0
	if(quote)
		quote.virus_strains |= id
	return record_reward_value(quote, "virology_dishes", 5)

/datum/controller/subsystem/trade/proc/get_anomaly_value(obj/machinery/anomaly_container/cage)
	var/obj/machinery/artifact/artifact = cage.contained
	var/obj/item/paper/anomaly_scan/scan = cage.attached_paper
	if(!artifact || !istype(scan) || scan.is_copy)
		return 0
	var/points = 10
	var/list/effects = list(artifact.my_effect, artifact.secondary_effect)
	for(var/datum/artifact_effect/effect as anything in effects)
		if(!effect)
			continue
		var/list/values = list()
		values["[EFFECT_ENERGY]"] = 20
		values["[EFFECT_ELECTRO]"] = 20
		values["[EFFECT_ORGANIC]"] = 30
		values["[EFFECT_SYNTH]"] = 30
		values["[EFFECT_BLUESPACE]"] = 40
		values["[EFFECT_PARTICLE]"] = 40
		points += values["[effect.effect_type]"] || 10
		points += effect.trigger.trigger_type == TRIGGER_COMPLEX ? 10 : (effect.trigger.trigger_type == TRIGGER_SIMPLE ? 5 : 2)
	return points

/datum/controller/subsystem/trade/proc/get_class_c_material_value(atom/movable/item, datum/trade_appraisal/quote)
	if(istype(item, /obj/item/ore))
		var/obj/item/ore/ore = item
		var/unit_val = get_raw_ore_export_value(ore)
		return max(0, unit_val)
	if(istype(item, /obj/item/stack/material))
		var/obj/item/stack/material/stack = item
		var/qty = max(1, stack.get_amount())
		var/unit_val = get_sheet_export_value(stack)
		var/total_val = max(0, unit_val * qty)
		if(total_val > 0 && quote)
			var/mat_name = stack.material?.display_name || "materials"
			quote.sources[mat_name] += total_val
		return total_val
	return null

/datum/controller/subsystem/trade/proc/get_raw_ore_export_value(obj/item/ore/ore)
	if(istype(ore, /obj/item/ore/iron) || istype(ore, /obj/item/ore/glass) || istype(ore, /obj/item/ore/slag))
		return 0
	if(istype(ore, /obj/item/ore/diamond))
		return 55
	if(istype(ore, /obj/item/ore/phoron))
		return 45
	if(istype(ore, /obj/item/ore/gold))
		return 35
	if(istype(ore, /obj/item/ore/osmium))
		return 30
	if(istype(ore, /obj/item/ore/silver))
		return 25
	if(istype(ore, /obj/item/ore/uranium))
		return 15
	if(istype(ore, /obj/item/ore/hydrogen))
		return 60
	var/mat_key = lowertext("[ore.material]")
	switch(mat_key)
		if("iron", "hematite", "glass", "sand", "slag")
			return 0
		if("borax", "rutile", "quartz", "pyrite", "spodumene", "cinnabar", "phosphorite", "rocksalt", "rock salt", "potash", "bauxite", "copper", "graphite", "coal")
			return 8
		if("pitchblende", "uranium")
			return 15
		if("silver")
			return 25
		if("osmium", "electrum")
			return 30
		if("gold")
			return 35
		if("phoron")
			return 45
		if("diamond")
			return 55
		if("platinum", "mhydrogen", "metallic hydrogen", "hydrogen", "tritium")
			return 60
	return 8

/datum/controller/subsystem/trade/proc/get_sheet_export_value(obj/item/stack/material/stack)
	if(istype(stack, /obj/item/stack/material/cardboard) || istype(stack, /obj/item/stack/material/cloth) || istype(stack, /obj/item/stack/material/leather))
		return 0
	if(istype(stack, /obj/item/stack/material/rods))
		return 1
	if(istype(stack, /obj/item/stack/material/glass/boron_reinforced))
		return 35
	if(istype(stack, /obj/item/stack/material/glass/boron))
		return 25
	if(istype(stack, /obj/item/stack/material/glass/reinforced))
		return 6
	if(istype(stack, /obj/item/stack/material/wood/ebony))
		return 35
	if(istype(stack, /obj/item/stack/material/wood/mahogany))
		return 20
	if(istype(stack, /obj/item/stack/material/wood/walnut))
		return 10
	if(istype(stack, /obj/item/stack/material/wood) || istype(stack, /obj/item/stack/material/steel) || istype(stack, /obj/item/stack/material/glass) || istype(stack, /obj/item/stack/material/aluminium))
		return 3
	if(istype(stack, /obj/item/stack/material/plastic))
		return 4
	if(istype(stack, /obj/item/stack/material/plasteel) || istype(stack, /obj/item/stack/material/marble))
		return 12
	if(istype(stack, /obj/item/stack/material/titanium))
		return 15
	if(istype(stack, /obj/item/stack/material/ocp))
		return 20
	if(istype(stack, /obj/item/stack/material/silver))
		return 30
	if(istype(stack, /obj/item/stack/material/osmium))
		return 35
	if(istype(stack, /obj/item/stack/material/gold))
		return 40
	if(istype(stack, /obj/item/stack/material/uranium))
		return 45
	if(istype(stack, /obj/item/stack/material/diamond))
		return 65
	if(istype(stack, /obj/item/stack/material/platinum))
		return 70
	if(istype(stack, /obj/item/stack/material/phoron) || istype(stack, /obj/item/stack/material/mhydrogen))
		return 75
	if(istype(stack, /obj/item/stack/material/tritium))
		return 90
	var/mat_key = lowertext("[stack.material?.name || stack.default_type]")
	switch(mat_key)
		if("cardboard", "cloth", "leather", "concrete", "holo")
			return 0
		if("steel", "glass", "aluminium", "wood", "maple", "yew", "stone", "sandstone")
			return 3
		if("plastic")
			return 4
		if("rglass")
			return 6
		if("walnut")
			return 10
		if("plasteel", "marble", "borax", "rutile", "quartz", "pyrite", "spodumene", "cinnabar", "phosphorite", "rocksalt", "rock salt", "potash", "bauxite", "copper", "graphite", "coal")
			return 12
		if("titanium")
			return 15
		if("mahogany", "ocp", "osmium-carbide plasteel")
			return 20
		if("boron glass", "bglass")
			return 25
		if("silver")
			return 30
		if("ebony", "osmium", "electrum", "reinforced boron glass", "rboron")
			return 35
		if("gold")
			return 40
		if("uranium", "pitchblende")
			return 45
		if("diamond")
			return 65
		if("platinum")
			return 70
		if("phoron", "mhydrogen", "metallic hydrogen")
			return 75
		if("tritium")
			return 90
	return 3

/datum/controller/subsystem/trade/proc/get_class_d_salvage_value(atom/movable/item)
	if(printable_types[item.type])
		return 0
	var/mult = get_export_price_multiplier(item)
	if(mult <= 0)
		return 0
	var/cond = get_condition_multiplier(item)
	var/raw_worth = max(0, get_value(item, include_contents = FALSE))
	var/qty = 1
	if(istype(item, /obj/item/stack))
		var/obj/item/stack/stack = item
		qty = max(1, stack.get_amount())
		if(!isnull(vending_prices[item.type]))
			return 0
	var/val = 0
	if(!isnull(vending_prices[item.type]))
		var/vp = vending_prices[item.type]
		if(vp <= 0)
			return 0
		val = min(floor(raw_worth * TRADE_SALVAGE_MULT * mult * cond), floor(vp * TRADE_VENDOR_EXPORT_CAP))
	else if(istype(item, /obj/item/fossil))
		val = floor(raw_worth * mult * cond)
	else if(istype(item, /obj/machinery) || istype(item, /obj/structure) || istype(item, /obj/item/sealgen_case))
		val = min(TRADE_MACHINERY_SALVAGE_CAP, floor(raw_worth * TRADE_MACHINERY_SALVAGE_MULT * mult * cond))
	else
		val = min(TRADE_SALVAGE_CAP, floor(raw_worth * TRADE_SALVAGE_MULT * mult * cond))
	var/cat_min = get_catalog_min_unit_price(item.type)
	if(!isnull(cat_min))
		val = min(val, floor(cat_min * qty * TRADE_CATALOG_EXPORT_CAP))
	return max(0, val)

/datum/controller/subsystem/trade/proc/get_catalog_min_unit_price(type_path)
	var/path = type_path
	while(path && path != /atom/movable && path != /obj && path != /obj/item)
		if(!isnull(catalog_min_unit_price[path]))
			return catalog_min_unit_price[path]
		path = ispath(path) ? null : null
		break
	return catalog_min_unit_price[type_path]
