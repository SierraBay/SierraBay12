/obj/item/modular_computer
	var/list/mars_encryption_keys
	var/max_mars_keys = 2

/obj/machinery/computer/modular
	var/list/mars_encryption_keys
	var/max_mars_keys = 2

/proc/mars_get_host_keys(atom/host)
	if(istype(host, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = host
		return computer.mars_encryption_keys
	if(istype(host, /obj/machinery/computer/modular))
		var/obj/machinery/computer/modular/console = host
		return console.mars_encryption_keys
	return null

/proc/mars_get_host_max_keys(atom/host)
	if(istype(host, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = host
		return computer.max_mars_keys
	if(istype(host, /obj/machinery/computer/modular))
		var/obj/machinery/computer/modular/console = host
		return console.max_mars_keys
	return 0

/proc/mars_try_insert_key(atom/host, obj/item/device/encryptionkey/key, mob/living/user)
	if(!istype(key) || !user)
		return FALSE
	if(!istype(host, /obj/item/modular_computer) && !istype(host, /obj/machinery/computer/modular))
		return FALSE
	var/list/keys = mars_get_host_keys(host)
	if(length(keys) >= mars_get_host_max_keys(host))
		to_chat(user, SPAN_WARNING("В \the [host] больше нет места для ключей шифрования."))
		return TRUE
	if(!user.unEquip(key, host))
		FEEDBACK_UNEQUIP_FAILURE(user, key)
		return TRUE
	if(istype(host, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = host
		LAZYADD(computer.mars_encryption_keys, key)
	else
		var/obj/machinery/computer/modular/console = host
		LAZYADD(console.mars_encryption_keys, key)
	user.visible_message(
		SPAN_NOTICE("\The [user] вставляет \a [key] в \a [host]."),
		SPAN_NOTICE("Ты вставляешь \the [key] в слот МАРС на \the [host]."),
		range = 2
	)
	return TRUE

/proc/mars_eject_one_key(atom/host, obj/item/device/encryptionkey/key, mob/user)
	if(!istype(key) || !user)
		return
	if(istype(host, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = host
		LAZYREMOVE(computer.mars_encryption_keys, key)
	else if(istype(host, /obj/machinery/computer/modular))
		var/obj/machinery/computer/modular/console = host
		LAZYREMOVE(console.mars_encryption_keys, key)
	else
		return
	key.dropInto(get_turf(user))
	user.put_in_hands(key)
	user.visible_message(
		SPAN_NOTICE("\The [user] выкручивает \a [key] из \a [host]."),
		SPAN_NOTICE("Ты выкручиваешь \the [key] из \the [host]."),
		range = 2
	)

/proc/mars_modular_screwdriver(obj/item/modular_computer/computer, mob/user)
	if(!istype(computer) || !user)
		return FALSE
	if(user.incapacitated() || !computer.Adjacent(user))
		return TRUE

	var/list/choices = list()
	var/key_index = 1
	for(var/obj/item/device/encryptionkey/key in computer.mars_encryption_keys)
		var/label = "Encryption key ([key.name])"
		if(choices[label])
			label = "Encryption key ([key.name]) #[key_index]"
		choices[label] = key
		key_index++

	if(computer.modifiable)
		for(var/obj/item/stock_parts/computer/part in computer.get_all_components())
			var/label = part.name
			if(choices[label])
				label = "[part.name] #[length(choices) + 1]"
			choices[label] = part

	if(!length(choices))
		to_chat(user, SPAN_WARNING("This device doesn't have any components installed."))
		return TRUE

	var/choice = input(user, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in choices
	if(!choice || !computer.Adjacent(user))
		return TRUE

	var/obj/selected = choices[choice]
	if(istype(selected, /obj/item/device/encryptionkey))
		mars_eject_one_key(computer, selected, user)
		return TRUE
	if(istype(selected, /obj/item/stock_parts/computer))
		computer.uninstall_component(user, selected)
		return TRUE
	return TRUE

/proc/mars_console_screwdriver(obj/machinery/computer/modular/console, mob/user)
	if(!istype(console) || !user)
		return FALSE
	if(user.incapacitated() || !console.Adjacent(user))
		return FALSE
	if(!length(console.mars_encryption_keys))
		return FALSE

	var/list/choices = list()
	var/key_index = 1
	for(var/obj/item/device/encryptionkey/key in console.mars_encryption_keys)
		var/label = "Encryption key ([key.name])"
		if(choices[label])
			label = "Encryption key ([key.name]) #[key_index]"
		choices[label] = key
		key_index++

	var/choice = input(user, "Which MARS key do you want to uninstall? Cancel to use the screwdriver normally.", "Computer maintenance", null) as null|anything in choices
	if(!choice || !console.Adjacent(user))
		return FALSE

	var/obj/item/device/encryptionkey/selected = choices[choice]
	if(istype(selected))
		mars_eject_one_key(console, selected, user)
		return TRUE
	return FALSE

/obj/item/device/encryptionkey/use_before(atom/target, mob/living/user, click_parameters)
	if(mars_try_insert_key(target, src, user))
		return TRUE
	return ..()

/obj/item/modular_computer/pda/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isScrewdriver(W))
		return mars_modular_screwdriver(src, user)
	return ..()

/obj/item/modular_computer/laptop/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isScrewdriver(W))
		return mars_modular_screwdriver(src, user)
	return ..()

/obj/item/modular_computer/tablet/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isScrewdriver(W))
		return mars_modular_screwdriver(src, user)
	return ..()

/obj/machinery/computer/modular/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(isScrewdriver(I) && mars_console_screwdriver(src, user))
		return TRUE
	return ..()

/obj/item/modular_computer/pda/examine(mob/user)
	. = ..()
	mars_examine_keys(src, user)

/obj/item/modular_computer/laptop/examine(mob/user)
	. = ..()
	mars_examine_keys(src, user)

/obj/item/modular_computer/tablet/examine(mob/user)
	. = ..()
	mars_examine_keys(src, user)

/obj/machinery/computer/modular/examine(mob/user)
	. = ..()
	mars_examine_keys(src, user)

/proc/mars_examine_keys(atom/host, mob/user)
	var/list/keys = mars_get_host_keys(host)
	if(!length(keys))
		return
	to_chat(user, SPAN_NOTICE("В слоте МАРС [length(keys)] [length(keys) == 1 ? "ключ" : "ключа"] шифрования. Выкручивается отвёрткой вместе с компонентами."))


/// Encryption key paths a headset type would spawn with (ks1/ks2).
/proc/mars_key_types_from_headset(headset_type)
	. = list()
	if (!ispath(headset_type, /obj/item/device/radio/headset))
		return
	var/obj/item/device/radio/headset/headset = headset_type
	var/key1 = initial(headset.ks1type)
	var/key2 = initial(headset.ks2type)
	// Bare /encryptionkey has no department channels — skip.
	if (ispath(key1, /obj/item/device/encryptionkey) && key1 != /obj/item/device/encryptionkey)
		. += key1
	if (ispath(key2, /obj/item/device/encryptionkey) && key2 != /obj/item/device/encryptionkey)
		. += key2


/proc/mars_key_types_from_equipped_headset(mob/living/carbon/human/H)
	. = list()
	if (!istype(H))
		return
	for (var/obj/item/device/radio/headset/headset in list(H.l_ear, H.r_ear))
		if (!istype(headset))
			continue
		. |= mars_key_types_from_headset(headset.type)


/proc/mars_job_key_types_for(mob/living/carbon/human/H)
	. = list()
	if (!istype(H) || istype(H, /mob/living/carbon/human/dummy))
		return
	var/datum/job/job = H.mind?.assigned_job
	if (!job && H.mind?.assigned_role)
		job = SSjobs.get_by_title(H.mind.assigned_role)
	if (!job)
		return
	var/singleton/hierarchy/outfit/outfit = job.get_outfit(H, H.mind?.role_alt_title, H.char_branch, H.char_rank)
	if (!outfit)
		return
	return mars_key_types_from_headset(outfit.l_ear)


/obj/item/modular_computer/proc/mars_install_key_types(list/key_types)
	if (!length(key_types))
		return
	LAZYINITLIST(mars_encryption_keys)
	for (var/path in key_types)
		if (length(mars_encryption_keys) >= max_mars_keys)
			break
		if (!ispath(path, /obj/item/device/encryptionkey))
			continue
		mars_encryption_keys += new path(src)


/// Install MARS keys from the wearer's job headset / outfit. PDA starts empty.
/obj/item/modular_computer/proc/mars_apply_job_keys(mob/living/carbon/human/H)
	if (!istype(H) || istype(H, /mob/living/carbon/human/dummy))
		return
	var/list/key_types = mars_key_types_from_equipped_headset(H)
	if (!length(key_types))
		key_types = mars_job_key_types_for(H)
	mars_install_key_types(key_types)
