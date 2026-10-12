// TGUI: browser and DPI fixes from Aurora #20734, retaining Sierra's theme hook.
/datum/browser
	title = ""
	window_options = "can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;"
	var/weakref/source_ref
	var/list/stylesheet_datums = list()

/datum/browser/New(mob/nuser, nwindow_id, ntitle = "", nwidth = 0, nheight = 0, atom/nref = null, skip_common_stylesheet = FALSE)
	set_user(nuser)
	window_id = nwindow_id
	if(ntitle)
		set_title(ntitle)
	width = nwidth
	height = nheight
	source_ref = weakref(nref)
	if(!skip_common_stylesheet)
		add_stylesheet("common", 'html/browser/common.css')

/datum/browser/Destroy()
	if(user)
		UnregisterSignal(user, COMSIG_QDELETING)
	source_ref = null
	stylesheet_datums = null
	return ..()

/datum/browser/proc/set_user(mob/new_user)
	if(user)
		UnregisterSignal(user, COMSIG_QDELETING)
	user = new_user
	if(user)
		RegisterSignal(user, COMSIG_QDELETING, PROC_REF(user_deleted))

/datum/browser/proc/user_deleted(datum/source)
	SIGNAL_HANDLER
	user = null

/datum/browser/add_head_content(nhead_content)
	head_content += nhead_content

/datum/browser/proc/set_head_content(nhead_content)
	head_content = nhead_content

/datum/browser/add_stylesheet(name, file)
	if(istype(name, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/sheet = name
		var/asset_name = "spritesheet_[sheet.name].css"
		stylesheets[asset_name] = SSassets.cache[asset_name]
		stylesheet_datums |= sheet
		return
	var/asset_name = "[name].css"
	stylesheets[asset_name] = SSassets.cache[asset_name] || SSassets.transport.register_asset(asset_name, file)

/datum/browser/add_script(name, file)
	var/asset_name = "[ckey(name)].js"
	scripts[asset_name] = SSassets.cache[asset_name] || SSassets.transport.register_asset(asset_name, file)

/datum/browser/proc/get_asset_head()
	var/list/tags = list()
	for(var/asset_name as anything in stylesheets)
		tags += "<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url(asset_name, stylesheets[asset_name])]'>"
	for(var/asset_name as anything in scripts)
		tags += "<script type='text/javascript' src='[SSassets.transport.get_asset_url(asset_name, scripts[asset_name])]'></script>"
	if(user?.client)
		SSassets.transport.send_assets(user.client, stylesheets)
		SSassets.transport.send_assets(user.client, scripts)
		for(var/datum/asset/spritesheet/sheet as anything in stylesheet_datums)
			sheet.send(user.client)
	return tags.Join()

/datum/browser/proc/get_scaling_head()
	var/client/client = user?.client
	if(!client || !width || !height || client.window_scaling == 1)
		return ""
	if(user.get_preference_value(/datum/client_preference/ui_scale) == GLOB.PREF_YES)
		return ""
	return "<style>body { zoom: [100 / client.window_scaling]%; }</style>"

/datum/browser/get_header()
	var/title_attributes = "class='uiTitle'"
	if(title_image)
		title_attributes = "class='uiTitle icon' style='background-image: url([title_image]);'"
	return {"<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		[get_asset_head()]
		[get_setup_styles(user)]
		[head_content]
		[get_scaling_head()]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div [title_attributes]><tt>[title]</tt></div><div class='uiTitleButtons'>[title_buttons]</div></div>" : ""]
			<div class='uiContent'>
	"}

/datum/browser/open(use_onclose = TRUE)
	if(isnull(window_id))
		log_debug("Browser [title] tried to open with a null ID")
		to_chat(user, SPAN_DANGER("The [title] browser failed a sanity check. Please report this issue."))
		return
	if(!user?.client)
		return
	var/window_size = ""
	if(width && height)
		var/scaling = user.get_preference_value(/datum/client_preference/ui_scale) == GLOB.PREF_YES ? user.client.window_scaling : 1
		window_size = "size=[round(width * scaling)]x[round(height * scaling)];"
	show_browser(user, get_content(), "window=[window_id];[window_size][window_options]")
	if(use_onclose)
		setup_onclose()

/datum/browser/proc/setup_onclose(attempt = 0)
	if(!user?.client || isnull(window_id))
		return
	if(!winexists(user, window_id))
		if(attempt < 10)
			addtimer(new Callback(src, PROC_REF(setup_onclose), attempt + 1), 1)
		return
	var/atom/source = source_ref?.resolve()
	if(!source)
		source_ref = null
	onclose(user, window_id, source)

/datum/browser/update(force_open = FALSE, use_onclose = TRUE)
	if(isnull(window_id) || !user?.client)
		return
	return ..()

/datum/browser/close()
	if(isnull(window_id))
		log_debug("Browser [title] tried to close with a null ID")
		return
	if(user?.client)
		return ..()
