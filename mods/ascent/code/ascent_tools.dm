/obj/item/weldingtool/electric/mantid
	name = "alien welding tool"
	desc = "An oddly shaped alien welding tool."
	icon = 'mods/ascent/icons/items/ascent.dmi'

/obj/item/device/multitool/mantid
	name = "alien multitool"
	desc = "An alien microcomputer of some kind."
	icon = 'mods/ascent/icons/items/ascent.dmi'
	icon_state = "multitool"

/obj/item/clothing/gloves/anomaly_detector/mantid
	color = COLOR_ASCENT_PURPLE
	name = "mantid anomaly detector"
	desc = "Some kind of strange alien anomolous detection technology."

/obj/item/clothing/gloves/anomaly_detector/mantid/try_found_anomalies(mob/living/user)
	if((user.r_hand != src && user.l_hand !=src) && (wearer && wearer.gloves != src) )
		to_chat(user, SPAN_BAD("You cant reach device."))
		return
	var/time_to_scan = 1 SECONDS
	var/scan_radius = 10
	in_scanning = TRUE
	update_icon()
	usr.update_action_buttons()
	if (do_after(user, time_to_scan, src, DO_DEFAULT | DO_USER_UNIQUE_ACT) && user)
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()
		var/list/victims = list()
		var/list/objs = list()
		var/turf/T = get_turf(src)
		get_mobs_and_objs_in_view_fast(T, scan_radius, victims, objs)
		var/list/allowed_anomalies = list()
		for(var/obj/anomaly/choosed_anomaly in objs)
			LAZYADD(allowed_anomalies, choosed_anomaly)
		var/flick_time = 10 SECONDS
		show_anomalies(user, flick_time, allowed_anomalies)
		if(LAZYLEN(allowed_anomalies))
			flick("detector_detected_anomalies", src)
			usr.update_action_buttons()
	else
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()