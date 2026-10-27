/proc/odyssey_lobby_votes_allowed()
	if (GAME_STATE != RUNLEVEL_LOBBY)
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return !state.active


/datum/vote/odyssey_lobby
	manual_allowed = FALSE
	var/odyssey_fail_verb = "начата"


/datum/vote/odyssey_lobby/can_run(mob/creator, automatic)
	if (!odyssey_lobby_votes_allowed())
		return FALSE
	return ..()


/datum/vote/odyssey_lobby/Process()
	if (GAME_STATE != RUNLEVEL_LOBBY)
		to_world("<b>Голосование по Одиссее отменено: раунд уже начался.</b>")
		return VOTE_PROCESS_ABORT
	return ..()


/datum/vote/odyssey_lobby/handle_default_votes()
	return 0


/datum/vote/odyssey_lobby/proc/odyssey_yes_votes()
	return choices[ODYSSEY_CHOICE_YES] || 0


/datum/vote/odyssey_lobby/proc/odyssey_no_votes()
	return choices[ODYSSEY_CHOICE_NO] || 0


/datum/vote/odyssey_lobby/proc/odyssey_yes_threshold_met()
	var/yes_votes = odyssey_yes_votes()
	var/no_votes = odyssey_no_votes()
	return yes_votes >= ODYSSEY_MIN_YES_VOTES && yes_votes > no_votes


/datum/vote/odyssey_lobby/proc/odyssey_no_threshold_met()
	var/yes_votes = odyssey_yes_votes()
	var/no_votes = odyssey_no_votes()
	return no_votes >= ODYSSEY_MIN_YES_VOTES && no_votes > yes_votes


/datum/vote/odyssey_lobby/proc/odyssey_vote_passed()
	if (!odyssey_lobby_votes_allowed())
		log_game("ODYSSEY: lobby vote result ignored, round already started")
		return FALSE
	var/yes_votes = odyssey_yes_votes()
	var/no_votes = odyssey_no_votes()
	if (!odyssey_yes_threshold_met())
		to_world(SPAN_NOTICE("<b>Одиссея не [odyssey_fail_verb]: нужно минимум [ODYSSEY_MIN_YES_VOTES] голосов «[ODYSSEY_CHOICE_YES]», и их должно быть больше, чем «[ODYSSEY_CHOICE_NO]» (За: [yes_votes], Против: [no_votes]).</b>"))
		log_game("ODYSSEY: vote failed yes=[yes_votes] no=[no_votes] need=[ODYSSEY_MIN_YES_VOTES]")
		return FALSE
	return TRUE


/datum/vote/odyssey_start
	parent_type = /datum/vote/odyssey_lobby
	name = "odyssey start"
	question = "Начать Одиссею в этом раунде? (нужно не меньше 10 голосов «За»)"
	manual_allowed = TRUE

/datum/vote/odyssey_start/can_run(mob/creator, automatic)
	if (odyssey_campaign_exists())
		return FALSE
	return ..()

/datum/vote/odyssey_start/setup_vote(mob/creator, automatic)
	choices = list(ODYSSEY_CHOICE_YES, ODYSSEY_CHOICE_NO)
	..()

/datum/vote/odyssey_start/report_result()
	. = ..()
	if (. || !length(result))
		return
	if (!odyssey_vote_passed())
		return
	odyssey_begin_campaign(FALSE)


/datum/vote/odyssey_continue
	parent_type = /datum/vote/odyssey_lobby
	name = "odyssey continue"
	question = "Продолжить сохранённую Одиссею? (нужно не меньше 10 голосов «За»)"
	manual_allowed = TRUE
	odyssey_fail_verb = "продолжена"

/datum/vote/odyssey_continue/can_run(mob/creator, automatic)
	if (!odyssey_campaign_exists())
		return FALSE
	var/list/lobby = SSticker?.lobby_players()
	if (length(lobby) < ODYSSEY_MIN_CONTINUE_PLAYERS && !isadmin(creator))
		return FALSE
	return ..()

/datum/vote/odyssey_continue/setup_vote(mob/creator, automatic)
	choices = list(ODYSSEY_CHOICE_YES, ODYSSEY_CHOICE_NO)
	var/list/meta = odyssey_load_meta()
	if (islist(meta))
		question = odyssey_continue_briefing(meta, TRUE)
		// Full IC briefing lives on the lobby Odyssey button; only spam chat on legacy auto-start.
		if (automatic)
			odyssey_announce_continue_briefing()
	..()


/// Starts start/continue vote from lobby UI. Returns TRUE if the vote began.
/proc/odyssey_try_start_lobby_vote(mob/user)
	if (!odyssey_lobby_votes_allowed())
		if (user)
			to_chat(user, SPAN_WARNING("Голосование по Одиссее доступно только в лобби, пока экспедиция ещё не включена."))
		return FALSE
	if (SSvote?.active_vote)
		if (user)
			to_chat(user, SPAN_WARNING("Уже идёт другое голосование."))
		return FALSE

	var/has_campaign = odyssey_campaign_exists()
	var/list/lobby = SSticker?.lobby_players()
	var/players = length(lobby)
	if (has_campaign && players < ODYSSEY_MIN_CONTINUE_PLAYERS && !isadmin(user))
		if (user)
			to_chat(user, SPAN_WARNING("Для голосования о продолжении нужно минимум [ODYSSEY_MIN_CONTINUE_PLAYERS] игроков в лобби (сейчас [players])."))
		return FALSE

	var/vote_path = has_campaign ? /datum/vote/odyssey_continue : /datum/vote/odyssey_start
	var/started = SSvote.initiate_vote(vote_path, user, automatic = 0)
	if (!started)
		if (user)
			to_chat(user, SPAN_WARNING("Не удалось начать голосование (задержка между vote или условия не выполнены)."))
		return FALSE
	log_game("ODYSSEY: lobby vote started by [user?.ckey || "unknown"] type=[vote_path]")
	return TRUE

/datum/vote/odyssey_continue/report_result()
	. = ..()
	if (. || !length(result))
		return
	if (!odyssey_lobby_votes_allowed())
		log_game("ODYSSEY: continue vote result ignored, round already started")
		return
	var/yes_votes = odyssey_yes_votes()
	var/no_votes = odyssey_no_votes()
	if (odyssey_yes_threshold_met())
		odyssey_begin_campaign(TRUE)
		return
	if (odyssey_no_threshold_met())
		odyssey_archive_campaign("continue_vote_no", ODYSSEY_STATUS_ADMIN_ABORTED)
		to_world(SPAN_NOTICE("<b>Одиссея не продолжена: набрано [no_votes] голосов «[ODYSSEY_CHOICE_NO]». Кампания архивирована.</b>"))
		log_game("ODYSSEY: continue vote archived yes=[yes_votes] no=[no_votes]")
		return
	to_world(SPAN_NOTICE("<b>Одиссея не продолжена: никто не набрал [ODYSSEY_MIN_YES_VOTES] голосов (За: [yes_votes], Против: [no_votes]). Сейв сохранён.</b>"))
	log_game("ODYSSEY: continue vote kept save yes=[yes_votes] no=[no_votes]")


/datum/vote/transfer/get_transfer_choice()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active)
		return "End the shift"
	return ..()


/datum/vote/transfer/can_run(mob/creator, automatic)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active && state.shift_end_queued)
		return FALSE
	return ..()
