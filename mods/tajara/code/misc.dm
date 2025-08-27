/*[SIERRA-REMOVE: перенесено в mods/utility_items/boozeomat.dm]
/datum/reagent/drink/tajaran/chai
	name = "Herbal tincture"
	description = "Drink similar to tea, but from other herbs. If you brewed hundreds of medicinal herbs from pharmacies - could be something similar."
	taste_description = "hundreds of herbs"
	color = "#8f86e4"
	glass_name = "Herbal tincture"
	glass_desc = " Drink similar to tea, but from other herbs. If you brewed hundreds of medicinal herbs from pharmacies - could be something similar."

/datum/reagent/drink/tajaran/chai/affect_ingest(mob/living/carbon/M, removed)
	if(M.is_species(SPECIES_TAJARA))
		M.heal_organ_damage(5 * removed, 5 * removed)
		M.adjustToxLoss(-3 * removed)

/datum/reagent/ethanol/tajaran/kotovino
	name = "Djurl'Ma-Tua"
	description = "One of the oldest tajaran drinks, the history of which stretches from unknown-distant epochs. \
	This drink is not produced anywhere but on Ahdomai. It tastes like wine, \
	but combines a large number of different types of spices and spices. "

	taste_description = "exotic, sweet, hard and gentle at the same time"
	color = "#ba86e4"
	strength = 80
	adj_temp = 5
	glass_name = "Djurl'Ma-Tua"
	glass_desc = "Exotic drink native to Ahdomai. Its taste is similar to wine with a lot of different condiments and spices."

/datum/reagent/ethanol/tajaran/kotovino/affect_ingest(mob/living/carbon/M, removed)
	if(M.is_species(SPECIES_TAJARA))
		M.adjustToxLoss(0.5 * removed)
		return
	else if (!IS_METABOLICALLY_INERT(M))
		M.adjustHalLoss(4)
		if(prob(5))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>", \
			"<span class='danger'>You can feel LIQUID HELL running down your throat and into your stomach!</span>")
	if(istype(M, /mob/living/carbon/slime))
		M.bodytemperature += rand(15, 30)
	holder.remove_reagent(/datum/reagent/frostoil, 5)

/obj/item/reagent_containers/food/drinks/bottle/kotovino
	name = "Djurl'Ma-Tua"
	desc = "One of the oldest tajaran drinks, the history of which stretches from unknown-distant epochs. \
	This drink is not produced anywhere but on Ahdomai. It tastes like wine, \
	but combines a large number of different types of spices and spices. "
	icon = 'mods/tajara/icons/drinks.dmi'
	icon_state = "kotovino"
	center_of_mass = "x=17;y=3"

/obj/item/reagent_containers/food/drinks/bottle/kotovino/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ethanol/tajaran/kotovino, 100)

/obj/item/reagent_containers/food/drinks/bottle/kotochai
	name = "Herbal tincture"
	desc = "Drink similar to tea, but from other herbs. If you brewed hundreds of medicinal herbs from pharmacies - could be something similar."
	icon = 'mods/tajara/icons/drinks.dmi'
	icon_state = "kotochai"
	center_of_mass = "x=17;y=3"

/obj/item/reagent_containers/food/drinks/bottle/kotochai/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/drink/tajaran/chai, 100)
[/SIERRA-REMOVE]*/
