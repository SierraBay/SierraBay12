#define HOME_SYSTEM_MEOT    "Meotourne"
#define HOME_SYSTEM_REPUBL  "Nova Respublica"

#define HUMAN_HOMES_TO_DELETE					list(HOME_SYSTEM_TERSTEN, \
													HOME_SYSTEM_AVALON, \
													HOME_SYSTEM_MIRANIA, \
													HOME_SYSTEM_NYX_BRINKBURN, \
													HOME_SYSTEM_NYX_KALDARK, \
													HOME_SYSTEM_NYX_ROANOK, \
													HOME_SYSTEM_NYX_YUKLIT, \
													HOME_SYSTEM_NYX_CASSER)
#define HUMAN_HOMES_TO_ADD						list(HOME_SYSTEM_MEOT, \
													HOME_SYSTEM_REPUBL)

/datum/map/New()
	available_cultural_info[TAG_HOMEWORLD] += HUMAN_HOMES_TO_ADD
	. = ..()

/datum/species/human/New()
	available_cultural_info[TAG_HOMEWORLD] += HUMAN_HOMES_TO_ADD
	..()
	available_cultural_info[TAG_HOMEWORLD] -= HUMAN_HOMES_TO_DELETE

/singleton/cultural_info/location/human/meotourne
	name = HOME_SYSTEM_MEOT
	distance = "23 light years"
	description = "Meotourne, the only planet in Delta Pavonis system, is a unique temperate world with its own ecosystem. \
	While a big chunk of its surface is a barren wasteland scorched by the star it's always facing, other areas are many other habitable, although never habitated and mostly unresearched, biomes with lush pine-like flora \
	of all kinds and no fauna to speak of. The story of its people, united by Belmeone Federation, is one of constant conflicts and a dozen wars; all this kept Meonians to foster their own \
	military and diplomatic schools over many years. Currently struggling in holding influence against its own corporations, Federation is largely known to humanity \
	as frontier's largest exporter of quality weaponry, skilled generals and shrewd diplomats. <br><br>\
	People of Meotourne are in all kinds different, although they tend to share allegiance to their national heritage and a mostly fake friendly attitude to cover their distrust. \
	Those who leave the home to explore humanity's core are often corporate workers or militarymen."
	capital = "Treone"
	economic_power = 1.1
	ruling_body = "Belmeone Federation"

/singleton/cultural_info/location/human/pospolita
	name = HOME_SYSTEM_REPUBL
	distance = "23 light years"
	description = "Nova Respublica is, in fact, not much more than several small planetary and asteroid resource extraction colonies and many space installations across Delta Pavonis and Kestalia systems. \
	Once united as means for simple survival, over time it became a large entity as lots of hardy spacers joined the fledgling colonial alliance. \
	After several unsuccessful wars with its neigbours, especially the planet of Meotourne, the Republic was never viewed as a major player again to this day. \
	Unsurprisingly, these so-called 'free people of the frontier' resent the idea of becoming a part of SCG themselves and actively discourage others from it. <br><br>\
	Republicans are often seen as simple and hard-working people, primarily specialised in heavy industry. \
	As with any outer-rim spacers they're knit closely with family relations, with said family taking precedence when moving within their societal hierarchy."
	capital = "Redsands Station"
	economic_power = 0.8
	ruling_body = "Nova Respublica"

#undef HOME_SYSTEM_MEOT
#undef HOME_SYSTEM_REPUBL

#undef HUMAN_HOMES_TO_DELETE
