/obj/screen/movable/exosuit/power
	name = "power"
	icon_state = null
	maptext_width = 64

/obj/screen/movable/exosuit/toggle/power_control
	name = "Power control"
	icon_state = "small_important"
	maptext = MECH_UI_STYLE("POWER")
	maptext_x = 3
	maptext_y = 13
	height = 12

/obj/screen/movable/exosuit/toggle/power_control/toggled()
	. = ..()
	owner.toggle_power(usr)
	owner.update_icon()
	owner.need_update_sensor_effects = TRUE

/obj/screen/movable/exosuit/toggle/power_control/on_update_icon()
	toggled = (owner.power == MECH_POWER_ON)
	. = ..()



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

	if(power == MECH_POWER_TRANSITION)
		to_chat(user, SPAN_NOTICE("Power transition in progress. Please wait."))

	else if(power == MECH_POWER_ON) //Turning it off is instant
		playsound(src, 'sound/mecha/mech-shutdown.ogg', 100, 0)
		turn_off_mech()
	else if(get_cell(TRUE))
		//Start power up sequence
		power = MECH_POWER_TRANSITION
		playsound(src, 'sound/mecha/powerup.ogg', 50, 0)
		if(user.do_skilled(1.5 SECONDS, SKILL_MECH, src, 0.5, DO_DEFAULT | DO_USER_UNIQUE_ACT) && power == MECH_POWER_TRANSITION)
			playsound(src, 'sound/mecha/nominal.ogg', 50, 0)
			turn_on_mech()
		else
			to_chat(user, SPAN_WARNING("You abort the powerup sequence."))
			turn_off_mech()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected."))

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
		turn_on_mech()
		add_heat(100)
		var/obj/item/cell/cell = src.get_cell()
		cell.use(100)
		body.take_burn_damage(rand(5,15))
		update_icon()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected."))

/mob/living/exosuit/proc/fast_toggle_power_garanted(mob/user)
	if(get_cell(TRUE))
		turn_on_mech()
	else
		to_chat(user, SPAN_WARNING("Error: No power cell was detected, can't autoboot."))

/mob/living/exosuit/proc/turn_on_mech()
	power = MECH_POWER_ON
	update_big_buttons()
	update_icon()

/mob/living/exosuit/proc/turn_off_mech()
	power = MECH_POWER_OFF
	update_big_buttons()
	update_icon()
