/datum/species
	var/virus_immune

/datum/species/adherent
	virus_immune = 1

/datum/species/machine
	virus_immune = 1

/datum/species/shapeshifter/promethean
	virus_immune = 1

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
	if(LAZYLEN(M.virus2))
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



/singleton/reaction/virus_food
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
			addtimer(new Callback(src, PROC_REF(on_completion), rand(30,40)))

/datum/goal/sickness/on_completion()
	if(!announced)
		announced = TRUE
		var/datum/mind/mind = owner
		to_chat(mind.current, SPAN_DANGER("You don't feel so good..."))

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
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	var/list/datum/disease2/disease/virus2 = list()


/obj/decal/cleanable/mucus/New()
	. = ..()
	addtimer(new Callback(src, PROC_REF(set_dry), 1), DRYING_TIME * 2)

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


/datum/controller/subsystem/supply
	var/list/sold_virus_strains = list()

/datum/reagent/blood/affect_touch(mob/living/carbon/M, alien, removed)
	.=..()
	if(data && data["virus2"])
		var/list/vlist = data["virus2"]
		if(LAZYLEN(vlist))
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
		if(LAZYLEN(vlist))
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

/mob/living/carbon/human/handle_post_breath(datum/gas_mixture/breath)
	.=..()
	//spread some viruses while we are at it
	if(breath && !internal && virus2.len > 0 && prob(10))
		for(var/mob/living/carbon/M in view(1,src))
			src.spread_disease_to(M)
/datum/sprite_accessory/facial_hair/ipc/scg
  name = "SCG"
  icon = "ipc_monitor_pics/icons/ipc_pics.dmi"
  icon_state = "ipc_scg"

/datum/sprite_accessory/facial_hair/ipc/scg/iccg
  name = "ICCG"
  icon_state = "ipc_iccg"

/datum/sprite_accessory/facial_hair/ipc/scg/minion
  name = "Minion"
  icon_state = "ipc_minion"

/datum/sprite_accessory/facial_hair/ipc/scg/loading
  name = "Loading"
  icon_state = "ipc_loading"

/datum/sprite_accessory/facial_hair/ipc/scg/check
  name = "Check Mark"
  icon_state = "ipc_check"

/datum/sprite_accessory/facial_hair/ipc/scg/affir
  name = "Affirmative"
  icon_state = "ipc_affir"

/datum/sprite_accessory/facial_hair/ipc/scg/earth
  name = "Earth"
  icon_state = "ipc_earth"

/datum/sprite_accessory/facial_hair/ipc/scg/calend
  name = "Calendar"
  icon_state = "ipc_calend"
