//datajack by Sad Ninja Sid, modified from multimeter
/obj/item/device/multitool/multimeter/datajack
	name = "data jack"
	desc = "Кабель для мультизадачного подключения к различным устройствам посредством электронных устройств и продвинутой диагностики."
	icon = 'maps/sierra/icons/obj/datajack.dmi'
	icon_state = "datajack"
	w_class = ITEM_SIZE_TINY
	slot_flags = null
	var/obj/item/modular_computer/holder

/obj/item/device/multitool/multimeter/datajack/New(obj/item/modular_computer/P)
	.=..()
	holder = P

/obj/item/device/multitool/multimeter/datajack/attack_self(mob/user)
	.=..()

/obj/item/modular_computer
	var/obj/item/device/multitool/multimeter/datajack/datajack

/obj/item/modular_computer/Initialize()
	.=..()
	datajack = new(src)
	datajack.forceMove(src)

/obj/item/modular_computer/resolve_attackby(obj/item/W, mob/user, click_params)
	.=..()
	if(datajack == W)
		insert_datajack()
		return

/obj/item/device/multitool/multimeter/datajack/Process()
	if(!holder)
		qdel_self()
		return PROCESS_KILL
	if(!Adjacent(holder))
		holder.insert_datajack()
		return PROCESS_KILL

/obj/item/modular_computer/proc/eject_datajack(mob/living/carbon/human/user)
	if(!datajack || datajack.loc != src)
		return

	if(!user.put_in_hands(datajack))
		to_chat(user, SPAN_WARNING("Datajack cannot be deployed in your hands, dropping it on the ground"))
		START_PROCESSING(SSobj, datajack)
		return

	START_PROCESSING(SSobj, datajack)
	visible_message(
	SPAN_WARNING("Datajack ejects from device."),
	SPAN_WARNING("You hear coil reeling out something.")
	)

/obj/item/modular_computer/proc/insert_datajack()
	if(!datajack)
		return

	STOP_PROCESSING(SSobj, datajack)

	if(istype(datajack.loc, /mob/living/carbon/human))

		var/mob/living/carbon/human/H = datajack.loc
		H.remove_from_mob(datajack, src)
		visible_message(
		SPAN_WARNING("Datajack moves into portable device."),
		SPAN_WARNING("You hear coil reeling back in place")
		)
		return
	visible_message(
	SPAN_WARNING("Datajack moves into portable device."),
	SPAN_WARNING("You hear coil reeling back in place")
	)
	datajack.forceMove(src)

/datum/terminal_command/datajack
	name = "datajack"
	man_entry = list("Format: datajack", "Works only on mobile devices. Ejects a datajack for checking wiring and pulsing any of those.")
	pattern = "^datajack$"
	skill_needed = SKILL_EXPERIENCED

/datum/terminal_command/datajack/proper_input_entered(text, mob/user, datum/terminal/terminal)
	var/datum/extension/interactive/ntos/C = terminal.computer
	if(!(C.get_hardware_flag() & (PROGRAM_PDA | PROGRAM_TABLET)))
		return SPAN_WARNING("This command cant be executed on this device.")

	var/obj/item/modular_computer/comp = terminal.computer.get_physical_host()
	comp.eject_datajack(user)
	return SPAN_WARNING("Datajack tried to eject further.")
