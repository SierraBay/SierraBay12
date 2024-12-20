/obj/screen/exosuit/menu_button/hatch_bolts
	name = "toggle hatch lock"
	desc = "Переключает замок у кабины меха, не позволяя открыть её ломом"
	switchable = TRUE
	icon_state = "lock"

/obj/screen/exosuit/menu_button/hatch_bolts/activated()
	if(!owner.hatch_locked && !owner.hatch_closed)
		to_chat(usr, SPAN_WARNING("You cannot lock the hatch while it is open."))
		return
	if(owner.body.hatch_bolts_status == BOLTS_DESTROYED)
		to_chat(usr, SPAN_WARNING("ERROR. Security cockpit bolts damaged or non operable anymore."))
		return
	owner.hatch_locked = !owner.hatch_locked
	to_chat(usr, SPAN_NOTICE("The [owner.body.hatch_descriptor] is [owner.hatch_locked ? "now" : "no longer" ] locked."))
	playsound(src.loc, 'sound/machines/suitstorage_lockdoor.ogg', 50, 1, -6)
	owner.need_update_sensor_effects = TRUE
