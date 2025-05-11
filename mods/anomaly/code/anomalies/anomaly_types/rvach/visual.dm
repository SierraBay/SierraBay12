/obj/anomaly/rvach/activate_anomaly()
	. = ..()
	new /obj/effect/warp/small/rvach(get_turf(src))

//эффект рвача который медленно уменьшается
/obj/effect/warp/small/rvach

/obj/effect/warp/small/rvach/Initialize()
	. = ..()
	start_smalling()

/obj/effect/warp/small/rvach/proc/start_smalling()
	set waitfor = FALSE
	animate(src, transform = matrix().Scale(0.3, 0.3), time = 5.5 SECOND, easing = SINE_EASING)
	sleep(5.5 SECONDS)
	animate(src, alpha = 40, transform = matrix().Scale(4, 4), time = 0.2 SECOND, easing = SINE_EASING)
	sleep(0.2 SECONDS)
	Destroy()
