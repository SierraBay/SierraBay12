/obj/item/device/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	get_asset_datum(/datum/asset/simple/paicard).send(user)
	user.set_machine(src)
	var/dat = {"
		<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
		<html>
			<head>
				<style>
					body {
						margin-top:5px;
						font-family:Verdana;
						color:white;
						font-size:13px;
						background-image:url('uiBackground.png');
						background-repeat:repeat-x;
						background-color:#272727;
						background-position:center top;
					}
					table {
						font-size:13px;
						margin-left:-2px;
					}
					table.request {
						border-collapse:collapse;
					}
					table.desc {
						border-collapse:collapse;
						font-size:13px;
						border: 1px solid #161616;
						width:100%;
					}
					table.download {
						border-collapse:collapse;
						font-size:13px;
						border: 1px solid #161616;
						width:100%;
					}
					tr.d0 td, tr.d0 th {
						background-color: #506070;
						color: white;
					}
					tr.d1 td, tr.d1 th {
						background-color: #708090;
						color: white;
					}
					tr.d2 td {
						background-color: #00ff00;
						color: white;
						text-align:center;
					}
					td.button {
						border: 1px solid #161616;
						background-color: #40628a;
					}
					td.button {
						border: 1px solid #161616;
						background-color: #40628a;
						text-align: center;
					}
					td.button_red {
						border: 1px solid #161616;
						background-color: #b04040;
						text-align: center;
					}
					td.download {
						border: 1px solid #161616;
						background-color: #40628a;
						text-align: center;
					}
					th {
						text-align:left;
						width:125px;
					}
					td.request {
						width:140px;
						vertical-align:top;
					}
					td.radio {
						width:90px;
						vertical-align:top;
					}
					td.request {
						vertical-align:top;
					}
					a {
						color:#4477e0;
					}
					a.button {
						color:white;
						text-decoration: none;
					}
					h2 {
						font-size:15px;
					}
				</style>
			</head>
			<body>
	"}

	if(pai)
		dat += {"
			<b><span style='font-size: 3px'>Personal AI Device</span></b><br><br>
			<table class="request">
				<tr>
					<td class="request">Installed Personality:</td>
					<td>[pai.name]</td>
				</tr>
				<tr>
					<td class="request">Prime directive:</td>
					<td>[pai.pai_law0]</td>
				</tr>
				<tr>
					<td class="request">Additional directives:</td>
					<td>[pai.pai_laws]</td>
				</tr>
			</table>
			<br>
		"}
		dat += {"
			<table>
				<td class="button">
					<a href='byond://?src=\ref[src];setlaws=1' class='button'>Configure Directives</a>
				</td>
			</table>
		"}
		if(pai && (!pai.master_dna || !pai.master))
			dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=\ref[src];setdna=1' class='button'>Imprint Master DNA</a>
					</td>
				</table>
			"}
		dat += "<br>"
		if(pai.silicon_radio)
			dat += "<b>Radio Uplink</b>"
			dat += {"
				<table class="request">
					<tr>
						<td class="radio">Transmit:</td>
						<td><a href='byond://?src=\ref[src];wires=4'>[pai.silicon_radio.broadcasting ? SPAN_COLOR("#55ff55", "Enabled") : SPAN_COLOR("#ff5555", "Disabled") ]</a>

						</td>
					</tr>
					<tr>
						<td class="radio">Receive:</td>
						<td><a href='byond://?src=\ref[src];wires=2'>[pai.silicon_radio.listening ? SPAN_COLOR("#55ff55", "Enabled") : SPAN_COLOR("#ff5555", "Disabled") ]</a>

						</td>
					</tr>
				</table>
				<br>
			"}
		else
			dat += "<b>Radio Uplink</b><br>"
			dat += "[SPAN_COLOR("red", "<i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i>")]<br>"
		dat += {"
			<table>
				<td class="button_red"><a href='byond://?src=\ref[src];wipe=1' class='button'>Wipe current pAI personality</a>

				</td>
			</table>
		"}
	else
		if(looking_for_personality)
			dat += {"
				<b><span style='font-size: 3px'>pAI Request Module</span></b><br><br>
				<p>Requesting AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>
				<img src='loading.gif' /> Searching for personalities<br><br>

				<table>
					<tr>
						<td class="button">
							<a href='byond://?src=\ref[src];request=1' class="button">Refresh available personalities</a>
						</td>
					</tr>
				</table><br>
			"}
		else
			dat += {"
				<b><span style='font-size: 3px'>pAI Request Module</span></b><br><br>
				<p>No personality is installed.</p>
				<table>
					<tr>
						<td class="button"><a href='byond://?src=\ref[src];request=1' class="button">Request personality</a>
						</td>
					</tr>
				</table>
				<br>
				<p>Each time this button is pressed, a request will be sent out to any available personalities. Check back often give plenty of time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness.</p>
			"}
	show_browser(user, dat, "window=paicard")
	onclose(user, "paicard")
	return

