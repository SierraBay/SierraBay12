/datum/species/machine
	spawn_flags = SPECIES_CAN_JOIN | SPECIES_NO_FBP_CONSTRUCTION

/datum/species/diona
	spawn_flags = SPECIES_CAN_JOIN | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN

// We don't have them in lore

#ifdef SPECIES_TAJARA

/datum/species/tajaran
	spawn_flags = SPECIES_IS_RESTRICTED

#endif


/datum/species/human/mule
	spawn_flags = SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_NO_ROBOTIC_INTERNAL_ORGANS
