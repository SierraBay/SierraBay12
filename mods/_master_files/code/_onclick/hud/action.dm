// Text labels over action buttons, such as a countdown or a charge count.
// An item opts in by overriding get_action_button_label(). The button draws the label on every
// redraw, so update_action_buttons() and refresh_action_button() never wipe it.

/// Builds a label for get_action_button_label(): short text centred along the bottom of the button.
/proc/create_action_button_label(text, text_color = COLOR_WHITE)
	RETURN_TYPE(/image)
	var/image/label = new()
	// Stays readable over the red tint of an unavailable button
	label.appearance_flags = RESET_COLOR | RESET_ALPHA
	label.maptext_width = 32
	label.maptext_height = 20
	label.maptext_y = 1
	label.maptext = STYLE_SMALLFONTS_OUTLINE("<center>[text]</center>", 7, text_color, COLOR_BLACK)
	return label

/// Whole seconds left until a world.time deadline, for countdown labels.
/proc/get_countdown_seconds(deadline)
	// Whole deciseconds first: float error can turn an exact 10 seconds into 10.00002, which ceil() makes 11
	return max(0, ceil(round(deadline - world.time, 1) / (1 SECOND)))

/// The label over this item's action button, made with create_action_button_label(), or null for none.
/obj/item/proc/get_action_button_label()
	RETURN_TYPE(/image)
	return null

/// The label over this action's button, or null for none.
/datum/action/proc/get_button_label()
	RETURN_TYPE(/image)
	var/obj/item/item = target
	if(istype(item))
		return item.get_action_button_label()

/obj/screen/movable/action_button/UpdateIcon()
	. = ..()
	var/image/label = owner?.get_button_label()
	if(label)
		AddOverlays(label)
