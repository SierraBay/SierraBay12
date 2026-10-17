/datum/asset/simple/nanoui_templates
	legacy = TRUE
	keep_local_name = TRUE

/datum/asset/simple/nanoui_templates/register()
	for(var/filename in flist(NANO_TEMPLATES_PATH))
		if(copytext(filename, length(filename)) == "/")
			continue

		assets[filename] = fcopy_rsc("[NANO_TEMPLATES_PATH][filename]")
	// Keep Sierra-only templates and modular names on the same transport.
	for(var/filename in flist("nano/templates/"))
		if(copytext(filename, -1) != "/" && !assets[filename])
			assets[filename] = fcopy_rsc("nano/templates/[filename]")
	for(var/filename in flist("nano/templates/mods/"))
		if(copytext(filename, -1) != "/")
			assets["mods-[filename]"] = fcopy_rsc("nano/templates/mods/[filename]")

	. = ..()
