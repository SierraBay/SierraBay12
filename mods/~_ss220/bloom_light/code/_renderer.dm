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
	var/has_exposure = TRUE
	if(istype(M))
		var/level = M.get_preference_value(/datum/client_preference/exposurelevel)
		var/alpha = 255
		if(level == GLOB.PREF_OFF)
			alpha *= 0
			has_exposure = FALSE
		else if(level == GLOB.PREF_LOW)
			alpha *= 0.33
		else if(level == GLOB.PREF_MED)
			alpha *= 0.66

		filters += filter(
			type = "color",
			color = rgb(255, 255, 255, alpha)
		)

	if(has_exposure)
		filters += filter(
			type = "blur",
			size = 20
		)

#ifdef MODPACK_FOV
	filters += filter(type="alpha", render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE)
#endif

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
	var/has_bloom = TRUE
	if(istype(M))
		var/level = M.get_preference_value(/datum/client_preference/bloomlevel)
		if(level == GLOB.PREF_OFF)
			has_bloom = FALSE
		else if(level == GLOB.PREF_LOW)
			bloomsize = 2
			bloomoffset = 1
		else if(level == GLOB.PREF_MED)
			bloomsize = 3
			bloomoffset = 2
		else if(level == GLOB.PREF_HIGH)
			bloomsize = 5
			bloomoffset = 3

	if(has_bloom)
		filters += filter(
			type = "bloom",
			threshold = "#aaaaaa",
			size = bloomsize,
			offset = bloomoffset,
			alpha = 100
		)

#ifdef MODPACK_FOV
	filters += filter(type="alpha", render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE)
#endif

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
	var/has_glare = TRUE
	if(istype(M))
		var/enabled = M.get_preference_value(/datum/client_preference/glare)
		if(enabled == GLOB.PREF_NO)
			filters += filter(
				type = "color",
				color = "#00000000"
			)
			has_glare = FALSE

	if(has_glare)
		filters += filter(
			type = "radial_blur",
			size = 0.03
		)

#ifdef MODPACK_FOV
	filters += filter(type="alpha", render_source = FIELD_OF_VISION_BLOCKER_RENDER_TARGET, flags = MASK_INVERSE)
#endif

/atom/movable/renderer/lamps_glare/proc/UpdateRenderer()
	Setup()

/atom/movable/renderer/lamps_glare/Initialize()
	. = ..()
	Setup()
