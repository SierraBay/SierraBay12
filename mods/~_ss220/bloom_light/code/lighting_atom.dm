/atom/var/exposure_icon = 'mods/~_ss220/bloom_light/icons/exposures.dmi'
/atom/var/exposure_icon_state
/atom/var/exposure_colored = TRUE
/atom/var/image/exposure_overlay

var/global/EXPOSURE_BRIGHTNESS_BASE = 0.2
var/global/EXPOSURE_BRIGHTNESS_POWER = -0.2
var/global/EXPOSURE_CONTRAST_BASE = 10
var/global/EXPOSURE_CONTRAST_POWER = 0

/atom/proc/update_bloom()
	CutOverlays(exposure_overlay)

	if (!(exposure_icon && exposure_icon_state))
		return

	if (!exposure_overlay)
		exposure_overlay = image(icon = exposure_icon, icon_state = exposure_icon_state, dir = dir, layer = -1)

	exposure_overlay.plane = LIGHTING_EXPOSURE_PLANE
	exposure_overlay.blend_mode = BLEND_ADD
	exposure_overlay.appearance_flags = RESET_ALPHA | RESET_COLOR | KEEP_APART

	var/contrast = EXPOSURE_CONTRAST_BASE + EXPOSURE_CONTRAST_POWER * light_power
	var/brightness = EXPOSURE_BRIGHTNESS_BASE + EXPOSURE_BRIGHTNESS_POWER * light_power

	var/datum/ColorMatrix/MATRIX = new(1, contrast, brightness)
	if(exposure_colored)
		MATRIX.SetColor(light_color, contrast, brightness)

	exposure_overlay.color = MATRIX.Get()

	var/icon/EX = icon(icon = exposure_icon, icon_state = exposure_icon_state)

	exposure_overlay.pixel_x = 16 - EX.Width() / 2
	exposure_overlay.pixel_y = 16 - EX.Height() / 2

	AddOverlays(exposure_overlay)

/atom/proc/delete_lights()
	CutOverlays(exposure_overlay)
	QDEL_NULL(exposure_overlay)
