#define CULTURE_HUMAN_KIPERIUSMINER     "Kiperius, Miner Colony"
#define CULTURE_HUMAN_KIPERIUSPRISONER  "Kiperius, Prison"
#define CULTURE_HUMAN_MEOT              "Meonian"
#define CULTURE_HUMAN_REPUBL            "Republican"
#define CULTURE_HUMAN_MARTIAN_FD        "Martian, Surfacer"
#define CULTURE_HUMAN_MARSTUN_FD        "Martian, Tunneller"
#define CULTURE_HUMAN_LUNAPOOR_FD       "Luna, Lower Class"
#define CULTURE_HUMAN_LUNARICH_FD       "Luna, Upper Class"
#define CULTURE_HUMAN_VENUSIAN_FD       "Venusian, Zoner"
#define CULTURE_HUMAN_VENUSLOW_FD       "Venusian, Surfacer"

#define HUMAN_CULTURES_TO_DELETE					list(CULTURE_HUMAN_AVACOMMON, \
														CULTURE_HUMAN_AVANOBLE, \
														CULTURE_HUMAN_LORRIMAN, \
														CULTURE_HUMAN_LORDUP, \
														CULTURE_HUMAN_LORDLOW, \
														CULTURE_HUMAN_MIRANIAN, \
														CULTURE_HUMAN_MARTIAN, \
														CULTURE_HUMAN_MARSTUN, \
														CULTURE_HUMAN_LUNAPOOR, \
														CULTURE_HUMAN_LUNARICH, \
														CULTURE_HUMAN_VENUSIAN, \
														CULTURE_HUMAN_VENUSLOW, \
														CULTURE_HUMAN_NYXIAN)
#define HUMAN_CULTURES_TO_ADD						list(CULTURE_HUMAN_KIPERIUSMINER, \
														CULTURE_HUMAN_KIPERIUSPRISONER, \
														CULTURE_HUMAN_MEOT, \
														CULTURE_HUMAN_MARTIAN_FD, \
														CULTURE_HUMAN_MARSTUN_FD, \
														CULTURE_HUMAN_LUNAPOOR_FD, \
														CULTURE_HUMAN_LUNARICH_FD, \
														CULTURE_HUMAN_VENUSIAN_FD, \
														CULTURE_HUMAN_VENUSLOW_FD, \
														CULTURE_HUMAN_REPUBL)

/datum/map/New()
	available_cultural_info[TAG_CULTURE] += HUMAN_CULTURES_TO_ADD
	. = ..()

/datum/species/human/New()
	available_cultural_info[TAG_CULTURE] += HUMAN_CULTURES_TO_ADD
	..()
	available_cultural_info[TAG_CULTURE] -= HUMAN_CULTURES_TO_DELETE

//OUR OWN CULTURES//
//START//

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

//END//

//REWRITED SIERRA AND OFF-BAY ONES//
//START//
/singleton/cultural_info/culture/human/martian_surfacer_alt
	name = CULTURE_HUMAN_MARTIAN_FD
	nickname = "Марсианин, Монсийец"
	description = "Вам посчастливилось оказаться среди счастливчиков, родившихся на поверхности, либо вы зарабатываете достаточно, чтобы поселиться там. \
	Здесь - люди не нуждаются практически ни в чём. Государство обеспечивает их абсолютно всеми благами, спонсируя любую их деятельность. \
	Это олигархи и прочие сливки общества, едва ли видевшие обратную сторону медали. Впрочем, их нельзя назвать эгоистичными или самовлюблёнными, \
	ведь они прекрасно понимают, что их блага - это чужие слёзы и часы. Скорее, подобно своим предкам - Гидеонцам, они не спешат отказываться от \
	утопичной, комфортной жизни в пользу борьбы за равенство и справедливость. \
	------------------------------------------------------------------------------ \
	Не смотря на то, что Марс был колонизирован ещё двести с лишним лет назад, как и на Луне - жизнь вне специальных городов-куполов на нём невозможна. \
	Большая часть Монсийцев распределена между тремя локациями - Горой Олимп, Провинцией Фарсида и Кратером Эллады, в то время как остальные поселения - \
	это преимущественно коммерческие и административные зоны, или же крупные фермерские угодья."
	economic_power = 1

/singleton/cultural_info/culture/human/martian_tunneller_alt
	name = CULTURE_HUMAN_MARSTUN_FD
	nickname = "Марсианин, Туннелер"
	description = "Так уж сложилось, что вы угодили сюда, на самое дно ИХ \"утопического\" мира - в старые рабочие туннели. \
	Так называемое \"временное\" решение вопроса работы и проживания, которое покинули с возведением первых белых шпилей на поверхности Марса. \
	Теперь, здесь живут лишь бедняки и нелегальные деятели, что сыты по горло подобной \"платой\" за собственный труд. \
	И тем не менее, они всё равно продолжают работать на неродивое государство, не только производя больше половины всех бытовых товаров \
	планеты, но также занимаясь и добычей таких жизненноважных ресурсов как \"Марсианский лёд\". Не потому, что верят в то, что ситуация наладится, \
	а потому что иных вариантов, кроме как податься в Фронтир - у них нет. А если кого они и не любят больше богачей - так это \"иностранцев\". \
	Туннелеры - ворчливые скряги, привыкшие считать каждый таллер в своём кармане. Они упрямы, горделивы, и предпочитают стоять на своём до момента, \
	пока их опоннент не признает их правоту или не начнёт молить о пощаде."
	economic_power = 0.9

/singleton/cultural_info/culture/human/luna_poor_alt
	name = CULTURE_HUMAN_LUNAPOOR_FD
	nickname = "Селениан, Гетто"
	description = "Вы родом с Луны - естественного спутника Земли, где своё гнёздышко свили известнейшие \
	личности корпоративной индустрии. К сожалению, вы совершенно точно к ним не относитесь... \
	Не смотря на то, что Луна носит гордое звание культурной столицы Сола, вполне обыденным явлением здесь \
	являются бесхозные рабочие и мафиози, что по-своему пытаются струсить с вас денег, да побольше. \
	Больше половины населения спутника находится за чертой бедности, пребывая в постоянных конфликтах друг с другом. \
	Банды сражаются за территорию, наёмники выполняют грязную работу для \"Конгломерата Четырёх\", а хакеры снабжают их информацией \
	и новыми контрактами. \
	------------------------------------------------------------------------------ \
	Здесь нет хороших и плохих, есть только те, кто едят и те кто сдыхают с голоду. Если верхушка рвёт глотки \
	ради статуса и славы, то здесь это делают из чистого желания жить, ведь так и устроены \"подворотни\". \
	Если вам удалось дожить хотя бы до двадцати и выбраться из этой дыры - то это действительно достижение. Для кого-то. \
	Местные же, вероятно, назовут вас просто трусом."
	economic_power = 1
	language = LANGUAGE_HUMAN_SELENIAN

/singleton/cultural_info/culture/human/luna_rich_alt
	name = CULTURE_HUMAN_LUNARICH_FD
	nickname = "Селениан, Звёздое дитя"
	description = "Вы родом с Луны - естественного спутника Земли, где своё гнёздышко свили известнейшие \
	личности корпоративной индустрии. Вероятнее всего, вы являетесь частью какой-то богатой династии, или  \
	состоите в одной из четырёх крупнейших корпораций на средних позициях и выше. Вам не приходиться жаловаться \
	на недостаток денег, но тем не менее, вокруг вас постоянно крутятся те, кто хотят эти деньги отобрать. \
	С самого рождения вы впутаны в их \"Игру\". Интриги, политические манёвры, предательства и пособничество криминалитету - \
	это то, чем живёт местная элита. Так уж тут заведено, что те, кто не готов идти по чужим головам - всегда будут оставаться на дне. \
	------------------------------------------------------------------------------ \
	Вероятно, вы крайне начитанный и умный человек, посвещавший не мало времени своему культурному развитию и различного рода творчеству. \
	Это отражается не только в ваших взглядах на мир, но и в характере. Многие отмечают, что звёздные дети персоны крайне меркантильные, мелочные, и капризные."
	economic_power = 1.3
	language = LANGUAGE_HUMAN_SELENIAN

/singleton/cultural_info/culture/human/venusian_upper_alt
	name = CULTURE_HUMAN_VENUSIAN_FD
	nickname = "Венерианец, житель \"Зоны\""
	description = "Если Марс административная столица, а Луна культурная - то Венеру можно по-праву назвать туристическим центром. \
	Не смотря на мёртвые пустоши, покрывающие всю планету, её величественные пузыри, парящие среди облаков ежемесячно привлекают десятки отдыхающих. \
	Для многих, Венера является не столько местом работы, сколько жилищем. Под её куполами располагаются целые районы, состоящие исключительно из \
	особняков высокопставленных офицеров, государственных представителей и глав корпораций. По этой же причине, не редко именно данная планета \
	становится центров для переговоров и решения важных дипломатических вопросов. Уровень преступности здесь, в практически полностью изолированной среде - \
	близится к нулю. И тем не менее, олигархи не чураются меряться размерами своих частных дивизионов, чаще всего состоящих из контрактников \"PCRC\". \
	------------------------------------------------------------------------------ \
	Какой-то устоявшейся бюрократической цепочки, законов, или вида управления на Венере нет, ведь каждая Зона(за некоторыми исключениями) уже давно \
	выкуплена частными предпринимателями и богатыми семьями, что сами обеспечивают своё снабжение, безопасность, и соблюдение прав гражданина. \
	Поэтому, средний класс, чаще всего, работает в соответствующих своим \"владельцам\" сферах, будь то пансионаты, казино, или огромные клубы. \
	Венерианцы взрощены культурой потребления, и поэтому часто ждут того же уровня жизни от других уголков галактики."
	economic_power = 1.4

/singleton/cultural_info/culture/human/venusian_surfacer_alt
	name = CULTURE_HUMAN_VENUSLOW_FD
	nickname = "Венерианец, житель поверхности"
	description = "Так уж сложилось, что вы родились здесь, глубоко в пучинах Венеры, среди потомственных должников. \
	Пещеры, что раньше служили способом выкупить свою шкуру у корпоратов, ныне являются главной производственной мощностью всей планеты. \
	Многие из здешний вовсе давно позабыли то, как они здесь оказались и ради чего пашут каждый день, передавая свои кредитные обязательства \
	от деда к отцу, и от отца к сыну. Многие из сегодняшних \"поверхностников\" вовсе не видели внешнего мира, собирая картину о нём по мусору, \
	что поступает сюда с верхов. \
	------------------------------------------------------------------------------ \
	Жителей этих старых шахт можно охарактеризовать как крайне трудолюбивых, справедливых мужей и женщин, что чтят традиции своих предков и вкладывают \
	всего себя в превращении этих ветхих тоннелей в прекрасный сад для своих будущих детей. Впрочем, как бы демократичны и уверены в себе они не были, \
	едва ли живущие там, в облаках, будут согласны поделиться с шахтёрами частичкой своей роскоши. И всё же, те не оставляют своих попыток достучаться до правительства."
	economic_power = 0.9

#undef CULTURE_HUMAN_KIPERIUSMINER
#undef CULTURE_HUMAN_KIPERIUSPRISONER
#undef CULTURE_HUMAN_MEOT
#undef CULTURE_HUMAN_REPUBL
#undef CULTURE_HUMAN_MARTIAN_FD
#undef CULTURE_HUMAN_MARSTUN_FD
#undef CULTURE_HUMAN_LUNAPOOR_FD
#undef CULTURE_HUMAN_LUNARICH_FD
#undef CULTURE_HUMAN_VENUSIAN_FD
#undef CULTURE_HUMAN_VENUSLOW_FD

#undef HUMAN_CULTURES_TO_DELETE
#undef HUMAN_CULTURES_TO_ADD
