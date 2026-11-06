// Paper space is counted in characters, the unit the write box limits text in.
// The core counts bytes of the text without HTML: a Cyrillic letter costs 2 and a quote, stored as &#34;, costs 5,
// so a Russian text the write box accepts can leave the sheet far below zero.
// The core charge is refunded down to characters, so this works in any order with other update_space() overrides.
/obj/item/paper/update_space(new_text)
	. = ..()
	if(!new_text)
		return
	var/visible_text = strip_html_properly(new_text)
	free_space += length(visible_text) - length_char(html_decode(visible_text))

// Every "write" link gets a "sign" link next to it. Signing works even when the sheet is full.
/obj/item/paper/updateinfolinks()
	. = ..()
	add_sign_links()

/obj/item/paper/proc/add_sign_links()
	var/static/regex/write_link = regex(@"write=(\w+)'>write</A>", "gi")
	info_links = write_link.Replace(info_links, "write=$1'>write</A> <a href='byond://?src=\ref[src];sign=$1'>sign</A>", 1)

// Admin faxes are written in their own form, whose Topic() handles only its own buttons.
/obj/item/paper/admin/add_sign_links()
	return

// Handled in Topic() like the core write link: OnTopic() is only reached through CanUseTopic(),
// which refuses a paper inside a clipboard or folder that the write link allows.
/obj/item/paper/Topic(href, href_list)
	if(!href_list["sign"])
		return ..()
	sign_paper(usr, href_list["sign"])

/// Adds the user's signature into a field or at the end of the paper, without checking free space.
/obj/item/paper/proc/sign_paper(mob/user, field_id)
	if(!can_sign(user))
		return
	var/obj/item/pen/pen = get_writing_pen(user)
	if(!pen)
		return
	var/field_index = 0
	if(field_id != "end")
		field_index = text2num(field_id)
		if(!isnum(field_index) || field_index != round(field_index) || field_index < 1 || field_index > fields)
			return
	if(!pen.active)
		pen.toggle()

	var/pencode = (field_index || !length(info)) ? "\[sign\]" : "\n\[sign\]"
	var/signature = parsepencode(pencode, pen, user, pen.iscrayon, pen.isfancy)
	if(field_index)
		addtofield(field_index, signature)
	else
		info += signature
		updateinfolinks()
	last_modified_ckey = user.ckey
	update_space(signature)
	show_content(user, editable = TRUE)
	playsound(src, pick('sound/effects/pen1.ogg', 'sound/effects/pen2.ogg'), 10)
	update_icon()

/// Same reach as the core write link: in hand, next to the user, or in a clipboard or folder that is.
/obj/item/paper/proc/can_sign(mob/user)
	if(!user || user.stat || user.restrained() || !readable || is_memo)
		return FALSE
	if(loc == user || Adjacent(user))
		return TRUE
	if(istype(loc, /obj/item/material/clipboard) || istype(loc, /obj/item/folder))
		return loc.loc == user || loc.Adjacent(user)
	return FALSE

/// The pen the user writes with: the one in the active hand or a hardsuit pen module.
/obj/item/paper/proc/get_writing_pen(mob/user)
	RETURN_TYPE(/obj/item/pen)
	var/obj/item/pen/pen = user.get_active_hand()
	if(istype(pen))
		return pen
	var/obj/item/rig/rig = user.back
	if(!istype(rig) || rig.offline)
		return null
	var/obj/item/rig_module/device/pen/module = locate() in rig.installed_modules
	pen = module?.device
	return istype(pen) ? pen : null
