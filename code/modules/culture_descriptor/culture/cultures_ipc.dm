
/singleton/cultural_info/culture/ipc
	name = CULTURE_ROOT
	description = "You are from Root, a forested super-Earth colonized by positronics in the Kernel system, 33 light years from Sol. \
	The planet is more than three times Earth's size, with a 28-hour day and a 412-day year. Fourteen continents and a 40% ocean cover \
	the surface; dust-and-metal rings are split by the tidally locked iron-nickel moon Akerta. Root was ignored by states and corporations \
	until the Positronic Union settled it in 2264, founding the capital 01 on the equator of the continent Kenurn. Cities are planned like \
	clockwork: maglev trams instead of roads, residential cells barely larger than a locker, and vast industrial sectors. Almost the entire \
	population is synthetic. Organic life suffers from volcanic and industrial pollution that barely affects positronics."
	language = LANGUAGE_EAL
	secondary_langs = list(
		LANGUAGE_HUMAN_EURO,
		LANGUAGE_HUMAN_CHINESE,
		LANGUAGE_HUMAN_ARABIC,
		LANGUAGE_HUMAN_INDIAN,
		LANGUAGE_HUMAN_IBERIAN,
		LANGUAGE_HUMAN_RUSSIAN,
		LANGUAGE_SPACER,
		LANGUAGE_SIGN
	)
	economic_power = 0.9

/singleton/cultural_info/culture/ipc/sanitize_name(new_name)
	return sanitizeName(new_name, allow_numbers = 1)
