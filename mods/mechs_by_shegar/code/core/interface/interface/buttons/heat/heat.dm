#include "render.dm"

/obj/screen/movable/exosuit/advanced_heat/Click(location, control, params)
	var/modifiers = params2list(params)
	if(modifiers["shift"])
		if(owner && owner.material)
			to_chat(usr, SPAN_NOTICE("Your suit's safe operating limit ceiling is [owner.material.melting_point - T0C] °C OR [owner.material.melting_point] K" ))
			return
	if(owner && owner.body && owner.body.diagnostics?.is_functional() && owner.loc)
		to_chat(usr, SPAN_NOTICE("The life support panel blinks several times as it updates:"))
		to_chat(usr, SPAN_NOTICE("Chassis heat probe reports temperature of [owner.bodytemperature - T0C] or [owner.bodytemperature] K"))
		if(owner.material.melting_point < owner.bodytemperature)
			to_chat(usr, SPAN_WARNING("Warning: Current chassis temperature exceeds operating parameters."))
		var/air_contents = owner.loc.return_air()
		if(!air_contents)
			to_chat(usr, SPAN_WARNING("The external air probe isn't reporting any data!"))
		else
			to_chat(usr, SPAN_NOTICE("External probes report: [jointext(atmosanalyzer_scan(owner.loc, air_contents), "<br>")]"))
	else
		to_chat(usr, SPAN_WARNING("The life support panel isn't responding."), VISIBLE_MESSAGE)

/obj/screen/movable/exosuit/advanced_heat/Click(location, control, params)
	if(!tooltip)
		tooltip = TRUE
		openToolTip(usr, src, params, "ТЕПЛО", "Текущее тепло в мехе: [owner.current_heat]/[owner.max_heat] <br> Скорость охлаждения: [owner.total_heat_cooling] <br> Статус перегрева:[owner.overheat]")
	else
		tooltip = FALSE
		closeToolTip(usr)

/obj/screen/movable/exosuit/advanced_heat/proc/start_overheat()
	overheat.layer = HUD_BASE_LAYER + 0.3

/obj/screen/movable/exosuit/advanced_heat/proc/stop_overheat()
	overheat.layer = HUD_BASE_LAYER - 0.1

/obj/screen/movable/exosuit/advanced_heat/Initialize()
	. = ..()
	cutter = new /obj/mech_heat_cutter(src)
	var/obj/spawned_obvodka = new /obj/obvodka(src)
	overheat = new /obj/overheat(src)
	add_vis_contents(cutter)
	add_vis_contents(spawned_obvodka)
	add_vis_contents(overheat)
