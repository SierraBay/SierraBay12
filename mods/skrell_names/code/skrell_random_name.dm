/// Skrell names come from /singleton/skrell_name_generator; the core syllable
/// generator is the fallback.
/datum/language/skrell/get_random_name(gender, name_count = 2, syllable_count = 4, syllable_divisor = 2)
	var/singleton/skrell_name_generator/generator = GET_SINGLETON(/singleton/skrell_name_generator)
	return generator.make_name(name_count) || ..()
