#define MECH_UI_STYLE(X) "<span style=\"font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 5px;\">" + X + "</span>"

/obj/screen/exosuit
	icon = 'mods/mechs_by_shegar/icons/mech_hud.dmi'

/obj/screen/exosuit
	name = "hardpoint"
	icon = 'mods/mechs_by_shegar/icons/mech_hud.dmi'
	icon_state = "base"
	var/mob/living/exosuit/owner
	var/height = 14

/obj/screen/movable/exosuit
	name = "hardpoint"
	icon = 'mods/mechs_by_shegar/icons/mech_hud.dmi'
	icon_state = "base"
	var/mob/living/exosuit/owner
	var/height = 14

/obj/screen/exosuit/Initialize()
	. = ..()
	var/mob/living/exosuit/newowner = loc
	if(!istype(newowner))
		return qdel(src)
	owner = newowner

/obj/screen/movable/exosuit/Initialize()
	. = ..()
	var/mob/living/exosuit/newowner = loc
	if(!istype(newowner))
		return qdel(src)
	owner = newowner

/mob/living/exosuit/proc/get_main_data(mob/user)
	to_chat(user, SPAN_NOTICE("Main mech integrity: <b> [health]/[maxHealth]([((health/maxHealth)*100)]%) </b>"))


/obj/screen/movable/exosuit/Click()
	return (!usr.incapacitated() && usr.canClick() && (usr == owner || usr.loc == owner))

/obj/screen/exosuit/Click()
	return (!usr.incapacitated() && usr.canClick() && (usr == owner || usr.loc == owner))






/obj/screen/exosuit/needle
	vis_flags = VIS_INHERIT_ID
	icon_state = "heatprobe_needle"

/obj/screen/exosuit/heat
	name = "heat probe"
	icon_state = "heatprobe"
	var/celsius = TRUE
	var/obj/screen/exosuit/needle/gauge_needle = null
	desc = "TEST"

/obj/screen/exosuit/heat/Initialize()
	. = ..()
	gauge_needle = new /obj/screen/exosuit/needle(owner)
	add_vis_contents(gauge_needle)

/obj/screen/exosuit/heat/Destroy()
	QDEL_NULL(gauge_needle)
	. = ..()

/obj/screen/exosuit/heat/Click(location, control, params)
	if(..())
		var/modifiers = params2list(params)
		if(modifiers[MOUSE_SHIFT])
			if(owner && owner.material)
				usr.show_message(SPAN_NOTICE("Your suit's safe operating limit ceiling is [(celsius ? "[owner.material.melting_point - T0C] °C" : "[owner.material.melting_point] K" )]."), VISIBLE_MESSAGE)
			return
		if(modifiers[MOUSE_CTRL])
			celsius = !celsius
			usr.show_message(SPAN_NOTICE("You switch the chassis probe display to use [celsius ? "celsius" : "kelvin"]."), VISIBLE_MESSAGE)
			return
		if(owner && owner.body && owner.body.diagnostics?.is_functional() && owner.loc)
			usr.show_message(SPAN_NOTICE("The life support panel blinks several times as it updates:"), VISIBLE_MESSAGE)

			usr.show_message(SPAN_NOTICE("Chassis heat probe reports temperature of [(celsius ? "[owner.bodytemperature - T0C] °C" : "[owner.bodytemperature] K" )]."), VISIBLE_MESSAGE)
			if(owner.material.melting_point < owner.bodytemperature)
				usr.show_message(SPAN_WARNING("Warning: Current chassis temperature exceeds operating parameters."), VISIBLE_MESSAGE)
			var/air_contents = owner.loc.return_air()
			if(!air_contents)
				usr.show_message(SPAN_WARNING("The external air probe isn't reporting any data!"), VISIBLE_MESSAGE)
			else
				usr.show_message(SPAN_NOTICE("External probes report: [jointext(atmosanalyzer_scan(owner.loc, air_contents), "<br>")]"), VISIBLE_MESSAGE)
		else
			usr.show_message(SPAN_WARNING("The life support panel isn't responding."), VISIBLE_MESSAGE)

/obj/screen/exosuit/heat/proc/Update()
	//Relative value of heat
	if(owner && owner.body && owner.body.diagnostics?.is_functional() && gauge_needle)
		var/value = clamp( owner.bodytemperature / (owner.material.melting_point * 1.55), 0, 1)
		animate(
			gauge_needle,
			transform = matrix().Update(
				rotation = Interpolate(-90, 90, value),
				offset_y = -2
			),
			time = 0.1,
			easing = SINE_EASING
		)


#undef BAR_CAP
