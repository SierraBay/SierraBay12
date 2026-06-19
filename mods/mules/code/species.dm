/singleton/species/human/mule
	name = SPECIES_MULE
	name_plural = "Mules"
	description = "Мулы, это подвид людей, имеющих предрасположенность к псионике, \
	но населяющие социальное дно, ввиду своих видимых мутаций и измененному виду. \
	Часто, не имеющие постоянного трудоустройства или даже, крыши над головой, о них \
	принято судить как о предрасположенным к совершению преступления, а так же, как тех \
	кто может злоупотреблять своим псионическим потенциалом."
	preview_icon = 'icons/mob/human_races/species/human/subspecies/mule_preview.dmi'
	icobase = 'mods/mules/icons/mule_body.dmi'
	deform = 'mods/mules/icons/mule_deformed.dmi'

	spawn_flags =   SPECIES_CAN_JOIN | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_NO_ROBOTIC_INTERNAL_ORGANS
	brute_mod =     1.25
	burn_mod =      1.25
	oxy_mod =       1.25
	toxins_mod =    1.25
	radiation_mod = 1.25
	flash_mod =     1.25
	blood_volume =  SPECIES_BLOOD_DEFAULT * 0.85
	min_age =       18
	max_age =       45
	strength =      STR_LOW

	available_cultural_info = list(
		TAG_FACTION = list("Люмпен")
	)

	extended_cultural_info = list(
		TAG_FACTION = list("Люмпен")
	)
