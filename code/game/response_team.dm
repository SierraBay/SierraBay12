//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

var/global/send_emergency_team = 0 // Used for automagic response teams
								   // 'admin_emergency_team' for admin-spawned response teams
var/global/can_call_ert

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Special Verbs"
	set desc = "Send an emergency response team"

	if(!holder)
		to_chat(usr, SPAN_DANGER("Only administrators may use this command."))
		return
	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, SPAN_DANGER("The game hasn't started yet!"))
		return
	if(send_emergency_team)
		to_chat(usr, SPAN_DANGER("[GLOB.using_map.boss_name] has already dispatched an emergency response team!"))
		return

	var/reason = input("What is the reason for dispatching this Emergency Response Team?\nThis will be shared with the ERT.", "Dispatching Emergency Response Team")

	if(!reason && alert("You did not input a reason. Continue anyway?",,"Yes", "No") != "Yes")
		return

	var/notify
	switch(alert("Notify the crew?\n(Eligible ghosts are always notified)", "ERT announcement", "Yes", "No"))
		if("No")
			notify = FALSE
			switch(alert("Make ERT stealthy?\n(Hides their presence in the overmap and prevents shuttle announcements)", "Stealth ERT", "Yes", "No"))
				if("Yes")
					GLOB.ert.is_secret = TRUE
				if("No")
					GLOB.ert.is_secret = FALSE
				else
					return
		if("Yes")
			GLOB.ert.is_secret = FALSE
			notify = TRUE
		else
			return // User closed the alert without picking any options

	if(alert("Are you sure?","Send ERT","Yes","No") != "Yes")
		return

	if(send_emergency_team)
		to_chat(usr, SPAN_DANGER("Looks like someone beat you to it!"))
		return

	if(reason)
		message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team for the reason: [reason]", 1)
	else
		message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.", 1)

	log_admin("[key_name(usr)] used Dispatch Response Team.")
	trigger_armed_response_team(TRUE, reason, notify)

/mob/observer/ghost/verb/JoinResponseTeam()

	set name = "Join Response Team"
	set category = "Ghost"

	if(!MayRespawn(1))
		to_chat(usr, SPAN_WARNING("You cannot join the response team at this time."))
		return

	if(isghost(usr) || isnewplayer(usr))
		if(!send_emergency_team)
			to_chat(usr, "No emergency response team is currently being sent.")
			return
		if(jobban_isbanned(usr, MODE_ERT) || jobban_isbanned(usr, "Security Officer"))
			to_chat(usr, SPAN_DANGER("You are jobbanned from the emergency reponse team!"))
			return
		if(length(GLOB.ert.current_antagonists) >= GLOB.ert.hard_cap)
			to_chat(usr, "The emergency response team is already full!")
			if(!send_emergency_team)
				return
			close_ert()
		GLOB.ert.create_default(usr)
	else
		to_chat(usr, "You need to be an observer or new player to use this.")

// returns a number of dead players in %
/proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in SSmobs.mob_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == 2) deadcount++
			total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
/proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in SSmobs.mob_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)

/// Sends a message to potential ERT candidates
/proc/notify_ert_candidates(message as text)
	for(var/mob/player in GLOB.player_list)
		if(!isghost(player) || jobban_isbanned(player, MODE_ERT) || jobban_isbanned(player, "Security Officer"))
			continue
		to_chat(player,message)

/// Prevents new users from joining the ERT and sends out a notification
/proc/close_ert()
	if(!send_emergency_team)
		return
	send_emergency_team = FALSE

	message_admins("The ERT is no longer accepting new players.\n[length(GLOB.ert.current_antagonists)]/[GLOB.ert.hard_cap] responders were dispatched.")
	notify_ert_candidates(SPAN_NOTICE("The ERT is no longer accepting new players."))
	var/msg = "No more emergency responders are expected to join your team. \
	Deck crew has loaded your munitions and mission equipment, ensure your team departs as soon as possible."
	GLOB.ert_announcer.autosay(msg, "Mission Control", "ERT")

/proc/trigger_armed_response_team(force = FALSE, reason = "", announce_ert = TRUE)
	if(!can_call_ert && !force)
		return
	if(send_emergency_team)
		return

	var/send_team_chance = 10
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force) send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance))
		command_announcement.Announce("It would appear that an emergency response team was requested for the [station_name()]. Unfortunately, we were unable to send one at this time.", "[GLOB.using_map.boss_name]")
		can_call_ert = 0 // Only one call per round, ladies.
		return

	can_call_ert = 0 // Only one call per round, gentleman.
	send_emergency_team = 1

	if(announce_ert)
		command_announcement.Announce("A distress signal has been recieved from your vessel. We're attempting to dispatch an emergency response team to your position.", "[GLOB.using_map.boss_name]", sound('sound/misc/notice1.ogg', volume = 30))

	notify_ert_candidates(SPAN_NOTICE(FONT_LARGE("An emergency response team is being sent to the [station_name()]. You can join it by going selecting the Ghost tab and clicking <b>Join Response Team</b>")))

	spawn(3 MINUTES)
		close_ert()

	GLOB.ert.reason = reason //Set it even if it's blank to clear a reason from a previous ERT
