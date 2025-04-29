/datum/mod_trait/unathi/
	species_allowed = list(SPECIES_UNATHI)

/datum/mod_trait/unathi/slow_regen
	name = SPECIES_UNATHI + " - slow regeneration"
	description = "Не может отрастить конечность в течении смены, регенерация все еще быстрее чем у человека. Меньше расовых негативных последствий от отсутствия пищи."
	incompatible_traits = list(/datum/mod_trait/unathi/no_regen)

/datum/mod_trait/unathi/slow_regen/apply_trait(mob/living/carbon/human/H)
	H.species.remove_base_auras(H)
	if(H.species.type == /datum/species/unathi/yeosa)
		H.species.base_auras = list(/obj/aura/regenerating/human/unathi_slow_regen/yeosa)
	else
		H.species.base_auras = list(/obj/aura/regenerating/human/unathi_slow_regen)
	H.species.add_base_auras(H)
	to_chat(H, SPAN_NOTICE("Активирована черта персонажа <b>[name]</b>."))

/datum/mod_trait/unathi/no_regen
	name = SPECIES_UNATHI + " - no regeneration"
	description = "Скорость регенерации как у человека, отсутствуют расовые негативные последствия от нехватки пищи."
	incompatible_traits = list(/datum/mod_trait/unathi/slow_regen)

/datum/mod_trait/unathi/no_regen/apply_trait(mob/living/carbon/human/H)
	H.species.remove_base_auras(H)
	H.species.base_auras = list()
	to_chat(H, SPAN_NOTICE("Активирована черта персонажа <b>[name]</b>."))


/obj/aura/regenerating/human/unathi_slow_regen
	regen_message = "<span class='warning'>You feel a soothing sensation as your ORGAN mends...</span>"
	ignore_tag = BP_HEAD

/obj/aura/regenerating/human/unathi_slow_regen/can_toggle()
	return FALSE

/obj/aura/regenerating/human/unathi_slow_regen/can_regenerate_organs()
	return can_toggle()

/obj/aura/regenerating/human/unathi_slow_regen/aura_check_life()
	var/mob/living/carbon/human/H = user
	if (!istype(H) || H.stat == DEAD)
		return AURA_CANCEL
	if (H.stasis_value)
		return AURA_FALSE
	if (H.nutrition < 50)
		H.apply_damage(1, DAMAGE_TOXIN)
		H.adjust_nutrition(3)
		return AURA_FALSE
	nutrition_damage_mult = 1
	brute_mult = 1
	organ_mult = 2
	grow_chance = 0
	var/obj/machinery/optable/optable = locate() in get_turf(H)
	if (optable?.suppressing && H.sleeping)
		nutrition_damage_mult = 0.5
		brute_mult = 0.5
		organ_mult = 1

	return ..()

/obj/aura/regenerating/human/unathi_slow_regen/yeosa
	tox_mult = 1.5