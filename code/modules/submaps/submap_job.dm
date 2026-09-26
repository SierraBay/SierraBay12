/// Bitflags: vessel-local Crew Records authority for /datum/job/submap (away ships).
#define CREW_RECORDS_AUTH_NONE     0
#define CREW_RECORDS_AUTH_MEDICAL  FLAG_01
#define CREW_RECORDS_AUTH_SECURITY FLAG_02
#define CREW_RECORDS_AUTH_COMMAND  FLAG_03

/datum/job/submap
	title = "Survivor"
	supervisors = "your conscience"
	account_allowed = FALSE
	latejoin_at_spawnpoints = TRUE
	announced = FALSE
	create_record = FALSE
	total_positions = 4
	outfit_type = /singleton/hierarchy/outfit/job/assistant
	hud_icon = "hudblank"
	available_by_default = FALSE
	allowed_ranks = null
	allowed_branches = null
	skill_points = 25
	give_psionic_implant_on_join = FALSE
	max_skill = list(   SKILL_BUREAUCRACY = SKILL_MAX,
	                    SKILL_FINANCE = SKILL_MAX,
	                    SKILL_EVA = SKILL_MAX,
	                    SKILL_MECH = SKILL_MAX,
	                    SKILL_PILOT = SKILL_MAX,
	                    SKILL_HAULING = SKILL_MAX,
	                    SKILL_COMPUTER = SKILL_MAX,
	                    SKILL_BOTANY = SKILL_MAX,
	                    SKILL_COOKING = SKILL_MAX,
	                    SKILL_COMBAT = SKILL_MAX,
	                    SKILL_WEAPONS = SKILL_MAX,
	                    SKILL_FORENSICS = SKILL_MAX,
	                    SKILL_CONSTRUCTION = SKILL_MAX,
	                    SKILL_ELECTRICAL = SKILL_MAX,
	                    SKILL_ATMOS = SKILL_MAX,
	                    SKILL_ENGINES = SKILL_MAX,
	                    SKILL_DEVICES = SKILL_MAX,
	                    SKILL_SCIENCE = SKILL_MAX,
	                    SKILL_MEDICAL = SKILL_MAX,
	                    SKILL_ANATOMY = SKILL_MAX,
	                    SKILL_CHEMISTRY = SKILL_MAX)

	var/info = "You have survived a terrible disaster. Make the best of things that you can."
	var/rank
	var/branch
	var/list/spawnpoints
	var/datum/submap/owner
	var/list/blacklisted_species = RESTRICTED_SPECIES
	var/list/whitelisted_species = UNRESTRICTED_SPECIES
	/// Explicit Crew Records authority on this vessel (see CREW_RECORDS_AUTH_*). 0 = infer from role.
	var/crew_records_auth = CREW_RECORDS_AUTH_NONE

/datum/job/submap/New(datum/submap/_owner, abstract_job = FALSE)
	if(!abstract_job)
		spawnpoints = list()
		owner = _owner
		..()

/datum/job/submap/proc/is_crew_records_subordinate()
	return ("requires_supervisor" in vars) && vars["requires_supervisor"]

/// Authority used to grant station record accesses on this ship's computers.
/datum/job/submap/proc/get_crew_records_authority(mob/user)
	. = crew_records_auth
	if(.)
		return
	. = CREW_RECORDS_AUTH_NONE
	var/display_title = user?.mind?.role_alt_title || title
	var/lower = lowertext(display_title)
	var/subordinate = is_crew_records_subordinate()

	if(!subordinate && total_positions == 1)
		. |= CREW_RECORDS_AUTH_COMMAND
	if(findtext(lower, "captain") || findtext(lower, "commander") || findtext(lower, "leader") || (findtext(lower, "merchant") && !subordinate))
		. |= CREW_RECORDS_AUTH_COMMAND
	if(findtext(lower, "medic") || findtext(lower, "doctor") || findtext(lower, "surgeon") || findtext(lower, "corpsman"))
		. |= CREW_RECORDS_AUTH_MEDICAL
	if(findtext(lower, "secur") || findtext(lower, "warden"))
		. |= CREW_RECORDS_AUTH_SECURITY

/// Station record access constants corresponding to vessel-local authority flags.
/proc/access_list_for_crew_records_auth(auth)
	RETURN_TYPE(/list)
	. = list()
	if(auth & CREW_RECORDS_AUTH_COMMAND)
		. |= access_employment_records
		. |= access_change_ids
		. |= access_bridge
		. |= access_medical_records
		. |= access_security_records
		. |= access_brig
	if(auth & CREW_RECORDS_AUTH_MEDICAL)
		. |= access_medical_records
	if(auth & CREW_RECORDS_AUTH_SECURITY)
		. |= access_security_records
		. |= access_brig
	return .

/// Inject vessel-local record accesses when the computer is on an away ship.
/proc/augment_vessel_crew_record_access(mob/user, list/access, atom/host)
	RETURN_TYPE(/list)
	if(!access)
		access = list()
	else
		access = access.Copy()
	var/obj/overmap/visitable/sector = get_overmap_sector_for_atom(host)
	if(!sector || HAS_FLAGS(sector.sector_flags, OVERMAP_SECTOR_BASE))
		return access
	if(!istype(user?.mind?.assigned_job, /datum/job/submap))
		return access
	var/datum/job/submap/job = user.mind.assigned_job
	if(job.owner && get_vessel_key_for_sector(map_sectors["[job.owner.associated_z]"]) != get_vessel_key_for_atom(host))
		// Not this vessel's crew — no local record privileges.
		return access
	access |= access_list_for_crew_records_auth(job.get_crew_records_authority(user))
	return access

/datum/job/submap/is_species_allowed(singleton/species/S)
	if(LAZYLEN(whitelisted_species) && !(S.name in whitelisted_species))
		return FALSE
	if(S.name in blacklisted_species)
		return FALSE
	if(owner && owner.archetype)
		if(LAZYLEN(owner.archetype.whitelisted_species) && !(S.name in owner.archetype.whitelisted_species))
			return FALSE
		if(S.name in owner.archetype.blacklisted_species)
			return FALSE
	return TRUE

/datum/job/submap/is_restricted(datum/preferences/prefs, feedback)
	var/singleton/species/S = GLOB.species_by_name[prefs.species]
	var/ship_name = owner?.archetype?.descriptor || "this vessel"
	if(LAZYACCESS(minimum_character_age, S.get_bodytype()) && (prefs.age < minimum_character_age[S.get_bodytype()]))
		to_chat(feedback, SPAN_CLASS("boldannounce", "Not old enough. Minimum character age is [minimum_character_age[S.get_bodytype()]]."))
		return TRUE
	if(LAZYLEN(whitelisted_species) && !(prefs.species in whitelisted_species))
		to_chat(feedback, SPAN_CLASS("boldannounce", "Your current species, [prefs.species], is not permitted as [title] on \a [ship_name]."))
		return TRUE
	if(prefs.species in blacklisted_species)
		to_chat(feedback, SPAN_CLASS("boldannounce", "Your current species, [prefs.species], is not permitted as [title] on \a [ship_name]."))
		return TRUE
	if(owner && owner.archetype)
		if(LAZYLEN(owner.archetype.whitelisted_species) && !(prefs.species in owner.archetype.whitelisted_species))
			to_chat(feedback, SPAN_CLASS("boldannounce", "Your current species, [prefs.species], is not permitted on \a [owner.archetype.descriptor]."))
			return TRUE
		if(prefs.species in owner.archetype.blacklisted_species)
			to_chat(feedback, SPAN_CLASS("boldannounce", "Your current species, [prefs.species], is not permitted on \a [owner.archetype.descriptor]."))
			return TRUE
	return FALSE

/datum/job/submap/check_is_active(mob/M)
	. = (..() && M.faction == owner.name)
