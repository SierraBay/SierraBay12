/obj/item/mech_component/manipulators/powerloader
	name = "powerloader mech arm"
	icon_state = "loader_arm"
	desc = "The Xion Industrial Digital Interaction Manifolds allow you poke untold dangers from the relative safety of your cockpit."
	exosuit_desc_string = "heavy-duty industrial lifters"
	punch_sound = 'sound/mecha/mech_punch_slow.ogg'
	power_use = 15
	melee_damage = 30
	//ХП
	max_hp = 40
	min_damage = 25
	max_repair = 15
	repair_damage = 10
	front_modificator_damage = 1

	matter = list(MATERIAL_STEEL = 10000)

	max_heat = 100
	heat_cooling = 7
	emp_heat_generation = 50
	heat_generation = 2.5

	weight = 70

/obj/item/mech_component/manipulators/powerloader/right
	side = RIGHT
