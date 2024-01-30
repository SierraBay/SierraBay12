// SIERRA TODO: multimeter

#define METER_MESURING "Measuring"
#define METER_CHECKING "Checking"

#define isMultimeter(A)   (A && A.ismultimeter())

/obj/item/device/multitool/multimeter
	name = "multimeter"
	desc = "Используется для измерения потребления электроэнергии оборудования и прозвонки проводов. Рекомендуется докторами."
	icon = 'mods/_master_files/icons/obj/multimeter.dmi'
	icon_state = "multimeter"
	origin_tech = list(TECH_MAGNET = 4, TECH_ENGINEERING = 4)
	slot_flags = SLOT_BELT
	var/mode = METER_MESURING // Mode

/obj/item/device/multitool/multimeter/attack_self(mob/user)
	switch(mode)
		if(METER_MESURING)
			mode = METER_CHECKING
		if(METER_CHECKING)
			mode = METER_MESURING
	to_chat(user, "Режим сменён на: [mode].")

/obj/item/device/multitool/multimeter/ismultimeter()
	return TRUE

/atom/proc/ismultimeter()
	return FALSE

/datum/wires/Topic(href, href_list)
	. = ..()
	var/list/unsolved_wires = src.wires.Copy()
	var/colour_function
	var/solved_colour_function

	if(in_range(holder, usr) && isliving(usr))

		var/mob/living/L = usr
		if(CanUse(L) && href_list["action"])

			var/obj/item/I = L.get_active_hand()

			var/obj/item/offhand_item
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				offhand_item = H.wearing_rig && H.wearing_rig.selected_module

			if(href_list["check"])
				if(isMultimeter(I) || isMultimeter(offhand_item))
					var/obj/item/device/multitool/multimeter/O = L.get_active_hand()
					if (L.skill_check(SKILL_ELECTRICAL, SKILL_TRAINED))
						if(O.mode == METER_CHECKING)
							to_chat(L, "<span class='notice'>Перебираем провода...</span>")
							var/name_by_type = name_by_type()
							to_chat(L, "[name_by_type] wires:")
							for(var/colour in src.wires)
								if(unsolved_wires[colour])
									if(!do_after(L, 10, holder))
										return
									if(!IsColourCut(colour))
										colour_function = unsolved_wires[colour]
										solved_colour_function = SolveWireFunction(colour_function)
										if(solved_colour_function != "")
											to_chat(L, "the [colour] wire connected to [solved_colour_function]")
											playsound(O.loc, 'mods/_master_files/sounds/mbeep.ogg', 20, 1)
										else
											to_chat(L, "the [colour] wire not connected")
									else
										to_chat(L, "the [colour] wire not connected")
							//to_chat(L, "<span class='notice'>[all_solved_wires[holder_type]]</span>")
						else
							to_chat(L, "<span class='notice'>Переключите мультиметр в режим прозвонки.</span>")
					else
						to_chat(L, "<span class='notice'>Вы не знаете как с этим работать.</span>")
				else
					to_chat(L, "<span class='warning'>Вам нужен мультиметр.</span>")

// Wire solve functions

/datum/wires/proc/name_by_type()
	var/name_by_type
	if(istype(src, /datum/wires/airlock))
		name_by_type = "Airlock"
	if(istype(src, /datum/wires/apc))
		name_by_type = "APC"
	if(istype(src, /datum/wires/robot))
		name_by_type = "Cyborg"
	if(istype(src, /datum/wires/fabricator))
		name_by_type = "Autolathe"
	if(istype(src, /datum/wires/alarm))
		name_by_type = "Air Alarm"
	if(istype(src, /datum/wires/camera))
		name_by_type = "Camera"
	if(istype(src, /datum/wires/explosive))
		name_by_type = "C4 Bomb"
	if(istype(src, /datum/wires/nuclearbomb))
		name_by_type = "Nuclear Bomb"
	if(istype(src, /datum/wires/particle_acc))
		name_by_type = "Particle Accelerator"
	if(istype(src, /datum/wires/radio))
		name_by_type = "Radio"
	if(istype(src, /datum/wires/vending))
		name_by_type = "Vending Machine"
	return name_by_type

/datum/wires/proc/SolveWireFunction(WireFunction)
	return WireFunction //Default returns the original number, so it still "works"

/datum/wires/proc/SolveWires()
	var/list/unsolved_wires = src.wires.Copy()
	var/colour_function
	var/solved_colour_function

	var/name_by_type = name_by_type()

	var/solved_txt = "[name_by_type] wires:<br>"

	for(var/colour in src.wires)
		if(unsolved_wires[colour]) //unsolved_wires[red]
			colour_function = unsolved_wires[colour] //unsolved_wires[red] = 1 so colour_index = 1
			solved_colour_function = SolveWireFunction(colour_function) //unsolved_wires[red] = 1, 1 = AIRLOCK_WIRE_IDSCAN
			solved_txt += "the [colour] wire connected to [solved_colour_function]<br>" //the red wire is the ID wire

	solved_txt += "<br>"

	return solved_txt

/datum/design/item/tool/multimeter
	name = "multimeter"
	desc = "Используется для измерения потребления электроэнергии оборудования и прозвонки проводов. Рекомендуется докторами."
	id = "multimeter"
	req_tech = list(TECH_MAGNET = 4, TECH_ENGINEERING = 5, TECH_MATERIAL = 6)
	materials = list(DEFAULT_WALL_MATERIAL = 1000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 500)
	build_path = /obj/item/device/multitool/multimeter
	sort_string = "VAGAM"
