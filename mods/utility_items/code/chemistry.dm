/singleton/reaction/goldalchemy
	name = "Gold"
	result = null
	required_reagents = list(/datum/reagent/frostoil = 5, /datum/reagent/gold = 20)
	catalysts = list(/datum/reagent/coolant=1)
	result_amount = 1
	mix_message = "The solution solidifies into a golden mass."

/singleton/reaction/goldalchemy/on_reaction(datum/reagents/holder, created_volume, reaction_flags)
	..()
	new /obj/item/stack/material/gold(get_turf(holder.my_atom), created_volume)

/singleton/reaction/silveralchemy
	name = "Silver"
	result = null
	required_reagents = list(/datum/reagent/frostoil = 5, /datum/reagent/silver = 20)
	result_amount = 1
	mix_message = "The solution solidifies into a silver mass."

/singleton/reaction/silveralchemy/on_reaction(datum/reagents/holder, created_volume, reaction_flags)
	..()
	new /obj/item/stack/material/silver(get_turf(holder.my_atom), created_volume)



/singleton/reaction/kompot
	name = "Kompot"
	result = /datum/reagent/drink/kompot
	required_reagents = list(/datum/reagent/water = 2, /datum/reagent/drink/juice/berry = 1, /datum/reagent/drink/juice/apple = 1, /datum/reagent/drink/juice/pear = 1)
	result_amount = 5
	mix_message = "The mixture turns a soft orange, bubbling faintly"

//REAGENTS//

/datum/reagent/drink/kompot
	name = "Kompot"
	description = "A traditional Eastern European beverage once used to preserve fruit in the 1980s."
	taste_description = "refreshuingly sweet and fruity"
	color = "#ed9415"

	glass_name = "Kompot"
	glass_desc = "Traditional Terran drink. Grandma would be proud."
