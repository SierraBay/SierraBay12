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
