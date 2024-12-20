/// List (string => integer). Map of descriptive words to the age threshhold to display these words. Age threshhold is the _highest_ age that can use this descriptor. Descriptors should make grammatical sense when used in the following sentence: "They are of [X] age for a [species]."
/datum/species/var/list/age_descriptors = list(
	"very young" = 20,
	"young" = 40,
	"moderate" = 60,
	"old" = 80,
	"very old" = 100,
	"ancient" = INFINITY
)


/// List (string => integer). Map of descriptive words to the age different threshhold to display these words. Age difference threshhold is the _highest_ number that can use this descriptor. Descriptors should make grammatical sence when used in the following sentence: "They are [X] you."
/datum/species/var/list/age_diff_descriptors = list(
	"much younger than" = -15,
	"younger than" = -10,
	"slightly younger than" = -5,
	"around the same age as" = 5,
	"slightly older than" = 10,
	"older than" = 15,
	"much older than" = INFINITY
)


/// Boolean. If set, allows other species to see age descriptions.
/datum/species/var/show_age_to_other_species = FALSE


/datum/species/proc/get_age_comparison_string(mob/living/carbon/human/observed, mob/living/carbon/human/observer)
	if (!age_descriptors || !age_diff_descriptors || !istype(observed) || observed.isSynthetic())
		return
	if (!show_age_to_other_species && name != observer.get_species())
		return

	var/observed_real_age = observed.age + observed.changed_age
	var/observer_real_age = observer.age + observer.changed_age
	var/age_diff
	var/age_percentile = round((observed_real_age / max_age) * 100)
	var/age_descriptor
	var/age_diff_descriptor

	for (var/descriptor in age_descriptors)
		if (age_percentile > age_descriptors[descriptor])
			continue
		age_descriptor = descriptor
		break
	if (!age_descriptor)
		age_descriptor = age_descriptors[length(age_descriptors)]

	if (istype(observer) && observed.get_species() == observer.get_species() && !observer.isSynthetic())
		age_diff = observed_real_age - observer_real_age
		for (var/descriptor in age_diff_descriptors)
			if (age_diff > age_diff_descriptors[descriptor])
				continue
			age_diff_descriptor = descriptor
			break
		if (!age_diff_descriptor)
			age_diff_descriptor = age_diff_descriptors[length(age_diff_descriptors)]

	var/datum/pronouns/pronouns = observed.choose_from_pronouns()
	if (age_diff_descriptor)
		return "[pronouns.He] [pronouns.is] of [age_descriptor] age for a [name], [age_diff_descriptor] you."
	else if (age_descriptor)
		return "[pronouns.He] [pronouns.is] of [age_descriptor] age for a [name]."
