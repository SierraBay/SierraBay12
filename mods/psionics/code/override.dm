/datum/job/proc/give_psi(mob/living/carbon/human/H)

	if(!(GLOB.species_by_name[SPECIES_HUMAN]) || !(GLOB.species_by_name[SPECIES_VATGROWN]) || !(GLOB.species_by_name[SPECIES_SPACER]) || !(GLOB.species_by_name[SPECIES_GRAVWORLDER]) || !(GLOB.species_by_name[SPECIES_MULE]))
		return

	if(psi_latency_chance && prob(psi_latency_chance))
		H.set_psi_rank(pick(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS, PSI_CONSCIOUSNESS, PSI_MANIFESTATION, PSI_METAKINESIS), 1, defer_update = TRUE)

	if(!whitelist_lookup(SPECIES_PSI, H.client.ckey))
		return

	var/list/psi_abilities_by_name = H.client.prefs.psi_abilities

	if(!H.client.prefs.psi_threat_level)
		return

	LAZYINITLIST(psi_faculties)
	for(var/faculty_name in list("Coercion", "Consciousness", "Energistics", "Manifestation", "Metakinesis", "Psychokinesis", "Redaction"))
		var/singleton/psionic_faculty/faculty = SSpsi.faculties_by_name[faculty_name]
		var/faculty_id = faculty.id
		psi_faculties |= list("[faculty_id]" = psi_abilities_by_name[faculty_name] - 1)

	for(var/psi in psi_faculties)
		if(psi_faculties[psi] > 0)
			H.set_psi_rank(psi, psi_faculties[psi], take_larger = TRUE, defer_update = TRUE)

	H.psi.update()

	give_psionic_implant_on_join ||= (H.client.prefs.psi_openness && H.client.prefs.psi_threat_level > 0)

	if(!give_psionic_implant_on_join)
		return

	var/obj/item/implant/psi_control/imp = new
	imp.implanted(H)
	imp.forceMove(H)
	imp.imp_in = H
	imp.implanted = TRUE
	var/obj/item/organ/external/affected = H.get_organ(BP_HEAD)
	if(affected)
		affected.implants += imp
		imp.part = affected
	to_chat(H, SPAN_DANGER("As a registered psionic, you are fitted with a psi-dampening control implant. Using psi-power while the implant is active will result in neural shocks and your violation being reported."))

/datum/job/equip(mob/living/carbon/human/H, alt_title, datum/mil_branch/branch, datum/mil_rank/grade)

	if (required_language)
		H.add_language(required_language)
		H.set_default_language(all_languages[required_language])

	if (!length(H.languages))
		H.add_language(LANGUAGE_SPACER)
		H.set_default_language(all_languages[LANGUAGE_SPACER])

	give_psi(H)

	var/singleton/hierarchy/outfit/outfit = get_outfit(H, alt_title, branch, grade)
	if(outfit) . = outfit.equip(H, title, alt_title)
	if(faction)
		H.faction = faction
		H.last_faction = faction

/datum/admins/show_player_panel(mob/M in SSmobs.mob_list)
	set category = null
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	var/last_ckey = LAST_CKEY(M)
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<a href='byond://?src=\ref[src];editrights=show'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"
		// [SIERRA-ADD] - EX666_ECOSYSTEM
		if (M.client.discord_id && length(M.client.discord_id) < 32)
			body += "\[<@![M.client.discord_id]>  <b>[M.client.discord_name]</b>\]"
		// [/SIERRA-ADD]
	else if(last_ckey)
		body += " (last occupied by ckey <b>[last_ckey]</b>)"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<a href='byond://?src=\ref[src];revive=\ref[M]'>Heal</A>\] "

	var/mob/living/exosuit/E = M
	if(istype(E) && E.pilots)
		body += "<br><b>Exosuit pilots:</b><br>"
		for(var/mob/living/pilot in E.pilots)
			body += "[pilot] "
			body += " \[<a href='byond://?src=\ref[src];pilot=\ref[pilot]'>link</a>\]<br>"

	var/inactivity_time = M.client ? time_to_readable(M.client.inactivity) : null

	var/logout_time = null
	if (!isnull(M.logout_time))
		logout_time = time_to_readable(world.time - M.logout_time)

	body += {"
		<br><br>\[
		<a href='byond://?_src_=vars;Vars=\ref[M]'>VV</a> -
		<a href='byond://?src=\ref[src];traitor=\ref[M]'>TP</a> -
		<a href='byond://?src=\ref[usr];priv_msg=\ref[M]'>PM</a> -
		<a href='byond://?src=\ref[src];narrateto=\ref[M]'>DN</a> -
		[admin_jump_link(M, src)]\] <br>
		<b>Mob type:</b> [M.type]<br>
		<b>Inactivity time:</b> [inactivity_time ? "[inactivity_time]" : "Logged out"]<br/>
		<b>Logout time:</b> [logout_time ? "[logout_time] ago" : "N/A"]<br/><br/>
		<a href='byond://?src=\ref[src];paralyze=\ref[M]'>PARALYZE</A> |
		<a href='byond://?src=\ref[src];boot2=\ref[M]'>Kick</A> |
		<a href='byond://?_src_=holder;warn=[last_ckey]'>Warn</A> |
		<a href='byond://?src=\ref[src];newban=\ref[M];last_key=[last_ckey]'>Ban</A> |
		<a href='byond://?src=\ref[src];jobban2=\ref[M]'>Jobban</A> |
		<a href='byond://?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A> |
		<a href='byond://?src=\ref[src];connections=\ref[M]'>Check Connections</A> |
		<a href='byond://?src=\ref[src];bans=\ref[M]'>Check Bans</A> |
	"}
	if (M.ckey)
		body += {"<a target="_blank" href="https://www.byond.com/members/[M.ckey]">View Byond Account</a> | "}

	if (!istype(M, /mob/new_player) && !istype(M, /mob/observer))
		body += "<a href='byond://?src=\ref[src];cryo=\ref[M]'>Cryo Character</A> | "
		body += "<a href='byond://?src=\ref[src];equip_loadout=\ref[M]'>Equip Loadout</A> | "

	if(M.client)
		body += "<a href='byond://?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | "
		body += "<a href='byond://?src=\ref[src];reloadsave=\ref[M]'>Reload Save</A> | "
		body += "<a href='byond://?src=\ref[src];reloadchar=\ref[M]'>Reload Character</A> | "
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			\[<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><span style='font-color: [(muted & MUTE_IC)?"red":"blue"]'>IC</span></a> |
			<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><span style='font-color: [(muted & MUTE_OOC)?"red":"blue"]'>OOC</span></a> |
			<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_AOOC]'><span style='font-color: [(muted & MUTE_AOOC)?"red":"blue"]'>AOOC</span></a> |
			<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><span style='font-color: [(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</span></a> |
			<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><span style='font-color: [(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</span></a> |
			<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><span style='font-color: [(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</span></a>\]
			(<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'><span style='font-color: [(muted & MUTE_ALL)?"red":"blue"]'>toggle all</span></a>)
		"}
		body += "<br><br><b>Staff Warning:</b> [M.client.staffwarn ? M.client.staffwarn : "No"]<br>"
		if (!M.client.staffwarn)
			body += "<a href='byond://?src=\ref[src];setstaffwarn=\ref[M]'>Set StaffWarn</A>"
		else
			body += "<a href='byond://?src=\ref[src];removestaffwarn=\ref[M]'>Remove StaffWarn</A>"

	body += {"<br><br>
		<a href='byond://?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> |
		<a href='byond://?src=\ref[src];getmob=\ref[M]'>Get</A> |
		<a href='byond://?src=\ref[src];sendmob=\ref[M]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN|R_MOD,0) ? "<a href='byond://?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> | " : "" ]
		[check_rights(R_INVESTIGATE,0) ? "<a href='byond://?src=\ref[src];skillpanel=\ref[M]'>Skill panel</A>" : "" ]
	"}

	if(M.mind)
		body += "<br><br>"
		body += "<b>Goals:</b>"
		body += "<br>"
		body += "[jointext(M.mind.summarize_goals(FALSE, TRUE, src), "<br>")]"
		body += "<br>"
		body += "<a href='byond://?src=\ref[M.mind];add_goal=1'>Add Random Goal</a>"

	body += "<br><br>"
	body += "<b>Psionics:</b><br/>"
	if(isliving(M))
		var/mob/living/psyker = M
		if(psyker.psi)
			body += "<a href='byond://?src=\ref[psyker.psi];remove_psionics=1'>Remove psionics.</a><br/><br/>"
			body += "<a href='byond://?src=\ref[psyker.psi];trigger_psi_latencies=1'>Trigger latencies.</a><br/>"
		body += "<table width = '100%'>"
		for(var/faculty in list(PSI_COERCION, PSI_CONSCIOUSNESS, PSI_PSYCHOKINESIS, PSI_MANIFESTATION, PSI_ENERGISTICS, PSI_REDACTION, PSI_METAKINESIS))
			var/singleton/psionic_faculty/faculty_singleton = SSpsi.get_faculty(faculty)
			var/faculty_rank = psyker.psi ? psyker.psi.get_rank(faculty) : 0
			body += "<tr><td><b>[faculty_singleton.name]</b></td>"
			for(var/i = 1 to LAZYLEN(GLOB.psychic_ranks_to_strings))
				var/psi_title = GLOB.psychic_ranks_to_strings[i]
				if(i == faculty_rank)
					psi_title = "<b>[psi_title]</b>"
				body += "<td><a href='byond://?src=\ref[psyker.mind];set_psi_faculty_rank=[i];set_psi_faculty=[faculty]'>[psi_title]</a></td>"
			body += "</tr>"
		body += "</table>"

	if (M.client)
		if(!istype(M, /mob/new_player))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(issmall(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<a href='byond://?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<a href='byond://?src=\ref[src];corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += {"<a href='byond://?src=\ref[src];makeai=\ref[M]'>Make AI</A> |
					<a href='byond://?src=\ref[src];makerobot=\ref[M]'>Make Robot</A> |
					<a href='byond://?src=\ref[src];makealien=\ref[M]'>Make Alien</A> |
					<a href='byond://?src=\ref[src];makeslime=\ref[M]'>Make Slime</A> |
					<a href='byond://?src=\ref[src];makezombie=\ref[M]'>Make Zombie</A> |
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<a href='byond://?src=\ref[src];makeanimal=\ref[M]'>Re-Animalize</A> | "
			else
				body += "<a href='byond://?src=\ref[src];makeanimal=\ref[M]'>Animalize</A> | "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				for(var/block=1;block<=DNA_SE_LENGTH;block++)
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					bname = assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"#006600":"#ff0000"]"
						body += "<a href='byond://?src=\ref[src];togmutate=\ref[M];block=[block]' style='color:[bcolor];'>[bname]</A><sub>[block]</sub>"
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			body += {"<br><br>
				<b>Rudimentary transformation:</b>[FONT_NORMAL("<br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.")]<br>
				<a href='byond://?src=\ref[src];simplemake=observer;mob=\ref[M]'>Observer</A> |
				\[ Xenos: <a href='byond://?src=\ref[src];simplemake=larva;mob=\ref[M]'>Larva</A>
				\[ Crew: <a href='byond://?src=\ref[src];simplemake=human;mob=\ref[M]'>Human</A>
				<a href='byond://?src=\ref[src];simplemake=human;species=Unathi;mob=\ref[M]'>Unathi</A>
				<a href='byond://?src=\ref[src];simplemake=human;species=Skrell;mob=\ref[M]'>Skrell</A>
				<a href='byond://?src=\ref[src];simplemake=human;species=Vox;mob=\ref[M]'>Vox</A> \] | \[
				<a href='byond://?src=\ref[src];simplemake=nymph;mob=\ref[M]'>Nymph</A>
				<a href='byond://?src=\ref[src];simplemake=human;species='Diona';mob=\ref[M]'>Diona</A> \] |
				\[ slime: <a href='byond://?src=\ref[src];simplemake=slime;mob=\ref[M]'>Baby</A>,
				<a href='byond://?src=\ref[src];simplemake=adultslime;mob=\ref[M]'>Adult</A> \]
				<a href='byond://?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Monkey</A> |
				<a href='byond://?src=\ref[src];simplemake=robot;mob=\ref[M]'>Cyborg</A> |
				<a href='byond://?src=\ref[src];simplemake=cat;mob=\ref[M]'>Cat</A> |
				<a href='byond://?src=\ref[src];simplemake=runtime;mob=\ref[M]'>Runtime</A> |
				<a href='byond://?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Corgi</A> |
				<a href='byond://?src=\ref[src];simplemake=ian;mob=\ref[M]'>Ian</A> |
				<a href='byond://?src=\ref[src];simplemake=crab;mob=\ref[M]'>Crab</A> |
				<a href='byond://?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Coffee</A> |
				\[ Construct: <a href='byond://?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Armoured</A> ,
				<a href='byond://?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Builder</A> ,
				<a href='byond://?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Wraith</A> \]
				<a href='byond://?src=\ref[src];simplemake=shade;mob=\ref[M]'>Shade</A>
				<br>
			"}
	body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<a href='byond://?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A> |
			<a href='byond://?src=\ref[src];cloneother=\ref[M]'>Clone Other</a>
			"}
	if (M.client)
		body += {" |
			<a href='byond://?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> |
			<a href='byond://?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> |
			<a href='byond://?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> |
			<a href='byond://?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A> |
		"}
	// language toggles
	body += "<br><br><b>Languages:</b><br>"
	var/f = 1
	for(var/k in all_languages)
		var/datum/language/L = all_languages[k]
		if(!(L.flags & INNATE))
			if(!f) body += " | "
			else f = 0
			if(L in M.languages)
				body += "<a href='byond://?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' style='color:#006600'>[k]</a>"
			else
				body += "<a href='byond://?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' style='color:#ff0000'>[k]</a>"

	body += {"<br>
		</body></html>
	"}

	show_browser(usr, body, "window=adminplayeropts;size=550x515")
