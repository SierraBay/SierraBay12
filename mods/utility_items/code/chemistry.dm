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

/singleton/reaction/concrete
	name = "concrete"
	result = null
	required_reagents = list(/datum/reagent/silicon = 20, /datum/reagent/iron = 5, /datum/reagent/aluminium = 5, /datum/reagent/water = 20)
	result_amount = 5
	mix_message = "The solution solidifies into a grey mass."

/obj/item/stack/material/concrete
	name = "concrete brick"
	default_type = MATERIAL_CONCRETE

/singleton/reaction/concrete/on_reaction(datum/reagents/holder, created_volume, reaction_flags)
	..()
	new /obj/item/stack/material/concrete(get_turf(holder.my_atom), created_volume)

/singleton/reaction/uranchemy
	name = "Uranium"
	result = null
	required_reagents = list(/datum/reagent/frostoil = 5, /datum/reagent/uranium = 20)
	catalysts = list(/datum/reagent/crystal=5)
	result_amount = 1
	mix_message = "The solution solidifies into a greeny mass."

/singleton/reaction/uranchemy/on_reaction(datum/reagents/holder, created_volume, reaction_flags)
	..()
	new /obj/item/stack/material/uranium(get_turf(holder.my_atom), created_volume)

/singleton/reaction/kompot
	name = "Kompot"
	result = /datum/reagent/drink/kompot
	required_reagents = list(/datum/reagent/water = 2, /datum/reagent/drink/juice/berry = 1, /datum/reagent/drink/juice/apple = 1, /datum/reagent/drink/juice/pear = 1)
	result_amount = 5
	mix_message = "The mixture turns a soft orange, bubbling faintly"

/singleton/reaction/github
	name = "GitHub"
	result = /datum/reagent/ethanol/github
	required_reagents = list(/datum/reagent/drink/juice/watermelon = 1, /datum/reagent/fuel = 1, /datum/reagent/iron = 1)
	result_amount = 10
	mix_message = "Microchips are starting to blur in the water..."

/singleton/reaction/discord
	name = "Discord"
	result = /datum/reagent/ethanol/discord
	required_reagents = list(/datum/reagent/drink/juice/grape = 1, /datum/reagent/fuel = 1, /datum/reagent/iron = 1)
	result_amount = 10
	mix_message = "Voice yelling and memes are starting to blur in the water..."

//REAGENTS//

/datum/reagent/drink/kompot
	name = "Kompot"
	description = "A traditional Eastern European beverage once used to preserve fruit in the 1980s."
	taste_description = "refreshuingly sweet and fruity"
	color = "#ed9415"

	glass_name = "Kompot"
	glass_desc = "Traditional Terran drink. Grandma would be proud."

/datum/reagent/ethanol/github
	name = "GitHub"
	description = "The famous cocktail. Coined by programmers for programmers. Made not from programmers. Where's my merge, Elar?"
	taste_description = "sweet microchips, steel and Elar's merge"
	color = "#3d3d3d"
	metabolite_potency = 20

	glass_name = "github cocktail"
	glass_desc = "The famous cocktail. Coined by programmers for programmers. Made not from programmers. Where's my merge, Elar?"

/datum/reagent/ethanol/discord
	name = "Discord"
	description = "You did it, Verhniy! Where's the Discord Nitro cocktail, though?"
	taste_description = "Well Played Good Games and CO-OP"
	color = "#36393f"
	metabolite_potency = 10

	glass_name = "Discord cocktail"
	glass_desc = "You did it, Verhniy! Where's the Discord Nitro cocktail, though?"

// SLIME REACTIONS //

// Silver

/singleton/reaction/slime/silver
	name = "Slime Silver"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/slime_extract/silver

/singleton/reaction/slime/silver/on_reaction(datum/reagents/holder)
	..()
	var/obj/item/stack/material/silver/S = new (get_turf(holder.my_atom))
	S.amount = 5

// Glass

/singleton/reaction/slime/glass
	name = "Slime Glass"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/slime_extract/metal

/singleton/reaction/slime/glass/on_reaction(datum/reagents/holder)
	..()
	var/obj/item/stack/material/glass/G = new (get_turf(holder.my_atom))
	G.amount = 15
	var/obj/item/stack/material/glass/reinforced/RG = new (get_turf(holder.my_atom))
	RG.amount = 5

// Oil

/singleton/reaction/slime/oil
	name = "Slime Machine Oil"
	result = /datum/reagent/oil
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 10
	required = /obj/item/slime_extract/oil

//Black
/singleton/reaction/slime/psimutate
	name = "Mule Mutation Toxin"
	result = /datum/reagent/psislimetoxin
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/slime_extract/black

/singleton/reaction/slime/psimutate/get_reaction_flags(datum/reagents/holder)
	for(var/datum/reagent/blood/blood in holder.reagent_list)
		var/weakref/donor_ref = islist(blood.data) && blood.data["donor"]
		if(istype(donor_ref))
			var/mob/living/donor = donor_ref.resolve()
			if(istype(donor) && (donor.psi || (donor.mind && GLOB.wizards.is_antagonist(donor.mind))))
				return TRUE

// Turning monkeys into mule

/* Transformations */
/datum/reagent/psislimetoxin
	name = "Twisted Mutation Toxin"
	description = "A corruptive toxin produced by slimes. This one looks like vomit."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#96c921"
	metabolism = REM * 0.2
	value = 2
	should_admin_log = TRUE

/datum/reagent/psislimetoxin/affect_blood(mob/living/carbon/M, removed)
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(M))
		return
	if(M.species.name != SPECIES_MONKEY)
		return
	to_chat(M, SPAN_DANGER("Your flesh rapidly mutates!"))
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(M)
	M.icon = null
	M.ClearOverlays()
	M.set_invisibility(INVISIBILITY_ABSTRACT)
	for(var/obj/item/W in M)
		if(istype(W, /obj/item/implant))
			qdel(W)
			continue
		M.drop_from_inventory(W)
	var/mob/living/carbon/human/new_mob = new /mob/living/carbon/human(M.loc)
	new_mob.skin_tone = 35
	new_mob.species = GLOB.species_by_name[SPECIES_MULE]
	if(M.mind)
		M.mind.transfer_to(new_mob)
		new_mob.languages = list(LANGUAGE_HUMAN_EURO)
	else
		new_mob.key = M.key
	qdel(M)

// Turning man into lizards

/singleton/reaction/yeostoxin
	name = "Lizard Toxin"
	result = /datum/reagent/yeostoxin
	required_reagents = list(/datum/reagent/slimetoxin = 1, /datum/reagent/toxin/yeosvenom = 1)
	result_amount = 1
	mix_message = "The mixture becomes cloudy and darkens slightly with a disgusting hissing sound."

/* Transformations */
/datum/reagent/yeostoxin
	name = "Envenomed Mutation Toxin"
	description = "A corruptive toxin produced by slimes. This one is little darker."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#13bc5e"
	metabolism = REM * 0.2
	value = 2
	should_admin_log = TRUE

/datum/reagent/yeostoxin/affect_blood(mob/living/carbon/human/affected, removed)
	if (!istype(affected))
		return
	if(affected.species.name == SPECIES_YEOSA)
		return
	affected.adjustToxLoss(40 * removed)

/datum/reagent/yeostoxin/affect_metabolites(mob/living/carbon/human/H, dose)
	if (!istype(H))
		return
	if(H.species.name == SPECIES_YEOSA)
		return
	if (dose < 1 || prob(30))
		return
	remove_self(dose)
	var/list/meatchunks = list()
	for(var/limb_tag in list(BP_R_ARM, BP_L_ARM, BP_R_LEG,BP_L_LEG))
		var/obj/item/organ/external/E = H.get_organ(limb_tag)
		if(E && !E.is_stump() && !BP_IS_ROBOTIC(E) && E.species.name != SPECIES_YEOSA)
			meatchunks += E
	if(!length(meatchunks))
		if(prob(10))
			to_chat(H, SPAN_DANGER("Your flesh rapidly mutates!"))
			H.set_species(SPECIES_YEOSA)
			H.shapeshifter_set_colour("#13bc5e")
		return
	var/obj/item/organ/external/O = pick(meatchunks)
	to_chat(H, SPAN_DANGER("Your [O.name]'s flesh mutates rapidly!"))
	if(!GLOB.mob_ref_to_species_name[any2ref(H)])
		GLOB.mob_ref_to_species_name[any2ref(H)] = H.species.name
	meatchunks = list(O) | O.children
	for(var/obj/item/organ/external/E in meatchunks)
		E.species = GLOB.species_by_name[SPECIES_YEOSA]
		E.skin_tone = null
		E.s_col = ReadRGB("#13bc5e")
		E.s_col_blend = ICON_ADD
		E.status &= ~ORGAN_BROKEN
		E.status |= ORGAN_MUTATED
		E.limb_flags &= ~ORGAN_FLAG_CAN_BREAK
		E.dislocated = -1
		E.max_damage = 5
		E.update_icon(1)
	O.max_damage = 15
	if(prob(10))
		to_chat(H, SPAN_DANGER("Your new [O.name] explodes with a stream of blood and unformed muscles!"))
		O.droplimb()
	H.update_body()

// Critter

/singleton/reaction/slime/crit
	possible_mobs = list(
							/mob/living/simple_animal/passive/cat,
							/mob/living/simple_animal/passive/cat/kitten,
							/mob/living/simple_animal/passive/corgi,
							/mob/living/simple_animal/passive/corgi/puppy,
							/mob/living/simple_animal/passive/cow,
							/mob/living/simple_animal/passive/chick,
							/mob/living/simple_animal/passive/chicken,
							/mob/living/simple_animal/passive/crab,
							/mob/living/simple_animal/passive/opossum,
							/mob/living/simple_animal/passive/snake,
							/mob/living/simple_animal/passive/thoom,
							/mob/living/simple_animal/butterfly,
							/mob/living/simple_animal/friendly/cat/maine_coon,
							/mob/living/simple_animal/friendly/cat/floppa,
							/mob/living/simple_animal/friendly/dogs,
							/mob/living/simple_animal/friendly/dogs/pug,
							/mob/living/simple_animal/friendly/dogs/shiba_inu,
							/mob/living/simple_animal/friendly/frog,
							/mob/living/simple_animal/friendly/rabbit,
							/mob/living/simple_animal/hostile/retaliate/kangaroo,
							/mob/living/simple_animal/friendly/lizard/axolotl,
							/mob/living/simple_animal/friendly/megamoth,
							/mob/living/simple_animal/penguin,
							/mob/living/simple_animal/penguin/emperor,
							/mob/living/simple_animal/penguin/baby,
							/mob/living/simple_animal/hostile/retaliate/reindeer,
							/mob/living/simple_animal/pet/sloth,
							/mob/living/simple_animal/hostile/commanded/dog/german,
							/mob/living/simple_animal/hostile/commanded/dog/german/black,
							/mob/living/simple_animal/hostile/commanded/dog/golden_retriever,
							/mob/living/simple_animal/hostile/commanded/dog/bullterrier,
							/mob/living/simple_animal/friendly/fox,
							/mob/living/simple_animal/friendly/koala
							)
