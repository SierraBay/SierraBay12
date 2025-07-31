var/global/list/protanopia_colors = list("red", "darkred", "green", "orange", "brown")
var/global/list/deuteranopia_colors = list("red", "green", "yellow", "brown", "gold")
var/global/list/tritanopia_colors = list("blue", "green", "yellow", "pink", "purple", "cyan", "navy", "gold")

var/global/list/protanopia_replacements = list(
	"red" = "green",
	"darkred" = "green",
	"green" = "green",
	"orange" = "brown",
	"brown" = "brown"
)
var/global/list/deuteranopia_replacements = list(
	"red" = "red",
	"green" = "red",
	"yellow" = "brown",
	"brown" = "darkred",
	"gold" = "brown"
)
var/global/list/tritanopia_replacements = list(
	"blue" = "green",
	"green" = "pink",
	"yellow" = "yellow",
	"pink" = "purple",
	"purple" = "purple",
	"cyan" = "gray",
	"navy" = "purple",
	"gold" = "yellow"
)

/datum/wires/proc/replace_colors_for_colorblind(mob/user, list/wires_list)
	var/list/result = list()
	var/list/color_mappings = list()
	var/is_colorblind = FALSE
	var/list/replacement_map = null

	if(istype(user, /mob/living) && user.client && user.client_colors)
		for(var/filter in user.client_colors)
			if(!filter)
				continue
			if(istype(filter, /datum/client_color/monochrome/disease))
				is_colorblind = TRUE
				replacement_map = list()
				for(var/colour in wireColours)
					replacement_map[colour] = "gray"
			else if(istype(filter, /datum/client_color/protanopia))
				is_colorblind = TRUE
				replacement_map = protanopia_replacements
			else if(istype(filter, /datum/client_color/deuteranopia))
				is_colorblind = TRUE
				replacement_map = deuteranopia_replacements
			else if(istype(filter, /datum/client_color/tritanopia))
				is_colorblind = TRUE
				replacement_map = tritanopia_replacements
			if(is_colorblind)
				break

	if(is_colorblind && replacement_map)
		for(var/colour in wires_list)
			var/display_colour = colour
			if(colour in replacement_map)
				display_colour = replacement_map[colour]
			result += colour
			color_mappings[colour] = display_colour
	else
		result = wires_list.Copy()
		for(var/colour in result)
			color_mappings[colour] = colour

	return list(result, color_mappings)

/datum/wires/Interact(mob/living/user)
	if(!user)
		return FALSE

	var/html = null
	if(holder && CanUse(user))
		var/is_colorblind = FALSE
		if(istype(user, /mob/living) && user.client && user.client_colors)
			for(var/filter in user.client_colors)
				if(!filter)
					continue
				if(istype(filter, /datum/client_color/monochrome/disease))
					is_colorblind = TRUE
				else if(istype(filter, /datum/client_color/protanopia))
					is_colorblind = TRUE
				else if(istype(filter, /datum/client_color/deuteranopia))
					is_colorblind = TRUE
				else if(istype(filter, /datum/client_color/tritanopia))
					is_colorblind = TRUE
				if(is_colorblind)
					break

		if(is_colorblind)
			html = GetInteractWindowColorblind(user)
		else
			html = call(src, "GetInteractWindow")(user)

	if(html)
		user.set_machine(holder)
	else
		user.unset_machine()
		close_browser(user, "window=wires")
		return FALSE

	var/datum/browser/popup = new(user, "wires", holder.name, window_x, window_y)
	popup.set_content(html)
	popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
	popup.open()
	return TRUE

/datum/wires/proc/GetInteractWindowColorblind(mob/user)
	var/html = list()
	html += "<div class='block'>"
	html += "<h3>Exposed Wires</h3>"
	html += "<table[table_options]>"

	var/list/wires_data = replace_colors_for_colorblind(user, wires)
	var/list/wires_used = wires_data[1]
	var/list/color_mappings = wires_data[2]

	if(!user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC))
		wires_used = shuffle(wires_used)

	var/show_labels = user.skill_check(SKILL_ELECTRICAL, SKILL_MASTER)

	for(var/original_colour in wires_used)
		var/display_colour = color_mappings[original_colour]

		html += "<tr>"
		html += "<td[row_options1]>[SPAN_COLOR(display_colour, "&#9724;") + capitalize(display_colour)]</td>"
		html += "<td[row_options2]>"
		html += "<a href='byond://?src=\ref[src];action=1;cut=[original_colour]'>[IsColourCut(original_colour) ? "Mend" : "Cut"]</A>"
		html += " <a href='byond://?src=\ref[src];action=1;pulse=[original_colour]'>Pulse</A>"
		html += " <a href='byond://?src=\ref[src];action=1;attach=[original_colour]'>[IsAttached(original_colour) ? "Detach" : "Attach"] Signaller</A>"
		var/label = "Examine"
		if(show_labels)
			var/datum/wire_description/wire_description = get_description(GetIndex(original_colour))
			if(wire_description && wire_description.skill_level <= SKILL_MASTER)
				label = "[label] ([wire_description.label])"
			else
				label = "[label] (???)"
		html += " <a href='byond://?src=\ref[src];action=1;examine=[original_colour]'>[label]</A></td></tr>"
	html += "</table>"

	var/original_html = call(src, "GetInteractWindow")(user)
	var/start_table = findtext(original_html, "<table[table_options]>")
	var/end_table = findtext(original_html, "</table>", start_table)
	if(start_table && end_table)
		var/status_html = copytext(original_html, end_table + length("</table>"))
		html += status_html

	if(random)
		html += "<i>\The [holder] appears to have tamper-resistant electronics installed.</i><br><br>"

	return JOINTEXT(html)
