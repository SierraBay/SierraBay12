/datum/admins/proc/player_list_legacy() // [SIERRA-EDIT]
	if (!usr.client.holder)
		return
	var/index = length(GLOB.player_list)
	var/list/entries = new (index)
	var/entry_template = file2text("html/pages/player_list_entry.html")
	var/regex/strip_symbols = regex(@/['"\\<>]/, "g")
	for (var/mob/player as anything in GLOB.player_list)
		var/job
		if (ishuman(player))
			var/mob/living/carbon/human/human = player
			job = "[human.species.name] [human.job]"
		else if (isAI(player))
			job = "AI"
		else if (ispAI(player))
			job = "pAI"
		else if (isrobot(player))
			job = "Robot"
		else if (isghost(player))
			job = "Ghost"
		else if (isnewplayer(player))
			job = "Lobby"
		else if (isanimal(player) || isalien(player))
			job = "Animal"
		else if (isslime(player))
			job = "Slime"
		else
			job = "[player.type]"
		var/entry = replacetext_char(entry_template, "{BACKGROUND}", index & 1 ? "#e0e0e0" : "#f0f0f0")
		entry = replacetext_char(entry, "{INDEX}", index)
		entry = replacetext_char(entry, "{JOB}", replacetext_char(job, strip_symbols, ""))
		entry = replacetext_char(entry, "{REAL_NAME}", replacetext_char(player.real_name, strip_symbols, ""))
		entry = replacetext_char(entry, "{NAME}", replacetext_char(player.name, strip_symbols, ""))
		entry = replacetext_char(entry, "{KEY}", replacetext_char(player.key, strip_symbols, ""))
		entry = replacetext_char(entry, "{ANTAG}", is_special_character(player) ? "true" : "false")
		entry = replacetext_char(entry, "{REF}", "\ref[player]")
		entry = replacetext_char(entry, "{ADDR}", player.lastKnownIP)
		entries[index] = entry
		--index
	var/doc = replacetext_char(file2text("html/pages/player_list.html"), "{REF_SRC}", "\ref[src]")
	doc = replacetext_char(doc, "{REF_USR}", "\ref[usr]")
	doc = replacetext_char(doc, "{ENTRIES}", jointext(entries, null))
	show_browser(usr, doc, "window=player_list;size=640x480")

// [SIERRA-ADD]
/datum/admins/proc/player_list()
	var/html = {"
		<style type="text/css">
			body { overflow: hidden !important; margin: 0; padding: 10px; box-sizing: border-box; }
			.action-link { display: inline-block; margin-right: 4px; font-family: monospace; }
			.search-input { width: 100%; padding: 4px; box-sizing: border-box; }
			.multikey-warn { color: #ff4444; font-weight: bold; margin-left: 5px; }
			.multiban-warn { color: #ff0000 ; font-weight: bold; margin-left: 5px; }
			table { border-collapse: collapse; border-spacing: 0; width: 100%; margin: 0; }
			th {
				position: -webkit-sticky;
				position: sticky;
				top: 0;
				background: #202020;
				z-index: 10;
				box-shadow: inset 0 -1px 0 #333;
				background-clip: padding-box;
			}
		</style>
		<div style="padding-bottom: 10px;">
			<input type="text" id="search_input" class="search-input" oninput="window.filterTable()" onkeyup="window.filterTable()" placeholder="Search for keys, names, jobs, IPs...">
		</div>
		<div style="padding-bottom: 10px;">
			<a href="?_src_=holder;refresh_player_list=1">Refresh</a> |
			<a href="?_src_=holder;check_antagonist=1">Check Antagonists</a>
		</div>
		<div style="height: calc(100vh - 140px); overflow-y: auto; border: 1px solid #333; border-radius: 4px;">
			<table class="data hover" id="player_table">
				<thead>
					<tr>
						<th onclick="window.sortTable(0)" style="cursor: pointer;">Ckey</th>
						<th onclick="window.sortTable(1)" style="cursor: pointer;">Name</th>
						<th onclick="window.sortTable(2)" style="cursor: pointer;">Real Name</th>
						<th onclick="window.sortTable(3)" style="cursor: pointer;">IP Address</th>
						<th onclick="window.sortTable(4)" style="cursor: pointer;">Job</th>
						<th onclick="window.sortTable(5)" style="cursor: pointer;">Antag</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody id="player_body">
	"}

	for (var/mob/player as anything in GLOB.player_list)
		var/job_text = ""
		var/job_color = "#ccc"
		if (ishuman(player))
			var/mob/living/carbon/human/human = player
			job_text = "[human.species.name] [human.job]"
			job_color = "#e0e0e0"
		else if (isAI(player))
			job_text = "AI"
			job_color = "#5dade2"
		else if (ispAI(player))
			job_text = "pAI"
			job_color = "#85c1e9"
		else if (isrobot(player))
			job_text = "Robot"
			job_color = "#3498db"
		else if (isghost(player))
			job_text = "Ghost"
			job_color = "#7f8c8d"
		else if (isnewplayer(player))
			job_text = "Lobby"
			job_color = "#2ecc71"
		else if (isanimal(player) || isalien(player))
			job_text = "Animal"
			job_color = "#e67e22"
		else if (isslime(player))
			job_text = "Slime"
			job_color = "#9b59b6"
		else
			job_text = "[player.type]"
			job_color = "#f1c40f"

		var/is_multicon = 0
		var/is_multiban = 0
		var/ip_address = "No Client"
		if (player.client)
			is_multicon = player.client.have_connection_warn
			is_multiban = player.client.have_bans_warn
			ip_address = player.client.address || "localhost"

		var/antag_role = "NO"
		if (is_special_character(player))
			antag_role = (player.mind && player.mind.special_role) ? player.mind.special_role : "Antagonist"

		var/antag_html = (antag_role != "NO") ? "<span class='highlight'>[antag_role]</span>" : "NO"
		var/multicon_html = is_multicon ? "<a href='?src=\ref[src];show_connections=\ref[player]' class='multikey-warn' title='Multiple connections detected!'>&#91;!&#93;</a>" : ""
		var/multiban_html = is_multiban ? "<a href='?src=\ref[src];show_bans=\ref[player]' class='multiban-warn' title='Associated bans detected!'>&#91;!&#93;</a>" : ""
		var/ref = "\ref[player]"
		var/src_ref = "\ref[src]"

		html += {"
				<tr class="player-row">
					<td>[player.key] [multiban_html]</td>
					<td>[player.name]</td>
					<td>[player.real_name]</td>
					<td>[ip_address] [multicon_html]</td>
					<td style="color: [job_color];">[job_text]</td>
					<td>[antag_html]</td>
					<td style="white-space: nowrap;">
						<a href='?src=[src_ref];adminplayeropts=[ref]' class='action-link'>PP</a>
						<a href='?src=[src_ref];notes=show;mob=[ref]' class='action-link'>N</a>
						<a href='?_src_=vars;Vars=[ref]' class='action-link'>VV</a>
						<a href='?src=[src_ref];traitor=[ref]' class='action-link'>TP</a>
						<a href='?src=[src_ref];priv_msg=[ref]' class='action-link'>PM</a>
						<a href='?src=[src_ref];narrateto=[ref]' class='action-link'>DN</a>
						<a href='?src=[src_ref];adminplayerobservefollow=[ref]' class='action-link'>JMP</a>
					</td>
				</tr>
		"}



	html += {"
				</tbody>
			</table>
		</div>
		<script type="text/javascript" src="playerlist.js"></script>
	"}

	send_rsc(usr, 'html/scripts/player_list.js', "playerlist.js")
	var/datum/browser/popup = new(usr, "player_list", "Player List", 1150, 700)
	popup.set_content(html)
	popup.open()
// [/SIERRA-ADD]
