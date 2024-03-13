#define CULTURE_HUMAN_KIPERIUSMINER     "Kiperius, Miner Colony"
#define CULTURE_HUMAN_KIPERIUSPRISONER  "Kiperius, Prison"
#define CULTURE_HUMAN_MEOT              "Meonian"
#define CULTURE_HUMAN_REPUBL            "Republican"

#define HUMAN_CULTURES_TO_DELETE					list(CULTURE_HUMAN_AVACOMMON, \
														CULTURE_HUMAN_AVANOBLE, \
														CULTURE_HUMAN_LORRIMAN, \
														CULTURE_HUMAN_LORDUP, \
														CULTURE_HUMAN_LORDLOW, \
														CULTURE_HUMAN_MIRANIAN, \
														CULTURE_HUMAN_NYXIAN)
#define HUMAN_CULTURES_TO_ADD						list(CULTURE_HUMAN_KIPERIUSMINER, \
														CULTURE_HUMAN_KIPERIUSPRISONER, \
														CULTURE_HUMAN_MEOT, \
														CULTURE_HUMAN_REPUBL)

/datum/map/New()
	available_cultural_info[TAG_CULTURE] += HUMAN_CULTURES_TO_ADD
	. = ..()

/datum/species/human/New()
	available_cultural_info[TAG_CULTURE] += HUMAN_CULTURES_TO_ADD
	..()
	available_cultural_info[TAG_CULTURE] -= HUMAN_CULTURES_TO_DELETE

/singleton/cultural_info/culture/human/kiperius_miner
	name = CULTURE_HUMAN_KIPERIUSMINER
	nickname = "Киперианец, шахтёр"
	description = "You were born in the golden age of the Kiperius. Probably, as a child of workers family or one of the many vat-grown kids, used by corpos for various labor. \
	Either way, you were pretty much used to harsh conditions of the planet and it logistical problems as well. You spent most of your life inside the dark, steel corridors of underground outposts, \
	rarely seeing any sunlight or stars. Thanks to the people that lived by your side - you also pretty used to hard work, most of the time spending HOURS on polishing one single thing. Someone can even call you workaholic. \
	When economical crisis hit the door, your familiy somehow managed to leave planet, bringing aside pretty big amount of phoron crystals, which helped to get new home and probably some kind of long-term buisness."
	economic_power = 1.4

/singleton/cultural_info/culture/human/kiperius_prisoner
	name = CULTURE_HUMAN_KIPERIUSPRISONER
	nickname = "Киперианец, заключённый"
	description = "You are from Kiperius, biggest prison in entire SCG. Not important were you brought here due to some government disagreements, or borned inside its underground caves - this planet changed you alot. \
	Living under always present death scythe, people from todays 'Ice Cage' is either broken and silent, or mad and mute. There is no sun, no grass, and no trace of the planet founders. \
	Being independent and forgotten in the same time brings us to the point, where most of the newborn generations not only can't speak due to the fact there is no one who can say them how, \
	but also don't know anything about SolGov itself. If you somehow leaved Kiperius - you are probably not the same person that entered it anymore. Well, if you even BEEN a person. \
	Kiperians are pretty cold people, not much into the all this chit-chat thing. The only thing that they know in life - is work for the sake of their dying home."
	economic_power = 0.8
	language = LANGUAGE_SIGN

/singleton/cultural_info/culture/human/meotourne
	name = CULTURE_HUMAN_MEOT
	nickname = "Меонец"
	description = "You are from Meotourne, one of the frontier worlds relatively close to humanity's core. \
	Being from either authoritarian city of Treone, industrialist Loinmont, liberalist Algonquin, shiny new Manhattan or one of tiny villages in between, your fellows are \
	mostly warm and welcoming to most, but distrustful to anyone deep inside. \
	Meonians are often seen as resourceful, diplomatic and highly aggressive in any hostilities. \
	Although recently they're seen in both SCG and GCC more often due to corporate influence on their homeworld, the nation still stands relatively unknown by most."
	economic_power = 1
	language = LANGUAGE_SPACER

/singleton/cultural_info/culture/human/pospolita
	name = CULTURE_HUMAN_REPUBL
	nickname = "Республиканец"
	description = "You are from Nova Respublica, the tight conglomerate of several frontier colonies and many space installations relatively close to humanity's core. \
	Republic was never exactly known for any of its strong suits, although it owes its sovereign existence to its aggressive expansion during the early 23rd century. \
	Nowadays it stands peacefully, having decent relations with frontier nations it once called enemies, and even incorporating some of them into itself. \
	With most of its space running dry of minerals from almost two centuries of mining, Republic struggles to reform itself into a less industrialist economy."
	economic_power = 0.8
	language = LANGUAGE_SPACER

#undef CULTURE_HUMAN_KIPERIUSMINER
#undef CULTURE_HUMAN_KIPERIUSPRISONER
#undef CULTURE_HUMAN_MEOT
#undef CULTURE_HUMAN_REPUBL

#undef HUMAN_CULTURES_TO_DELETE
#undef HUMAN_CULTURES_TO_ADD
