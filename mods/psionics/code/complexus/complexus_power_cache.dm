/datum/psi_complexus/proc/rebuild_power_cache()
	if(rebuild_power_cache)

		melee_powers =         list()
		grab_powers =          list()
		ranged_powers =        list()
		manifestation_powers = list()
		powers_by_faculty =    list()

		for(var/faculty in ranks)
			var/relevant_rank = get_rank(faculty)
			var/singleton/psionic_faculty/faculty_singleton = SSpsi.get_faculty(faculty)
			if(!faculty_singleton)
				continue
			for(var/thing in faculty_singleton.powers)
				var/singleton/psionic_power/power = thing
				if(relevant_rank >= power.min_rank && is_power_selected(power))
					if(!powers_by_faculty[power.faculty]) powers_by_faculty[power.faculty] = list()
					powers_by_faculty[power.faculty] += power
					if(power.use_ranged)
						if(!ranged_powers[faculty]) ranged_powers[faculty] = list()
						ranged_powers[faculty] += power
					if(power.use_melee)
						if(!melee_powers[faculty]) melee_powers[faculty] = list()
						melee_powers[faculty] += power
					if(power.use_manifest)
						manifestation_powers += power
					if(power.use_grab)
						if(!grab_powers[faculty]) grab_powers[faculty] = list()
						grab_powers[faculty] += power
		rebuild_power_cache = FALSE

/datum/psi_complexus/proc/get_powers_by_faculty(faculty)
	rebuild_power_cache()
	return powers_by_faculty[faculty]

/datum/psi_complexus/proc/get_melee_powers(faculty)
	rebuild_power_cache()
	return melee_powers[faculty]

/datum/psi_complexus/proc/get_ranged_powers(faculty)
	rebuild_power_cache()
	return ranged_powers[faculty]

/datum/psi_complexus/proc/get_grab_powers(faculty)
	rebuild_power_cache()
	return grab_powers[faculty]

/datum/psi_complexus/proc/get_manifestations()
	rebuild_power_cache()
	return manifestation_powers

/// Replaces the list of powers the owner has chosen to use within a faculty (see preferences).
/datum/psi_complexus/proc/set_selected_powers(faculty, list/power_ids)
	faculty = psi_normalize_faculty(faculty)
	LAZYSET(selected_powers, faculty, power_ids ? power_ids.Copy() : list())
	rebuild_power_cache = TRUE

/// Whether the power may be used: it has to be chosen, unless the faculty has no selection at all
/// or its rank is temporarily boosted above the base rank (amplifier helmet, three-eye).
/datum/psi_complexus/proc/is_power_selected(singleton/psionic_power/power)
	var/list/chosen = LAZYACCESS(selected_powers, power.faculty)
	if(isnull(chosen))
		return TRUE
	if(get_rank(power.faculty) > (LAZYACCESS(base_ranks, power.faculty) || 0))
		return TRUE
	return (power.get_id() in chosen)

/// Whether the owner currently has access to the power (rank, selection and faculty state are all taken into account).
/datum/psi_complexus/proc/has_power(power_type)
	rebuild_power_cache()
	var/singleton/psionic_power/power = GET_SINGLETON(power_type)
	if(!power)
		return FALSE
	var/list/available = powers_by_faculty[power.faculty]
	return (power in available)

/// Id of all psi-powers OR selected only, if chosen any.
/datum/psi_complexus/proc/get_selected_power_ids(faculty)
	faculty = psi_normalize_faculty(faculty)
	var/list/chosen = LAZYACCESS(selected_powers, faculty)
	if(!isnull(chosen))
		return chosen.Copy()
	. = list()
	var/rank = get_rank(faculty) || 0
	for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
		if(rank >= power.min_rank)
			. += power.get_id()

/// Gives psi-power by type, levels up rank, if ability needs higher rank
/datum/psi_complexus/proc/grant_power(singleton/psionic_power/power)
	var/list/ids = get_selected_power_ids(power.faculty)
	ids |= power.get_id()
	if((get_rank(power.faculty) || 0) < power.min_rank)
		set_rank(power.faculty, power.min_rank, TRUE)
	set_selected_powers(power.faculty, ids)
	update(TRUE)

/// Ditto
/datum/psi_complexus/proc/revoke_power(singleton/psionic_power/power)
	var/list/ids = get_selected_power_ids(power.faculty)
	ids -= power.get_id()
	set_selected_powers(power.faculty, ids)
