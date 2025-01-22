/obj/item/photo/use_tool(obj/item/P, mob/living/user)
	. = ..()
	if(istype(P, /obj/item/flame))
		burnphoto(P, user)

/obj/item/photo/proc/burnphoto(obj/item/flame/P, mob/user)
	var/class = "warning"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/flame/lighter/zippo))
			class = "rose"

		user.visible_message("<span class='[class]'>[user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!</span>", \
		"<span class='[class]'>You hold \the [P] up to \the [src], burning it slowly.</span>")

		if (do_after(user, 5 SECONDS, src, DO_PUBLIC_UNIQUE))
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("<span class='[class]'>[user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"<span class='[class]'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")
				new /obj/decal/cleanable/ash(get_turf(src))
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")

/obj/item/stock_parts/computer/hard_drive/ui_data()
	var/list/data = list(
		"disk_name" = get_disk_name(),
		"max_capacity" = max_capacity,
		"used_capacity" = used_capacity
	)

	var/list/files = list()
	for(var/datum/computer_file/F in stored_files)
		files.Add(list(list(
			"filename" = F.filename,
			"filetype" = F.filetype,
			"size" = F.size,
			"undeletable" = F.undeletable
		)))
	data["files"] = files
	return data

/obj/item/stock_parts/computer/hard_drive/proc/get_disk_name()
	var/datum/computer_file/data/text/D = find_file_by_name("DISK_NAME")
	if(!istype(D))
		return null

	return sanitizeSafe(D.stored_data, max_length = MAX_LNAME_LEN)
