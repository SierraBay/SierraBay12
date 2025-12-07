/obj/item/material/utensil/chopsticks
	name = "chopsticks"
	desc = "It's not so easy as it looks. Take a fork."
	icon = 'mods/utility_items/icons/chopsticks.dmi'
	icon_state = "chopsticks"
	item_icons = list(
		slot_l_hand_str = 'mods/utility_items/icons/lefthand.dmi',
		slot_r_hand_str = 'mods/utility_items/icons/righthand.dmi',
		)

/obj/item/material/chopsticks/material/New(newloc, new_material)
	..(newloc)
	if(!new_material)
		new_material = MATERIAL_ALUMINIUM
	material = SSmaterials.get_material_by_name(new_material)
	if(!istype(material))
		qdel(src)
		return
	name = "[material.display_name] chopsticks"
	color = material.icon_colour

/obj/item/material/utensil/chopsticks/steel/New(newloc)
	..(newloc, MATERIAL_STEEL)

/obj/item/material/utensil/chopsticks/bamboo/New(newloc)
	..(newloc, MATERIAL_BAMBOO)

/obj/item/material/utensil/chopsticks/wood/New(newloc)
	..(newloc, MATERIAL_WOOD)

/obj/item/material/utensil/chopsticks/maple/New(newloc)
	..(newloc, MATERIAL_MAPLE)

/obj/item/material/utensil/chopsticks/bronze/New(newloc)
	..(newloc, MATERIAL_BRONZE)

/obj/item/material/utensil/chopsticks/aluminium/New(newloc)
	..(newloc, MATERIAL_ALUMINIUM)

/obj/item/material/utensil/chopsticks/silver/New(newloc)
	..(newloc, MATERIAL_SILVER)

/datum/stack_recipe/chopsticks
	title = "chopsticks"
	result_type = /obj/item/material/utensil/chopsticks
	send_material_data = 1

/material/wood/bamboo/generate_recipes(reinforce_material)
	. = ..()
	if(reinforce_material)
		return
	. += new/datum/stack_recipe/chopsticks(src)

/material/wood/maple/generate_recipes(reinforce_material)
	. = ..()
	if(reinforce_material)
		return
	. += new/datum/stack_recipe/chopsticks(src)
