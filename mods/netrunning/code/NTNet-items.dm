//  HACSO's HUD and related interactions
// code\__defines\items_clothing.dm - used outside pack
// code\modules\mob\living\carbon\human\examine.dm - used outside pack

/obj/item/clothing/glasses/hud/it
	name = "IT special HUD"
	desc = "An augmented reality device that allows you to see doors NTNet ID's."
	icon = 'mods/NTNet/icons/obj_eyes.dmi'
	item_icons = list(slot_glasses_str = 'mods/NTNet/icons/onmob_eyes.dmi')
	icon_state = "ithud"
	off_state = "ithud_off"
	hud_type = HUD_IT
	body_parts_covered = 0

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["main_power_loss"]		= round(main_power_lost_until 	> 0 ? max(main_power_lost_until - world.time,	0) / 10 : main_power_lost_until,	1)
	data["backup_power_loss"]	= round(backup_power_lost_until	> 0 ? max(backup_power_lost_until - world.time,	0) / 10 : backup_power_lost_until,	1)
	data["electrified"] 		= round(electrified_until		> 0 ? max(electrified_until - world.time, 	0) / 10 	: electrified_until,		1)
	data["open"] = !density

	data["airlock_ntnet_id"]	= NTNet_id

	var/commands[0]
	commands[LIST_PRE_INC(commands)] = list("name" = "IdScan",					"command"= "idscan",				"active" = !aiDisabledIdScanner,	"enabled" = "Enabled",	"disabled" = "Disable",		"danger" = 0, "act" = 1)
	commands[LIST_PRE_INC(commands)] = list("name" = "Bolts",					"command"= "bolts",					"active" = !locked,					"enabled" = "Raised ",	"disabled" = "Dropped",		"danger" = 0, "act" = 0)
	commands[LIST_PRE_INC(commands)] = list("name" = "Lights",					"command"= "lights",				"active" = lights,					"enabled" = "Enabled",	"disabled" = "Disable",		"danger" = 0, "act" = 1)
	commands[LIST_PRE_INC(commands)] = list("name" = "Safeties",				"command"= "safeties",				"active" = safe,					"enabled" = "Nominal",	"disabled" = "Overridden",	"danger" = 1, "act" = 0)
	commands[LIST_PRE_INC(commands)] = list("name" = "Timing",					"command"= "timing",				"active" = normalspeed,				"enabled" = "Nominal",	"disabled" = "Overridden",	"danger" = 1, "act" = 0)
	commands[LIST_PRE_INC(commands)] = list("name" = "Door State",				"command"= "open",					"active" = density,					"enabled" = "Closed",	"disabled" = "Opened", 		"danger" = 0, "act" = 0)

	data["commands"] = commands

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "door_control.tmpl", "Door Controls", 450, 350, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (src.isElectrified())
		if (istype(mover, /obj/item))
			var/obj/item/i = mover
			if (i.matter && (MATERIAL_STEEL in i.matter) && i.matter[MATERIAL_STEEL] > 0)
				var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()

/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if (lock_cut_state == BOLTS_EXPOSED)
		to_chat(user, "The bolt cover has been cut open.")
	if (lock_cut_state == BOLTS_CUT)
		to_chat(user, "The door bolts have been cut.")
	if(brace)
		to_chat(user, "\The [brace] is installed on \the [src], preventing it from opening.")
		brace.examine_damage_state(user)
	if(hasHUD(user, HUD_IT) && arePowerSystemsOn())
		to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [NTNet_id]")))

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	if(hasHUD(user, HUD_IT))
		if(network_card && network_card.check_functionality() && enabled)
			to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [network_card.get_network_tag()].")))

/obj/machinery/computer/modular/examine(mob/user)
	. = ..()
	if(hasHUD(user, HUD_IT))
		var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
		var/obj/item/stock_parts/computer/network_card/network_card = os.get_component(PART_NETWORK)
		if(istype(network_card) && network_card.check_functionality() && os.on)
			to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [network_card.get_network_tag()].")))

/*
/client/proc/debug_airlocks_id()
	set name = "Debug Airlocks ID"
	set category = "Debug"
//html{background: linear-gradient(180deg, #373737, #171717);color: #a4bad6;}hr{background-color: #40628a;height: 1px;}
	var/stylesheet = {"<style>
							div.id_airlocksbugged{
								background: #844;
								border-radius: 5px;
								border-color: #a00;
								padding: 20px;
							}
							table, td, th {
								border: 1px solid #6a6;
							}
							td, th {
								width: 100px;
							}
							table.id_airlocksbugged{
							border: 1px solid #a66;
							}
							table.id_airlocksbugged td, table.id_airlocksbugged th{
							border: 1px solid #a66;
							}
							.airlocksid_stable{
								background: #4c4;
								border-radius: 5px;
								border: #0a0 solid 3px;
								padding: 30px;
								font-size: 30px;
							}
						</style>"}
	var/IDS_table = {"<table>
					<tr>
						<th>ID
						<th>NAME
						<th>LOCATION"}
	var/list/IDS = list()
	var/list/bugged_airlocks = list()
	var/bugged_airlocks_table = {"<tr>
									<th class='id_airlocksbugged'>ID
									<th class='id_airlocksbugged'>NAME
									<th class='id_airlocksbugged'>LOCATION
									<th class='id_airlocksbugged'>ID PAIR
									<th class='id_airlocksbugged'>PAIR NAME
									<th class='id_airlocksbugged'>PAIR LOCATION"}
	var/data = ""
	for(var/obj/machinery/door/airlock/TEST in GLOB.airlocks)
/*
		for(var/obj/machinery/door/airlock/I in SSmachines.machinery)
			if(TEST.NTNet_id == I.NTNet_id && I != TEST)
				bugged_airlocks += "[I.name] | ID: [I.NTNet_id] | Location: [I.loc]"
				continue
*/
		IDS += {"	<td>[TEST.NTNet_id]
					<td>[TEST.name]
					<td>(<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[TEST.x];Y=[TEST.y];Z=[TEST.z]'>[where]</a> ([TEST.loc]))"}
	for(var/obj/machinery/door/airlock/i in GLOB.airlocks)
		for(var/obj/machinery/door/airlock/n in GLOB.airlocks)
			if(n == i)
				continue
			if(n.NTNet_id == i.NTNet_id)
				bugged_airlocks += {"	<td class='id_airlocksbugged'>[n.NTNet_id]
										<td class='id_airlocksbugged'>[n.name]
										<td class='id_airlocksbugged'>[n.loc] ([<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[n.x];Y=[n.y];Z=[n.z]'>[where]</a>(n)])

										<td class='id_airlocksbugged'>[i.NTNet_id]
										<td class='id_airlocksbugged'>[i.name]
										<td class='id_airlocksbugged'>[i.loc] ([<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[i.x];Y=[i.y];Z=[i.z]'>[where]</a>(i)])"}

	if(bugged_airlocks.len)
		data += {"<div class = 'id_airlocksbugged'>
					<center>
						<h2>
							Airlocks with same ID's:
						</h2>
						<br>
						<div align='center'>
							<table class="id_airlocksbugged">
								[bugged_airlocks_table]<tr>
								[bugged_airlocks.Join("<tr>")]
							</table>
						</div>
					</center>
				</div><hr>"}
	else
		data += "<div class = 'airlocksid_stable'>Airlocks ID system stable</div>"
	data += "<center><h1>All airlocks IDs:</h1></center><hr>"
	if(IDS.len)
		data += "<div align='center'>[IDS_table]<tr>[IDS.Join("<tr>")]</div>"
	else
		data += "<div class = 'id_airlocksbugged'>ERROR CODE 523 (Origin Is Unreachable): Airlocks isn't initialized or not found.</div>"
	data += stylesheet
	//show_browser(src, data, "airlocks_ntnet_id_debug")
	var/datum/browser/popup = new(src.virtual_eye, "ailocksdebug", "Airlock ID Debug", 700, 800)
	popup.set_content(data)
	popup.open()
	return 1
*/
