/datum/client_preference/scarythings
	description = "Allow psi screamers?"
	key = "SCREAMERS"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_NO

var/global/datum/scarythings_prompt/scarythings_prompt = new
/datum/scarythings_prompt/proc/offer(mob/user)
    if (!user?.client)
        return
    var/current = user.get_preference_value(/datum/client_preference/scarythings)
    var/label = (current == GLOB.PREF_YES) ? "выключить" : "включить"
    to_chat(user, SPAN_INFO(FONT_SMALL("Переключить режим скримеров: [current]. <a href='byond://?src=\ref[src];toggle=1'>([label])</a>")))

/datum/scarythings_prompt/Topic(href, href_list)
    if (..())
        return TRUE
    if (!href_list["toggle"] || !usr?.client)
        return
    usr.cycle_preference(/datum/client_preference/scarythings)
    offer(usr)
    return TRUE
