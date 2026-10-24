/datum/trade_appraisal
	var/list/items = list()
	var/list/sources = list()
	var/list/virus_strains = list()
	var/total = 0
	var/artefact_points = 0

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
		for(var/atom/movable/child as anything in target.contents)
			if(istype(child))
				tree |= child
	return length(tree) <= TRADE_EXPORT_LIMIT ? tree : list()

/datum/controller/subsystem/trade/proc/is_protected(atom/movable/target)
	if(ismob(target))
		var/mob/subject = target
		return subject.mind || subject.client || !istype(subject, /mob/living/simple_animal) || istype(subject, /mob/living/simple_animal/hostile/human) || !istype(subject.loc, /obj/machinery/stasis_cage)
	return istype(target, /obj/item/disk/nuclear) || istype(target, /obj/machinery/nuclearbomb) || istype(target, /obj/machinery/tele_beacon) || istype(target, /obj/machinery/trade_beacon)

/datum/controller/subsystem/trade/proc/get_export_price_multiplier(atom/target)
	if(!ismovable(target))
		return TRADE_NONEXPORTABLE
	var/atom/movable/item = target
	if(item.anchored || is_protected(item) || istype(item, /obj/item/paper) || ismob(item))
		return TRADE_NONEXPORTABLE
	if(TRADE_TAG_NONEXPORTABLE in item.trade_export_tags)
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
			return quote
	for(var/atom/movable/item as anything in tree)
		if(TRADE_TAG_NONEXPORTABLE in item.trade_export_tags)
			continue
		var/value = get_legacy_value(item, quote)
		if(isnull(value))
			value = max(0, get_value(item, include_contents = FALSE)) * get_export_price_multiplier(item) * get_condition_multiplier(item)
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
		return record_reward_value(quote, "research_reports", report.cargo_value)
	if(istype(item, /obj/item/disk/survey))
		return record_reward_value(quote, "gep", round(item.Value() * 0.05))
	if(istype(item, /obj/item/artefact))
		var/obj/item/artefact/artefact = item
		quote.artefact_points += artefact.cargo_price
		return record_reward_value(quote, "artefacts", artefact.cargo_price)
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
	if(istype(item, /obj/machinery/stasis_cage))
		var/obj/machinery/stasis_cage/cage = item
		var/mob/living/simple_animal/animal = cage.contained
		if(!animal || is_protected(animal))
			return 0
		var/points = 10 * (istype(animal, /mob/living/simple_animal/hostile) ? 2 : 1) * (animal.stat != DEAD ? 2 : 1)
		if(istype(animal, /mob/living/simple_animal/hostile/retaliate/beast))
			points *= 2
		quote.items[animal] = 0
		return record_reward_value(quote, "animal", points)
	if(istype(item, /obj/machinery/anomaly_container))
		var/obj/machinery/anomaly_container/cage = item
		var/points = get_anomaly_value(cage)
		if(points)
			quote.items[cage.contained] = 0
		return record_reward_value(quote, "anomaly", points)
	return null

/datum/controller/subsystem/trade/proc/record_reward_value(datum/trade_appraisal/quote, source, points)
	points = max(0, points)
	quote.sources[source] += points * TRADE_POINT_VALUE
	return points * TRADE_POINT_VALUE

/datum/controller/subsystem/trade/proc/get_virus_value(obj/item/virusdish/dish, datum/trade_appraisal/quote)
	if(!dish.analysed || !dish.virus2?.uniqueID)
		return 0
	var/id = dish.virus2.uniqueID
	if((id in SSsupply.sold_virus_strains) || (id in quote.virus_strains))
		return 0
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
