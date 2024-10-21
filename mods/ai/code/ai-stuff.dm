/mob/living/silicon/ai/verb/interact_with_machine(obj/machinery/A as obj in SSmachines.get_machinery_of_type(/obj/machinery))
	set category = "Software"
	set name = "Interact with machine"
	set desc = "Another way to interact with machines"
	var/mob/living/silicon/ai/user = usr
	A.attack_ai(user)


/proc/get_all_machines(mob/living/silicon/ai/user)
	RETURN_TYPE(/list)
	var/list/list_of_machines = list()
	for(var/obj/machinery/power/apc/A as anything in SSmachines.get_machinery_of_type(/obj/machinery))
		LAZYADD(list_of_machines, A)
	return list_of_machines

//Комплюктор для ИИ
/obj/item/modular_computer/telescreen/preset/ai/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	return


/obj/item/modular_computer/telescreen/preset/install_default_hardware()
	..()
	processor_unit = new/obj/item/stock_parts/computer/processor_unit(src)
	tesla_link = new/obj/item/stock_parts/computer/tesla_link(src)
	hard_drive = new/obj/item/stock_parts/computer/hard_drive/cluster(src)
	network_card = new/obj/item/stock_parts/computer/network_card/advanced(src)


/obj/item/modular_computer/telescreen/preset/ai/install_default_programs()
	..()
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
	if(os)
		os.create_file(new/datum/computer_file/program/alarm_monitor())
		os.create_file(new/datum/computer_file/program/camera_monitor())
		os.create_file(new/datum/computer_file/program/shields_monitor())
		os.create_file(new/datum/computer_file/program/supermatter_monitor())
		os.create_file(new/datum/computer_file/program/records())
		os.create_file(new/datum/computer_file/program/suit_sensors())
		os.create_file(new/datum/computer_file/program/ntnetmonitor())
		os.create_file(new/datum/computer_file/program/email_administration())
		os.create_file(new/datum/computer_file/program/email_client())
		os.create_file(new/datum/computer_file/program/docking())
		os.create_file(new/datum/computer_file/program/forceauthorization())
		os.create_file(new/datum/computer_file/program/supply())
		os.create_file(new/datum/computer_file/program/deck_management())
		os.create_file(new/datum/computer_file/program/nttransfer())
		os.set_autorun("alarmmonitor")
