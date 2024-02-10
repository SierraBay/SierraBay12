/atom/movable/renderer/exposure
	name = "Lighting Exposure"
	group = RENDER_GROUP_SCENE
	plane = LIGHTING_EXPOSURE_PLANE
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	appearance_flags = PLANE_MASTER|PIXEL_SCALE // should use client color
	renderer_flags = RENDERER_FLAG_AUTO

/atom/movable/renderer/exposure/proc/Setup()
	filters = list()

	var/mob/M = owner
	if(istype(M))
		var/level = M.get_preference_value(/datum/client_preference/exposurelevel)
		var/alpha = 255
		if(level == GLOB.PREF_OFF)
			alpha *= 0
		else if(level == GLOB.PREF_LOW)
			alpha *= 0.33
		else if(level == GLOB.PREF_MEDIUM)
			alpha *= 0.66

		filters += filter(
			type = "color",
			color = rgb(255, 255, 255, alpha)
		)

		if(level == GLOB.PREF_OFF)
			return

	filters += filter(
		type = "blur",
		size = 20
	)

/atom/movable/renderer/exposure/proc/UpdateRenderer()
	Setup()

/atom/movable/renderer/exposure/Initialize()
	. = ..()
	Setup()

/atom/movable/renderer/lamps
	name = "Lamps Plane Master"
	group = RENDER_GROUP_SCENE
	plane = LIGHTING_LAMPS_PLANE
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	appearance_flags = PLANE_MASTER // should use client color
	renderer_flags = RENDERER_FLAG_AUTO

/atom/movable/renderer/lamps/proc/Setup()
	filters = list()

	var/bloomsize = 0
	var/bloomoffset = 0

	var/mob/M = owner
	if(istype(M))
		var/level = M.get_preference_value(/datum/client_preference/bloomlevel)
		if(level == GLOB.PREF_OFF)
			return
		else if(level == GLOB.PREF_LOW)
			bloomsize = 2
			bloomoffset = 1
		else if(level == GLOB.PREF_MED)
			bloomsize = 3
			bloomoffset = 2
		else if(level == GLOB.PREF_HIGH)
			bloomsize = 5
			bloomoffset = 3

	filters += filter(
		type = "bloom",
		threshold = "#aaaaaa",
		size = bloomsize,
		offset = bloomoffset,
		alpha = 100
	)

/atom/movable/renderer/lamps/proc/UpdateRenderer()
	Setup()

/atom/movable/renderer/lamps/Initialize()
	. = ..()
	Setup()

/atom/movable/renderer/lamps_glare
	name = "Lamps Glare Plane Master"
	group = RENDER_GROUP_SCENE
	plane = LIGHTING_LAMPS_GLARE
	blend_mode = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	appearance_flags = PLANE_MASTER // should use client color
	renderer_flags = RENDERER_FLAG_AUTO

/atom/movable/renderer/lamps_glare/proc/Setup()
	filters = list()

	var/mob/M = owner
	if(istype(M))
		var/enabled = M.get_preference_value(/datum/client_preference/glare)
		if(enabled == GLOB.PREF_NO)
			filters += filter(
				type = "color",
				color = "#00000000"
			)
			return

	filters += filter(
		type = "radial_blur",
		size = 0.03
	)

/atom/movable/renderer/lamps_glare/proc/UpdateRenderer()
	Setup()

/atom/movable/renderer/lamps_glare/Initialize()
	. = ..()
	Setup()
