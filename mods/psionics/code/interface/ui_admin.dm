var/global/datum/psi_admin_panel/psi_admin_panel = new

/datum/psi_admin_panel

/datum/psi_admin_panel/CanUseTopic(mob/user, datum/topic_state/state = GLOB.default_state)
	return (user.client && check_rights(R_ADMIN, FALSE, user.client))

/datum/psi_admin_panel/Topic(href, list/href_list)
	. = ..()
	if(. || !check_rights(R_ADMIN))
		return

	var/mob/living/target = locate(href_list["target"])
	if(!istype(target) || QDELETED(target))
		return TRUE

	var/singleton/psionic_power/chosen_power
	var/power_id = href_list["power"]
	for(var/faculty in GLOB.psi_faculty_ids)
		for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
			if(power.get_id() == power_id)
				chosen_power = power
				break
		if(chosen_power)
			break
	if(!chosen_power)
		return TRUE

	switch(href_list["do"])
		if("add")
			if(!target.psi)
				target.set_psi_rank(chosen_power.faculty, chosen_power.min_rank, defer_update = TRUE)
			if(!target.psi)
				to_chat(usr, SPAN_WARNING("У [target] нет возможности получить псионику."))
				return TRUE
			target.psi.grant_power(chosen_power)
			log_and_message_admins("выдал способность [chosen_power.name] ([chosen_power.faculty]).", target)
		if("remove")
			if(!target.psi)
				return TRUE
			target.psi.revoke_power(chosen_power)
			log_and_message_admins("забрал способность [chosen_power.name] ([chosen_power.faculty]).", target)

	var/datum/admins/admin = GLOB.admins[usr.key]
	if(istype(admin))
		admin.show_player_panel(target)
	return TRUE
