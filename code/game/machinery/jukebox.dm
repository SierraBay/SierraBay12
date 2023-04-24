/obj/machinery/jukebox
	name = "mediatronic jukebox"
	desc = "An immense, standalone touchscreen on a swiveling base, equipped with phased array speakers. Embossed on one corner of the ultrathin bezel is the brand name, 'Leitmotif Enterprise Edition'."
	icon = 'icons/obj/jukebox_new.dmi'
	icon_state = "jukebox3"
	anchored = TRUE
	density = TRUE
	power_channel = EQUIP
	idle_power_usage = 10
	active_power_usage = 100
	clicksound = 'sound/machines/buttonbeep.ogg'
	pixel_x = -8

	var/jukebox/jukebox
	var/obj/item/music_tape/tape // SIERRA

/obj/machinery/jukebox/verb/eject()
	set name = "Eject"
	set category = "Object"
	set src in oview(1)

	if(!CanPhysicallyInteract(usr))
		return

	if(tape)
		jukebox.Stop()
		for(var/jukebox_track/T in jukebox.tracks)
			if(T == tape.track)
				jukebox.tracks -= T
				jukebox.Last()

		if(!usr.put_in_hands(tape))
			tape.dropInto(loc)

		tape = null
		visible_message(SPAN_NOTICE("[usr] eject \a [tape] from \the [src]."))
		verbs -= /obj/machinery/jukebox/verb/eject
		playsound(src, 'packs/sierra-tweaks/sound/effects/tape_eject.ogg', 40)
		jukebox.ui_interact(usr)
//[/SIERRA]

/obj/machinery/jukebox/Initialize()
	. = ..()
	jukebox = new(src, "jukebox.tmpl", "MediaTronic Library", 400, 600)
	jukebox.falloff = 3
	queue_icon_update()


/obj/machinery/jukebox/Destroy()
	QDEL_NULL(jukebox)
	. = ..()


/obj/machinery/jukebox/on_update_icon()
	overlays.Cut()
	if (!anchored || inoperable())
		icon_state = "[initial(icon_state)]-[MACHINE_IS_BROKEN(src) ? "broken" : "nopower"]"
		return
	icon_state = initial(icon_state)
	if (!jukebox?.playing)
		return
	overlays += "[initial(icon_state)]-[emagged ? "emagged" : "running"]"


/obj/machinery/jukebox/powered()
	return anchored && ..()


/obj/machinery/jukebox/power_change()
	. = ..()
	if (inoperable() && jukebox?.playing)
		jukebox.Stop()


/obj/machinery/jukebox/CanUseTopic(mob/user, datum/topic_state/state)
	if (!anchored)
		to_chat(user, SPAN_WARNING("Secure \the [src] first."))
		return STATUS_CLOSE
	return ..()


/obj/machinery/jukebox/interface_interact(mob/user)
	jukebox.ui_interact(user)
	return TRUE

//[SIERRA]
/obj/machinery/jukebox/attackby(obj/item/I, mob/user)
	if (isWrench(I))
		add_fingerprint(user)
		wrench_floor_bolts(user, 0)
		power_change()
		return

	if(istype(I, /obj/item/music_tape))
		var/obj/item/music_tape/D = I
		if(tape)
			to_chat(user, "<span class='notice'>There is already \a [tape] inside.</span>")
			return

		if(D.ruined)
			to_chat(user, "<span class='warning'>\The [D] is ruined, you can't use it.</span>")
			return

		if(!D.track)
			to_chat(user, "<span class='warning'>There is no music recorded on \a [D].</span>")
			return

		if(user.drop_item())
			visible_message("<span class='notice'>[usr] insert \a [tape] into \the [src].</span>")
			D.forceMove(src)
			playsound(loc, 'packs/sierra-tweaks/sound/effects/tape_insert.ogg', 40)
			tape = D
			jukebox.tracks += tape.track
			verbs += /obj/machinery/jukebox/verb/eject
			return

	return ..()
//[/SIERRA]
/obj/machinery/jukebox/old
	name = "space jukebox"
	desc = "A battered and hard-loved jukebox in some forgotten style, carefully restored to some semblance of working condition."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2"
	pixel_x = 0
