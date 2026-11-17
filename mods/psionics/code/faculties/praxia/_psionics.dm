/datum/psi_complexus
	var/ward_until = 0
	var/mirror_until = 0
	var/null_field_active = FALSE
	var/list/branded_by

/datum/psi_complexus/proc/is_warded()
	return world.time < ward_until

/datum/psi_complexus/proc/is_mirroring()
	return world.time < mirror_until

/datum/psi_complexus/proc/notify_brands()
	if(!LAZYLEN(branded_by) || !owner)
		return
	for(var/mob/living/brander in branded_by.Copy())
		if(QDELETED(brander) || world.time >= branded_by[brander])
			branded_by -= brander
			continue
		if(brander.z != owner.z)
			to_chat(brander, SPAN_OCCULT("Метка на [owner] вспыхивает: он применил силу где-то очень далеко."))
		else
			to_chat(brander, SPAN_OCCULT("Метка на [owner] вспыхивает: он применил силу, примерно в [get_dist(brander, owner)] шагах на [dir2text(get_dir(brander, owner))]."))
	if(!LAZYLEN(branded_by))
		branded_by = null

/datum/psi_complexus/proc/psi_show_marker(mob/viewer, atom/A, duration = 5 SECONDS)
	set waitfor = FALSE
	if(!viewer || !viewer.client || !A)
		return
	var/image/marker = image('icons/effects/effects.dmi', A, "cyan_sparkles")
	marker.layer = FLY_LAYER
	viewer.client.images += marker
	sleep(duration)
	if(viewer && viewer.client)
		viewer.client.images -= marker
	qdel(marker)

/singleton/psionic_power/praxia/psionics
	abstract_type = /singleton/psionic_power/praxia/psionics

/singleton/psionic_power/praxia/psionics/proc/zone_is(mob/living/user, list/zones)
	return (user.zone_sel && (user.zone_sel.selecting in zones))

/singleton/psionic_power/praxia/psionics/proc/contest_chance(mob/living/user, mob/living/target)
	var/user_rank = user.psi.get_rank(PSI_PRAXIA)
	var/target_rank = 0
	if(target.psi)
		for(var/faculty in target.psi.ranks)
			target_rank = max(target_rank, target.psi.ranks[faculty])
	return clamp(50 + 15 * (user_rank - target_rank), 10, 90)
