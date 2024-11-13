SUBSYSTEM_DEF(init_misc_late)
	name = "Misc Initialization (Late)"
	init_order = SS_INIT_MISC_LATE
	flags = SS_NO_FIRE


/datum/controller/subsystem/init_misc_late/UpdateStat(time)
	if (initialized)
		return
	..()


/datum/controller/subsystem/init_misc_late/Initialize(start_uptime)
	GLOB.using_map.build_away_sites()
	GLOB.using_map.build_exoplanets()
	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	asset_cache.load()
	init_recipes()


GLOBAL_VAR_INIT(microwave_maximum_item_storage, 0)
GLOBAL_LIST_EMPTY(microwave_recipes)
GLOBAL_LIST_EMPTY(microwave_accepts_reagents)
GLOBAL_LIST_EMPTY(microwave_accepts_items)

/datum/controller/subsystem/init_misc_late/proc/init_recipes()
	var/list/reagents = list()
	var/list/items = list(
		/obj/item/holder = TRUE,
		/obj/item/reagent_containers/food/snacks/grown = TRUE
	)
	for (var/datum/microwave_recipe/recipe as anything in subtypesof(/datum/microwave_recipe))
		recipe = new recipe
		recipe.produce_amount = 0
		for (var/tag in recipe.required_produce)
			recipe.produce_amount += recipe.required_produce[tag]
		var/objects_amount = recipe.produce_amount + length(recipe.required_items)
		recipe.weight = objects_amount + length(recipe.required_reagents)
		if (!recipe.result_path || !recipe.weight)
			log_error("Recipe [recipe.type] has invalid results or requirements.")
			continue
		GLOB.microwave_recipes += recipe
		for (var/type in recipe.required_reagents)
			reagents[type] = TRUE
		for (var/type in recipe.required_items)
			items[type] = TRUE
		GLOB.microwave_maximum_item_storage = max(GLOB.microwave_maximum_item_storage, objects_amount)
	for (var/type in reagents)
		GLOB.microwave_accepts_reagents += type
	for (var/type in items)
		GLOB.microwave_accepts_items += type
	sortTim(GLOB.microwave_recipes, GLOBAL_PROC_REF(cmp_microwave_recipes_by_weight_dsc))

/proc/cmp_microwave_recipes_by_weight_dsc(datum/microwave_recipe/a, datum/microwave_recipe/b)
	return a.weight - b.weight
