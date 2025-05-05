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

/obj/screen/exosuit/overheat
	icon = 'mods/mechs_by_shegar/icons/mech_heat.dmi'
	icon_state = "overheat"
	name = "overheat"
	vis_flags = VIS_INHERIT_ID

/obj/screen/movable/exosuit/advanced_heat
	icon = 'mods/mechs_by_shegar/icons/mech_heat.dmi'
	name = "Heat"
	icon_state = "heat_0"
	var/obj/screen/exosuit/overheat/overheat
	var/tooltip = FALSE

/obj/screen/movable/exosuit/advanced_heat/Click(location, control, params)
	if(!tooltip)
		tooltip = TRUE
		openToolTip(usr, src, params, "ТЕПЛО", "Текущее тепло в мехе: [owner.current_heat]/[owner.max_heat] <br> Скорость охлаждения: [owner.total_heat_cooling] <br> Статус перегрева:[owner.overheat]")
	else
		tooltip = FALSE
		closeToolTip(usr)

/obj/screen/movable/exosuit/advanced_heat/proc/Update()
	var/value = (owner.current_heat/owner.max_heat) * 42
	var/output = floor(value)
	output = clamp(output, 0, 42)
	icon_state = "heat_[output]"

/obj/screen/movable/exosuit/advanced_heat/proc/start_overheat()
	overheat.layer = 2.1

/obj/screen/movable/exosuit/advanced_heat/proc/stop_overheat()
	overheat.layer = 1.9

/obj/screen/movable/exosuit/advanced_heat/Initialize()
	. = ..()
	overheat = new /obj/screen/exosuit/overheat(owner)
	overheat.layer = 1.9
	vis_contents += overheat
	overheat.pixel_y = 32
