/datum/controller/subsystem/processing/nano/close_uis(datum/src_object)
	var/src_key = "\ref[src_object]"
	var/list/source_uis = open_uis[src_key]
	. = 0
	for(var/ui_key in source_uis?.Copy())
		var/list/key_uis = source_uis[ui_key]
		for(var/datum/nanoui/ui in key_uis?.Copy())
			ui.close()
			.++

/datum/controller/subsystem/processing/nano/close_user_uis(mob/user, datum/src_object, ui_key)
	. = 0
	for(var/datum/nanoui/ui in user?.open_uis?.Copy())
		if((isnull(src_object) || ui.src_object == src_object) && (isnull(ui_key) || ui.ui_key == ui_key))
			ui.close()
			.++
