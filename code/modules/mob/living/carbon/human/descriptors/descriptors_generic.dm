/datum/mob_descriptor/height
	name = "Рост"
	standalone_value_descriptors = list(
		"очень низкий",
		"низкий",
		"средний рост",
		"высокий",
		"очень высокий"
		)
	comparative_value_descriptor_equivalent = "around the same height as you"
	comparative_value_descriptors_smaller = list(
		"slightly shorter than you",
		"shorter than you",
		"much shorter than you",
		"tiny and insignificant next to you"
		)
	comparative_value_descriptors_larger = list(
		"slightly taller than you",
		"taller than you",
		"much taller than you",
		"towering over you"
		)
	var/list/scale_effect = list(
		SPECIES_HUMAN = list(-7, -4, 0, 4, 7)
	)

/datum/mob_descriptor/build
	name = "Телосложение"
	comparative_value_descriptor_equivalent = "around the same build as you"
	standalone_value_descriptors = list(
		"тощий",
		"худой",
		"среднее телосложение",
		"хорошо сложенный",
		"полный"
		)
	comparative_value_descriptors_smaller = list(
		"a bit smaller in build than you",
		"smaller in build than you",
		"much smaller in build than you",
		"dwarfed by your bulk"
		)
	comparative_value_descriptors_larger = list(
		"slightly larger than you in build",
		"built larger than you",
		"built much larger than you",
		"dwarfing you"
		)
	var/list/scale_effect = list(
		//SPECIES_TAG_DEFINE = list(lowest, low, middle, high, highest)<,>
	)
