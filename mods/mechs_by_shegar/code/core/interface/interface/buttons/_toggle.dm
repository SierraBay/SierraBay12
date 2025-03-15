/obj/screen/movable/exosuit/toggle
	name = "toggle"
	var/toggled = FALSE

/obj/screen/movable/exosuit/toggle/Initialize()
	. = ..()
	queue_icon_update()

/obj/screen/movable/exosuit/toggle/on_update_icon()
	icon_state = "[initial(icon_state)][toggled ? "_enabled" : ""]"
	maptext = SPAN_COLOR(toggled ? COLOR_WHITE : COLOR_GRAY,initial(maptext))

/obj/screen/movable/exosuit/toggle/Click()
	toggled()

/obj/screen/movable/exosuit/toggle/proc/toggled()
	toggled = !toggled
	queue_icon_update()
	return toggled
