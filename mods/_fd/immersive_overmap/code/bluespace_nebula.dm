#define OVERMAP_WEAKNESS_BLUESPACE 16

/obj/overmap/event/nebula
	name = "bluespace nebula"
	events = list(/datum/event/nebula)
	event_icon_states = list("nebula")
	weaknesses = OVERMAP_WEAKNESS_BLUESPACE | OVERMAP_WEAKNESS_EMP
	colors = list("#578ddd")
	color = "#578ddd"

/datum/overmap_event/nebula
	name = "bluespace nebula"
	count = 12
	radius = 3
	hazards = /obj/overmap/event/nebula

///// Event datum /////

/datum/event/nebula
	has_skybox_image = TRUE
	var/cloud_hueshift
	var/obj/effect/overmap/visitable/ship/victim

/datum/event/nebula/get_skybox_image()
	if(!cloud_hueshift)
		cloud_hueshift = color_rotation(rand(-3,3)*15)
	var/image/res = overlay_image('icons/skybox/ionbox.dmi', "ions", cloud_hueshift, RESET_COLOR)
	res.blend_mode = BLEND_ADD
	return res

/datum/event/nebula/start()
	var/obj/visitor = map_sectors["[pick(affecting_z)]"]
	if(!isobj(visitor))
		return

	var/overmap_size = GLOB.using_map.overmap_size
	var/x_coord = rand(OVERMAP_EDGE, overmap_size)
	var/y_coord = rand(OVERMAP_EDGE, overmap_size)

	var/turf/destination = locate(x_coord, y_coord, GLOB.using_map.overmap_z)
	if (!isturf(destination))
		return

	visitor.dropInto(destination)

/datum/event/nebula/announce()
	command_announcement.Announce("The [location_name()] is now passing through the unstable bluespace cloud.", "[location_name()] Sensor Array", zlevels = affecting_z)

/datum/event/nebula/end()
	for(var/mob/living/carbon/human/crewmember as() in GLOB.human_mobs)
		if(crewmember.isSynthetic() || !(crewmember.z in affecting_z))
			return

		to_chat(crewmember, SPAN_DANGER("<font size=10>You seeing the chain of the bright blue flashes all around the ship, causing your head to almost explode!</font>"))
		crewmember.adjustBrainLoss(rand(20,30))

		var/mind_blast = rand(5,15)
		crewmember.set_confused(mind_blast)
		crewmember.eye_blurry += mind_blast
