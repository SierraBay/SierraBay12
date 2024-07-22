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
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/mobs = ""
	for(var/i = 1 to size)
		for(var/j = 1 to size)
			var/turf/T = locate(x_c, y_c, z_c)
			if(user.can_capture_turf(T))
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/obj/item/photo/p = createpicture(target, user, mobs, flag)
	var/datum/computer_file/binary/photo/file = new
	file.photo = p
	file.set_filename(++photo_num)
	file.assetname = "[rand(0,999)][rand(0,999)][rand(0,999)].png"
	register_asset(file.assetname, p.img)
	return file

/datum/extension/interactive/ntos/proc/camera()
	var/obj/item/modular_computer/c = holder
	if(c.in_camera_mode)
		c.in_camera_mode = 0
	else
		c.in_camera_mode = 1
