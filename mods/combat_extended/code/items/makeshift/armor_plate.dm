/*
	COMBAT_EXTENDED — самодельные пластины плитоноски и их крафт из стальных листов.

	Перенесены из `packs/infinity` (`clothing/accessories/armor.dm` и
	`interactions/armorplates_craft.dm`). Там они лежали на
	`/obj/item/clothing/accessory/armorplate/mainkraft` — без подчёркивания, то есть не пластинами,
	а голыми аксессуарами. От `armor_plate` они не брали закрытых частей тела, а у аксессуара
	`body_parts_covered` по умолчанию пуст: броня пластин не закрывала ничего. Числа — прежние.
*/

/// Голый стальной лист без подбоя: сдавшая сталь колется в носителя. Сама не создаётся — только
/// лёгкая, средняя и тяжёлая.
/obj/item/clothing/accessory/armor_plate/makeshift
	abstract_type = /obj/item/clothing/accessory/armor_plate/makeshift
	ce_armor_material = /singleton/ce_armor_material/steel
	ce_armor_shards = TRUE

/obj/item/clothing/accessory/armor_plate/makeshift/light
	name = "light metal plate"
	desc = "Thin metal plate that can fit inside plate carrier."
	icon_state = "armor_light"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_MINOR
	)
	slowdown = 0.25

/obj/item/clothing/accessory/armor_plate/makeshift/medium
	name = "medium metal plate"
	desc = "Metal plate that can fit inside plate carrier."
	icon_state = "armor_medium"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_PISTOL - 10,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED
	)

/obj/item/clothing/accessory/armor_plate/makeshift/heavy
	name = "heavy metal plate"
	desc = "Thick metal plate that can fit inside plate carrier."
	icon_state = "armor_merc"
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
	)
	slowdown = 0.75


/datum/stack_recipe/makeshift_armor_plate/light
	title = "light armor plate"
	result_type = /obj/item/clothing/accessory/armor_plate/makeshift/light
	req_amount = 5
	time = 30

/datum/stack_recipe/makeshift_armor_plate/medium
	title = "armor plate"
	result_type = /obj/item/clothing/accessory/armor_plate/makeshift/medium
	req_amount = 10
	difficulty = 1
	time = 60

/datum/stack_recipe/makeshift_armor_plate/heavy
	title = "heavy armor plate"
	result_type = /obj/item/clothing/accessory/armor_plate/makeshift/heavy
	req_amount = 15
	difficulty = 2
	time = 120

/material/steel/generate_recipes(reinforce_material)
	. = ..()
	. += new /datum/stack_recipe/makeshift_armor_plate/light(src)
	. += new /datum/stack_recipe/makeshift_armor_plate/medium(src)
	. += new /datum/stack_recipe/makeshift_armor_plate/heavy(src)
