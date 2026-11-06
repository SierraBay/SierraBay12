// Every image a player posts is logged with the writer's ckey:
// - game.log gets a line for every post;
// - the "images" page of the Investigate admin verb lists every post with a VIEW link;
// - staff with investigate rights get a chat alert with a VIEW link the first time a player posts a link this round.
// VIEW opens a small dark preview window with the images blurred until clicked, closed by a button or Esc.

#define PENCODE_IMAGE_EXCERPT_CHARS 600
#define PENCODE_IMAGE_PREVIEW_WINDOW "pencode_image_preview"

/datum/client_preference/staff/show_image_logs
	description = "Image Log Messages"
	key = "CHAT_IMAGELOGS"
	options = list(GLOB.PREF_SHOW, GLOB.PREF_HIDE)
	flags = R_INVESTIGATE

/// Every post with images this round; a VIEW link carries the index of its post.
GLOBAL_LIST_EMPTY(pencode_image_posts)

/// "ckey link" pairs staff were already alerted about this round, so reposts stay out of chat.
GLOBAL_LIST_EMPTY(pencode_image_alerts)

/datum/pencode_image_post
	var/writer_key
	var/action
	var/list/image_links
	var/excerpt
	var/time_posted

/datum/pencode_image_post/New(mob/writer, action, list/image_links, html)
	writer_key = key_name(writer)
	src.action = action
	src.image_links = image_links
	time_posted = time_stamp()
	excerpt = html_decode(strip_html_properly(html))
	if(length_char(excerpt) > PENCODE_IMAGE_EXCERPT_CHARS)
		excerpt = copytext_char(excerpt, 1, PENCODE_IMAGE_EXCERPT_CHARS + 1) + "..."

/datum/pencode_image_post/proc/get_preview_html()
	var/list/previews = list()
	for(var/image_link in image_links)
		previews += {"<div class='preview' onclick="this.className = this.className == 'preview' ? 'preview revealed' : 'preview';"><div class='hint'>Click to show</div><img src='[image_link]' referrerpolicy='no-referrer'></div><div class='link'>[image_link]</div>"}
	return {"<html><head><title>Image preview</title><style>
body {background: #1b1b1b; color: #dddddd; font-family: Verdana, sans-serif; font-size: 12px; margin: 8px;}
.close {float: right; padding: 3px 12px; background: #993333; color: #ffffff; text-decoration: none; font-weight: bold;}
.preview {display: inline-block; margin-top: 8px; padding: 4px; min-width: 160px; background: #2a2a2a; overflow: hidden; cursor: pointer;}
.preview img {display: none; max-width: 480px; max-height: 360px;}
.preview.revealed img {display: block;}
.preview.revealed .hint {display: none;}
@supports (filter: blur(1px)) {.preview img {display: block; filter: blur(24px);} .preview.revealed img {filter: none;}}
.hint {color: #999999; padding: 2px;}
.link {color: #888888; font-size: 10px; word-break: break-all;}
.excerpt {white-space: pre-wrap; background: #232323; color: #bbbbbb; padding: 6px; margin-top: 10px;}
</style></head><body>
<a class='close' href='byond://?_src_=holder;pencode_image_close=1'>Close (Esc)</a>
<div><b>[html_encode(writer_key)]</b> [html_encode(action)]</div>
<div class='hint'>[time_posted]. Click an image to show it sharp, click again to blur it.</div>
[jointext(previews, null)]
<div class='excerpt'>[html_encode(excerpt)]</div>
<script>document.onkeydown = function (event) {if ((event || window.event).keyCode == 27) window.location.href = 'byond://?_src_=holder;pencode_image_close=1';};</script>
</body></html>"}

/// Logs the images in html that writer posted. action says where, like: wrote on paper "Report".
/proc/log_pencode_images(mob/writer, html, action)
	if(!writer?.ckey)
		return
	var/list/image_links = get_pencode_image_links(html)
	if(!length(image_links))
		return
	log_game("IMAGES: [key_name(writer)] [action]: [jointext(image_links, " ")]")

	GLOB.pencode_image_posts += new /datum/pencode_image_post(writer, action, image_links, html)
	var/view_link = "<a href='byond://?_src_=holder;pencode_image_view=[length(GLOB.pencode_image_posts)]'>VIEW</a>"
	add_image_investigate_entry(writer, "([writer.ckey]) [html_encode(action)]: [jointext(image_links, " ")] ([view_link])")

	var/new_images = 0
	for(var/image_link in image_links)
		var/alert_key = "[writer.ckey] [image_link]"
		if(!GLOB.pencode_image_alerts[alert_key])
			GLOB.pencode_image_alerts[alert_key] = TRUE
			new_images++
	if(new_images)
		alert_staff_about_images(writer, "[html_encode(action)]: [new_images] new image\s ([view_link])")

/// Appends a line to the "images" Investigate page, in the investigate_log() format.
/// investigate_log() itself writes nothing: it sends the line with to_chat(), which only delivers to clients.
/proc/add_image_investigate_entry(mob/writer, message)
	var/page = "[INVESTIGATE_DIR]images.html"
	if(!fexists(page))
		text2file("<meta charset='UTF-8'>\n", page)
	var/turf/turf = get_turf(writer)
	text2file("<small>[time_stamp()] ([turf?.x],[turf?.y],[turf?.z])</small> || [html_encode(writer.name)] [message]<br>\n", page)

/proc/alert_staff_about_images(mob/writer, message)
	message = append_admin_tools("[key_name_admin(writer)] [message]", writer, get_turf(writer))
	var/rendered = SPAN_CLASS("log_message", "[SPAN_CLASS("prefix", "IMAGE:")] [SPAN_CLASS("message", message)]")
	for(var/client/staff as anything in GLOB.admins)
		if(!check_rights(R_INVESTIGATE, FALSE, staff))
			continue
		if(staff.get_preference_value(/datum/client_preference/staff/show_image_logs) == GLOB.PREF_SHOW)
			to_chat(staff, rendered)

/datum/admins/Topic(href, href_list)
	..()
	if(href_list["pencode_image_view"])
		if(!check_rights(R_INVESTIGATE))
			return
		var/post_index = text2num(href_list["pencode_image_view"])
		if(!isnum(post_index) || post_index != round(post_index) || post_index < 1 || post_index > length(GLOB.pencode_image_posts))
			return
		var/datum/pencode_image_post/post = GLOB.pencode_image_posts[post_index]
		show_browser(usr, post.get_preview_html(), "window=[PENCODE_IMAGE_PREVIEW_WINDOW];size=540x620")
		return
	if(href_list["pencode_image_close"])
		close_browser(usr, "window=[PENCODE_IMAGE_PREVIEW_WINDOW]")
		return

// Paper: the write link and printing both build the paper text here.
/obj/item/paper/parsepencode(t, obj/item/pen/P, mob/user, iscrayon, isfancy, isadmin)
	. = ..()
	log_pencode_images(user || usr, ., "[user ? "wrote on" : "made"] paper \"[name]\"")

/datum/computer_file/data/email_account/send_mail(recipient_address, datum/computer_file/data/email_message/message, relayed = 0)
	. = ..()
	if(. && !relayed)
		log_pencode_images(usr, pencode_images_to_html(message.stored_data), "emailed [login] -> [recipient_address]")

/datum/computer_file/program/wordprocessor/save_file(filename)
	. = ..()
	if(.)
		log_pencode_images(usr, pencode_images_to_html(loaded_data), "saved file \"[filename]\"")

/datum/computer_file/program/wordprocessor/create_file(filename, data = "")
	. = ..()
	if(.)
		log_pencode_images(usr, pencode_images_to_html(data), "saved file \"[filename]\"")

/datum/report_field/pencode_text/set_value(given_value)
	. = ..()
	log_pencode_images(usr, pencode_images_to_html(value), "filled report field \"[display_name()]\"")

#undef PENCODE_IMAGE_EXCERPT_CHARS
#undef PENCODE_IMAGE_PREVIEW_WINDOW
