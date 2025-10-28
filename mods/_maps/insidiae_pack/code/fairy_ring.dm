/datum/map_template/ruin/exoplanet/fairy_ring
	name = "fairy ring"
	id = "fairy_ring"
	description = "A circle dance of fairies, from which only death or four men with a rope can lead you out."
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("fairy_ring_base.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS|TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_NATURAL
	skip_main_unit_tests = TRUE

/obj/landmark/map_load_mark/fairy_ring
	name = "random fairy ring site"
	templates = list(/datum/map_template/fairy_ring/a, /datum/map_template/fairy_ring/b, /datum/map_template/fairy_ring/c, /datum/map_template/fairy_ring/d)

/datum/map_template/fairy_ring
	skip_main_unit_tests = TRUE

/datum/map_template/fairy_ring/a
	name = "random fairy ring site #1"
	id = "fairy_ring_1"
	mappaths = list("mods/_maps/insidiae_pack/maps/fairy_ring1.dmm")

/datum/map_template/fairy_ring/b
	name = "random fairy ring site #2"
	id = "fairy_ring_2"
	mappaths = list("mods/_maps/insidiae_pack/maps/fairy_ring2.dmm")

/datum/map_template/fairy_ring/c
	name = "random fairy ring site #3"
	id = "fairy_ring_3"
	mappaths = list("mods/_maps/insidiae_pack/maps/fairy_ring3.dmm")

/datum/map_template/fairy_ring/d
	name = "random fairy ring site #4"
	id = "fairy_ring_4"
	mappaths = list("mods/_maps/insidiae_pack/maps/fairy_ring4.dmm")



/obj/fairy_ring_portal
	name = "entrance"
	desc = "You will need four adult men and a rope to pull out the poor fellow who fell in there."
	icon = 'icons/obj/portals.dmi'
	icon_state = "rift"
	density = FALSE
	anchored = TRUE
	invisibility = 60

/obj/fairy_ring_portal/Crossed(mob/M as mob|obj)
	if(!istype(M, /mob/living/carbon/human))
		return

	src.visible_message(SPAN_WARNING("\The [M] disappears right before your eyes!"))
	do_teleport(M, locate(world.maxx/2, world.maxy/2, pick(GLOB.using_map.player_levels)), 15, /singleton/teleport)
	return
