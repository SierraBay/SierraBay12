//random room spawner. takes random rooms from their appropriate map file and places them. the room will spawn with the spawner in the bottom left corner
/obj/spawner/room
	name = "random room spawner"
	icon = 'mods/_fd/random_rooms/icons/landmarks.dmi'
	icon_state = "closet-red"
	dir = NORTH
	var/datum/map_template/ruin/random_room/template
	var/room_width = 0
	var/room_height = 0
	var/room_type = "maintenance" // Used so we can place landmarks in ruins and such.

/obj/spawner/room/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/spawner/room/LateInitialize()
	var/list/possibletemplates = list()
	var/datum/map_template/ruin/random_room/candidate = null
	for(var/ID in SSmapping.random_room_templates)
		candidate = SSmapping.random_room_templates[ID]
		if(istype(candidate, /datum/map_template/ruin/random_room) && (room_height == candidate.template_height) && (room_width == candidate.template_width) && (room_type == candidate.room_type))
			if(!candidate.spawned)
				possibletemplates[candidate] = candidate.weight
		candidate = null
	if(possibletemplates.len)
		template = pickweight(possibletemplates)
		template.stock --
		template.weight = (template.weight / 2)
		if(template.stock <= 0)
			template.spawned = TRUE
		addtimer(new Callback(src, .proc/LateSpawn), 30 SECONDS)
	else
		template = null
	if(!template)
		qdel(src)

/obj/spawner/room/proc/LateSpawn()
	template.load(get_turf(src), centered = template.centerspawner)
	qdel(src)

/* Spawner landmarks */

/obj/spawner/room/threexthree
	name = "3x3 room spawner"
	room_width = 3
	room_height = 3
