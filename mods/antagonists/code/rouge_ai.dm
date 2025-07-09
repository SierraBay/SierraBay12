/datum/antagonist/rogue_ai/finalize_spawn()
	if(!pending_antagonists)
		return

	for(var/datum/mind/player in pending_antagonists)
		pending_antagonists -= player
		add_antagonist(player,0,0,1)

	reset_antag_selection()

	empty_playable_ai_cores = 0
	log_admin("Сбойный ИИ успешно выбран и добавлен. Остальные ядра ИИ отключены.")
