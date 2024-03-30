/datum/species/proc/get_virus_immune(mob/living/carbon/human/H)
	return ((H && H.isSynthetic()) ? 1 : virus_immune)


///
// pure concentrated antibodies
/datum/reagent/antibodies
	data = list("antibodies"=list())
	name = "Antibodies"
	taste_description = "slime"
	reagent_state = LIQUID
	color = "#0050f0"
	value = 6

/datum/reagent/antibodies/affect_blood(mob/living/carbon/M, alien, removed)
	if(src.data)
		M.antibodies |= src.data["antibodies"]
	..()

/datum/reagent/radium/affect_blood(mob/living/carbon/M, alien, removed)
	.=..()
	if(M.virus2.len)
		for(var/ID in M.virus2)
			var/datum/disease2/disease/V = M.virus2[ID]
			if(prob(5))
				M.antibodies |= V.antigen
				if(prob(50))
					M.apply_damage(50, DAMAGE_RADIATION, armor_pen = 100) // curing it that way may kill you instead
					var/absorbed = 0
					var/obj/item/organ/internal/diona/nutrients/rad_organ = locate() in M.internal_organs
					if(rad_organ && !rad_organ.is_broken())
						absorbed = 1
					if(!absorbed)
						M.adjustToxLoss(100)


/datum/reagent/nutriment/virus_food
	name = "Virus Food"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	taste_description = "vomit"
	taste_mult = 2
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#899613"



/datum/chemical_reaction/virus_food
	name = "Virus Food"
	result = /datum/reagent/nutriment/virus_food
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/drink/milk = 1)
	result_amount = 5
	mix_message = "The water dilutes the milk into a thin white solution."


/obj/structure/reagent_dispensers/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of virus food."
	icon = 'mods/virusology/icons/virology.dmi'
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = 1
	initial_reagent_types = list(/datum/reagent/nutriment/virus_food = 1)



/obj/item/stock_parts/circuitboard/curefab
	name = "circuit board (cure fabricator)"
	build_path = /obj/machinery/computer/curer

/obj/item/stock_parts/circuitboard/splicer
	name = "circuit board (disease splicer)"
	build_path = /obj/machinery/computer/diseasesplicer
	origin_tech = list(TECH_DATA = 5, TECH_BIO = 5)

/obj/item/stock_parts/circuitboard/centrifuge
	name = "circuit board (isolation centrifuge)"
	build_path = /obj/machinery/computer/centrifuge
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 3)


/datum/design/circuit/centrifuge
	name = "isolation centrifuge console"
	id = "iso_centrifuge"
	req_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	build_path = /obj/item/stock_parts/circuitboard/centrifuge
	sort_string = "FACAG"

/datum/design/circuit/splicer
	name = "disease splicer"
	id = "isplicer"
	req_tech = list(TECH_DATA = 5, TECH_BIO = 5)
	build_path = /obj/item/stock_parts/circuitboard/splicer
	sort_string = "FACAH"

/datum/species
	var/virus_immune

/mob/living/carbon/
	var/list/datum/disease2/disease/virus2 = list()
	var/list/antibodies = list()


/datum/goal/sickness
	description = "Don't get sick! Avoid catching any viruses during the shift."
	var/got_sick
	var/announced

/datum/goal/sickness/check_success()
	return !got_sick

/datum/goal/sickness/update_progress(progress)
	if(!got_sick)
		got_sick = progress
		if(got_sick)
			addtimer(CALLBACK(src, PROC_REF(on_completion), rand(30,40)))

/datum/goal/sickness/on_completion()
	if(!announced)
		announced = TRUE
		var/datum/mind/mind = owner
		to_chat(mind.current, SPAN_DANGER("You don't feel so good..."))



//SPACE COLD EVENT
/datum/event/space_cold/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/sniffle = new
	sniffle.max_stage = 3
	sniffle.makerandom(1)
	sniffle.spreadtype = "Airborne"

	var/victims = min(rand(1,3), candidates.len)
	while(victims)
		infect_virus2(pick_n_take(candidates),sniffle,1)
		victims--
////////


/obj/decal/cleanable/blood
	var/list/viruses = list()
	var/list/datum/disease2/disease/virus2 = list()

/obj/decal/cleanable/vomit
	var/list/viruses = list()

/obj/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'mods/virusology/icons/virology.dmi'
	icon_state = "mucus"
	var/list/datum/disease2/disease/virus2 = list()


/obj/decal/cleanable/mucus/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(set_dry), 1), DRYING_TIME * 2)

/mob/living/carbon/human/proc/cure_virus(virus_uuid)
	if(vessel && virus_uuid)
		for(var/datum/reagent/blood/B in vessel.reagent_list)
			var/list/viruses = list()
			viruses = B.data["virus2"]
			viruses.Remove("[virus_uuid]")
			B.data["virus2"] = viruses


/singleton/hierarchy/supply_pack/science/virus
	name = "Samples - Virus (BIOHAZARD)"
	contains = list(/obj/item/virusdish/random = 4)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "virus sample crate"
	access = access_virology



/datum/event_container/mundane/New()
	LAZYINITLIST(available_events)
	available_events = list(new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Space Cold Outbreak", /datum/event/space_cold, 100, list(ASSIGNMENT_MEDICAL = 20)))


/datum/controller/subsystem/supply
	var/list/sold_virus_strains = list()


/mob/living/carbon/handle_viruses()
	.=..()

	if(bodytemperature > 406)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)

	if(life_tick % 3) //don't spam checks over all objects in view every tick.
		for(var/obj/decal/cleanable/O in view(1,src))
			if(istype(O,/obj/decal/cleanable/blood))
				var/obj/decal/cleanable/blood/B = O
				if(isnull(B.virus2))
					B.virus2 = list()
				if(B.virus2.len)
					for (var/ID in B.virus2)
						var/datum/disease2/disease/V = B.virus2[ID]
						infect_virus2(src,V)

			else if(istype(O,/obj/decal/cleanable/mucus))
				var/obj/decal/cleanable/mucus/M = O
				if(isnull(M.virus2))
					M.virus2 = list()
				if(M.virus2.len)
					for (var/ID in M.virus2)
						var/datum/disease2/disease/V = M.virus2[ID]
						infect_virus2(src,V)

	if(virus2.len)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
				CRASH("virus2 nulled before calling activate()")
			else
				V.process(src)
			// activate may have deleted the virus
			if(!V) continue

			// check if we're immune
			var/list/common_antibodies = V.antigen & src.antibodies
			if(common_antibodies.len)
				V.dead = 1

	if(immunity > 0.2 * immunity_norm && immunity < immunity_norm)
		immunity = min(immunity + 0.25, immunity_norm)

	if(life_tick % 5 && immunity < 15 && chem_effects[CE_ANTIVIRAL] < VIRUS_COMMON && !virus2.len)
		var/infection_prob = 15 - immunity
		var/turf/simulated/T = loc
		if(istype(T))
			infection_prob += T.dirt
		if(prob(infection_prob))
			infect_mob_random_lesser(src)


/datum/reagent/blood/affect_touch(mob/living/carbon/M, alien, removed)
	.=..()
	if(data && data["virus2"])
		var/list/vlist = data["virus2"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if(V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())
	if(data && data["antibodies"])
		M.antibodies |= data["antibodies"]

/datum/reagent/blood/affect_ingest(mob/living/carbon/M, removed)
	.=..()
	if(data && data["virus2"])
		var/list/vlist = data["virus2"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if(V && V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())

/datum/reagent/blood/mix_data(newdata, newamount)
	if(!islist(newdata))
		return
	if(!data["virus2"])
		data["virus2"] = list()
	data["virus2"] |= newdata["virus2"]
	if(!data["antibodies"])
		data["antibodies"] = list()
	data["antibodies"] |= newdata["antibodies"]

/mob/living/carbon/take_blood(obj/item/reagent_containers/container, amount)
	.=..()
	var/datum/reagent/blood/B = get_blood(container.reagents)
	if (!B.data["virus2"])
		B.data["virus2"] = list()
	B.data["virus2"] |= virus_copylist(virus2)
	B.data["antibodies"] = antibodies

/mob/living/carbon/inject_blood(datum/reagent/blood/injected, amount)
	.=..()
	var/list/sniffles = virus_copylist(injected.data["virus2"])
	for(var/ID in sniffles)
		var/datum/disease2/disease/sniffle = sniffles[ID]
		infect_virus2(src, sniffle, 1)

	if(injected.data["antibodies"] && prob(5))
		antibodies |= injected.data["antibodies"]

/datum/reagent/blood/affect_ingest(mob/living/carbon/M, removed)
	.=..()
	if(data && data["virus2"])
		var/list/vlist = data["virus2"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if(V && V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())

/mob/living/carbon/Bump(atom/movable/AM, yes)
	.=..()
	if(istype(AM, /mob/living/carbon) && prob(10))
		src.spread_disease_to(AM, "Contact")

/mob/living/carbon/human/attack_hand(mob/living/carbon/M as mob)
	.=..()
	if(istype(M,/mob/living/carbon))
		M.spread_disease_to(src, "Contact")

/mob/living/carbon/human/handle_post_breath(datum/gas_mixture/breath)
	.=..()
	//spread some viruses while we are at it
	if(breath && !internal && virus2.len > 0 && prob(10))
		for(var/mob/living/carbon/M in view(1,src))
			src.spread_disease_to(M)
