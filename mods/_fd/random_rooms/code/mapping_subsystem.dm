/datum/controller/subsystem/mapping
	var/list/random_room_templates = list()

/datum/controller/subsystem/mapping/Recover()
	. = ..()
	random_room_templates = SSmapping.random_room_templates

/datum/controller/subsystem/mapping/preloadBlacklistableTemplates()
	. = ..()
	for(var/datum/map_template/MT as() in map_templates)
		if(istype(MT, /datum/map_template/ruin/random_room))
			random_room_templates[MT.name] = MT
