/obj/item/mech_component/sensors/powerloader
	name = "exosuit sensors"
	desc = "A primitive set of sensors designed to work in tandem with most MKI Eyeball platforms."
	gender = PLURAL
	exosuit_desc_string = "simple collision detection sensors"
	prebuilt_software = list(/obj/item/circuitboard/exosystem/utility, /obj/item/circuitboard/exosystem/engineering)
	power_use = 0
	//Хп
	max_hp = 40
	min_damage = 25
	max_repair = 15
	repair_damage = 10
	front_modificator_damage = 1
	//Тепло
	max_heat = 100
	heat_cooling = 7
	emp_heat_generation = 50

	matter = list(MATERIAL_STEEL = 5000)

	weight = 70
