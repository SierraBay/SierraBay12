/obj/overmap/visitable/star/get_skybox_representation()
	return skybox_image

/obj/overmap/visitable/star/proc/generate_star_image()
	skybox_image = image('icons/skybox/star.dmi', "base")
	skybox_image.AddOverlays(image('icons/skybox/star.dmi', "weak_clouds"))
	if (class.extra_clouds)
		skybox_image.AddOverlays(image('icons/skybox/star.dmi', "clouds"))
		skybox_image.underlays += image('icons/skybox/star.dmi', "plumes")
	else
		skybox_image.underlays += image('icons/skybox/star.dmi', "atmoring")

	skybox_image.color = class.color
	skybox_image.pixel_x = rand(0,64)
	skybox_image.pixel_y = rand(128,256)
	skybox_image.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
	skybox_image.blend_mode = BLEND_OVERLAY

	var/matrix/M = matrix()
	M.Scale(clamp(star_scale, 0.5, 2))
	skybox_image.transform = M
