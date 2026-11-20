#define PSI_DISORDER_NONE "none"
#define PSI_DISORDER_CUSTOM "custom"

GLOBAL_LIST_AS(psi_disorder_groups, list("green", "blue", "red"))
GLOBAL_LIST_AS(psi_disorder_group_names, list("green" = "Зелёная группа - небольшой дискомфорт", "blue" = "Синяя группа - весомое влияние на жизнь и поведение", "red" = "Красная группа - невменяемость"))
GLOBAL_LIST_AS(psi_disorder_group_colors, list("green" = COLOR_CYBERUI_GREEN, "blue" = COLOR_CYBERUI_BLUE, "red" = COLOR_CYBERUI_RED))

/singleton/psi_disorder
	abstract_type = /singleton/psi_disorder
	var/id
	var/name
	var/group
	var/description
	var/delay_min = 30 SECONDS
	var/delay_max = 60 SECONDS

/singleton/psi_disorder/proc/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	return

/singleton/psi_disorder/proc/on_apply(mob/living/owner, datum/psi_complexus/psi, list/state)
	return

/singleton/psi_disorder/proc/blocks_power(mob/living/owner, datum/psi_complexus/psi, singleton/psionic_power/power, list/state)
	return FALSE

/singleton/psi_disorder/proc/on_power_used(mob/living/owner, datum/psi_complexus/psi, singleton/psionic_power/power, list/state)
	return

/singleton/psi_disorder/proc/get_name(list/state)
	return name

/singleton/psi_disorder/proc/get_description(list/state)
	return description


GLOBAL_LIST_EMPTY(psi_disorders_by_id)

/proc/get_psi_disorders()
	if(!length(GLOB.psi_disorders_by_id))
		var/list/all = GET_SINGLETON_SUBTYPE_MAP(/singleton/psi_disorder)
		for(var/disorder_type in all)
			var/singleton/psi_disorder/D = all[disorder_type]
			if(D.id)
				GLOB.psi_disorders_by_id[D.id] = D
	return GLOB.psi_disorders_by_id

/proc/get_psi_disorder(id)
	var/list/all = get_psi_disorders()
	return all[id]

/proc/get_psi_disorders_in_group(group)
	. = list()
	var/list/all = get_psi_disorders()
	for(var/id in all)
		var/singleton/psi_disorder/D = all[id]
		if(D.group == group)
			. += D


/datum/psi_complexus
	var/list/disorders

/datum/psi_complexus/proc/add_disorder(id, list/extra)
	var/singleton/psi_disorder/D = get_psi_disorder(id)
	if(!D || !owner)
		return FALSE
	var/list/state = list("next" = world.time + rand(D.delay_min, D.delay_max))
	if(extra)
		for(var/key in extra)
			state[key] = extra[key]
	LAZYSET(disorders, id, state)
	D.on_apply(owner, src, state)
	owner.verbs |= /mob/living/proc/view_psi_disorders
	return TRUE

/datum/psi_complexus/proc/remove_disorder(id)
	LAZYREMOVE(disorders, id)
	if(!LAZYLEN(disorders))
		disorders = null
		owner?.verbs -= /mob/living/proc/view_psi_disorders

/datum/psi_complexus/proc/apply_pref_disorders(datum/preferences/P)
	if(!P || !islist(P.psi_disorders))
		return
	for(var/group in GLOB.psi_disorder_groups)
		var/id = P.psi_disorders[group]
		if(!id || id == PSI_DISORDER_NONE)
			continue
		if(id == PSI_DISORDER_CUSTOM)
			if(length(P.psi_custom_name))
				add_disorder(PSI_DISORDER_CUSTOM, list("name" = P.psi_custom_name, "desc" = P.psi_custom_desc, "group" = group))
		else
			add_disorder(id)

/datum/psi_complexus/proc/process_disorders()
	if(!LAZYLEN(disorders) || !owner || owner.stat == DEAD)
		return
	for(var/id in disorders)
		var/singleton/psi_disorder/D = get_psi_disorder(id)
		var/list/state = disorders[id]
		if(!D || !state)
			continue
		if(world.time < state["next"])
			continue
		state["next"] = world.time + rand(D.delay_min, D.delay_max)
		D.process(owner, src, state)

/datum/psi_complexus/proc/disorders_block_power(singleton/psionic_power/power)
	if(!LAZYLEN(disorders) || !owner)
		return FALSE
	for(var/id in disorders)
		var/singleton/psi_disorder/D = get_psi_disorder(id)
		if(D && D.blocks_power(owner, src, power, disorders[id]))
			return TRUE
	return FALSE

/datum/psi_complexus/proc/disorders_power_used(singleton/psionic_power/power)
	if(!LAZYLEN(disorders) || !owner)
		return
	for(var/id in disorders)
		var/singleton/psi_disorder/D = get_psi_disorder(id)
		if(D)
			D.on_power_used(owner, src, power, disorders[id])

/mob/living/proc/view_psi_disorders()
	set name = "Remember disorders"
	set category = "IC"
	if(!psi || !LAZYLEN(psi.disorders))
		to_chat(src, SPAN_NOTICE("У тебя нет пси-расстройств."))
		return
	to_chat(src, "<hr>")
	for(var/id in psi.disorders)
		var/singleton/psi_disorder/D = get_psi_disorder(id)
		var/list/state = psi.disorders[id]
		if(!D)
			continue
		var/group = D.group || state["group"]
		to_chat(src, "<font color='[GLOB.psi_disorder_group_colors[group]]'><b>[D.get_name(state)]</b></font> ([GLOB.psi_disorder_group_names[group]])")
		to_chat(src, SPAN_NOTICE(D.get_description(state)))
	to_chat(src, "<hr>")
