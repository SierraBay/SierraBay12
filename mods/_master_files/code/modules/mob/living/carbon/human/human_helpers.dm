/mob/living/carbon/human/has_meson_effect()
	. = FALSE
	for(var/obj/screen/equipment_screen in equipment_overlays) // check through our overlays to see if we have any source of the meson overlay
		if (equipment_screen.color == GLOB.global_hud.meson.color)
			return TRUE
