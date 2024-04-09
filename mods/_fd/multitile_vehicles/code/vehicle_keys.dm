/obj/item/key/car
	name = "key"
	desc = "A small steel key, it's intended for a car."
	icon = 'mods/_fd/multitile_vehicles/icons/vehicle_keys.dmi'
	icon_state = null
	w_class = ITEM_SIZE_TINY

/obj/item/key/car/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "key[rand(1, 5)]"

/obj/item/key/car/exploration
	icon_state = "key4"
	key_data = "exploration"

/obj/vehicles/proc/doors_locked()
	return block_enter_exit

/obj/vehicles/proc/attack_key(obj/item/key/car/key, user)
	if(key.key_data != serial_number)
		to_chat(user, SPAN_WARNING("The key doesn't fit!"))
		return TRUE

	playsound(src, 'sound/effects/buckle.ogg', 150, 1, 5)

	block_enter_exit = !block_enter_exit
	visible_message(SPAN_NOTICE("[user] [block_enter_exit ? "" : "un"]locks \the [src]."))

/obj/vehicles/verb/keys()
	set name = "Take/Insert the key"
	set category = "Vehicle"
	set src in view(1)
	var/mob/living/carbon/human/user = usr
	if(!istype(user) || !(user in get_occupants_in_position("driver")))
		to_chat(user, SPAN_NOTICE("You must be the driver of [src] to reach for the keys."))
		return
	if(inserted_key)
		if(user.put_in_hands(inserted_key))
			to_chat(user, SPAN_NOTICE("You have removed keys from the ignition."))
			inserted_key = null
		else
			inserted_key.forceMove(src)
			return
	else
		var/obj/item/key/car/key = user.get_active_hand()
		if(!istype(key))
			return
		if(key.key_data != serial_number)
			to_chat(user, SPAN_WARNING("The key doesn't fit!"))
			return

		to_chat(user, SPAN_NOTICE("You have inserted keys into the ignition."))
		user.drop_from_inventory(key)
		inserted_key = key
		key.forceMove(src)
	playsound(src, 'sound/effects/buckle.ogg', 150, 1)

/obj/vehicles/verb/engine()
	set name = "Start/Shut the engine"
	set category = "Vehicle"
	set src in view(1)
	var/mob/living/user = usr
	if(!istype(user) || !(user in get_occupants_in_position("driver")))
		to_chat(user, SPAN_NOTICE("You must be the driver of [src] to reach for the ignition."))
		return
	if(!inserted_key)
		to_chat(user, SPAN_NOTICE("There are no keys in the ignition."))
		return

	if(!active)
		active = TRUE
		to_chat(user, SPAN_NOTICE("You turned the engine ingnition key."))
	else
		active = FALSE
		to_chat(user, SPAN_NOTICE("You stop the engine."))
