/mob/living/exosuit/proc/Initialize_big_menu_background()
	var/obj/screen/exosuit/menu_background = new /obj/screen/exosuit/menu_background(src)
	menu_background.screen_loc = "CENTER-2.85,CENTER-2.5"
	menu_hud_elements |= menu_background
