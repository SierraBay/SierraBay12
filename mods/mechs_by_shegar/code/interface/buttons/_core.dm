#define MECH_UI_STYLE(X) "<span style=\"font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 5px;\">" + X + "</span>"

/obj/screen/exosuit
	icon = 'mods/mechs_by_shegar/icons/mech_hud.dmi'

/obj/screen/movable/exosuit
	name = "hardpoint"
	icon = 'mods/mechs_by_shegar/icons/mech_hud.dmi'
	icon_state = "base"
	var/mob/living/exosuit/owner
	var/height = 14

/obj/screen/movable/exosuit/Initialize()
	. = ..()
	var/mob/living/exosuit/newowner = loc
	if(!istype(newowner))
		return qdel(src)
	owner = newowner

/mob/living/exosuit/proc/get_main_data(mob/user)
	to_chat(user, SPAN_NOTICE("Main mech integrity: <b> [health]/[maxHealth]([((health/maxHealth)*100)]%) </b>"))
