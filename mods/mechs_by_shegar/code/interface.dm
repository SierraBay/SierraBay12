#define MECH_UI_STYLE(X) "<span style=\"font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 5px;\">" + X + "</span>"


/obj/screen/movable/exosuit
	icon = 'mods/mechs_by_shegar/icons/mech_hud.dmi'

/obj/screen/movable/exosuit/heat
	//icon_state = "heatprobe_up"
	var/obj/screen/movable/exosuit/heatprob_down
	var/obj/screen/movable/exosuit/overheat/overheat
	icon_state = "heatprobe_up_0"

/obj/screen/movable/exosuit/heatprob_down
	vis_flags = VIS_INHERIT_ID
	icon_state = "heatprobe_down_0"

/obj/screen/movable/exosuit/overheat
	vis_flags = VIS_INHERIT_ID
	icon_state = "overheat"

/obj/screen/movable/exosuit/heat/Initialize()
	. = ..()
	gauge_needle.layer = 1.9
	heatprob_down = new /obj/screen/movable/exosuit/heatprob_down(owner)
	heatprob_down.pixel_y = -32
	overheat = new /obj/screen/movable/exosuit/overheat(owner)
	overheat.layer = 1.9
	vis_contents += overheat
	vis_contents += heatprob_down

/obj/screen/movable/exosuit/heat/Click(location, control, params)
	var/modifiers = params2list(params)
	if(modifiers["shift"])
		usr.show_message(SPAN_NOTICE("Текущее тепло в мехе: [owner.current_heat]/[owner.max_heat], скорость охлаждения: [owner.total_heat_cooling] Статус перегрева:[owner.overheat]"), VISIBLE_MESSAGE)
	return

/obj/screen/movable/exosuit/toggle/air/Click(location, control, params)
	var/modifiers = params2list(params)
	if(modifiers["shift"])
		if(owner && owner.material)
			usr.show_message(SPAN_NOTICE("Your mech's safe operating limit ceiling is [("[owner.material.melting_point - T0C] °C")]."), VISIBLE_MESSAGE)
		return
	if(modifiers["alt"])
		if(owner && owner.body && owner.body.diagnostics?.is_functional() && owner.loc)
			usr.show_message(SPAN_NOTICE("The life support panel blinks several times as it updates:"), VISIBLE_MESSAGE)
			usr.show_message(SPAN_NOTICE("Chassis heat probe reports temperature of [("[owner.bodytemperature - T0C] °C" )]."), VISIBLE_MESSAGE)
			if(owner.material.melting_point < owner.bodytemperature)
				usr.show_message(SPAN_WARNING("Warning: Current chassis temperature exceeds operating parameters."), VISIBLE_MESSAGE)
			var/air_contents = owner.loc.return_air()
			if(!air_contents)
				usr.show_message(SPAN_WARNING("The external air probe isn't reporting any data!"), VISIBLE_MESSAGE)
			else
				usr.show_message(SPAN_NOTICE("External probes report: [jointext(atmosanalyzer_scan(owner.loc, air_contents), "<br>")]"), VISIBLE_MESSAGE)
		else
			usr.show_message(SPAN_WARNING("The life support panel isn't responding."), VISIBLE_MESSAGE)
		return
	if(modifiers["ctrl"])
		owner.body.atmos_clear_protocol(usr)
		return
	.=..()


//Быстрый запуск

/obj/screen/movable/exosuit/toggle/power_control/Click(location, control, params)
	var/mod_modifiers = params2list(params)
	if(mod_modifiers["alt"])
		owner.fast_toggle_power(usr)
		owner.update_icon()
		return
	if(owner.overheat && owner.power != MECH_POWER_ON)
		to_chat(usr, "Overheat detected, safe protocol active.")
		return
	.=..()



/mob/living/exosuit/toggle_power(mob/user)
	if(!body.cell.check_charge(50) && power == MECH_POWER_OFF)
		to_chat(user, SPAN_WARNING("Error: Not enough power for power up."))
		return
	if(overheat  && power == MECH_POWER_OFF)
		to_chat(user, SPAN_WARNING("Error: overheat detected, safe protocol active."))
		return
	.=..()

/mob/living/exosuit/proc/fast_toggle_power(mob/user)
	//Данная функция - "Быстрый старт", тратящий энергию батареи и поднимающий температуру меха.
	if(power != MECH_POWER_OFF)
		return
	if(!body.have_fast_power_up)
		to_chat(user, SPAN_WARNING("Error: this body dont have fast power up subsystem."))
		return
	if(!body.cell.check_charge(50))
		to_chat(user, SPAN_WARNING("Error: Not enough power for fast power up."))
		return
	if(get_cell(TRUE))
		playsound(src, 'mods/mechs_by_shegar/sounds/mecha_fast_power_up.ogg', 70, 0)
		power = MECH_POWER_ON
		hud_power_control.update_icon()
		//hud_power_control?.queue_icon_update()
		add_heat(100)
		var/obj/item/cell/cell = src.get_cell()
		cell.use(100)
		body.take_burn_damage(rand(5,15))
		update_icon()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected."))

/mob/living/exosuit/proc/fast_toggle_power_garanted(mob/user)
	if(get_cell(TRUE))
		power = MECH_POWER_ON
		hud_power_control.update_icon()
		update_icon()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected, can't autoboot."))

/obj/screen/movable/exosuit/toggle/menu
	name = "toggle mech menu "
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("MENU")
	maptext_x = 6
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/menu/toggled()
	owner.menu_status = !owner.menu_status
	owner.refresh_menu_hud()

/obj/screen/movable/exosuit/toggle/megaspeakers
	name = "Use megaspeakers "
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("SPEAK")
	maptext_x = 4
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/megaspeakers/toggled()
	if (usr.client)
		if(usr.client.prefs.muted & MUTE_IC)
			to_chat(usr, SPAN_WARNING("You cannot speak in IC (muted)."))
			return
	if(owner.power != MECH_POWER_ON)
		to_chat(usr, SPAN_WARNING("The power indicator flashes briefly."))
		return
	if(!(usr in owner.pilots))
		return
	var/message = sanitize(input(usr, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = capitalize(message)
	owner.audible_message("[FONT_GIANT("\ [owner] integrated megaspeaker speaks: [message]\"")]",10)
	runechat_message("[message]")
	return

/obj/screen/movable/exosuit/toggle/gps
	name = "Use integrated GPS"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("GPS")
	maptext_x = 6
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/gps/toggled()
	owner.GPS.attack_self(usr)

/obj/screen/movable/exosuit/toggle/medscan
	name = "Full scan pilot"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("PLTSCN")
	maptext_x = 2
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/id
	name = "ID control"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("ID")
	maptext_x = 12
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/id/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(istype(tool, /obj/item/card/id))
		if(owner.id_holder == "EMAGED")
			to_chat(user, "Error 404, ID controlled din't respond.")
			return
		var/obj/item/card/id/card = tool
		if(!owner.id_holder) //Холдер пустой?
			owner.control_id(card,user)
		else //В холдере какой-то доступ уже есть
			//Доступ из холдера есть в нашей карте?
			if(has_access(owner.id_holder, card.access))
				owner.control_id(card,user)
			else //Доступа нет в списке, увы
				to_chat(user, "Acsess denied.")
				return
	else if (istype(tool, /obj/item/device/multitool/multimeter) || istype(tool, /obj/item/device/multitool))
		owner.can_hack_id()

	.=..()

/obj/screen/movable/exosuit/toggle/medscan/toggled()
	owner.medscan.scan(usr,usr)
	roboscan(usr,usr)



/mob/living/exosuit/proc/get_main_data(mob/user)
	to_chat(user, SPAN_NOTICE("Main mech integrity: <b> [health]/[maxHealth]([((health/maxHealth)*100)]%) </b>"))


/obj/screen/movable/exosuit/toggle/hatch_open/toggled()
	.=..()
	owner.need_update_sensor_effects = TRUE

/obj/screen/movable/exosuit/toggle/hatch/toggled()
	.=..()
	owner.need_update_sensor_effects = TRUE

/obj/screen/movable/exosuit/toggle/power_control/toggled()
	. = ..()
	owner.update_icon()
	owner.need_update_sensor_effects = TRUE
