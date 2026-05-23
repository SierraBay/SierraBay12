
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(msg)
	msg = SPAN_CLASS("log_message", "[SPAN_CLASS("prefix", "ADMIN LOG:")] [SPAN_CLASS("message", msg)]")
	log_adminwarn(msg)
	for(var/client/C as anything in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)
/proc/message_staff(msg)
	msg = SPAN_CLASS("log_message", "[SPAN_CLASS("prefix", "STAFF LOG:")] [SPAN_CLASS("message", msg)]")
	log_adminwarn(msg)
	for(var/client/C as anything in GLOB.admins)
		// [SIERRA-EDIT]
		// if(C && C.holder && (R_INVESTIGATE & C.holder.rights)) // SIERRA-EDIT - ORIGINAL
		if(C && C.holder && ((R_INVESTIGATE|R_DEBUG) & C.holder.rights))
		// [/SIERRA-EDIT]
			to_chat(C, msg)
/proc/msg_admin_attack(text) //Toggleable Attack Messages
	log_attack(text)
	var/rendered = SPAN_CLASS("log_message", "[SPAN_CLASS("prefix", "ATTACK:")] [SPAN_CLASS("message", text)]")
	for(var/client/C as anything in GLOB.admins)
		if(check_rights(R_INVESTIGATE, 0, C))
			if(C.get_preference_value(/datum/client_preference/staff/show_attack_logs) == GLOB.PREF_SHOW)
				var/msg = rendered
				to_chat(C, msg)
/proc/admin_notice(message, rights)
	for(var/mob/M in SSmobs.mob_list)
		if(check_rights(rights, 0, M))
			to_chat(M, message)
///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in SSmobs.mob_list)
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

	// [SIERRA-EDIT]
	var/last_ckey = LAST_CKEY(M)
	var/is_online = M.client ? 1 : 0
	var/status_class = is_online ? "status-online" : "status-offline"
	var/status_text = is_online ? "Online" : "Offline"
	var/css_open_selector = "details\[open\]"
	var/is_paralyzed = 0
	var/current_species = ""
	if(isliving(M))
		var/mob/living/L = M
		is_paralyzed = L.admin_paralyzed
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species)
				current_species = H.species.name

	var/is_ghost = istype(M, /mob/observer/ghost)
	var/is_larva = 0
	var/is_nymph = istype(M, /mob/living/carbon/alien/diona)
	var/is_slime = istype(M, /mob/living/carbon/slime)
	var/is_adult_slime = istype(M, /mob/living/carbon/slime) && M:is_adult
	var/is_monkey = istype(M, /mob/living/carbon/human/monkey)
	var/is_cyborg = istype(M, /mob/living/silicon/robot)
	var/is_runtime = istype(M, /mob/living/simple_animal/passive/cat/fluff/Runtime)
	var/is_cat = istype(M, /mob/living/simple_animal/passive/cat) && !is_runtime
	var/is_ian = istype(M, /mob/living/simple_animal/passive/corgi/Ian)
	var/is_corgi = istype(M, /mob/living/simple_animal/passive/corgi) && !is_ian
	var/is_coffee = istype(M, /mob/living/simple_animal/passive/crab/Coffee)
	var/is_crab = istype(M, /mob/living/simple_animal/passive/crab) && !is_coffee
	var/is_constr_arm = istype(M, /mob/living/simple_animal/construct/armoured)
	var/is_constr_bld = istype(M, /mob/living/simple_animal/construct/builder)
	var/is_constr_wrt = istype(M, /mob/living/simple_animal/construct/wraith)
	var/is_shade = istype(M, /mob/living/simple_animal/shade)

	var/is_human_base = (current_species == "Human")
	var/is_unathi = (current_species == "Unathi")
	var/is_skrell = (current_species == "Skrell")
	var/is_tajara = (current_species == "Tajara")
	var/is_resomi = (current_species == "Resomi")
	var/is_vox = (current_species == "Vox")
	var/is_diona_adult = (current_species == "Diona")

	var/body = {"
		<style type="text/css">
			body { overflow: hidden !important; margin: 0; padding: 10px; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #272727; color: #fff; }
			.admin-container { height: calc(100vh - 50px); overflow-y: auto; padding-right: 5px; }
			.hero-card { background: #1c1c1c; border: 1px solid #333; border-radius: 6px; padding: 12px; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between; }
			.hero-left { display: flex; align-items: center; gap: 10px; }
			.hero-avatar { width: 48px; height: 48px; border-radius: 6px; background: #111; border: 1px solid #444; display: flex; align-items: center; justify-content: center; overflow: hidden; }
			.hero-title { font-size: 14px; font-weight: bold; margin-bottom: 2px; }
			.hero-sub { font-size: 11px; color: #aaa; }
			.status-badge { padding: 3px 8px; border-radius: 12px; font-size: 10px; font-weight: bold; text-transform: uppercase; }
			.status-online { background: rgba(46, 204, 113, 0.15); color: #2ec571; border: 1px solid rgba(46, 204, 113, 0.3); }
			.status-offline { background: rgba(231, 76, 60, 0.15); color: #e74c3c; border: 1px solid rgba(231, 76, 60, 0.3); }

			.quick-actions { display: grid; grid-template-columns: repeat(6, 1fr); gap: 6px; margin-bottom: 12px; }
			.qa-btn { display: block; text-align: center; padding: 8px 4px; border-radius: 4px; background: #1c1c1c; border: 1px solid #333; color: #fff; font-weight: bold; font-size: 11px; transition: all 0.2s; text-decoration: none; }
			.qa-btn:hover { background: #3498db; border-color: #3498db; color: #fff; }
			.qa-btn.heal { background: rgba(46, 204, 113, 0.15); border-color: #2ecc71; color: #2ecc71; }
			.qa-btn.heal:hover { background: #2ecc71; color: #fff; }

			.section-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
			.control-card { background: #1c1c1c; border: 1px solid #333; border-radius: 6px; padding: 12px; box-sizing: border-box; }
			.card-title { font-size: 13px; font-weight: bold; color: #3498db; border-bottom: 1px solid #333; padding-bottom: 6px; margin-bottom: 10px; }

			.action-buttons { display: flex; flex-wrap: wrap; gap: 6px; }
			.action-btn { font-size: 11px; padding: 6px 10px; border-radius: 3px; background: #2a2a2a; border: 1px solid #444; color: #ddd; text-decoration: none; font-weight: bold; text-align: center; }
			.action-btn:hover { background: #3498db; color: #fff; border-color: #3498db; }
			.action-btn.danger { background: rgba(231, 76, 60, 0.15); border-color: #e74c3c; color: #e74c3c; }
			.action-btn.danger:hover { background: #e74c3c; color: #fff; }
			.action-btn.warning { background: rgba(241, 196, 15, 0.15); border-color: #f1c40f; color: #f1c40f; }
			.action-btn.warning:hover { background: #f1c40f; color: #000; }
			.action-btn.active { background: rgba(46, 204, 113, 0.2) !important; border-color: #2ecc71 !important; color: #2ecc71 !important; box-shadow: 0 0 6px rgba(46, 204, 113, 0.4); }

			.grid-list { display: grid; grid-template-columns: 1fr; gap: 6px; }
			.grid-item { font-size: 11px; color: #aaa; }
			.grid-value { font-weight: bold; color: #fff; word-break: break-all; }

			.mute-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px; }
			.mute-btn { display: block; text-align: center; font-size: 11px; padding: 6px 2px; border-radius: 3px; text-decoration: none; font-weight: bold; border: 1px solid #333; }
			.mute-btn.on { background: rgba(231, 76, 60, 0.15); border-color: #e74c3c; color: #e74c3c; }
			.mute-btn.off { background: rgba(46, 204, 113, 0.15); border-color: #2ecc71; color: #2ecc71; }

			.dna-table { width: 100%; border-collapse: collapse; margin-top: 5px; font-size: 10px; background: #111; border-radius: 4px; overflow: hidden; }
			.dna-table th { background: #222; color: #888; font-size: 10px; padding: 4px; font-weight: bold; }
			.dna-table td { padding: 6px 4px; border: 1px solid #222; text-align: center; }
			.dna-link { display: block; padding: 2px 4px; border-radius: 3px; text-decoration: none; font-weight: bold; font-size: 10px; text-align: center; }

			.admin-jump-links a {
				display: inline-block;
				font-size: 11px;
				padding: 5px 10px;
				border-radius: 3px;
				background: #2a2a2a;
				border: 1px solid #444;
				color: #ddd;
				text-decoration: none;
				font-weight: bold;
				margin-right: 4px;
				margin-bottom: 4px;
			}
			.admin-jump-links a:hover {
				background: #3498db;
				color: #fff;
				border-color: #3498db;
			}

			details { background: #1c1c1c; border: 1px solid #333; border-radius: 6px; padding: 8px 12px; margin-bottom: 8px; }
			details summary { cursor: pointer; font-size: 12px; font-weight: bold; color: #3498db; outline: none; }
			[css_open_selector] summary { border-bottom: 1px solid #333; padding-bottom: 6px; margin-bottom: 8px; }

			.goal-text { font-size: 11px; font-style: italic; color: #ccc; background: #222; border-left: 2px solid #f1c40f; padding: 6px; margin-bottom: 6px; border-radius: 0 4px 4px 0; }
			.refresh-btn:hover { background: #3498db !important; color: #fff !important; border-color: #3498db !important; box-shadow: 0 0 6px rgba(52, 152, 219, 0.4); }
		</style>
		<div class="admin-container" id="admin-player-container">
	"}

	// 1. Profile Hero Card
	var/player_name = M.name
	var/player_details = ""
	if(M.client)
		var/rank_link = ""
		if(M.client.holder)
			rank_link = "<a href='byond://?src=\ref[src];editrights=show'>[M.client.holder.rank]</a>"
		else
			rank_link = "Player"
		player_details = "played by <span style='font-weight: bold;'>[M.client]</span> \[[rank_link]\]"
	else if(last_ckey)
		player_details = "last occupied by <span style='font-weight: bold;'>[last_ckey]</span>"
	else
		player_details = "No client association"

	var/avatar_file = "avatar_[ref(M)].png"
	var/icon/flat_icon = getFlatIcon(M, SOUTH)
	send_rsc(usr, flat_icon, avatar_file)

	body += {"
		<div class="hero-card">
			<div class="hero-left">
				<div class="hero-avatar"><img src="[avatar_file]" style="width: 48px; height: 48px; image-rendering: pixelated; display: block; object-fit: contain;"></div>
				<div>
					<div class="hero-title" style="display: flex; align-items: center; gap: 8px;">
						[player_name]
						<a href='byond://?src=\ref[src];refresh_player_panel=\ref[M]' class='refresh-btn' title='Refresh Panel' style='text-decoration: none; font-size: 11px; color: #3498db; background: rgba(52, 152, 219, 0.1); border: 1px solid rgba(52, 152, 219, 0.3); border-radius: 4px; padding: 2px 6px; font-weight: bold; transition: all 0.2s; display: inline-flex; align-items: center; gap: 4px;'>🔄 Refresh</a>
					</div>
					<div class="hero-sub">[player_details]</div>
				</div>
			</div>
			<div class="status-badge [status_class]">[status_text]</div>
		</div>
	"}

	// 2. Quick Actions
	body += "<div class='quick-actions'>"
	if(istype(M, /mob/new_player))
		body += "<a href='#' class='qa-btn heal' style='opacity: 0.5; cursor: not-allowed;'>No Heal</a>"
	else
		body += "<a href='byond://?src=\ref[src];revive=\ref[M]' class='qa-btn heal'>Heal</a>"

	body += {"
			<a href='byond://?_src_=vars;Vars=\ref[M]' class='qa-btn'>VV</a>
			<a href='byond://?src=\ref[src];traitor=\ref[M]' class='qa-btn'>TP</a>
			<a href='byond://?src=\ref[usr];priv_msg=\ref[M]' class='qa-btn'>PM</a>
			<a href='byond://?src=\ref[src];narrateto=\ref[M]' class='qa-btn'>DN</a>
			<a href='byond://?src=\ref[src];jumpto=\ref[M]' class='qa-btn'>Jump</a>
		</div>
	"}

	// Exosuit Pilots list (if E has pilots)
	var/mob/living/exosuit/E = M
	if(istype(E) && E.pilots)
		body += {"
			<div class="control-card" style="margin-bottom: 12px;">
				<div class="card-title">Exosuit Pilots</div>
				<div class="action-buttons">
		"}
		for(var/mob/living/pilot in E.pilots)
			body += "<a href='byond://?src=\ref[src];pilot=\ref[pilot]' class='action-btn'>[pilot] (link)</a>"
		body += {"
				</div>
			</div>
		"}

	// 3. Grid Content (Mob info & Jump tools)
	var/inactivity_time = M.client ? time_to_readable(M.client.inactivity) : null

	var/logout_time = null
	if (!isnull(M.logout_time))
		logout_time = time_to_readable(world.time - M.logout_time)

	body += {"
		<div class="section-grid">
			<div class="control-card">
				<div class="card-title">Entity Information</div>
				<div class="grid-list">
					<div class="grid-item">Mob Type: <span class="grid-value">[M.type]</span></div>
					<div class="grid-item">Inactivity: <span class="grid-value">[inactivity_time ? "[inactivity_time]" : "Logged out / N/A"]</span></div>
					<div class="grid-item">Logout Time: <span class="grid-value">[logout_time ? "[logout_time] ago" : "N/A"]</span></div>
				</div>
			</div>

			<div class="control-card">
				<div class="card-title">Movement & Observation</div>
				<div class="admin-jump-links">
					[admin_jump_link(M, src)]
					<a href='byond://?src=\ref[src];jumpto=\ref[M]'>Jump To</a>
					<a href='byond://?src=\ref[src];getmob=\ref[M]'>Get Mob</a>
				</div>
			</div>
	"}

	// 4. Mutes & Warnings Panel
	if(M.client)
		var/muted = M.client.prefs.muted
		var/staffwarn_color = M.client.staffwarn ? "#e74c3c" : "#2ecc71"
		var/staffwarn_text = M.client.staffwarn ? M.client.staffwarn : "None"
		body += {"
			<div class='control-card' style='grid-column: span 2;'>
				<div class='card-title'>Communication Mutes</div>
				<div class='mute-grid'>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]' class='mute-btn [(muted & MUTE_IC) ? "on" : "off"]'>IC Chat</a>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]' class='mute-btn [(muted & MUTE_OOC) ? "on" : "off"]'>OOC Chat</a>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_AOOC]' class='mute-btn [(muted & MUTE_AOOC) ? "on" : "off"]'>AOOC Chat</a>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]' class='mute-btn [(muted & MUTE_PRAY) ? "on" : "off"]'>Prayers</a>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]' class='mute-btn [(muted & MUTE_ADMINHELP) ? "on" : "off"]'>A-Help</a>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]' class='mute-btn [(muted & MUTE_DEADCHAT) ? "on" : "off"]'>Deadchat</a>
				</div>
				<div style='margin-top: 10px; display: flex; gap: 6px;'>
					<a href='byond://?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]' class='action-btn' style='flex-grow: 1;'>Toggle All Channels</a>
					[M.client.staffwarn ? "<a href='byond://?src=\ref[src];removestaffwarn=\ref[M]' class='action-btn danger' style='flex-grow: 1;'>Remove StaffWarn</a>" : "<a href='byond://?src=\ref[src];setstaffwarn=\ref[M]' class='action-btn warning' style='flex-grow: 1;'>Set StaffWarn</a>"]
				</div>
				<div style='margin-top: 8px; font-size: 11px; text-align: center; color: #888;'>
					Staff Warning Status: <span style='font-weight: bold; color: [staffwarn_color]'>[staffwarn_text]</span>
				</div>
			</div>
		"}

	body += "</div>" // end of section-grid

	// 5. Core Actions Panel
	body += {"
		<div class="control-card" style="margin-bottom: 12px;">
			<div class="card-title">Core Administrative Actions</div>
			<div class="action-buttons">
				[is_paralyzed ? "<a href='byond://?src=\ref[src];paralyze=\ref[M]' class='action-btn danger' style='background: #e74c3c; color: #fff; box-shadow: 0 0 8px rgba(231, 76, 60, 0.6); border-color: #e74c3c;'>Unparalyze</a>" : "<a href='byond://?src=\ref[src];paralyze=\ref[M]' class='action-btn danger'>Paralyze</a>"]
				<a href='byond://?src=\ref[src];boot2=\ref[M]' class='action-btn danger'>Kick Player</a>
				<a href='byond://?_src_=holder;warn=[last_ckey]' class='action-btn danger'>Warn Player</a>
				<a href='byond://?src=\ref[src];newban=\ref[M];last_key=[last_ckey]' class='action-btn danger'>Ban Player</a>
				<a href='byond://?src=\ref[src];jobban2=\ref[M]' class='action-btn danger'>Job Ban</a>
				<a href='byond://?src=\ref[src];notes=show;mob=\ref[M]' class='action-btn warning'>Player Notes</a>
				<a href='byond://?src=\ref[src];connections=\ref[M]' class='action-btn'>Check Connections</a>
				<a href='byond://?src=\ref[src];bans=\ref[M]' class='action-btn'>Check Bans</a>
	"}
	if (M.ckey)
		body += "<a target='_blank' href='https://www.byond.com/members/[M.ckey]' class='action-btn'>View BYOND Account</a>"

	if (!istype(M, /mob/new_player) && !istype(M, /mob/observer))
		body += "<a href='byond://?src=\ref[src];cryo=\ref[M]' class='action-btn warning'>Cryo Character</a>"
		body += "<a href='byond://?src=\ref[src];equip_loadout=\ref[M]' class='action-btn warning'>Equip Loadout</a>"

	if(M.client)
		body += "<a href='byond://?src=\ref[src];sendtoprison=\ref[M]' class='action-btn danger'>Prison</a>"
		body += "<a href='byond://?src=\ref[src];reloadsave=\ref[M]' class='action-btn'>Reload Save</a>"
		body += "<a href='byond://?src=\ref[src];reloadchar=\ref[M]' class='action-btn'>Reload Character</a>"

	body += {"
				[check_rights(R_ADMIN|R_MOD,0) ? "<a href='byond://?src=\ref[src];traitor=\ref[M]' class='action-btn warning'>Traitor Panel</a>" : "" ]
				[check_rights(R_INVESTIGATE,0) ? "<a href='byond://?src=\ref[src];skillpanel=\ref[M]' class='action-btn'>Skill Panel</a>" : "" ]
			</div>
		</div>
	"}
	// 6. Goals Summary & Mind Panel
	if(M.mind)
		var/goals_text = jointext(M.mind.summarize_goals(FALSE, TRUE, src), "<br>")
		body += {"
			<div class="control-card" style="margin-bottom: 12px;">
				<div class="card-title">Mind Goals & Objectives</div>
				[goals_text ? "<div class='goal-text'>[goals_text]</div>" : "<i>No objectives defined for this mind.</i><br/>"]
				<div style="margin-top: 10px;">
					<a href='byond://?src=\ref[M.mind];add_goal=1' class='action-btn warning'>Add Random Goal</a>
				</div>
			</div>
		"}

	// 7. Collapsible Psionics (if living)
	if(isliving(M))
		var/mob/living/psyker = M
		body += "<details id='details-psionics'><summary>Psionics Controls</summary><div style='padding-top: 8px;'>"
		if(psyker.psi)
			body += {"
				<div class='action-buttons' style='margin-bottom: 10px;'>
					<a href='byond://?src=\ref[psyker.psi];remove_psionics=1' class='action-btn danger'>Remove Psionics</a>
					<a href='byond://?src=\ref[psyker.psi];trigger_psi_latencies=1' class='action-btn warning'>Trigger Latencies</a>
				</div>
			"}
		body += "<table width='100%' class='dna-table'><thead><tr><th>Faculty</th>"
		for(var/i = 1 to LAZYLEN(GLOB.psychic_ranks_to_strings))
			body += "<th>[GLOB.psychic_ranks_to_strings[i]]</th>"
		body += "</tr></thead><tbody>"
		for(var/faculty in list(PSI_COERCION, PSI_CONSCIOUSNESS, PSI_PSYCHOKINESIS, PSI_MANIFESTATION, PSI_ENERGISTICS, PSI_REDACTION, PSI_METAKINESIS, PSI_SHAYMANISM))
			var/singleton/psionic_faculty/faculty_singleton = SSpsi.get_faculty(faculty)
			var/faculty_rank = psyker.psi ? psyker.psi.get_rank(faculty) : 0
			body += "<tr><td><b>[faculty_singleton.name]</b></td>"
			for(var/i = 1 to LAZYLEN(GLOB.psychic_ranks_to_strings))
				var/psi_title = GLOB.psychic_ranks_to_strings[i]
				var/psi_style = ""
				if(i == faculty_rank)
					psi_style = "background: rgba(52, 152, 219, 0.2); border-color: #3498db; color: #3498db; text-shadow: 0 0 4px #3498db;"
				body += "<td><a href='byond://?src=\ref[psyker.mind];set_psi_faculty_rank=[i];set_psi_faculty=[faculty]' class='dna-link' style='[psi_style]'>[psi_title]</a></td>"
			body += "</tr>"
		body += "</tbody></table></div></details>"

	// 8. Transformations & DNA blocks (if carbon)
	if(M.client && !istype(M, /mob/new_player))
		body += "<details id='details-dna'><summary>Transformations & Character DNA</summary><div style='padding-top: 8px;'>"

		// DNA Blocks Grid (if M.dna is present)
		if(M.dna && iscarbon(M))
			body += {"
				<div style='font-weight: bold; font-size: 11px; margin-bottom: 6px; color: #3498db;'>DNA Mutant SE Blocks:</div>
				<table class="dna-table">
					<thead>
						<tr>
							<th>&nbsp;</th>
							<th>1</th>
							<th>2</th>
							<th>3</th>
							<th>4</th>
							<th>5</th>
						</tr>
					</thead>
					<tbody>
			"}
			var/bname
			for(var/block=1;block<=DNA_SE_LENGTH;block++)
				if(((block-1)%5)==0)
					if(block > 1) body += "</tr>"
					body += "<tr><th>[block-1]</th>"
				bname = assigned_blocks[block]
				body += "<td>"
				if(bname)
					var/bstate=M.dna.GetSEState(block)
					var/bstyle = bstate ? "background: rgba(46, 204, 113, 0.15); color: #2ecc71; border: 1px solid rgba(46, 204, 113, 0.3);" : "background: rgba(231, 76, 60, 0.15); color: #e74c3c; border: 1px solid rgba(231, 76, 60, 0.3);"
					body += "<a href='byond://?src=\ref[src];togmutate=\ref[M];block=[block]' class='dna-link' style='[bstyle]'>[bname]<sub>[block]</sub></a>"
				else
					body += "<span style='color: #555;'>[block]</span>"
				body += "</td>"
			body += "</tr></tbody></table><br/>"

		// Transformations Action Buttons
		body += {"
			<div style='font-weight: bold; font-size: 11px; margin-bottom: 6px; color: #3498db;'>Standard Transformations:</div>
			<div class='action-buttons' style='margin-bottom: 12px;'>
		"}
		if(issmall(M))
			body += "<a href='#' class='action-btn' style='opacity: 0.5; cursor: not-allowed;'>Monkeyized</a>"
		else
			body += "<a href='byond://?src=\ref[src];monkeyone=\ref[M]' class='action-btn'>Monkeyize</a>"

		if(iscorgi(M))
			body += "<a href='#' class='action-btn' style='opacity: 0.5; cursor: not-allowed;'>Corgized</a>"
		else
			body += "<a href='byond://?src=\ref[src];corgione=\ref[M]' class='action-btn'>Corgize</a>"

		if(isAI(M))
			body += "<a href='#' class='action-btn' style='opacity: 0.5; cursor: not-allowed;'>Is an AI</a>"
		else if(ishuman(M))
			body += {"
				<a href='byond://?src=\ref[src];makeai=\ref[M]' class='action-btn'>Make AI</a>
				<a href='byond://?src=\ref[src];makerobot=\ref[M]' class='action-btn'>Make Robot</a>
				<a href='byond://?src=\ref[src];makealien=\ref[M]' class='action-btn'>Make Alien</a>
				<a href='byond://?src=\ref[src];makeslime=\ref[M]' class='action-btn'>Make Slime</a>
				<a href='byond://?src=\ref[src];makezombie=\ref[M]' class='action-btn'>Make Zombie</a>
			"}

		if(isanimal(M))
			body += "<a href='byond://?src=\ref[src];makeanimal=\ref[M]' class='action-btn'>Re-Animalize</a>"
		else
			body += "<a href='byond://?src=\ref[src];makeanimal=\ref[M]' class='action-btn'>Animalize</a>"

		body += {"
			</div>

			<div style='font-weight: bold; font-size: 11px; margin-bottom: 6px; color: #3498db;'>Rudimentary Transformations (Quick Switch):</div>
			<div class='action-buttons'>
				<a href='byond://?src=\ref[src];simplemake=observer;mob=\ref[M]' class='action-btn warning[is_ghost ? " active" : ""]'>Observer</a>
				<a href='byond://?src=\ref[src];simplemake=larva;mob=\ref[M]' class='action-btn warning[is_larva ? " active" : ""]'>Xeno Larva</a>
				<a href='byond://?src=\ref[src];simplemake=human;mob=\ref[M]' class='action-btn[is_human_base ? " active" : ""]'>Human Crew</a>
				<a href='byond://?src=\ref[src];simplemake=human;species=Unathi;mob=\ref[M]' class='action-btn[is_unathi ? " active" : ""]'>Unathi Crew</a>
				<a href='byond://?src=\ref[src];simplemake=human;species=Skrell;mob=\ref[M]' class='action-btn[is_skrell ? " active" : ""]'>Skrell Crew</a>
				<a href='byond://?src=\ref[src];simplemake=human;species=Tajara;mob=\ref[M]' class='action-btn[is_tajara ? " active" : ""]'>Tajara Crew</a>
				<a href='byond://?src=\ref[src];simplemake=human;species=Resomi;mob=\ref[M]' class='action-btn[is_resomi ? " active" : ""]'>Resomi Crew</a>
				<a href='byond://?src=\ref[src];simplemake=human;species=Vox;mob=\ref[M]' class='action-btn[is_vox ? " active" : ""]'>Vox Crew</a>
				<a href='byond://?src=\ref[src];simplemake=nymph;mob=\ref[M]' class='action-btn[is_nymph ? " active" : ""]'>Diona Nymph</a>
				<a href='byond://?src=\ref[src];simplemake=human;species=Diona;mob=\ref[M]' class='action-btn[is_diona_adult ? " active" : ""]'>Diona Adult</a>
				<a href='byond://?src=\ref[src];simplemake=slime;mob=\ref[M]' class='action-btn[is_slime && !is_adult_slime ? " active" : ""]'>Baby Slime</a>
				<a href='byond://?src=\ref[src];simplemake=adultslime;mob=\ref[M]' class='action-btn[is_adult_slime ? " active" : ""]'>Adult Slime</a>
				<a href='byond://?src=\ref[src];simplemake=monkey;mob=\ref[M]' class='action-btn[is_monkey ? " active" : ""]'>Monkey</a>
				<a href='byond://?src=\ref[src];simplemake=robot;mob=\ref[M]' class='action-btn[is_cyborg ? " active" : ""]'>Cyborg</a>
				<a href='byond://?src=\ref[src];simplemake=cat;mob=\ref[M]' class='action-btn[is_cat ? " active" : ""]'>Normal Cat</a>
				<a href='byond://?src=\ref[src];simplemake=runtime;mob=\ref[M]' class='action-btn[is_runtime ? " active" : ""]'>Runtime Cat</a>
				<a href='byond://?src=\ref[src];simplemake=corgi;mob=\ref[M]' class='action-btn[is_corgi ? " active" : ""]'>Normal Corgi</a>
				<a href='byond://?src=\ref[src];simplemake=ian;mob=\ref[M]' class='action-btn[is_ian ? " active" : ""]'>Ian Corgi</a>
				<a href='byond://?src=\ref[src];simplemake=crab;mob=\ref[M]' class='action-btn[is_crab ? " active" : ""]'>Crab</a>
				<a href='byond://?src=\ref[src];simplemake=coffee;mob=\ref[M]' class='action-btn[is_coffee ? " active" : ""]'>Coffee Crab</a>
				<a href='byond://?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]' class='action-btn[is_constr_arm ? " active" : ""]'>Armoured Construct</a>
				<a href='byond://?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]' class='action-btn[is_constr_bld ? " active" : ""]'>Builder Construct</a>
				<a href='byond://?src=\ref[src];simplemake=constructwraith;mob=\ref[M]' class='action-btn[is_constr_wrt ? " active" : ""]'>Wraith Construct</a>
				<a href='byond://?src=\ref[src];simplemake=shade;mob=\ref[M]' class='action-btn[is_shade ? " active" : ""]'>Shade</a>
			</div>
		</div></details>
		"}

	// 9. Other Actions details
	body += "<details id='details-actions'><summary>Other Actions & Languages</summary><div style='padding-top: 8px;'>"
	body += {"
		<div style='font-weight: bold; font-size: 11px; margin-bottom: 6px; color: #3498db;'>Speech & Manipulation:</div>
		<div class='action-buttons' style='margin-bottom: 12px;'>
			<a href='byond://?src=\ref[src];forcespeech=\ref[M]' class='action-btn warning'>Forcesay Speech</a>
			<a href='byond://?src=\ref[src];cloneother=\ref[M]' class='action-btn'>Clone Other Character</a>
		</div>
	"}

	if(M.client)
		body += {"
			<div style='font-weight: bold; font-size: 11px; margin-bottom: 6px; color: #3498db;'>Thunderdome Arenas:</div>
			<div class='action-buttons' style='margin-bottom: 12px;'>
				<a href='byond://?src=\ref[src];tdome1=\ref[M]' class='action-btn'>Thunderdome 1</a>
				<a href='byond://?src=\ref[src];tdome2=\ref[M]' class='action-btn'>Thunderdome 2</a>
				<a href='byond://?src=\ref[src];tdomeadmin=\ref[M]' class='action-btn warning'>Thunderdome Admin</a>
				<a href='byond://?src=\ref[src];tdomeobserve=\ref[M]' class='action-btn'>Thunderdome Observe</a>
			</div>
		"}

	body += {"
		<div style='font-weight: bold; font-size: 11px; margin-bottom: 6px; color: #3498db;'>Languages:</div>
		<div class='action-buttons'>
	"}
	for(var/k in all_languages)
		var/datum/language/L = all_languages[k]
		if(!(L.flags & INNATE))
			var/lang_style = ""
			if(L in M.languages)
				lang_style = "background: rgba(46, 204, 113, 0.15); color: #2ecc71; border: 1px solid rgba(46, 204, 113, 0.3);"
			else
				lang_style = "background: rgba(231, 76, 60, 0.15); color: #e74c3c; border: 1px solid rgba(231, 76, 60, 0.3);"
			body += "<a href='byond://?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' class='action-btn' style='[lang_style]'>[k]</a>"
	body += "</div></div></details>"

// End container
	body += {"
		</div>
		<script type="text/javascript">
			window.onload = function() {
				var detailsIds = new Array('details-psionics', 'details-dna', 'details-actions');
				detailsIds.forEach(function(id) {
					var d = document.getElementById(id);
					if (d) {
						var stateId = 'player_panel_' + id + '_[ref(M)]';
						var savedState = localStorage.getItem(stateId);
						if (savedState === 'open') d.open = true;
						else if (savedState === 'closed') d.open = false;

						d.addEventListener('toggle', function() {
							localStorage.setItem(stateId, d.open ? 'open' : 'closed');
						});
					}
				});

				var container = document.getElementById('admin-player-container');
				if (container) {
					var savedScroll = localStorage.getItem('player_panel_scroll_[ref(M)]');
					if (savedScroll) {
						container.scrollTop = parseInt(savedScroll, 10);
					}
					container.onscroll = function() {
						localStorage.setItem('player_panel_scroll_[ref(M)]', container.scrollTop);
					};
				}
			};
		</script>
	"}

	var/datum/browser/popup = new(usr, "adminplayeropts", "Options for [M.key ? M.key : M.name]", 750, 750)
	popup.set_content(body)
	popup.open()
	// [/SIERRA-EDIT]


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying
/// Round ID of the note
/datum/player_info/var/game_id

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	PlayerNotesPage()

/datum/admins/proc/PlayerNotesPage(filter_term)
	var/list/dat = list()
	dat += "<B>Player notes</B><HR>"
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	from_save(S, note_keys)

	if(filter_term)
		for(var/t in note_keys)
			if(findtext(lowertext(t), lowertext(filter_term)))
				continue
			note_keys -= t

	dat += "<center><b>Search term:</b> <a href='byond://?src=\ref[src];notes=set_filter'>[filter_term ? filter_term : "-----"]</a></center><hr>"

	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)
		for(var/t in note_keys)
			dat += "<tr><td><a href='byond://?src=\ref[src];notes=show;ckey=[t]'>[t]</a></td></tr>"
		dat += "</table><br>"

	var/datum/browser/popup = new(usr, "player_notes", "Player Notes", 400, 400)
	popup.set_content(jointext(dat, null))
	popup.open()


/datum/admins/proc/player_has_info(key)
	var/target = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext_char(target, 1, 2)]/[target]/info.sav")
	var/list/infos
	from_save(info, infos)
	if (!length(infos))
		return FALSE
	return TRUE


/proc/html_page(title, list/body, list/head)
	return {"\
		<!doctype html>
		<html lang="en">\
		<head>\
			<meta charset="UTF-8">\
			<meta name="viewport" content="width=device-width,initial-scale=1">\
			<link rel="icon" href="data:,">\
			[head ? (islist(head) ? jointext(head, null) : head) : ""]\
			<title>[title]</title>\
		</head>\
		<body>[body ? (islist(body) ? jointext(body, null) : body) : ""]</body>\
		</html>\
	"}


/proc/html_page_common(title, list/body, list/head)
	var/list/prefix = list(
		{"<link rel="stylesheet" href="common.css">"},
		"<style>html, body { padding: 8px; font-family: Verdana, Geneva, sans-serif; }</style>"
	)
	return html_page(title, body, head ? prefix + head : prefix)


/datum/admins/proc/show_player_info(target as text)
	set category = "Admin"
	set name = "Show Player Info"
	if (!target)
		return
	if (!istext(target))
		return
	target = ckey(target)
	var/client/user = resolve_client(usr)
	if (!check_rights(R_INVESTIGATE, TRUE, user))
		return
	var/datum/admins/handler = user.holder
	var/client/subject
	for (var/client/client as anything in GLOB.clients)
		if (client.ckey == target)
			subject = client
			break
	var/list/body = list()
	body += {"\
		<div style="text-align: center;">\
			<b>Player Age</b>: [subject ? subject.player_age : "Not Connected"]\
			<hr>\
			<a href="?src=\ref[handler];add_player_info=[target]">Add Comment</a>\
		</div>\
		<hr>\
	"}
	var/list/infos
	var/savefile = new /savefile ("data/player_saves/[copytext_char(target, 1, 2)]/[target]/info.sav")
	from_save(savefile, infos)
	if (!infos)
		body += {"<div style="text-align: center; font-style: italic;">No comments saved.</div>"}
	for (var/i = length(infos) to 1 step -1)
		var/datum/player_info/comment = infos[i]
		var/remove_button = ""
		if (comment.author == user.key || check_rights(R_HOST, FALSE, user))
			remove_button = {"<a href="?src=\ref[handler];remove_player_info=[target];remove_index=[i]">Remove</a>"}
		body += {"\
			<div style="text-align: right; margin-bottom: 8px;">\
				<div style="text-align: left; border: 1px dashed #808080; padding: 2px;">[comment.content]</div>\
				<div style="text-align: right;">\
					<b>[comment.author || "(not recorded)"]</b>, \
					<b>[comment.rank || "(not recorded)"]</b>, \
					on <b>[comment.timestamp || "(not recorded)"]</b>\
					[comment.game_id ? "<br>Round ID: <b>[comment.game_id]</b>" : null]\
				</div>\
				[remove_button]\
			</div>\
		"}
	send_rsc(user, 'html/browser/common.css', "common.css")
	show_browser(user, html_page_common("Player Info: [target]", body), "window=showplayernotes;size=480x480;")


/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/datum/feed_network/torch_network = news_network[1] //temp change until the UI can be updated to support switching networks.

	var/dat = "<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>"

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!
			"}
			if(torch_network.wanted_issue)
				dat+= "<HR><a href='byond://?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><a href='byond://?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>
				<BR><a href='byond://?src=\ref[src];ac_view=1'>View Feed Channels</A>
				<BR><a href='byond://?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>
				<BR><BR><a href='byond://?src=\ref[usr];mach_close=newscaster_main'>Exit</A>
			"}

			var/wanted_already = 0
			if(torch_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR><B>Feed Security functions:</B><BR>
				<BR><a href='byond://?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
				<BR><a href='byond://?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>
				<BR><a href='byond://?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with [GLOB.using_map.company_name] D-Notice (disables and locks the channel.</A>
				<BR><HR><a href='byond://?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> [SPAN_COLOR("green", src.admincaster_signature)]</A>
			"}
		if(1)
			dat+= "Feed Channels<HR>"
			if( !length(torch_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in torch_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><span style='background-color: LightGreen'><a href='byond://?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></span></B><BR>"
					else
						dat+="<B><a href='byond://?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (SPAN_COLOR("red", "***")) : null ]<BR></B>"
			dat+={"<BR><HR><a href='byond://?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR><B><a href='byond://?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B><a href='byond://?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> [SPAN_COLOR("green", src.admincaster_signature)]<BR>
				<B><a href='byond://?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><a href='byond://?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR><B><a href='byond://?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
				<B>Message Author:</B> [SPAN_COLOR("green", src.admincaster_signature)]<BR>
				<B><a href='byond://?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>
				<BR><a href='byond://?src=\ref[src];ac_submit_new_message=1'>Submit</A><BR><BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+="<B>[SPAN_COLOR("maroon", "ERROR: Could not submit Feed story to Network.</B>")]<HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="[SPAN_COLOR("maroon", "Invalid receiving channel name.")]<BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="[SPAN_COLOR("maroon", "Invalid message body.")]<BR>"
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B>[SPAN_COLOR("maroon", "ERROR: Could not submit Feed Channel to Network.</B>")]<HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="[SPAN_COLOR("maroon", "Invalid channel name.")]<BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in torch_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="[SPAN_COLOR("maroon", "Channel name already in use.")]<BR>"
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B>[FONT_SMALL("\[created by: [SPAN_COLOR("maroon", src.admincaster_feed_channel.author)]\]")]<HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					[SPAN_COLOR("red", "<B>ATTENTION: </B>")]This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( !length(admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							send_rsc(usr, MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="[FONT_SMALL("\[Story by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR>"
			dat+={"
				<BR><HR><a href='byond://?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><a href='byond://?src=\ref[src];ac_setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				<B>[GLOB.using_map.company_name] Feed Censorship Tool</B><BR>
				<span style='font-size: 10px'>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
				Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</span>
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(!length(torch_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in torch_network.network_channels)
					dat+="<a href='byond://?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (SPAN_COLOR("red", "***")) : null ]<BR>"
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				<B>[GLOB.using_map.company_name] D-Notice Handler</B><HR>
				<span style='font-size: 10px'>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the [station_name()]'s
				morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
				stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</span><HR>
			"}
			if(!length(torch_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in torch_network.network_channels)
					dat+="<a href='byond://?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? (SPAN_COLOR("red", "***")) : null ]<BR>"

			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B>[FONT_SMALL("\[ created by: [SPAN_COLOR("maroon", src.admincaster_feed_channel.author)] \]")]<BR>
				[FONT_NORMAL("<a href='byond://?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A>")]<HR>
			"}
			if( !length(admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR>[FONT_SMALL("\[Story by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR>
						[FONT_NORMAL("<a href='byond://?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <a href='byond://?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A>")]<BR>
					"}
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B>[FONT_SMALL("\[ created by: [SPAN_COLOR("maroon", src.admincaster_feed_channel.author)] \]")]<BR>
				Channel messages listed below. If you deem them dangerous to the [station_name()], you can <a href='byond://?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					[SPAN_COLOR("red", "<B>ATTENTION: </B>")]This channel has been deemed as threatening to the welfare of the [station_name()], and marked with a [GLOB.using_map.company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( !length(admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR>[FONT_SMALL("\[Story by [SPAN_COLOR("maroon", MESSAGE.author)]\]")]<BR>"

			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(torch_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="[FONT_NORMAL("<BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.")]</I>"
			dat+={"
				<HR>
				<a href='byond://?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<a href='byond://?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B>[SPAN_COLOR("green", " [torch_network.wanted_issue.backup_author]")]<BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B>[SPAN_COLOR("green", " [src.admincaster_signature]")]<BR>"
			dat+="<BR><a href='byond://?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><a href='byond://?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				[SPAN_COLOR("green", "Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.")]<BR><BR>
				<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+="<B>[SPAN_COLOR("maroon", "ERROR: Wanted Issue rejected by Network.</B>")]<HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="[SPAN_COLOR("maroon", "Invalid name for person wanted.")]<BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="[SPAN_COLOR("maroon", "Invalid description.")]<BR>"
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				<B>Wanted Issue successfully deleted from Circulation</B><BR>
				<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				[SPAN_COLOR("maroon", "<B>-- STATIONWIDE WANTED ISSUE --</B>")]<BR>[FONT_NORMAL("\[Submitted by: [SPAN_COLOR("green", torch_network.wanted_issue.backup_author)]\]")]<HR>
				<B>Criminal</B>: [torch_network.wanted_issue.author]<BR>
				<B>Description</B>: [torch_network.wanted_issue.body]<BR>
				<B>Photo:</B>:
			"}
			if(torch_network.wanted_issue.img)
				send_rsc(usr, torch_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				[SPAN_COLOR("green", "Wanted issue for [src.admincaster_feed_message.author] successfully edited.")]<BR><BR>
				<BR><a href='byond://?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

//	log_debug("Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]")
//	log_debug("Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]")

	show_browser(usr, dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")



/datum/admins/proc/Jobbans()
	if(!check_rights(R_BAN))	return

	var/dat = "<B>Job Bans!</B><HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += "<tr><td>[t] (<A href='byond://?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>"
	dat += "</table>"
	show_browser(usr, dat, "window=ban;size=400x400")

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<a href='byond://?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(SSticker.master_mode == "secret")
		dat += "<a href='byond://?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<a href='byond://?src=\ref[src];create_object=1'>Create Object</A><br>
		<a href='byond://?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<a href='byond://?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<br><a href='byond://?src=\ref[src];vsc=airflow'>Edit Airflow Settings</A><br>
		<a href='byond://?src=\ref[src];vsc=phoron'>Edit Phoron Settings</A><br>
		<a href='byond://?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	show_browser(usr, dat, "window=admin2;size=210x280")
	return

/datum/admins/proc/Secrets(datum/admin_secret_category/active_category = null)
	if(!check_rights(0))	return

	// Print the header with category selection buttons.
	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"
	for(var/datum/admin_secret_category/category in admin_secrets.categories)
		if(!category.can_view(usr))
			continue
		if(active_category == category)
			dat += SPAN_CLASS("linkOn", category.name)
		else
			dat += "<a href='byond://?src=\ref[src];admin_secrets_panel=\ref[category]'>[category.name]</A> "
	dat += "<HR>"

	// If a category is selected, print its description and then options
	if(istype(active_category) && active_category.can_view(usr))
		if(active_category.desc)
			dat += "<I>[active_category.desc]</I><BR>"
		for(var/datum/admin_secret_item/item in active_category.items)
			if(!item.can_view(usr))
				continue
			dat += "<a href='byond://?src=\ref[src];admin_secrets=\ref[item]'>[item.name()]</A><BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(usr, "secrets", "Secrets", 550, 500)
	popup.set_content(dat)
	popup.open()
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		to_world("[SPAN_DANGER("Restarting world!")] [SPAN_NOTICE("Initiated by [usr.key]!")]")
		log_admin("[key_name(usr)] initiated a reboot.")

		sleep(50)
		world.Reboot()


/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))	return

	var/message = input("Global message to send:", "Admin Announce", null, null) as message
	message = sanitize(message, 500, extra = 0)
	if(message)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_world("[SPAN_NOTICE("<b>[usr.key] Announces:</b><p style='text-indent: 50px'>[message]</p>")]")
		log_admin("Announce: [key_name(usr)] : [message]")


GLOBAL_VAR_AS(skip_allow_lists, FALSE)

/datum/admins/proc/toggle_allowlists()
	set category = "Server"
	set name = "Toggle Allow Lists"
	if(!check_rights(R_ADMIN))
		return
	GLOB.skip_allow_lists = !GLOB.skip_allow_lists
	var/outcome = GLOB.skip_allow_lists ? "disabled" : "enabled"
	log_and_message_admins("[key_name(usr)] [outcome] allow lists.")


/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	config.ooc_allowed = !(config.ooc_allowed)
	if (config.ooc_allowed)
		to_world("<B>The OOC channel has been globally enabled!</B>")
	else
		to_world("<B>The OOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled OOC.")

/datum/admins/proc/toggleaooc()
	set category = "Server"
	set desc="Globally Toggles AOOC"
	set name="Toggle AOOC"

	if(!check_rights(R_ADMIN))
		return

	config.aooc_allowed = !(config.aooc_allowed)
	if (config.aooc_allowed)
		communicate_broadcast(/singleton/communication_channel/aooc, "The AOOC channel has been globally enabled!", TRUE)
	else
		communicate_broadcast(/singleton/communication_channel/aooc, "The AOOC channel has been globally disabled!", TRUE)
	log_and_message_admins("toggled AOOC.")

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	config.looc_allowed = !(config.looc_allowed)
	if (config.looc_allowed)
		to_world("<B>The LOOC channel has been globally enabled!</B>")
	else
		to_world("<B>The LOOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled LOOC.")


/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	config.dsay_allowed = !(config.dsay_allowed)
	if (config.dsay_allowed)
		to_world("<B>Deadchat has been globally enabled!</B>")
	else
		to_world("<B>Deadchat has been globally disabled!</B>")
	log_and_message_admins("toggled deadchat.")

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	config.dooc_allowed = !( config.dooc_allowed )
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)

/datum/admins/proc/togglehubvisibility()
	set category = "Server"
	set desc="Globally Toggles Hub Visibility"
	set name="Toggle Hub Visibility"

	if(!check_rights(R_ADMIN))
		return

	world.update_hub_visibility()
	var/long_message = "Updated hub visibility. The server is now [config.hub_visible ? "visible" : "invisible"]."
	if (config.hub_visible && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a firewall is blocking incoming connections.")

	send_to_admin_discord(EXCOM_MSG_AHELP, "[key_name(src, highlight_special_characters = FALSE)]" + long_message)
	log_and_message_admins(long_message)

/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	config.traitor_scaling = !config.traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [config.traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [config.traitor_scaling ? "on" : "off"].", 1)

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(GAME_STATE < RUNLEVEL_LOBBY)
		to_chat(usr, FONT_LARGE(SPAN_DANGER("Unable to start the game as it is not yet set up.")))
		SSticker.start_ASAP = !SSticker.start_ASAP
		if(SSticker.start_ASAP)
			to_chat(usr, FONT_LARGE(SPAN_WARNING("The game will begin as soon as possible.")))
			log_and_message_admins("will begin the game as soon as possible.")
		else
			to_chat(usr, FONT_LARGE(SPAN_WARNING("The game will begin as normal.")))
			log_and_message_admins("will begin the game as normal.")
		return 0
	SSticker.start_ASAP = TRUE
	if(SSticker.start_now())
		log_and_message_admins("has started the game.")
		return 1
	else
		to_chat(usr, SPAN_CLASS("bigwarning", "Error: Start Now: Game has already started."))
		return 0

/datum/admins/proc/endnow()
	set category = "Server"
	set desc = "End the round immediately."
	set name = "End Round"

	var/check = alert("This will immediately end the current round. Are you sure?", "End Game", "Yes", "No") == "Yes"

	if (!check)
		return

	if (GAME_STATE > RUNLEVEL_LOBBY)
		SSticker.forced_end = TRUE
		log_and_message_admins("has ended the round.")
	else
		to_chat(usr, FONT_LARGE(SPAN_WARNING("You cannot end the round before it's begun!")))

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	config.enter_allowed = !(config.enter_allowed)
	if (!(config.enter_allowed))
		to_world("<B>New players may no longer enter the game.</B>")
	else
		to_world("<B>New players may now enter the game.</B>")
	log_and_message_admins("[key_name_admin(usr)] toggled new player game entering.")
	world.update_status()

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	config.abandon_allowed = !(config.abandon_allowed)
	if(config.abandon_allowed)
		to_world("<B>You may now respawn.</B>")
	else
		to_world("<B>You may no longer respawn :(</B>")
	log_and_message_admins("toggled respawn to [config.abandon_allowed ? "On" : "Off"].")
	world.update_status()

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))	return
	if (GAME_STATE > RUNLEVEL_LOBBY)
		SSticker.delay_end = !SSticker.delay_end
		log_and_message_admins("[SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		return //alert("Round end delayed", null, null, null, null, null)
	SSticker.round_progressing = !SSticker.round_progressing
	if (!SSticker.round_progressing)
		to_world("<b>The game start has been delayed.</b>")
		log_admin("[key_name(usr)] delayed the game.")
	else
		to_world("<b>The game will start soon.</b>")
		log_admin("[key_name(usr)] removed the delay.")

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	log_and_message_admins("Toggled admin jumping to [config.allow_admin_jump].")

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	log_and_message_admins("toggled admin item spawning to [config.allow_admin_spawning].")

/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	log_and_message_admins("toggled reviving to [config.allow_admin_rev].")

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)	return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	to_world("[SPAN_DANGER("Rebooting world!")] [SPAN_NOTICE("Initiated by [usr.key]!")]")
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	world.Reboot()

/datum/admins/proc/unprison(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (isAdminLevel(M.z))
		if (config.allow_admin_jump)
			M.forceMove(pick(GLOB.latejoin))
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(character) // returns 1 for special characters and 2 for heroes of gamemode
	if(!SSticker.mode)
		return 0
	var/datum/mind/M
	if (ismob(character))
		var/mob/C = character
		M = C.mind
	else if(istype(character, /datum/mind))
		M = character

	if(M)
		if(SSticker.mode.antag_templates && length(SSticker.mode.antag_templates))
			for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
				if(antag.is_antagonist(M))
					return 2
		if(M.special_role)
			return 1

	if(isrobot(character))
		var/mob/living/silicon/robot/R = character
		if(R.emagged)
			return 1

	return 0

/datum/admins/proc/mass_debug_closet_icons()

	set name = "Mass Debug Closet Icons"
	set desc = "Spawn every possible custom closet. Do not do this on live."
	set category = "Debug"

	// [SIERRA-EDIT]
	// if(!check_rights(R_SPAWN)) // SIERRA-EDIT - ORIGINAL
	if(!check_rights(R_SPAWN|R_DEBUG)) // SIERRA-EDIT
	// [/SIERRA-EDIT]
		return

	if((input(usr, "Are you sure you want to spawn all these closets?", "So Many Closets") as null|anything in list("No", "Yes")) == "Yes")
		log_admin("[key_name(usr)] mass-spawned closets (icon debug), if this is a live server you should yell at them.")
		var/x = 0
		var/y = 0
		for(var/check_appearance in typesof(/singleton/closet_appearance))
			x++
			if(x > 10)
				x = 0
				y++
			var/turf/T = locate(usr.x+x, usr.y+y, usr.z)
			if(T)
				new /obj/structure/closet/debug(T, check_appearance)

/datum/admins/proc/spawn_fruit(seedtype in SSplants.seeds)
	set category = "Debug"
	set desc = "Spawn the product of a seed."
	set name = "Spawn Fruit"

	// [SIERRA-EDIT]
	// if(!check_rights(R_SPAWN))	return // SIERRA-EDIT - ORIGINAL
	if(!check_rights(R_SPAWN|R_DEBUG))	return
	// [/SIERRA-EDIT]

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	var/datum/seed/S = SSplants.seeds[seedtype]
	S.harvest(usr,0,0,1)
	log_admin("[key_name(usr)] spawned [seedtype] fruit at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_custom_item()
	set category = "Debug"
	set desc = "Spawn a custom item."
	set name = "Spawn Custom Item"

	// [SIERRA-EDIT]
	// if(!check_rights(R_SPAWN))	return // SIERRA-EDIT - ORIGINAL
	if(!check_rights(R_SPAWN|R_DEBUG))	return
	// [/SIERRA-EDIT]

	var/owner = input("Select a ckey.", "Spawn Custom Item") as null|anything in SScustomitems.custom_items_by_ckey
	if(!owner|| !SScustomitems.custom_items_by_ckey[owner])
		return

	var/list/possible_items = list()
	for(var/datum/custom_item/item in SScustomitems.custom_items_by_ckey[owner])
		possible_items[item.item_name] = item
	var/item_to_spawn = input("Select an item to spawn.", "Spawn Custom Item") as null|anything in possible_items
	if(item_to_spawn && possible_items[item_to_spawn])
		var/datum/custom_item/item_datum = possible_items[item_to_spawn]
		item_datum.spawn_item(get_turf(usr))

/datum/admins/proc/check_custom_items()

	set category = "Debug"
	set desc = "Check the custom item list."
	set name = "Check Custom Items"

	// [SIERRA-EDIT]
	// if(!check_rights(R_SPAWN))	return // SIERRA-EDIT - ORIGINAL
	if(!check_rights(R_SPAWN|R_DEBUG))	return
	// [/SIERRA-EDIT]

	if(!SScustomitems.custom_items_by_ckey)
		to_chat(usr, "Custom item list is null.")
		return

	if(!length(SScustomitems.custom_items_by_ckey))
		to_chat(usr, "Custom item list not populated.")
		return

	for(var/assoc_key in SScustomitems.custom_items_by_ckey)
		to_chat(usr, "[assoc_key] has:")
		var/list/current_items = SScustomitems.custom_items_by_ckey[assoc_key]
		for(var/datum/custom_item/item in current_items)
			to_chat(usr, "- name: [item.item_name] icon: [item.item_icon_state] path: [item.item_path] desc: [item.item_desc]")

/datum/admins/proc/spawn_plant(seedtype in SSplants.seeds)
	set category = "Debug"
	set desc = "Spawn a spreading plant effect."
	set name = "Spawn Plant"

	// [SIERRA-EDIT]
	//	if(!check_rights(R_ADMIN))	return // SIERRA-EDIT - ORIGINAL
	if(!check_rights(R_SPAWN|R_DEBUG))	return
	// [/SIERRA-EDIT]

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	new /obj/vine(get_turf(usr), SSplants.seeds[seedtype])
	log_admin("[key_name(usr)] spawned [seedtype] vines at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	// [SIERRA-EDIT]
	//	if(!check_rights(R_ADMIN))	return // SIERRA-EDIT - ORIGINAL
	if(!check_rights(R_SPAWN|R_DEBUG))	return
	// [/SIERRA-EDIT]

	var/list/matches = typesof_filtered(/atom, object)

	if(length(matches)==0)
		return

	var/chosen
	if(length(matches)==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return
	var/reason = prevent_spawn_reason(chosen)
	if (reason)
		to_chat(usr, SPAN_WARNING("Cannot create a [chosen] - [reason]"))
		return
	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_and_message_admins("spawned [chosen] at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_artifact(effect in subtypesof(/datum/artifact_effect))
	set category = "Debug"
	set desc = "(atom path) Spawn an artifact with a specified effect."
	set name = "Spawn Artifact"

	// [SIERRA-EDIT]
	//	if(!check_rights(R_ADMIN))	return // SIERRA-EDIT - ORIGINAL
	if (!check_rights(R_SPAWN|R_DEBUG))
	// [/SIERRA-EDIT]
		return

	var/obj/machinery/artifact/A
	var/datum/artifact_trigger/primary_trigger

	var/datum/artifact_effect/secondary_effect
	var/datum/artifact_trigger/secondary_trigger

	var/damage_type

	if (ispath(effect))
		primary_trigger = input(usr, "Choose a trigger", "Choose a trigger") as null | anything in subtypesof(/datum/artifact_trigger)

		if (!ispath(primary_trigger))
			return

		var/choice = alert(usr, "Secondary effect?", "Secondary effect", "Yes", "No") == "Yes"

		if (choice)
			secondary_effect = input(usr, "Choose an effect", "Choose effect") as null | anything in subtypesof(/datum/artifact_effect)

			if (!ispath(secondary_effect))
				return

			secondary_trigger = input(usr, "Choose a trigger", "Choose a trigger") as null | anything in subtypesof(/datum/artifact_trigger)

			if (!ispath(secondary_trigger))
				return

		var/damage_types = list("Sharp" = DAMAGE_FLAG_SHARP, "Bullet" = DAMAGE_FLAG_BULLET, "Edge" = DAMAGE_FLAG_EDGE, "Laser" = DAMAGE_FLAG_LASER)
		choice = input(usr, "Choose a damage effect", "Choose Damage Effect") as null | anything in damage_types | "Invincible"

		if (!choice)
			return

		if (choice != "Invincible")
			damage_type = damage_types[choice]


		A = new(usr.loc)
		A.my_effect = new effect(A)
		A.my_effect.trigger = new primary_trigger(A.my_effect)
		A.damage_type = damage_type
		A.set_damage_description(damage_type)

		if (secondary_effect)
			A.secondary_effect = new secondary_effect
			A.secondary_effect.trigger = new secondary_trigger
		else
			QDEL_NULL(A.secondary_effect)

		log_and_message_admins("spawned an artifact with effects [A.my_effect][A.secondary_effect ? ", [A.secondary_effect]" : ""].")

/datum/admins/proc/show_traitor_panel(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()

/datum/admins/proc/show_game_mode()
	set category = "Admin"
	set desc = "Show the current round configuration."
	set name = "Show Game Mode"

	if(!SSticker.mode)
		alert("Not before roundstart!", "Alert")
		return

	var/out = "[FONT_LARGE("<b>Current mode: [SSticker.mode.name] (<a href='byond://?src=\ref[SSticker.mode];debug_antag=self'>[SSticker.mode.config_tag]</a>)</b>")]<br/>"
	out += "<hr>"

	if(SSticker.mode.ert_disabled)
		out += "<b>Emergency Response Teams:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=ert'>disabled</a>"
	else
		out += "<b>Emergency Response Teams:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=ert'>enabled</a>"
	out += "<br/>"

	if(SSticker.mode.deny_respawn)
		out += "<b>Respawning:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=respawn'>disallowed</a>"
	else
		out += "<b>Respawning:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=respawn'>allowed</a>"
	out += "<br/>"

	out += "<b>Shuttle delay multiplier:</b> <a href='byond://?src=\ref[SSticker.mode];set=shuttle_delay'>[SSticker.mode.shuttle_delay]</a><br/>"

	if(SSticker.mode.auto_recall_shuttle)
		out += "<b>Shuttle auto-recall:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=shuttle_recall'>enabled</a>"
	else
		out += "<b>Shuttle auto-recall:</b> <a href='byond://?src=\ref[SSticker.mode];toggle=shuttle_recall'>disabled</a>"
	out += "<br/><br/>"

	if(SSticker.mode.event_delay_mod_moderate)
		out += "<b>Moderate event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_moderate'>[SSticker.mode.event_delay_mod_moderate]</a><br/>"
	else
		out += "<b>Moderate event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_moderate'>unset</a><br/>"

	if(SSticker.mode.event_delay_mod_major)
		out += "<b>Major event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_severe'>[SSticker.mode.event_delay_mod_major]</a><br/>"
	else
		out += "<b>Major event time modifier:</b> <a href='byond://?src=\ref[SSticker.mode];set=event_modifier_severe'>unset</a><br/>"

	out += "<hr>"

	if(SSticker.mode.antag_tags && length(SSticker.mode.antag_tags))
		out += "<b>Core antag templates:</b></br>"
		for(var/antag_tag in SSticker.mode.antag_tags)
			out += "<a href='byond://?src=\ref[SSticker.mode];debug_antag=[antag_tag]'>[antag_tag]</a>.</br>"

	if(SSticker.mode.round_autoantag)
		out += "<b>Autotraitor <a href='byond://?src=\ref[SSticker.mode];toggle=autotraitor'>enabled</a></b>."
		if(SSticker.mode.antag_scaling_coeff > 0)
			out += " (scaling with <a href='byond://?src=\ref[SSticker.mode];set=antag_scaling'>[SSticker.mode.antag_scaling_coeff]</a>)"
		else
			out += " (not currently scaling, <a href='byond://?src=\ref[SSticker.mode];set=antag_scaling'>set a coefficient</a>)"
		out += "<br/>"
	else
		out += "<b>Autotraitor <a href='byond://?src=\ref[SSticker.mode];toggle=autotraitor'>disabled</a></b>.<br/>"

	out += "<b>All antag ids:</b>"
	if(SSticker.mode.antag_templates && length(SSticker.mode.antag_templates))
		for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
			antag.update_current_antag_max(SSticker.mode)
			out += " <a href='byond://?src=\ref[SSticker.mode];debug_antag=[antag.id]'>[antag.id]</a>"
			out += " ([antag.get_antag_count()]/[antag.cur_max]) "
			out += " <a href='byond://?src=\ref[SSticker.mode];remove_antag_type=[antag.id]'>\[-\]</a><br/>"
	else
		out += " None."
	out += " <a href='byond://?src=\ref[SSticker.mode];add_antag_type=1'>\[+\]</a><br/>"

	show_browser(usr, out, "window=edit_mode[src]")


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmets."
	config.welder_vision = !( config.welder_vision )
	if (config.welder_vision)
		to_world("<B>Reduced welder vision has been enabled!</B>")
	else
		to_world("<B>Reduced welder vision has been disabled!</B>")
	log_and_message_admins("toggled welder vision.")

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	config.guests_allowed = !(config.guests_allowed)
	if (!(config.guests_allowed))
		to_world("<B>Guests may no longer enter the game.</B>")
	else
		to_world("<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [config.guests_allowed?"":"dis"]allowed.")
	log_and_message_admins("toggled guests game entering [config.guests_allowed?"":"dis"]allowed.")

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in SSmobs.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, usr)]'s laws:</b>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>")
		else if (ispAI(S))
			to_chat(usr, "<b>pAI [key_name(S, usr)]'s laws:</b>")
		else
			to_chat(usr, "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>")

		if (isnull(S.laws))
			to_chat(usr, "[key_name(S, usr)]'s laws are null?? Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>")//Just so you know the thing is actually working and not just ignoring you.

/datum/admins/proc/show_skills(mob/M)
	set category = null
	set name = "Skill Panel"

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!M)
		M = input("Select mob.", "Select mob.") as null|mob in GLOB.player_list
	if(!istype(M))
		return
	var/datum/nano_module/skill_ui/NM = /datum/nano_module/skill_ui
	if(isadmin(usr))
		NM = /datum/nano_module/skill_ui/admin //They get the fancy version that lets you change skills and debug stuff.
	NM = new NM(usr, override = M.skillset)
	NM.ui_interact(usr)

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1, datum/ticket/ticket = null)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return "<b>(*not a mob*)</b>"
	switch(detail)
		if(0)
			return "<b>[key_name(C, link, name, highlight_special, ticket)]</b>"

		if(1)	//Private Messages
			return "<b>[key_name(C, link, name, highlight_special, ticket)](<a href='byond://?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)</b>"

		if(2)	//Admins
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special, ticket)](<a href='byond://?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<a href='byond://?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<a href='byond://?_src_=vars;Vars=[ref_mob]'>VV</A>) (<a href='byond://?_src_=holder;narrateto=[ref_mob]'>DN</A>) ([admin_jump_link(M)]) (<a href='byond://?_src_=holder;check_antagonist=1'>CA</A>)</b>"

		if(3)	//Devs
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special, ticket)](<a href='byond://?_src_=vars;Vars=[ref_mob]'>VV</A>)([admin_jump_link(M)])</b>"

/proc/ishost(client/C)
	return check_rights(R_HOST, 0, C)

//Prevents SDQL2 commands from changing admin permissions
/datum/admins/SDQL_update(var_name, new_value)
	return 0

//
//
//ALL DONE
//*********************************************************************************************************
//

//Returns 1 to let the dragdrop code know we are trapping this event
//Returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/observer/ghost/frommob, mob/living/tomob)
	if(!istype(frommob))
		return //Extra sanity check to make sure only observers are shoved into things

	//Same as assume-direct-control perm requirements.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_ADMIN|R_DEBUG,0))
		return 0
	if (!frommob.ckey)
		return 0
	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"
	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1
	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1
	if(tomob.client) //No need to ghostize if there is no client
		tomob.ghostize(0)
	message_admins(SPAN_CLASS("adminnotice", "[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	tomob.ckey = frommob.ckey
	tomob.teleop = null
	qdel(frommob)
	return 1

/datum/admins/proc/force_antag_latespawn()
	set category = "Admin"
	set name = "Force Template Spawn"
	set desc = "Force an antagonist template to spawn."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, "Mode has not started.")
		return

	var/list/all_antag_types = GLOB.all_antag_types_
	var/antag_type = input("Choose a template.","Force Latespawn") as null|anything in all_antag_types
	if(!antag_type || !all_antag_types[antag_type])
		to_chat(usr, "Aborting.")
		return

	var/datum/antagonist/antag = all_antag_types[antag_type]
	message_admins("[key_name(usr)] attempting to force latespawn with template [antag.id].")
	antag.attempt_auto_spawn()

/datum/admins/proc/force_mode_latespawn()
	set category = "Admin"
	set name = "Force Mode Spawn"
	set desc = "Force autotraitor to proc."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins) || !check_rights(R_ADMIN))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, "Mode has not started.")
		return

	log_and_message_admins("attempting to force mode autospawn.")
	SSticker.mode.process_autoantag()

/datum/admins/proc/paralyze_mob(mob/living/H as mob in GLOB.player_list)
	set category = null
	set name = "Toggle Paralyze"
	set desc = "Toggles paralyze state, which stuns, blinds and mutes the victim."

	var/msg

	if(!isliving(H))
		return

	if(check_rights(R_INVESTIGATE))
		if (!H.admin_paralyzed)
			H.paralysis = 8000
			H.admin_paralyzed = TRUE
			msg = "has paralyzed [key_name(H)]."
			H.visible_message(SPAN_DEBUG("OOC: \The [H] has been paralyzed by a staff member. Please hold all interactions with them until staff have finished with them."))
			to_chat(H, SPAN_DEBUG("OOC: You have been paralyzed by a staff member. Please refer to your currently open admin help ticket or, if you don't have one, admin help for assistance."))
		else
			H.paralysis = 0
			H.admin_paralyzed = FALSE
			msg = "has unparalyzed [key_name(H)]."
			H.visible_message(SPAN_DEBUG("OOC: \The [H] has been released from paralysis by staff. You may resume interactions with them."))
			to_chat(H, SPAN_DEBUG("OOC: You have been released from paralysis by staff and can return to your game."))
		log_and_message_staff(msg)


/datum/admins/proc/sendFax()
	set category = "Special Verbs"
	set name = "Send Fax"
	set desc = "Sends a fax to this machine"

	// Admin status checks
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	// Origin
	var/list/option_list = GLOB.admin_departments.Copy() + GLOB.alldepartments.Copy() + "(Custom)" + "(Cancel)"
	var/replyorigin = input(owner, "Please specify who the fax is coming from. Choose '(Custom)' to enter a custom department or '(Cancel) to cancel.", "Fax Origin") as null|anything in option_list
	if (!replyorigin || replyorigin == "(Cancel)")
		return
	if (replyorigin == "(Custom)")
		replyorigin = input(owner, "Please specify who the fax is coming from.", "Fax Machine Department Tag") as text|null
		if (!replyorigin)
			return
	if (replyorigin == "Unknown" || replyorigin == "(Custom)" || replyorigin == "(Cancel)")
		to_chat(owner, SPAN_WARNING("Invalid origin selected."))
		return

	// Generate the fax
	var/obj/item/paper/admin/P = new /obj/item/paper/admin( null ) //hopefully the null loc won't cause trouble for us
	faxreply = P
	P.admindatum = src
	P.origin = replyorigin
	// P.department = department
	P.adminbrowse()


/client/proc/check_fax_history()
	set category = "Special Verbs"
	set name = "Check Fax History"
	set desc = "Look up the faxes sent this round."

	var/data = "<center><b>Fax History:</b></center><br>"

	if(GLOB.adminfaxes)
		for(var/obj/item/item in GLOB.adminfaxes)
			data += "[item.name] - <a href='byond://?_src_=holder;AdminFaxView=\ref[item]'>view message</a><br>"
	else
		data += "<center>No faxes yet.</center>"
	show_browser(usr, "<HTML><HEAD><TITLE>Fax History</TITLE></HEAD><BODY>[data]</BODY></HTML>", "window=FaxHistory;size=450x400")

/datum/admins/var/obj/item/paper/admin/faxreply // var to hold fax replies in

/datum/admins/proc/faxCallback(obj/item/paper/admin/P)
	var/customname = input(src.owner, "Pick a title for the report", "Title") as text|null

	P.SetName("[customname]")

	if(P.should_stamp)
		P.stamps += "<hr><i>This paper has been stamped by the [P.origin] Quantum Relay.</i>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x
		var/y
		x = rand(-2, 0)
		y = rand(-1, 2)
		P.offset_x += x
		P.offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(!P.ico)
			P.ico = new
		P.ico += "paper_stamp-boss"
		stampoverlay.icon_state = "paper_stamp-boss"

		if(!P.stamped)
			P.stamped = new
		P.stamped += /obj/item/stamp/boss
		P.AddOverlays(stampoverlay)

	var/obj/item/rcvdcopy
	var/obj/machinery/photocopier/faxmachine/temp_fax = new
	rcvdcopy = temp_fax.copy(P, FALSE)
	rcvdcopy.forceMove(null) //hopefully this shouldn't cause trouble
	GLOB.adminfaxes += rcvdcopy
	qdel(temp_fax)
	var/success = send_fax_loop(P, P.destinations, P.origin)

	if (success)
		var/dests_string = P.destinations.Join(", ")
		to_chat(src.owner, SPAN_NOTICE("Message reply to transmitted successfully."))
		if(P.sender) // sent as a reply
			log_admin("[key_name(src.owner)] replied to a fax message from [key_name(P.sender)]")
			for(var/client/C as anything in GLOB.admins)
				if((R_INVESTIGATE) & C.holder.rights)
					to_chat(C, SPAN_CLASS("log_message", "[SPAN_CLASS("prefix", "FAX LOG:")][key_name_admin(src.owner)] replied to a fax message from [key_name_admin(P.sender)] (<a href='byond://?_src_=holder;AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)"))
		else
			log_admin("[key_name(src.owner)] has sent a fax message to [dests_string]")
			for(var/client/C as anything in GLOB.admins)
				if((R_INVESTIGATE) & C.holder.rights)
					to_chat(C, SPAN_CLASS("log_message", "[SPAN_CLASS("prefix", "FAX LOG:")][key_name_admin(src.owner)] has sent a fax message to [dests_string] (<a href='byond://?_src_=holder;AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)"))
	else
		to_chat(src.owner, SPAN_WARNING("Message reply failed."))

	spawn(100)
		qdel(P)
		faxreply = null
	return


/datum/admins/proc/SetRoundLength()
	set category = "Server"
	set name = "Set Round Length"
	set desc = "Set how long before the initial continue vote occurs (in minutes)."
	if (GAME_STATE > RUNLEVEL_GAME)
		to_chat(usr, SPAN_WARNING("The game is already ending!"))
		return
	var/current = round(round_duration_in_ticks / 600, 0.1)
	var/response = input(usr, "Time in minutes before the continue vote will occur, or 0 to set to default.\nCurrent time: [current]m") as null | num
	current = round(round_duration_in_ticks / 600, 0.1)
	if (!isnum(response))
		return
	if (!response)
		log_and_message_admins("set the time to first continue vote to default.")
		config.vote_autotransfer_initial = initial(config.vote_autotransfer_initial)
	else if (response > current)
		log_and_message_admins("set time to first continue vote to [response] minutes.")
		config.vote_autotransfer_initial = response
		SSroundend.vote_check = (round_duration_in_ticks / 600) + response
	else
		to_chat(usr, SPAN_WARNING("You cannot set a continue vote time in the past."))

/datum/admins/proc/SetMaximumRoundLength()
	set category = "Server"
	set name = "Set Maximum Round Length"
	set desc = "Set the maximum length of a round in minutes."
	if (GAME_STATE > RUNLEVEL_GAME)
		to_chat(usr, SPAN_WARNING("The game is already ending!"))
		return
	var/current = round(round_duration_in_ticks / 600, 0.1)
	var/response = input(usr, "Time in minutes when the round will end, or 0 to disable.\nCurrent time: [current]m") as null | num
	if (!isnum(response))
		return
	if (!response)
		log_and_message_admins("disabled max round length.")
		config.maximum_round_length = response
	else if (response > current)
		log_and_message_admins("set max round length to [response] minutes.")
		config.maximum_round_length = response
	else
		to_chat(usr, SPAN_WARNING("You cannot set a max round length in the past."))


/datum/admins/proc/ToggleContinueVote()
	set category = "Server"
	set name = "Toggle Continue Vote"
	set desc = "Toggle the continue vote on/off. Toggling off will cause round-end to occur when the next continue vote time would be."
	if (GAME_STATE > RUNLEVEL_GAME)
		to_chat(usr, SPAN_WARNING("The game is already ending!"))
		return
	SSroundend.vote_check = !SSroundend.vote_check
	if (SSroundend.vote_check)
		var/interval = config.vote_autotransfer_interval
		if (!interval)
			to_chat(usr, SPAN_WARNING("Continue votes not configured."))
			SSroundend.vote_check = 0
			return
		SSroundend.vote_check = (round_duration_in_ticks / 600) + interval
	log_and_message_admins("toggled continue votes [SSroundend.vote_check ? "ON" : "OFF"]")


/datum/admins/proc/togglemoderequirementchecks()
	set category = "Server"
	set desc = "Toggle the gamemode requirement checks on/off. Toggling off will allow any gamemode to start regardless of readied players."
	set name = "Toggle Gamemode Requirement Checks"

	if (GAME_STATE > RUNLEVEL_LOBBY)
		to_chat(usr, SPAN_WARNING("You cannot change the gamemode requirement checks after the game has started!"))
		return

	SSticker.skip_requirement_checks = !SSticker.skip_requirement_checks
	log_and_message_admins("toggled the gamemode requirement checks [SSticker.skip_requirement_checks ? "OFF" : "ON"]")


/datum/admins/proc/EnableDevtools()
	set category = "Debug"
	set name = "Enable Devtools"
	set desc = "Self-enable chromium devtools on browser panes."
	if (!check_rights(R_DEBUG))
		return
	winset(usr, "", "browser-options=devtools")
