/obj/decal/cleanable/snow
	name = "snow"
	desc = "A thin layer of snow."
	gender = PLURAL
	alpha = 50
	icon = 'mods/_fd/_maps/new_blueriver/icons/snow.dmi'
	icon_state = "snow_tile"
	mouse_opacity = 0
	persistent = FALSE

/obj/decal/cleanable/snow/monotile
	icon_state = "snow"
	alpha = 100

/obj/decal/cleanable/snow/plain
	icon_state = "snow_plain"
	alpha = 200

/obj/decal/cleanable/snow/plain/New()
	..()
	src.dir = rand(1,4)

/obj/decal/cleanable/snow/hexagonal
	icon_state = "snow_hex"
	alpha = 100

/obj/decal/cleanable/snow/side
	icon_state = "snow_side"
	alpha = 100

/obj/decal/cleanable/snow/side/corner
	icon_state = "snow_corner"
