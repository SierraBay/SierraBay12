/singleton/cooking_recipe
	/// An /atom/movable/... path. Required.
	var/atom/result_path
	var/result_quantity = 1 //number of instances of result that are created.

	/// A base ds time for how long the recipe waits before completing.
	var/time = 10 SECONDS

	/// A map? of (/datum/reagent/... = amount). Highest specificity first. Reagent is transfered to final item.
	var/list/datum/reagent/required_reagents

	/// A map of (/datum/reagent/... = amount); get consumed and is not transfered to final item.
	var/list/datum/reagent/consumed_reagents

	/// A list? of (/obj/item/...). Highest specificity first. Multiple entries for multiple same items.
	var/list/obj/item/required_items

	/// A map? of ("fruit tag" = amount).
	var/list/required_produce

	/// What scent does it give off when cooked?
	var/datum/extension/scent/cooked_scent

	/// The sum of required_produce entries. Generated.
	var/produce_amount

	/// The sum length of each required_* for sorting. Generated. Must be > 0.
	var/weight

	// Codex values.
	var/display_name
	var/hidden_from_codex
	var/lore_text
	var/mechanics_text
	var/antag_text

	#define RECIPE_REAGENT_REPLACE		0 //Reagents in the ingredients are discarded.
	#define RECIPE_REAGENT_MAX			1 //The result will contain the maximum of each reagent present between the two pools. Compiletime result, and sum of ingredients
	#define RECIPE_REAGENT_MIN 			2 //As above, but the minimum, ignoring zero values.
	#define RECIPE_REAGENT_SUM 			3 //The entire quantity of the ingredients are added to the result

	var/reagent_mix = RECIPE_REAGENT_SUM	//How to handle reagent differences between the ingredients and the results

	/// Which appliances this recipe can be made in.
	var/appliance = COOKING_APPLIANCE_MIX

/singleton/cooking_recipe/proc/get_appliance_names()
	var/list/appliance_names
	if(appliance & COOKING_APPLIANCE_GRILL)
		LAZYADD(appliance_names, "a grill")
	if(appliance & COOKING_APPLIANCE_MIX)
		LAZYADD(appliance_names, "a mixing bowl or plate")
	if(appliance & COOKING_APPLIANCE_FRYER)
		LAZYADD(appliance_names, "a fryer")
	if(appliance & COOKING_APPLIANCE_OVEN)
		LAZYADD(appliance_names, "an oven")
	if(appliance & COOKING_APPLIANCE_SKILLET)
		LAZYADD(appliance_names, "a skillet")
	if(appliance & COOKING_APPLIANCE_SAUCEPAN)
		LAZYADD(appliance_names, "a saucepan")
	if(appliance & COOKING_APPLIANCE_POT)
		LAZYADD(appliance_names, "a pot")
	return english_list(appliance_names, and_text = " or ")

///Creates the result and transfers over all reagents (except those in consumed_reagents) and reagents from ingredients EXCEPT nutriment.
///Nutriment is handled by nutriment_amt at level of the created item; not transferred here.
/singleton/cooking_recipe/proc/CreateResult(obj/container as obj, ...)
	if(!result_path)
		return

//We will subtract all the ingredients from the container, and transfer their reagents into a holder
//We will not touch things which are not required for this recipe. They will be left behind for the caller
//to decide what to do. They may be used again to make another recipe or discarded, or merged into the results,
//thats no longer the concern of this proc
	var/datum/reagents/buffer = new /datum/reagents(1e12, GLOB.temp_reagents_holder)

	if (LAZYLEN(required_items))
		for (var/item in required_items)
			var/obj/item/obj_item = locate(item) in container
			if (obj_item && obj_item.reagents)
				obj_item.reagents.trans_to_holder(buffer, obj_item.reagents.total_volume)
				qdel(obj_item)

	if (LAZYLEN(required_produce))
		var/list/checklist = list()
		checklist = required_produce.Copy()

		for(var/obj/item/reagent_containers/food/snacks/grown/grown in container)
			if(!grown.seed || !grown.seed.kitchen_tag || isnull(checklist[grown.seed.kitchen_tag]))
				continue

			if (checklist[grown.seed.kitchen_tag] > 0)
				checklist[grown.seed.kitchen_tag]--
				if (grown && grown.reagents)
					grown.reagents.trans_to_holder(buffer, grown.reagents.total_volume)
				qdel(grown)

	if (LAZYLEN(consumed_reagents))
		for (var/reagent in consumed_reagents)
			container.reagents.remove_reagent(reagent, consumed_reagents[reagent])
	if (LAZYLEN(required_reagents))
		for (var/reagent in required_reagents)
			container.reagents.trans_type_to_holder(buffer, reagent, required_reagents[reagent])

	/*
	Now we've removed all the ingredients that were used and we have the buffer containing the total of
	all their reagents.
	If we have multiple results, holder will be used as a buffer to hold reagents for the result objects.
	If, as in the most common case, there is only a single result, then it will just be a reference to
	the single-result's reagents
	*/
	var/datum/reagents/holder = new/datum/reagents(10000000000, GLOB.temp_reagents_holder)
	var/list/results = list()
	for (var/_ in 1 to result_quantity)
		var/obj/result_obj = new result_path(container)
		results.Add(result_obj)

		if (!result_obj.reagents)
			result_obj.create_reagents(buffer.total_volume*1.5)

		if (result_quantity == 1)
			qdel(holder)
			holder = result_obj.reagents
		else
			result_obj.reagents.trans_to_holder(holder, result_obj.reagents.total_volume)

	switch(reagent_mix)
		if (RECIPE_REAGENT_SUM)
			buffer.trans_to_holder(holder, buffer.total_volume)
		if (RECIPE_REAGENT_MAX)
			for (var/datum/reagent/reagent in buffer.reagent_list)
				var/rvol = holder.get_reagent_amount(reagent.type)
				if (rvol < reagent.volume)
					buffer.trans_type_to_holder(holder, reagent, reagent.volume-rvol)

		if (RECIPE_REAGENT_MIN)
			for (var/datum/reagent/reagent in buffer.reagent_list)
				var/rvol = holder.get_reagent_amount(reagent.type)
				var/bvol = reagent.volume
				if (rvol == 0)
					buffer.trans_type_to_holder(holder, reagent, bvol)
				else if (rvol > bvol)
					holder.remove_reagent(reagent, rvol-bvol)

	var/total = holder.total_volume
	for (var/i in results)
		var/obj/result_obj = i
		holder.trans_to_obj(result_obj, total / length(results))
		if (cooked_scent)
			set_extension(result_obj, cooked_scent)

	return results

/singleton/cooking_recipe/proc/CheckReagents(datum/reagents/reagents)
	var/required_count = length(required_reagents) + length(consumed_reagents)
	if (!required_count)
		return reagents.total_volume ? COOKING_CHECK_EXTRA : COOKING_CHECK_EXACT
	if (required_count > length(reagents.reagent_list))
		return COOKING_CHECK_FAIL
	. = COOKING_CHECK_EXACT
	var/list/datum/reagent/reagents_to_check = list()
	for (var/datum/reagent/reagent as anything in consumed_reagents)
		reagents_to_check[reagent] = consumed_reagents[reagent]
	for (var/datum/reagent/reagent as anything in required_reagents)
		if(reagents_to_check[reagent])
			reagents_to_check[reagent] += required_reagents[reagent]
		else
			reagents_to_check[reagent] = required_reagents[reagent]
	for (var/datum/reagent/reagent as anything in reagents_to_check)
		var/available_amount = reagents.get_reagent_amount(reagent)
		if (available_amount - reagents_to_check[reagent] >= 0)
			if (available_amount > reagents_to_check[reagent])
				. = COOKING_CHECK_EXTRA
		else
			return COOKING_CHECK_FAIL
	return .


/singleton/cooking_recipe/proc/CheckProduce(list/ingredients)
	if (!produce_amount)
		var/obj/item/reagent_containers/food/snacks/grown/grown = locate() in ingredients
		return grown ? COOKING_CHECK_EXTRA : COOKING_CHECK_EXACT
	if (produce_amount > length(ingredients))
		return COOKING_CHECK_FAIL
	var/list/remaining_produce = required_produce.Copy()
	. = COOKING_CHECK_EXACT
	for (var/obj/item/reagent_containers/food/snacks/grown/grown in ingredients)
		var/tag = grown.seed?.kitchen_tag
		if (!tag)
			return COOKING_CHECK_FAIL
		if (--remaining_produce[tag] < 0)
			. = COOKING_CHECK_EXTRA
	for (var/tag in remaining_produce)
		if (remaining_produce[tag])
			return COOKING_CHECK_FAIL
	return .


/singleton/cooking_recipe/proc/CheckItems(obj/container as obj)
	var/required_count = length(required_items)
	if (!required_count)
		return length(container?.contents) ? COOKING_CHECK_EXTRA : COOKING_CHECK_EXACT
	if (required_count > length(container.contents))
		return COOKING_CHECK_FAIL
	. = COOKING_CHECK_EXACT
	var/list/remaining = required_items.Copy()
	for (var/obj/item/item as anything in container)
		if (istype(item, /obj/item/reagent_containers/food/snacks/grown))
			continue
		var/remaining_count = length(remaining)
		if (!remaining_count)
			return COOKING_CHECK_FAIL
		var/found = FALSE
		for (var/i = 1 to length(remaining))
			if (istype(item, remaining[i]))
				remaining.Cut(i, i + 1)
				found = TRUE
				break

		if (!found)
			. = COOKING_CHECK_EXTRA
		if (!length(remaining) && . != COOKING_CHECK_EXTRA)
			return COOKING_CHECK_EXTRA
	if (length(remaining))
		return COOKING_CHECK_FAIL
	return .

//When exact is false, extraneous ingredients are ignored
//When exact is true, extraneous ingredients will fail the recipe
//In both cases, the full complement of required inredients is still needed
/proc/select_recipe(obj/obj as obj, exact = COOKING_CHECK_EXTRA, appliance = null)
	if(!appliance)
		CRASH("Null appliance flag passed to select_recipe!")
	var/list/possible_recipes = list()
	for (var/singleton/cooking_recipe/candidate as anything in GLOB.microwave_recipes)
		if(!(appliance & candidate.appliance))
			continue
		if((candidate.CheckReagents(obj.reagents) < exact) || (candidate.CheckItems(obj) < exact) || (candidate.CheckProduce(obj) < exact))
			continue
		possible_recipes |= candidate
	if (!length(possible_recipes))
		return null
	sortTim(possible_recipes, GLOBAL_PROC_REF(cmp_recipe_complexity_dsc)) // Select the most complex recipe
	return possible_recipes[1]
