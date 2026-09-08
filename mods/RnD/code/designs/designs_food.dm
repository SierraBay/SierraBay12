// Food replicator designs — printed in /obj/machinery/fabricator/food_replicator
// Each design consumes nutriment reagent from the replicator's internal beaker.

/datum/design/food
	build_type = FOOD_REPLICATOR
	time = 8
	category = list("Food")
	adjust_materials = FALSE

/datum/design/food/Fabricate(newloc, mat_efficiency, fabricator)
	var/obj/item/reagent_containers/food/F = ..()
	if(istype(F))
		F.fabricated = TRUE
	return F

// --- Skill-gated fabricated examine note ---

/obj/item/reagent_containers/food
	var/fabricated = FALSE

/obj/item/reagent_containers/food/examine(mob/user, distance, is_adjacent, infix, suffix)
	. = ..()
	if(fabricated && isliving(user))
		var/mob/living/L = user
		if(L.get_skill_value(SKILL_COOKING) >= SKILL_TRAINED)
			. += SPAN_NOTICE("Trained eye tells you this dish was synthesised by a replicator, not cooked by hand.")

// ---- Basic dishes ----

/datum/design/food/tofurkey
	id = "food_tofurkey"
	build_path = /obj/item/reagent_containers/food/snacks/sliceable/tofurkey
	chemicals = list(/datum/reagent/nutriment = 10)

/datum/design/food/soylentviridians
	id = "food_soylentviridians"
	build_path = /obj/item/reagent_containers/food/snacks/soylenviridians
	chemicals = list(/datum/reagent/nutriment = 6)

/datum/design/food/fries
	id = "food_fries"
	build_path = /obj/item/reagent_containers/food/snacks/fries
	chemicals = list(/datum/reagent/nutriment = 5)

/datum/design/food/soydope
	id = "food_soydope"
	build_path = /obj/item/reagent_containers/food/snacks/soydope
	chemicals = list(/datum/reagent/nutriment = 6)

/datum/design/food/ricepudding
	id = "food_ricepudding"
	build_path = /obj/item/reagent_containers/food/snacks/ricepudding
	chemicals = list(/datum/reagent/nutriment = 8)
