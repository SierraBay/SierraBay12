/datum/stack_recipe/mainkraft/larmor
	title = "light armor plate"
	result_type = /obj/item/clothing/accessory/armorplate/mainkraft/light
	req_amount = 5
	time = 30

/datum/stack_recipe/mainkraft/marmor
	title = "armor plate"
	result_type = /obj/item/clothing/accessory/armorplate/mainkraft/medium
	req_amount = 10
	difficulty = 1
	time = 60

/datum/stack_recipe/mainkraft/harmor
	title = "heavy armor plate"
	result_type = /obj/item/clothing/accessory/armorplate/mainkraft/heavy
	req_amount = 15
	difficulty = 2
	time = 120

/material/steel/generate_recipes(reinforce_material)
	. = ..()
	. += new/datum/stack_recipe/mainkraft/larmor(src)
	. += new/datum/stack_recipe/mainkraft/marmor(src)
	. += new/datum/stack_recipe/mainkraft/harmor(src)