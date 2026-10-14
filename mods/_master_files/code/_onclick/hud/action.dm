/datum/action
	var/button_overlay_icon

/obj/screen/movable/action_button/UpdateIcon()
	..()
	if(!owner || owner.action_type == AB_ITEM || !owner.button_overlay_icon || !owner.button_icon_state)
		return
	ClearOverlays()
	var/image/img = image(owner.button_overlay_icon, src, owner.button_icon_state)
	img.pixel_x = 0
	img.pixel_y = 0
	AddOverlays(img)
