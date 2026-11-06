#define PENCODE_IMAGES_PER_TEXT 5
#define PENCODE_IMAGE_MAX_HEIGHT_PX 400
/// Matches an <img> tag made by pencode_image_link_to_html(); group 1 is the link.
#define PENCODE_IMAGE_HTML_PATTERN @"<img class='pencode_image' src='([^']*)'[^>]*>"

/// Turns [img]link[/img] into an <img> tag, up to PENCODE_IMAGES_PER_TEXT per call.
/// A link to any other host, or one with unexpected characters, stays as plain text.
/proc/pencode_images_to_html(pencode)
	if(!pencode || !findtext(pencode, "\[img\]"))
		return pencode
	var/static/regex/image_tag = regex(@"\[img\](.*?)\[/img\]", "i")
	var/list/parts = list()
	var/position = 1
	var/images_left = PENCODE_IMAGES_PER_TEXT
	while(images_left > 0 && image_tag.Find(pencode, position))
		var/match_end = image_tag.index + length(image_tag.match)
		var/image_html = pencode_image_link_to_html(image_tag.group[1])
		if(image_html)
			parts += copytext(pencode, position, image_tag.index)
			parts += image_html
			images_left--
		else
			parts += copytext(pencode, position, match_end)
		position = match_end
	parts += copytext(pencode, position)
	return jointext(parts, null)

/// Returns the <img> tag for an https link to a host from config/image_hosts.txt, or null for any other link.
/// The character set leaves out quotes, spaces, < > @ : and #, so the link can't leave the src attribute.
/proc/pencode_image_link_to_html(image_link)
	var/static/regex/safe_link = regex(@"^https://([a-z0-9.-]+)/[\w./%~+-]+(\?[\w./%~+=&;-]*)?$", "i")
	if(!safe_link.Find(image_link))
		return null
	if(!config.pencode_image_hosts[lowertext(safe_link.group[1])])
		return null
	return "<img class='pencode_image' src='[image_link]' referrerpolicy='no-referrer' style='max-width: 100%; max-height: [PENCODE_IMAGE_MAX_HEIGHT_PX]px'>"

/// Turns <img> tags made by pencode_images_to_html() back into [img]link[/img].
/proc/pencode_images_to_pencode(html)
	if(!html || !findtext(html, "pencode_image"))
		return html
	var/static/regex/image_html = regex(PENCODE_IMAGE_HTML_PATTERN, "gi")
	return image_html.Replace(html, "\[img\]$1\[/img\]", 1)

/// Links of the <img> tags made by pencode_images_to_html(), in order.
/proc/get_pencode_image_links(html)
	RETURN_TYPE(/list)
	. = list()
	if(!html || !findtext(html, "pencode_image"))
		return
	var/static/regex/image_html = regex(PENCODE_IMAGE_HTML_PATTERN, "i")
	var/position = 1
	while(image_html.Find(html, position))
		. += image_html.group[1]
		position = image_html.index + length(image_html.match)

/// Total length of the links in <img> tags made by pencode_images_to_html().
/proc/pencode_image_links_length(html)
	. = 0
	for(var/image_link in get_pencode_image_links(html))
		. += length(image_link)

/datum/codex_entry/pen/New(_display_name, list/_associated_paths, list/_associated_strings, _lore_text, _mechanics_text, _antag_text)
	. = ..()
	mechanics_text += "<b>Images (paper and digital):</b><br>"
	mechanics_text += "\[img\]link\[/img\] : Inserts an image from a direct https link. Paper takes up to [PENCODE_IMAGES_PER_TEXT] images per write, and a digital file shows up to [PENCODE_IMAGES_PER_TEXT]. "
	if(length(config.pencode_image_hosts))
		mechanics_text += "Only links to these hosts work: [jointext(config.pencode_image_hosts, ", ")].<br><br>"
	else
		mechanics_text += "This server allows no image hosts, so the tag stays plain text.<br><br>"

#undef PENCODE_IMAGES_PER_TEXT
#undef PENCODE_IMAGE_MAX_HEIGHT_PX
#undef PENCODE_IMAGE_HTML_PATTERN
