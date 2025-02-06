/obj/item/device/camera/computer
	name = "device camera"
	var/photo_num = 0

/obj/item/modular_computer
	var/obj/item/device/camera/computer/camera = new /obj/item/device/camera/computer
	var/in_camera_mode = 0


/obj/item/modular_computer/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	. = ..()
	if(in_camera_mode)
		hard_drive.create_file(camera.captureimagecomputer(target, usr))
		to_chat(usr, SPAN_NOTICE("You took a photo of \the [target]."))
		in_camera_mode = 0


/obj/item/device/camera/computer/proc/captureimagecomputer(atom/target, mob/living/user, flag)
	set_light(3, 3, light_color)
	var/obj/item/photo/p = createpicture(get_turf(target), user, flag)
	addtimer(new Callback(src, PROC_REF(finish)), 5)
	var/datum/computer_file/binary/photo/file = new
	file.photo = p
	file.set_filename(++photo_num)
	file.assetname = "[rand(0,999)][rand(0,999)][rand(0,999)].png"
	register_asset(file.assetname, p.img)
	return file


/obj/item/device/camera/computer/proc/printpicturecomputer(mob/user, obj/item/photo/p)
	var/obj/item/photo/newp = new(get_turf(src), p)
	newp = p.copy(p.id)
	user.put_in_hands(newp)



/datum/extension/interactive/ntos/proc/camera()
	var/obj/item/modular_computer/c = holder
	if(c.in_camera_mode)
		c.in_camera_mode = 0
	else
		c.in_camera_mode = 1

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
