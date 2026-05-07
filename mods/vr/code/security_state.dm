/datum/map
	var/list/vr_levels = list()

/singleton/security_level
	var/kick_vr_users = FALSE

/singleton/security_state/set_security_level(singleton/security_level/new_security_level, force_change = FALSE)
	if (new_security_level.kick_vr_users) // wake the fuck up, samurai
		for (var/mob/living/M in SSvirtual_reality.virtual_occupants_to_mobs)
			var/turf/T = get_turf(M)
			if (T.z in GLOB.using_map.contact_levels)
				var/mob/living/surrogate = SSvirtual_reality.virtual_occupants_to_mobs[M]
				to_chat(surrogate, SPAN_DANGER(FONT_LARGE("ALERT: VR is no longer safe to use. Connection terminated.")))
				SSvirtual_reality.remove_virtual_mob(M, TRUE, silent = TRUE)
	..()