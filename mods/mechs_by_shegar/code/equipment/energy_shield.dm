/obj/item/mech_equipment/shields
	max_charge = 200
	charge = 200
	var/OVERHEAT = FALSE
	var/last_overheat = 0
	var/overheat_cooldown = 50 SECONDS //Огромное окно для пробития меха.
	cooldown = 4 SECONDS



/obj/item/mech_equipment/shields/proc/delayed_toggle() //Отложит поднятие щита на опр время, без вреда работы коду
	set waitfor = 0
	if(charge == -1)
		return
	sleep(overheat_cooldown)
	if(OVERHEAT)
		src.visible_message("Overheat terminated,energy shield automaticly up!","Overheat terminated,energy shield automaticly up",0)
		charge=200
		OVERHEAT = FALSE
		update_icon()
		toggle()
		var/obj/item/cell/cell = owner.get_cell()
		cell.use(max_charge)
	else
		OVERHEAT = TRUE
		delayed_toggle()



//ЭМИ атака по щиту
/obj/aura/mechshield/proc/emp_attack(severity)
	if(shields)
		if(shields.charge)
			if(severity == 1)
				var/emp_damage = severity * 100
				shields.stop_damage(emp_damage)
			if(severity == 2)
				var/emp_damage = severity * 75
				shields.stop_damage(emp_damage)
			user.visible_message(SPAN_WARNING("\The [shields.owner]'s shilds craks, flashs and covers with sparks and energy strikes."))
			flick("shield_impact", src)

/obj/aura/mechshield
	icon = 'mods/mechs_by_shegar/icons/energy_shield.dmi'
