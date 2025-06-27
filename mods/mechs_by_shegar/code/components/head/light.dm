/obj/item/mech_component/sensors/light
	name = "light sensors"
	desc = "A series of high resolution optical sensors. They can overlay several images to give the pilot a sense of location even in total darkness. "
	gender = PLURAL
	exosuit_desc_string = "advanced sensor array"
	icon_state = "light_head"
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	prebuilt_software = list(/obj/item/circuitboard/exosystem/medical, /obj/item/circuitboard/exosystem/utility)

	max_hp = 75
	min_damage = 30
	max_repair = 50
	repair_damage = 15
	front_modificator_damage = 1

	req_material = MATERIAL_ALUMINIUM
	power_use = 50
	//Тепло
	max_heat = 100
	heat_cooling = 12
	emp_heat_generation = 110

	weight = 50
