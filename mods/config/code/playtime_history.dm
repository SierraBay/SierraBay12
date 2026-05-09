SUBSYSTEM_DEF(playtime_history)
	name = "Playtime History"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_GAME
	wait = 5 MINUTES

/datum/controller/subsystem/playtime_history/fire(resumed = FALSE)
	if(!sqlenabled)
		return
	if(!establish_db_connection() || !dbcon.IsConnected())
		return

	var/minutes_to_add = round(wait / (1 MINUTE))
	if(minutes_to_add < 1)
		minutes_to_add = 1

	for(var/client/client as anything in GLOB.clients)
		if(!client?.mob?.mind)
			continue

		var/added_living = 0
		var/added_ghost = 0
		if(client.mob.stat != DEAD)
			if(client.mob.mind.assigned_role)
				added_living = minutes_to_add
		else if(isobserver(client.mob))
			added_ghost = minutes_to_add
		else
			continue

		if(!added_living && !added_ghost)
			continue

		var/sql_ckey = sql_sanitize_text(client.ckey)
		var/sql = {"INSERT INTO `erro_playtime_history` (`ckey`, `date`, `time_living`, `time_ghost`)
			VALUES ('[sql_ckey]', CURDATE(), [added_living], [added_ghost])
			ON DUPLICATE KEY UPDATE
			`time_living` = `time_living` + VALUES(`time_living`),
			`time_ghost` = `time_ghost` + VALUES(`time_ghost`)"}
		var/DBQuery/query = dbcon.NewQuery(sql)
		if(!query.Execute())
			log_debug("SS [name]: erro_playtime_history save failed ([client.ckey]): [dbcon.ErrorMsg()]")
