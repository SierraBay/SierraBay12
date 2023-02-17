// When i wrote this, it was called at SS_INIT_EARLY - right after SS_INIT_DBCODE
/singleton/modpack/don_loadout/initialize()
	if(!sqlenabled)
		log_debug("Donations system is disabled with SQL!")
		return

	if(!config.donations_enabled)
		log_debug("Donations system is disabled by configuration!")
		return

	if(establish_db_connection())
		log_debug("Donations system successfully connected to DB!")
		UpdateAllClients()
	else
		log_debug("Donations system failed to connect with DB!")

	return ..()

/singleton/modpack/don_loadout/proc/UpdateAllClients()
	set waitfor = 0
	for(var/client/C in GLOB.clients)
		log_client_to_db(C)
		update_donator(C)
		update_donator_items(C)
	log_debug("Donators info were updated!")


/singleton/modpack/don_loadout/proc/log_client_to_db(client/player)
	set waitfor = 0

	if(!establish_db_connection())
		return FALSE

	sql_query("INSERT IGNORE INTO players (ckey) VALUES ($ckey)", dbcon, list(ckey = player.ckey))

	return TRUE


/singleton/modpack/don_loadout/proc/update_donator(client/player)
	set waitfor = 0

	if(!establish_db_connection())
		return FALSE
	ASSERT(player)

	var/was_donator = player.donator_info.donator

	var/DBQuery/query = sql_query({"
		SELECT
			donation_types.type
		FROM
			players
		JOIN
			donation_types ON players.donation_type = donation_types.id
		WHERE
			ckey = $ckey
		LIMIT 0,1
	"}, dbcon, list(ckey = player.ckey))

	if(query.NextRow())
		player.donator_info.donation_type = query.item[1]

	query = sql_query({"
		SELECT
			`change`
		FROM
			points_transactions
		JOIN
			players ON players.id = points_transactions.player
		WHERE
			ckey = $ckey
	"}, dbcon, list(ckey = player.ckey))

	player.donator_info.phinixes = 0
	while(query.NextRow())
		player.donator_info.phinixes += text2num(query.item[1])

	if(player.donator_info.phinixes > 0)
		player.donator_info.donator = TRUE

	if(!was_donator)
		player.donator_info.on_donation_tier_loaded(player)

	return TRUE

/singleton/modpack/don_loadout/proc/update_donator_items(client/player)
	set waitfor = 0

	if(!establish_db_connection())
		return FALSE

	var/DBQuery/query = sql_query({"
		SELECT
			item_path
		FROM
			store_players_items
		WHERE
			player = (SELECT id FROM players WHERE ckey = $ckey)
	"}, dbcon, list(ckey = player.ckey))

	while(query.NextRow())
		player.donator_info.items.Add(query.item[1])

	return TRUE

/singleton/modpack/don_loadout/proc/create_transaction(client/player, change, type, comment)
	if(!establish_db_connection())
		return FALSE
	ASSERT(player)
	ASSERT(isnum(change))

	update_donator(player)
	if(!player) // check if player was gone away, while we were updating him
		return FALSE

	if(player.donator_info.phinixes + change < 0)
		return FALSE

	sql_query({"
		INSERT INTO
			points_transactions
		VALUES (
			NULL,
			(SELECT id FROM players WHERE ckey = $ckey),
			(SELECT id FROM points_transactions_types WHERE type = $type),
			NOW(),
			$change,
			$comment)
	"}, dbcon, list(ckey = player.ckey, type = type, change = change, comment = comment))

	var/transaction_id
	var/DBQuery/query = sql_query({"
		SELECT
			id
		FROM
			points_transactions
		WHERE
			player = (SELECT id FROM players WHERE ckey = $ckey)
			AND
			comment = $comment
		ORDER BY
			id
			DESC
	"}, dbcon, list(ckey = player.ckey, comment = comment))

	if(query.NextRow())
		transaction_id = query.item[1]

	update_donator(player)

	return text2num(transaction_id)


/singleton/modpack/don_loadout/proc/remove_transaction(client/player, id)
	if(!establish_db_connection())
		return FALSE
	ASSERT(isnum(id))

	log_debug("\[Donations DB] Transaction [id] rollback is called! User is '[player]'.")

	sql_query({"
		DELETE FROM
			points_transactions
		WHERE
			id = $id
	"}, dbcon, list(id = id))

	if(player)
		update_donator(player)
	return TRUE


/singleton/modpack/don_loadout/proc/give_item(client/player, item_type, transaction_id = null)
	if(!establish_db_connection())
		return FALSE
	ASSERT(player)
	ASSERT(item_type)
	ASSERT(transaction_id == null || isnum(transaction_id))

	sql_query({"
		INSERT INTO
			store_players_items
		VALUES
			(NULL,
			(SELECT id from players WHERE ckey = $ckey),
			$tid,
			NOW(),
			$item_type)
	"}, dbcon, list(ckey = player.ckey, tid = transaction_id ? transaction_id : "NULL", item_type = item_type))

	player.donator_info.items.Add("[item_type]")

	return TRUE

/singleton/modpack/don_loadout/proc/show_donations_info(mob/user)
	ASSERT(user)

	var html = {"
	<p>Резвизиты для <b>разовых пожертвований</b> можно найти в разделе <b>#донаты</b> нашего дискорда:</p>
	<center><a href="?src=\ref[src]">Открыть Discord</a></center>
	<p>
			За денежные пожертвования, в благодарность от нашего сервера, вы получаете <b>phinix</b>. Либо доступ на месяц к
	</p>
	"}
	if(length(SSmodpacks.loaded_modpacks))
		. = "<hr><br><center><b><font size = 3>Modpacks List</font></b></center><br><hr><br>"
		for(var/modpack in SSmodpacks.loaded_modpacks)
			var/singleton/modpack/M = SSmodpacks.loaded_modpacks[modpack]

	var/datum/browser/popup = new(user, "modpacks_list", "Modpacks List", 480, 580)
	popup.set_content(html)
	popup.open()


/singleton/modpack/don_loadout/Topic(href, href_list)
	var/mob/user = usr

	switch(href_list["action"])
		if("go_to_discord")
			log_debug("\[Donations] discord link used by '[user]'")
			send_link(user, config.discord_url)
			return 1

	return 0
