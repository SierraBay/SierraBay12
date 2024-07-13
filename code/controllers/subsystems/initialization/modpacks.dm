SUBSYSTEM_DEF(modpacks)
	name = "Modpacks"
	init_order = SS_INIT_EARLY
	flags = SS_NO_FIRE
	var/list/loaded_modpacks = list()

/datum/controller/subsystem/modpacks/Initialize()
	var/list/all_modpacks = GET_SINGLETON_SUBTYPE_MAP(/singleton/modpack)

	// Pre-init and register all compiled modpacks.
	for(var/package in all_modpacks)
		var/singleton/modpack/manifest = all_modpacks[package]
		var/fail_msg = manifest.pre_initialize()
		if(QDELETED(manifest))
			crash_with("Modpack of type [package] is null or queued for deletion.")
			continue
		if(fail_msg)
			crash_with("Modpack [manifest.name] failed to pre-initialize: [fail_msg].")
			continue
		if(loaded_modpacks[manifest.name])
			crash_with("Attempted to register duplicate modpack name [manifest.name].")
			continue
		loaded_modpacks[manifest.name] = manifest

	// Handle init and post-init (two stages in case a modpack needs to implement behavior based on the presence of other packs).
	for(var/package in all_modpacks)
		var/singleton/modpack/manifest = all_modpacks[package]
		var/fail_msg = manifest.initialize()
		if(fail_msg)
			crash_with("Modpack [(istype(manifest) && manifest.name) || "Unknown"] failed to initialize: [fail_msg]")
	for(var/package in all_modpacks)
		var/singleton/modpack/manifest = all_modpacks[package]
		var/fail_msg = manifest.post_initialize()
		if(fail_msg)
			crash_with("Modpack [(istype(manifest) && manifest.name) || "Unknown"] failed to post-initialize: [fail_msg]")

	. = ..()

/datum/controller/subsystem/modpacks/UpdateStat()
	..("Modpacks: [length(loaded_modpacks)]")

/datum/controller/subsystem/modpacks/UpdateStat()
	..("Modpacks: [length(loaded_modpacks)]")

/client/verb/modpacks_list()
	set name = "Modpacks List"
	set category = "OOC"

	if(!mob || !SSmodpacks.initialized)
		return

	if(length(SSmodpacks.loaded_modpacks))
		var/datum/nano_module/modlist/modlist_panel = locate("modlist_[usr.ckey]")
		if(!modlist_panel)
			modlist_panel = new /datum/nano_module/modlist(usr)
			modlist_panel.tag = "modlist_[usr.ckey]"
		modlist_panel.ui_interact(usr)
	else
		to_chat(src, SPAN_WARNING("Этот сервер не использует какие-либо модификации."))

/datum/nano_module/modlist

/datum/nano_module/modlist/CanUseTopic(mob/user, datum/topic_state/state = GLOB.xeno_state)
	. = ..()

/datum/nano_module/modlist/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.xeno_state)
	var/data[0]
	var/list/mods = list()
	for(var/modpack in SSmodpacks.loaded_modpacks)
		var/singleton/modpack/mod = SSmodpacks.loaded_modpacks[modpack]
		if(mod.name)
			mods[LIST_PRE_INC(mods)] = list("name" = mod.name, "description" = mod.desc ? mod.desc : "Нет описания", "author" = mod.author ? mod.author : "Нет автора")

	data["mods"] = mods
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-modlist.tmpl", "Список модификаций", 350, 500, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/modlist/Topic(href, href_list, state)
	if(..())
		return TRUE
