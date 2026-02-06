/obj/item/mech_component/manipulators/heavy
	name = "heavy armored mech arm"
	desc = "Designed to function where any other piece of equipment would have long fallen apart, the Hephaestus Superheavy Lifter series can take a beating and excel at delivering it."
	exosuit_desc_string = "super-heavy reinforced manipulators"
	icon_state = "heavy_arm"
	punch_sound = 'sound/mecha/mech_punch_slow.ogg'
	action_delay = 20
	power_use = 30
	melee_damage = 40

	max_hp = 150
	min_damage = 100
	max_repair = 40
	repair_damage = 10
	back_modificator_damage = 3
	front_modificator_damage = 0.5

	matter = list(MATERIAL_STEEL = 48000, MATERIAL_PLASTEEL = 20000, MATERIAL_ALUMINIUM = 20000)

	req_material = MATERIAL_PLASTEEL
	//Тепло
	max_heat = 400
	heat_cooling = 4
	emp_heat_generation = 150
	heat_generation = 7.5

	weight = 225

/obj/item/mech_component/manipulators/heavy/right
	side = RIGHT
