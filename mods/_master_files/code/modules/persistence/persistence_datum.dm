//Fixes read/write of the persistence files
/datum/persistent/SetFilename()
	..()
	if(name)
		filename = "data/persistent/[lowertext(GLOB.using_map.path)]-[lowertext(name)].json"

/datum/controller/subsystem/persistence/proc/mapload_track_value(atom/value, track_type)

	var/turf/T = get_turf(value)
	if(!T)
		return

	var/area/A = get_area(T)
	if(!A || (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT))
		return

	if(!(T.z in GLOB.using_map.station_levels)) //without !initialized
		return

	if(!tracking_values[track_type])
		tracking_values[track_type] = list()
	tracking_values[track_type] += value

/datum/persistent/paper/CreateEntryInstance(turf/creating, list/tokens)
	var/obj/structure/noticeboard/board = locate() in creating
	if(requires_noticeboard && LAZYLEN(board.notices) >= board.max_notices)
		return
	var/obj/item/paper/paper = new paper_type(creating)
	paper.set_content(tokens["message"], tokens["title"])
	paper.last_modified_ckey = tokens["author"]
	if(requires_noticeboard)
		board.add_paper(paper)
	SSpersistence.mapload_track_value(paper, type)
	return paper

/datum/persistent/filth/CreateEntryInstance(turf/creating, list/tokens)
	var/_path = tokens["path"]
	var/obj/filth = new _path(creating, tokens["age"]+1)
	SSpersistence.mapload_track_value(filth, type)

/datum/persistent/graffiti/CreateEntryInstance(turf/creating, list/tokens)
	var/obj/decal/w = new /obj/decal/writing(creating, tokens["age"]+1, tokens["message"], tokens["author"])
	SSpersistence.mapload_track_value(w, type)