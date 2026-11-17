/singleton/psionic_power
	abstract_type = /singleton/psionic_power
	var/name             // Name. If null, psipower won't be generated on roundstart.
	var/faculty          // Associated psi faculty.
	var/min_rank         // Minimum psi rank to use this power.
	var/cost             // Base psi stamina cost for using this power.
	var/cooldown         // Deciseconds cooldown after using this power.
	var/admin_log = TRUE // Whether or not using this power prints an admin attack log.
	var/use_ranged       // This power functions from a distance.
	var/use_melee        // This power functions at melee range.
	var/use_grab         // This power has a variant invoked via grab.
	var/use_manifest     // This power manifests an item in the user's hands.
	var/use_description  // A short description of how to use this power, shown via assay.
	var/use_intent       // Intent (I_HELP, I_DISARM, I_GRAB, I_HURT) on which this power is invoked. Null - any intent.
	// A sound effect to play when the power is used.
	var/use_sound = 'sound/effects/psi/power_used.ogg'

/singleton/psionic_power/proc/invoke(mob/living/user, atom/target)

	if(!user.psi)
		return FALSE

	if(!user.psi.ranks_stat[faculty])
		return FALSE

	if(faculty && min_rank)
		var/user_rank = user.psi.get_rank(faculty)
		if(user_rank < min_rank)
			return FALSE

	if(cost && !user.psi.spend_power(cost))
		return FALSE

	var/user_psi_leech = user.do_psionics_check(cost, user)
	if(user_psi_leech)
		to_chat(user, SPAN_WARNING("Your power is leeched away by \the [user_psi_leech] as fast as you can focus it..."))
		return FALSE

	if(target.do_psionics_check(cost, user))
		to_chat(user, SPAN_WARNING("Your power skates across \the [target], but cannot get a grip..."))
		return FALSE

	return TRUE

/singleton/psionic_power/proc/handle_post_power(mob/living/user, atom/target)
	user.psi?.notify_brands()
	if(cooldown)
		user.psi.set_cooldown(cooldown)
	if(admin_log && ismob(user) && ismob(target))
		admin_attack_log(user, target, "Used psipower ([name])", "Was subjected to a psipower ([name])", "used a psipower ([name]) on")
	if(use_sound)
		playsound(user.loc, use_sound, 75)

/// Stable identifier of the power, used to save the choice made in preferences.
/singleton/psionic_power/proc/get_id()
	return replacetext(replacetext("[type]", "/singleton/psionic_power/", ""), "/", ":")

/// Common check for powers that work on a living mind: the target must be a mob that has one.
/singleton/psionic_power/proc/is_valid_mind_target(atom/target)
	var/mob/living/L = target
	if(!istype(L))
		return FALSE
	if(L.is_species(SPECIES_IPC) || L.is_species(SPECIES_ADHERENT))
		return FALSE
	return TRUE

GLOBAL_LIST_EMPTY(psi_selectable_powers) // faculty id -> list of power singletons

/// Powers of the faculty that can be chosen in preferences, ordered by required rank.
/proc/get_selectable_psi_powers(faculty_id)
	if(!length(GLOB.psi_selectable_powers))
		var/list/powers = GET_SINGLETON_SUBTYPE_MAP(/singleton/psionic_power)
		for(var/ptype in powers)
			var/singleton/psionic_power/power = powers[ptype]
			if(!power.name || !power.faculty)
				continue
			if(!GLOB.psi_selectable_powers[power.faculty])
				GLOB.psi_selectable_powers[power.faculty] = list()
			GLOB.psi_selectable_powers[power.faculty] += power
		for(var/fid in GLOB.psi_selectable_powers)
			var/list/L = GLOB.psi_selectable_powers[fid]
			for(var/i in 2 to length(L))
				var/singleton/psionic_power/current = L[i]
				var/j = i - 1
				while(j >= 1)
					var/singleton/psionic_power/other = L[j]
					if(other.min_rank <= current.min_rank)
						break
					L[j + 1] = other
					--j
				L[j + 1] = current
	return GLOB.psi_selectable_powers[faculty_id] || list()
