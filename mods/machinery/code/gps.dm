GLOBAL_LIST_EMPTY(GPS_list)

GLOBAL_LIST_EMPTY(gps_by_type)

/obj/item/device/telesci/gps
	name = "telesci positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = 2
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_ALUMINIUM = 250, MATERIAL_STEEL = 250, MATERIAL_GLASS = 50)
	var/gps_prefix = "COM"
	var/gpstag = "COM0"
	var/emped = 0
	var/turf/locked_location

/obj/item/device/telesci/gps/Initialize()
	. = ..()
	GLOB.GPS_list += src
	LAZYADD(GLOB.gps_by_type["[type]"], src)
	gpstag = "[gps_prefix][LAZYLEN(GLOB.gps_by_type["[type]"])]"
	name = "global positioning system ([gpstag])"
	AddOverlays(image(icon, "working"))

/obj/item/device/telesci/gps/Destroy()
	GLOB.GPS_list -= src
	var/list/typelist = GLOB.gps_by_type["[type]"]
	LAZYREMOVE(typelist, src)
	return ..()

/obj/item/device/gps/emp_act(severity)
	emped = 1
	CutOverlays()
	AddOverlays(image(icon, "emp"))
	addtimer(new Callback(src, .proc/post_emp), 300)

/obj/item/device/telesci/gps/proc/post_emp()
	emped = 0
	CutOverlays()
	AddOverlays(image(icon, "working"))

/obj/item/device/telesci/gps/attack_self(mob/user)

	var/obj/item/device/telesci/gps/t = ""
	var/gps_window_height = 110 + LAZYLEN(GLOB.GPS_list) * 20 // Variable window height, depending on how many GPS units there are to show
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"
		if(locked_location?.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"
			gps_window_height += 20

		for(var/obj/item/device/telesci/gps/G in GLOB.GPS_list)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1 || !pos)
				t += "<BR>[tracked_gpstag]: ERROR"
			else
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x], [pos.y], [pos.z])"

	var/datum/browser/popup = new(user, "GPS", name, 360, min(gps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/telesci/gps/Topic(href, href_list)
	..()
	if(href_list["tag"] )
		var/a = input("Please enter desired tag.", name, gpstag) as text
		a = uppertext(copytext(sanitize(a), 1, 5))
		if(src.loc == usr)
			gpstag = a
			name = "global positioning system ([gpstag])"
			attack_self(usr)

/obj/item/device/telesci/gps/science
	icon_state = "gps-s"
	gps_prefix = "SCI"
	gpstag = "SCI0"

/obj/item/device/telesci/gps/engineering
	icon_state = "gps-e"
	gps_prefix = "ENG"
	gpstag = "ENG0"

/obj/item/device/telesci/gps/mining
	icon_state = "gps-m"
	gps_prefix = "MIN"
	gpstag = "MIN0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."
