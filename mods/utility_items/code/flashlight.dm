/obj/item/device/flashlight
	var/suitable_cell = /obj/item/cell/device/standard
	var/obj/item/cell/cell
	var/power_cost = 0.1

/obj/item/device/flashlight

/obj/item/device/flashlight/lamp/floodlamp
	power_cost = 0.5
/obj/item/device/flashlight/lamp
	power_cost = 0.15
/obj/item/device/flashlight/lamp/lava
	on = 1

/obj/item/device/flashlight/upgraded
	cell = /obj/item/cell/device/high
/obj/item/device/flashlight/maglight
	cell = /obj/item/cell/device/high
/obj/item/device/flashlight/lantern
	cell = /obj/item/cell/device/high//inf
/obj/item/device/flashlight/drone
	suitable_cell = null

/obj/item/device/flashlight/flare
	suitable_cell = null

/obj/item/device/flashlight/Initialize()
	. = ..()
	if(!ispath(cell) && ispath(suitable_cell))
		cell = new suitable_cell(src)
	else if(ispath(cell))
		suitable_cell = cell
		cell = new cell()

/obj/item/device/flashlight/get_cell()
	return cell

/obj/item/device/flashlight/proc/get_power_cost()
	return abs(power_cost * flashlight_power / 2)

/obj/item/device/flashlight/Process()
	if(on && suitable_cell)
		var/obj/item/cell/C = get_cell()
		if(!C || !C.checked_use(get_power_cost()))
			if(ismob(loc))
				to_chat(loc, SPAN_WARNING("\The [src] dies. You are alone now."))
			turn_off()
		else
			apply_power_deficiency()

/obj/item/device/flashlight/proc/apply_power_deficiency()
	var/obj/item/cell/C = get_cell()
	if(!C)
		return
	if(flashlight_range > 0)
		var/percent = C.percent()
		var/min_range = 1
		var/min_power = 0.1
		var/range_out
		var/power_out
		if(percent >= 25)
			range_out = flashlight_range
			power_out = flashlight_power
		else
			var/k = percent / 25 // от 0 до 1
			range_out = max(min_range, round(flashlight_range * k))
			power_out = max(min_power, flashlight_power * k)
		set_light(range_out, power_out)

/obj/item/device/flashlight/set_flashlight()
	if(on && cell && cell.charge > 1)
		set_light(flashlight_range, flashlight_power)
		START_PROCESSING(SSobj, src)
	else if(on && !suitable_cell)
		set_light(flashlight_range, flashlight_power)
	else
		turn_off()
	update_icon()

/obj/item/device/flashlight/proc/turn_off()
	on = FALSE
	set_light(0)
	STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/device/flashlight/MouseDrop(over_object)
	if(istype(over_object, /obj/screen/inventory))
		if(ismob(usr))
			var/mob/user = usr
			var/obj/screen/inventory/hand = over_object
			if(!user.stat && hand.name && (loc == user) && eject_item_from(cell, user))
				turn_off()
				cell = null
	else
		return ..()

/obj/item/device/flashlight/use_tool(obj/item/C, mob/living/user)
	. = ..()
	if(istype(C, suitable_cell) && !cell && insert_item_into(C, user))
		cell = C


/obj/proc/eject_item_from(obj/item/I, mob/living/user)
	if(!I || !user.IsAdvancedToolUser())
		return FALSE
	user.put_in_hands(I)
	playsound(src.loc, 'sound/weapons/guns/interaction/pistol_magin.ogg', 75, 1)
	to_chat(user, SPAN_NOTICE("You remove \the [I] from \the [src]."))
	return TRUE

/obj/proc/insert_item_into(obj/item/I, mob/living/user)
	if(!I || !user.unEquip(I))
		return FALSE
	I.forceMove(src)
	playsound(src.loc, 'sound/weapons/guns/interaction/pistol_magout.ogg', 75, 1)
	to_chat(user, SPAN_NOTICE("You insert \the [I] into \the [src]."))
	return TRUE
