/// Shellguard tactical terminal (slavers away site puzzle). Independent of removed contracts.

var/global/const/TACTICAL_WIRE_DATA = 1
var/global/const/TACTICAL_WIRE_POWER = 2
var/global/const/TACTICAL_WIRE_SECURITY = 4
var/global/const/TACTICAL_WIRE_GROUND = 8
var/global/const/TACTICAL_WIRE_ANTENNA = 16
var/global/const/TACTICAL_WIRE_AUX = 32

/datum/wires/tactical_terminal
	holder_type = /obj/item/tactical_terminal
	random = 1
	wire_count = 6
	descriptions = list(
		new /datum/wire_description(TACTICAL_WIRE_DATA, "A narrow-gauge wire with consistent high-frequency digital oscillations.", "Data Port", SKILL_EXPERIENCED),
		new /datum/wire_description(TACTICAL_WIRE_POWER, "A thick wire carrying heavy electrical current.", "Power Feed", SKILL_TRAINED),
		new /datum/wire_description(TACTICAL_WIRE_SECURITY, "A wire leading to the security alarm module.", "Security", SKILL_TRAINED),
		new /datum/wire_description(TACTICAL_WIRE_GROUND, "A thick grounding cable.", "Ground"),
		new /datum/wire_description(TACTICAL_WIRE_ANTENNA, "A shielded antenna transceiver wire.", "Antenna"),
		new /datum/wire_description(TACTICAL_WIRE_AUX, "A power routing wire with minor interference artifacts.", "Auxiliary")
	)

/datum/wires/tactical_terminal/CanUse(mob/living/L)
	var/obj/item/tactical_terminal/T = holder
	if(T.hack_phase != 1)
		return FALSE
	return TRUE

/datum/wires/tactical_terminal/GetInteractWindow(mob/user)
	. = ..()
	if(.)
		. += "<br><i>Locate the data port by pulsing the correct wire.</i>"

/datum/wires/tactical_terminal/UpdatePulsed(index)
	var/obj/item/tactical_terminal/T = holder
	if(T.hack_phase != 1)
		return
	switch(index)
		if(TACTICAL_WIRE_DATA)
			to_chat(usr, SPAN_NOTICE("HIGH-FREQUENCY DIGITAL SIGNAL DETECTED. Data port established!"))
			T.visible_message(SPAN_NOTICE("[usr] successfully locates the data port on [T]."))
			T.hack_phase = 2
			close_browser(usr, "window=wires")
		if(TACTICAL_WIRE_POWER)
			to_chat(usr, SPAN_DANGER("POWER FEED — you take a sharp shock!"))
			if(isliving(usr))
				var/mob/living/L = usr
				L.apply_damage(5, DAMAGE_BURN, "chest")
		if(TACTICAL_WIRE_SECURITY)
			to_chat(usr, SPAN_WARNING("Security circuit triggered!"))
			playsound(get_turf(T), 'sound/machines/buzz-two.ogg', 80, FALSE)
			T.visible_message(SPAN_WARNING("[T] emits a piercing alarm tone!"))
			T.trigger_security_alarm()
		else
			to_chat(usr, SPAN_NOTICE("No digital signal detected. Incorrect circuit."))

/datum/wires/tactical_terminal/UpdateCut(index, mended)
	switch(index)
		if(TACTICAL_WIRE_DATA)
			if(!mended)
				to_chat(usr, SPAN_WARNING("The data port wire goes dead. You can mend it to restore it."))
		if(TACTICAL_WIRE_SECURITY)
			if(!mended)
				to_chat(usr, SPAN_NOTICE("The security alarm circuit is disabled."))


/obj/item/tactical_terminal
	name = "tactical operations terminal"
	icon = 'mods/RnD/icons/derelict_mission.dmi'
	icon_state = "terminal"
	desc = "A hardened military-grade terminal. Encrypted with Shellguard security protocols. A datajack interface port is visible on the side."
	w_class = ITEM_SIZE_NO_CONTAINER
	var/hack_phase = 0
	var/access_code = ""
	var/datum/wires/tactical_terminal/wires

/obj/item/tactical_terminal/New()
	..()
	var/a = rand(0, 0xFFFF)
	access_code = uppertext(pad_left(num2hex(a), 4, "0"))
	wires = new(src)

/obj/item/tactical_terminal/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/item/tactical_terminal/examine(mob/user)
	. = ..()
	switch(hack_phase)
		if(0)
			to_chat(user, SPAN_WARNING("The terminal is locked. A datajack interface port is visible on the side."))
		if(1)
			to_chat(user, SPAN_NOTICE("The wire panel is exposed. Use a datajack to interact with the wires."))
		if(2)
			to_chat(user, SPAN_NOTICE("Data port established. Use a datajack on the terminal to enter the access code."))
		if(3)
			to_chat(user, SPAN_NOTICE("Terminal decrypted. Tactical data has been extracted."))

/obj/item/tactical_terminal/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/device/multitool/multimeter/datajack))
		terminal_interact(user)
		return TRUE
	if(isWirecutter(W) && hack_phase == 1)
		wires.Interact(user)
		return TRUE
	. = ..()

/obj/item/tactical_terminal/attack_self(mob/living/user)
	if(hack_phase == 3)
		to_chat(user, SPAN_NOTICE("The terminal is already decrypted."))
		return
	if(hack_phase == 2)
		if(!istype(user, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = user
		if(terminal_user_has_datajack(H))
			terminal_prompt_code(user)
		else
			to_chat(user, SPAN_WARNING("You need a datajack to enter the access code."))
		return
	to_chat(user, SPAN_NOTICE("Place the terminal on a surface and use your datajack on it to access the wire panel."))

/obj/item/tactical_terminal/proc/terminal_interact(mob/living/user)
	if(hack_phase == 3)
		to_chat(user, SPAN_NOTICE("The terminal is already decrypted."))
		return
	if(hack_phase == 0)
		to_chat(user, SPAN_NOTICE("You connect your datajack to the terminal's maintenance port. The wire panel clicks open."))
		hack_phase = 1
	if(hack_phase == 1)
		wires.Interact(user)
	else if(hack_phase == 2)
		terminal_prompt_code(user)

/obj/item/tactical_terminal/proc/terminal_user_has_datajack(mob/living/carbon/human/H)
	if(istype(H.l_hand, /obj/item/device/multitool/multimeter/datajack) || istype(H.r_hand, /obj/item/device/multitool/multimeter/datajack))
		return TRUE
	if(istype(H.back, /obj/item/rig))
		var/obj/item/rig/R = H.back
		if(R.suit_is_deployed())
			for(var/obj/item/rig_module/M in R.installed_modules)
				if(istype(M, /obj/item/rig_module/datajack) && M.active)
					return TRUE
	return FALSE

/obj/item/tactical_terminal/proc/trigger_security_alarm()
	for(var/obj/machinery/door/airlock/A in range(7, src))
		if(!A.locked)
			A.lock(forced = 1)

/obj/item/tactical_terminal/proc/terminal_prompt_code(mob/living/user)
	if(hack_phase != 2)
		return
	var/code_input = input(user, "Data port active. Enter the 4-character access verification code.\n\n(Check nearby documents for the access code.)", "Terminal Interface — Code Entry") as text|null
	if(!code_input)
		return
	if(uppertext(trimtext(code_input)) == access_code)
		to_chat(user, SPAN_NOTICE("ACCESS GRANTED. Terminal decrypted. Extracting Shellguard tactical data..."))
		visible_message(SPAN_NOTICE("[src] beeps rapidly as [user] extracts the encrypted tactical data."))
		hack_phase = 3
		var/obj/item/disk/shellguard_tactical/disk = new(get_turf(src))
		visible_message(SPAN_NOTICE("[src]: Tactical data extracted onto [disk]."))
	else
		to_chat(user, SPAN_WARNING("ACCESS DENIED. Incorrect code."))


/obj/item/disk/shellguard_tactical
	name = "Shellguard tactical data disk"
	desc = "Encrypted field data extracted from a Shellguard operations terminal."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk0"
