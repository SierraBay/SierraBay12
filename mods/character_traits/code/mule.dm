/datum/mod_trait/mule/
	subspecies_allowed = list(SPECIES_MULE)

/datum/mod_trait/mule/mutate_head
	name = "Mule - Mutated Head"
	description = "Ваша голова мутирована"

/datum/mod_trait/mule/mutate_head/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_HEAD)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_torso
	name = "Mule - Mutated Torso"
	description = "Ваше туловище мутировано."

/datum/mod_trait/mule/mutate_torso/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_CHEST)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_pelvis
	name = "Mule - Mutated Pelvis"
	description = "Ваш таз мутирован."

/datum/mod_trait/mule/mutate_pelvis/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_GROIN)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_arm_left
	name = "Mule - Mutated Left Arm"
	description = "Ваша левая рука мутирована."

/datum/mod_trait/mule/mutate_arm_left/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_L_ARM)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_arm_right
	name = "Mule - Mutated Right Arm"
	description = "Ваша правая рука мутирована."

/datum/mod_trait/mule/mutate_arm_right/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_R_ARM)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_hand_left
	name = "Mule - Mutated Left Hand"
	description = "Ваша левая ладонь мутирована."

/datum/mod_trait/mule/mutate_hand_left/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_L_HAND)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_hand_right
	name = "Mule - Mutated Right Hand"
	description = "Ваша правая ладонь мутирована."

/datum/mod_trait/mule/mutate_hand_right/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_R_HAND)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_leg_left
	name = "Mule - Mutated Left Leg"
	description = "Ваша левая нога мутирована."

/datum/mod_trait/mule/mutate_leg_left/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_L_LEG)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_leg_right
	name = "Mule - Mutated Right Leg"
	description = "Ваша правая нога мутирована."

/datum/mod_trait/mule/mutate_leg_right/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_R_LEG)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_foot_left
	name = "Mule - Mutated Left Foot"
	description = "Ваша левая ступня мутирована."

/datum/mod_trait/mule/mutate_foot_left/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_L_FOOT)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()

/datum/mod_trait/mule/mutate_foot_right
	name = "Mule - Mutated Right Foot"
	description = "Ваша правая ступня мутирована."

/datum/mod_trait/mule/mutate_foot_right/apply_trait(mob/living/carbon/human/H)
	var/obj/item/organ/external/O = H.get_organ(BP_R_FOOT)
	if(O && !BP_IS_ROBOTIC(O))
		O.mutate()
