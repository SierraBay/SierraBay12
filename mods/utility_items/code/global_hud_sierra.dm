/datum/global_hud/proc/setup_overlay(icon_state, color)
	var/obj/screen/screen = new /obj/screen()
	screen.screen_loc = ui_entire_screen
	screen.icon = 'mods/utility_items/icons/hud_tiled.dmi'
	screen.icon_state = icon_state
	screen.mouse_opacity = 0
	screen.color = color
	screen.alpha = 25
	return screen

/datum/global_hud/New()
	.=..()
	nvg = setup_overlay("scanline", "#06ff00")
	thermal = setup_overlay("scanline", "#ff0000")
	meson = setup_overlay("scanline", "#9fd800")
	science = setup_overlay("scanline", "#d600d6")
