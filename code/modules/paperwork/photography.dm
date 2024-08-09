/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/tools/photography.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = ITEM_SIZE_TINY


/********
* photo *
********/
var/global/photo_count = 0

/obj/item/photo
	name = "photo"
	icon = 'icons/obj/tools/photography.dmi'
	icon_state = "photo"
	item_state = "paper"
	randpixel = 10
	w_class = ITEM_SIZE_TINY
	var/id
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/photo_size = 3

/obj/item/photo/Initialize()
	. = ..()
	id = photo_count++

/obj/item/photo/attack_self(mob/user as mob)
	examinate(user, src)

/obj/item/photo/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(istype(item, /obj/item/pen))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text, 128)
		if(loc == user && user.stat == 0)
			scribble = txt
		return TRUE
	return ..()

/obj/item/photo/examine(mob/user, distance)
	. = TRUE
	if(!img)
		return
	if(distance <= 1)
		show(user)
		to_chat(user, desc)
	else
		to_chat(user, SPAN_NOTICE("It is too far away."))

/obj/item/photo/proc/show(mob/user as mob)
	send_rsc(user, img, "tmp_photo_[id].png")
	var/output = "<html><head><title>[name]</title></head>"
	output += "<body style='overflow:hidden;margin:0;text-align:center'>"
	output += "<img src='tmp_photo_[id].png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />"
	output += "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"
	output += "</body></html>"
	show_browser(user, output, "window=book;size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(user, "[name]")
	return

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = sanitizeSafe(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(!n_name || !CanInteract(usr, GLOB.deep_inventory_state))
		return
	SetName("[(n_name ? text("[n_name]") : "photo")]")
	add_fingerprint(usr)
	return


/**************
* photo album *
**************/
/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/tools/photography.dmi'
	icon_state = "album"
	item_state = "briefcase"
	w_class = ITEM_SIZE_NORMAL //same as book
	storage_slots = DEFAULT_BOX_STORAGE //yes, that's storage_slots. Photos are w_class 1 so this has as many slots equal to the number of photos you could put in a box
	contents_allowed = list(/obj/item/photo)

/obj/item/storage/photo_album/MouseDrop(obj/over_object as obj)

	if((istype(usr, /mob/living/carbon/human)))
		var/mob/M = usr
		if(!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(loc, "rustle", 50, 1, -5)
		if((!( M.restrained() ) && !( M.stat ) && M.back == src))
			switch(over_object.name)
				if("r_hand")
					if(M.unEquip(src))
						M.put_in_r_hand(src)
				if("l_hand")
					if(M.unEquip(src))
						M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return

/*********
* camera *
*********/
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/tools/photography.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_ALUMINIUM = 1000, MATERIAL_PLASTIC = 750)
	var/black_white = FALSE
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/size = 3
//[SIERRA-EDIT]
	var/Flash = FALSE


/obj/item/device/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = "Object"
	set src in usr

	var/nsize = input("Photo Size","Pick a size of resulting photo.") as null|anything in list(1,3,5,7)
	if(nsize)
		size = nsize
		to_chat(usr, "<span class='notice'>Camera will now take [size]x[size] photos.</span>")

/obj/item/device/camera/verb/set_flash()
	set name = "Set Flash"
	set category = "Object"
	set src in usr

	Flash = !Flash
	to_chat(usr, "You switch the camera's flash [Flash ? "on" : "off"].")


/obj/item/device/camera/attack_self(mob/user as mob)
	on = !on
	if(on)
		src.icon_state = icon_on
	else
		src.icon_state = icon_off
	to_chat(user, "You switch the camera [on ? "on" : "off"].")
	return

/obj/item/device/camera/use_tool(obj/item/tool, mob/user, list/click_params)
	if(istype(tool, /obj/item/device/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You insert [tool] into [src].</span>")
		user.drop_from_inventory(tool, get_turf(src))
		qdel(tool)
		pictures_left = pictures_max
		return TRUE
	return ..()

/obj/item/device/camera/AltClick(mob/user)
	change_size()

/obj/item/device/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand) holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if(!mob_detail)
			mob_detail = "You can see [A] in the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] in the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/device/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!on || ismob(target.loc)) return
	if(pictures_left > 0)
		captureimage(target, user, flag)
		pictures_left--

	if(Flash)
		set_light(4, 2, light_color)
		addtimer(new Callback(src, PROC_REF(finish)), 5)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	icon_state = icon_off
	on = 0
	addtimer(new Callback(src, PROC_REF(ready_to_use)), 2 SECONDS)


/obj/item/device/camera/proc/ready_to_use()
	icon_state = icon_on
	on = 1


//Proc for capturing check
/mob/living/proc/can_capture_turf(turf/T)
	var/viewer = src
	if(src.client)		//To make shooting through security cameras possible
		viewer = src.client.eye
	var/can_see = (T in view(viewer))
	return can_see

/obj/item/device/camera/proc/captureimage(atom/target, mob/living/user, flag)
	var/obj/item/photo/p = createpicture(get_turf(target), user, flag)
	printpicture(user, p)

/obj/item/device/camera/proc/finish()
	set_light(0)

/obj/item/device/camera/proc/createpicture(atom/target, mob/living/user, flag)
	var/mobs = ""
	var/list/turfs = list()

	FOR_DVIEW(var/turf/T, size, target, INVISIBILITY_LIGHTING)
		if (user.can_capture_turf(T))
			mobs += get_mobs(T)
			turfs += T

	END_FOR_DVIEW

	var/x_c = target.x - (size-1)/2
	var/y_c = target.y - (size-1)/2
	var/z_c	= target.z
	var/icon/photoimage

	var/turf/topleft = locate(x_c, y_c, z_c)
	if (!topleft)
		return null

	if(Flash)
		photoimage = generate_image_from_turfs(topleft, turfs, size, CAPTURE_MODE_REGULAR, user, lighting = FALSE)
	else
		photoimage = generate_image_from_turfs(topleft, turfs, size, CAPTURE_MODE_REGULAR, user, lighting = TRUE)

	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/tools/photography.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

	var/obj/item/photo/p = new()
	p.name = "photo"
	p.icon = ic
	p.tiny = pc
	p.img = photoimage
	if(black_white)
		p.img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		p.tiny.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	p.desc = mobs
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.photo_size = size

	return p

/obj/item/device/camera/proc/printpicture(mob/user, obj/item/photo/p)
	p.forceMove(user.loc)
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(p)

/obj/item/photo/proc/copy(copy_id = 0)
	var/obj/item/photo/p = new/obj/item/photo()

	p.name = name
	p.icon = icon(icon, icon_state)
	p.tiny = icon(tiny)
	p.img = icon(img)
	p.desc = desc
	p.pixel_x = pixel_x
	p.pixel_y = pixel_y
	p.photo_size = photo_size
	p.scribble = scribble

	if(copy_id)
		p.id = id

	return p
//[/SIERRA-EDIT]
