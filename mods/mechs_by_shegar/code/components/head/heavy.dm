/obj/item/mech_component/sensors/heavy
	name = "heavy sensors"
	desc = "A solitary sensor moves inside a recessed slit in the armour plates."
	exosuit_desc_string = "a reinforced monoeye"
	icon_state = "heavy_head"
	prebuilt_software = list(/obj/item/circuitboard/exosystem/weapons)
	power_use = 0

	//Хп
	max_hp = 150
	min_damage = 100
	max_repair = 40
	repair_damage = 10
	back_modificator_damage = 3
	front_modificator_damage = 0.5

	req_material = MATERIAL_PLASTEEL
	//Тепло
	max_heat = 400
	heat_cooling = 4
	emp_heat_generation = 150

	weight = 150
