/singleton/reaction/slime/crit_hostile
	name = "Slime Crit Hostile"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/slime_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/carp,
							/mob/living/simple_animal/hostile/carp/shark,
							/mob/living/simple_animal/hostile/carp/pike,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/drake,
							/mob/living/simple_animal/hostile/giant_spider,
							/mob/living/simple_animal/hostile/retaliate/beast/antlion,
							/mob/living/simple_animal/hostile/creature,
							/mob/living/simple_animal/hostile/leech,
							/mob/living/simple_animal/hostile/vagrant
							)

/singleton/reaction/slime/crit_hostile/on_reaction(datum/reagents/holder)
	..()
	var/type = pick(possible_mobs)
	new type(get_turf(holder.my_atom))

/singleton/reaction/slime/grevive
	name = "Slime Revive"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/slime_extract/cerulean
