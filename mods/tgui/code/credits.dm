/datum/tgui_module/credits
	name = "Credits"

/datum/tgui_module/credits/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_module/credits/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Credits", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_module/credits/tgui_static_data(mob/user)
	var/list/data = list()

	var/list/credits = list()
	var/credit_singletons = GET_SINGLETON_SUBTYPE_MAP(/singleton/credits)
	for(var/singleton_type in credit_singletons)
		var/singleton/credits/build = credit_singletons[singleton_type]
		credits += list(list(
			"name" = build.name,
			"coders" = build.coders,
			"mappers" = build.mappers,
			"spriters" = build.spriters,
			"ui_designers" = build.ui_designers,
			"special" = build.special,
			"linkContributors" = build.contributors,
		))
	data["credits"] = credits

	return data



/datum/tgui_module/credits/tgui_act(action, list/params)
	if(..())
		return TRUE
	var/url
	switch(action)
		if("openContributors")
			var/list/credit_singletons = GET_SINGLETON_SUBTYPE_MAP(/singleton/credits)
			for(var/singleton_type in credit_singletons)
				var/singleton/credits/build = credit_singletons[singleton_type]
				if(build.contributors && build.contributors == params["buildPage"])
					url = build.contributors
					break
		if("openGitHub")
			url = config.source_url || "https://github.com/SierraBay/SierraBay12"
		if("openWiki")
			url = config.wiki_url || "https://sierra.celadon.pro/"
		if("openDiscord")
			url = config.discord_url || "https://discord.com/invite/rxsggTJzY3"
	if(!url)
		return FALSE
	var/mob/user = usr
	if(tgui_alert(user, "Open this project page in your browser?", "Credits", list("Yes", "No")) == "Yes" && user?.client)
		to_target(user, link(url))
	return TRUE
