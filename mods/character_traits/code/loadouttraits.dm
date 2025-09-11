/singleton/species/proc/get_selectable_mod_traits()
	var/list/allowed_mod_traits = list()
	for (var/mod_trait_id in GLOB.all_mod_traits)
		var/datum/mod_trait/T = GLOB.all_mod_traits[mod_trait_id]
		if (!T.name)
			continue
		if (T.species_allowed && !(name in T.species_allowed))
			continue
		if (T.subspecies_allowed && !(get_bodytype() in T.subspecies_allowed))
			continue
		if (LAZYISIN(traits, T.type))
			continue
		allowed_mod_traits[T.name] = T
	return allowed_mod_traits

/obj/item/storage/box/asthma
	name = "box of asthma autoinjectors"
	desc = "A compact case containing emergency autoinjectors. Issued to patients with asthma for rapid relief of attacks."
	icon_state = "box"
	startswith = list(/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/dexalin = 5)

/datum/gear/dexalin_box
	display_name = "Diseases — Asthma Kit"
	path = /obj/item/storage/box/asthma
	cost = 2
	allowed_mod_traits = list("Disease - Asthma")

/obj/item/reagent_containers/pill/synaptizine
	name = "Synaptizine (1u)"
	desc = "Commonly used to treat hallucinations. Prescribed."
	icon_state = "pill3"

/obj/item/reagent_containers/pill/synaptizine/New()
	..()
	reagents.add_reagent(/datum/reagent/synaptizine, 1)
	color = reagents.get_color()

/obj/item/storage/pill_bottle/synaptizine
	name = "prescribed pill bottle (Synaptizine)"
	desc = "A pillbox containing Synaptizine pills. Prescription only. Used to suppress hallucinations and stabilize neural function."
	startswith = list(/obj/item/reagent_containers/pill/synaptizine = 4)
	wrapper_color = COLOR_CYAN_BLUE

/datum/gear/synaptizine_box
	display_name = "Diseases — Hallucinations Kit"
	path = /obj/item/storage/pill_bottle/synaptizine
	cost = 2
	allowed_mod_traits = list("Disease - Hallucinations")
