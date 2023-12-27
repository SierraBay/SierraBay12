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
