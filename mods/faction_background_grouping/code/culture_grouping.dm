#define CULTURE_HUMAN_CONFED_NOVOZEM "Novozem"
#define CULTURE_HUMAN_CONFED_PROVIDENCE_NOMAD "Providence Nomad"
#define CULTURE_HUMAN_CONFED_PROVIDENCE_COLONIST "Providence Colonist"

#define HOME_SYSTEM_AMELIA "Amelia"
#define HOME_SYSTEM_PUTKARI "Putkari"
#define HOME_SYSTEM_QABIL "Qabil"
#define HOME_SYSTEM_PENGLAI "Penglai"
#define HOME_SYSTEM_PROVIDENCE "Providence"
#define HOME_SYSTEM_VALY "Valy"
#define HOME_SYSTEM_NOVAYA_ZEMLYA "Novaya Zemlya"

/singleton/cultural_info
	var/faction

/singleton/cultural_info/location/New()
	..()
	if(ruling_body == "Центральное Правительство Солнечной Системы")
		faction = FACTION_SOL_CENTRAL
	else if(ruling_body == "Гильгамешская Колониальная Конфедерация")
		faction = FACTION_INDIE_CONFED
	else
		faction = ruling_body

// Оверрайды для места жительства
/singleton/cultural_info/location/human
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/earth
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/luna
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/venus
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/ceres
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/pluto
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/cetiepsilon
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/eos
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/saffar
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/pirx
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/tadmor
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/castilla
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/fosters
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/quig
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/human/tersten
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/lorriman
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/cinu
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/yuklid
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/lordania
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/kingston
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/location/kharmaani
	faction = FACTION_OTHER

/singleton/cultural_info/location/human/terra
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/amelia
	name = HOME_SYSTEM_AMELIA
	nickname = "Амелия"
	description = "Амелия в системе Сестрис обладает гравитацией, подобной земной, и горячей, плотной атмосферой - условия на поверхности пригодны для выживания, но некомфортны сами по себе, потому большинство поселений имеют контролируемый климат. В этих купольных городах жизнь, как правило, довольно приятна: Сент-Маргерит, первая колония, основанная в Сестрисе, сегодня является блестящим мегаполисом и финансовой столицей ГКК. Одним из других крупных поселений является Шартрез - город под открытым небом около относительно умеренного южного полюса Амелии, который может похвастаться крупнейшим ботаническим садом планеты, а также несколькими престижными университетами."
	capital = "Сент-Маргерит"
	distance = "18 световых лет"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/putkari
	name = HOME_SYSTEM_PUTKARI
	nickname = "Путкари"
	description = "Путкари - это суровая и скованная льдом планета в системе Барода на периферии человеческого космоса и центра ГКК. В прошлом амбициозный научный проект Терранского Содружества, пережившая десятилетия забвения и едва не погибшая, прежде чем стать одним из самых преданных и идеологически закаленных штатов Гильгамешской Колониальной Конфедерации. Сегодня этот мир представляет собой холодную, но уже пригодную к жизни планету, которая такой благодаря неистовому упорству её жителей и вложениям соседних колоний."
	capital = "Агни-Сити"
	distance = "~20 световых лет"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/qabil
	name = HOME_SYSTEM_QABIL
	nickname = "Кабиль"
	description = "Индустриальный мир Конфедерации, Кабиль в системе Альтаир прошел путь от бесконтрольной эксплуатации ресурсов компаниями свободной зоны Карвана до жесткого государственного режима после катастрофического разрушения спутника Хабиль. Несмотря на разреженную атмосферу и экстремальную опасность орбиты, заполненной высокоскоростными обломками, система остается одной из богатейших в Конфедерации (уступая лишь Сестрису и Гильгамешу). Экономика базируется на сверхприбыльной добыче минералов из недр расколотого спутника, напоминающего гигантскую разрезанную геоду."
	capital = "Мадинат-Аль-Хадид"
	distance = "17 световых лет"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/penglai
	name = HOME_SYSTEM_PENGLAI
	nickname = "Пэнглай"
	description = "Небольшой, каменистый и практически бесплодный мир, основанный китайской экспедицией как убежище в эпоху гибели Земли. Пэнглай в одноименной системе обладает специфической разреженной атмосферой, требующей от неподготовленного человека навыков дыхания в условиях высокогорья. Стратегическая значимость планеты для Конфедерации обусловлена колоссальными залежами редкоземельных металлов. Политическая интеграция в состав ГКК была добровольной и мотивированной вопросами выживания: после ухода Терранского Содружества колония столкнулась с критическим дефицитом продовольствия, который был восполнен за счет ресурсов Гильгамеша."
	capital = "Куньлунь"
	distance = "24 световых года"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/providence
	name = HOME_SYSTEM_PROVIDENCE
	nickname = "Провиденс"
	description = "Система Провиденс представляет собой уникальный кластер орбитальных поселений, основанный частными корпорациями в послевоенный период конфликта Ареса. Мощь Провиденса сосредоточена в трех гигантских станционных комплексах и развитой промышленной периферии. Экономическим ядром системы является Нью-Виктория - расположенный на окраине колоссальный добывающий узел, чей доступ к богатейшим астероидным полям сделал регион самым процветающим в Конфедерации по показателю дохода на душу населения, привлекая лучших металлургов со всех обитаемых миров.\n\nЭнергетическую независимость и туристическую привлекательность системы обеспечивает станция Нью-Вашингтон, развернутая на орбите Провиденс VII для переработки геотермальной энергии планеты и организации уникальных экскурсионных маршрутов к зонам тектонической активности. В свою очередь, станция Нуэво-Мексико, парящая над Провиденс I, выступает в роли передового научного форпоста. Благодаря тесному партнерству с Колониальным Флотом ГКК, станция получает неограниченное финансирование на исследовательские проекты, что гарантирует системе технологическое доминирование и стабильный приток инвестиций в долгосрочной перспективе."
	capital = "Нью-Виктория"
	distance = "15 световых лет"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/valy
	name = HOME_SYSTEM_VALY
	nickname = "Вали"
	description = "Вали - это суровый мир, основанный независимыми колонистами задолго до его принудительного включения в состав Гильгамешской Колониальной Конфедерации. Столица планеты, Хлидскьяльв, изначально задуманная как величественный венец освоения системы, сегодня превратилась в оплот скрытого сопротивления и главный индустриальный узел, где жизнь поддерживается масштабными установками жизнеобеспечения. Несмотря на экономическую стабильность и развитый аграрный сектор, планета несет на себе шрамы оккупации силами ГКК, которые вошли в систему под предлогом прекращения гражданской войны, но так и не покинули её. Жизнь на Вали требует постоянного использования дыхательных аппаратов вне защищенных городских зон, что сформировало у местных жителей привычку к аскетизму и глубокое недоверие к представителям власти, а недавнее сближение лидеров их движения за независимость с Альянсом Фронтира окончательно закрепило за выходцами из Хлидскьяльва репутацию неблагонадежных, но опасных противников порядков Конфедерации."
	capital = "Хлидскьяльв"
	distance = "19 световых лет"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/location/human/novaya_zemlya
	name = HOME_SYSTEM_NOVAYA_ZEMLYA
	nickname = "Новая Земля"
	description = "Новая Земля - холодная, бесплодная карликовая планета в системе Гильгамеш. Она была широко колонизирована и является крупным промышленным центром в Гильгамешской Колониальной Конфедерации. Из-за отсутствия атмосферы жители планеты размещаются либо под землей, в одном из многочисленных промышленных сооружений, выступающих из бесплодного ландшафта, либо в куполообразной столице Доноровке."
	capital = "Доноровка"
	distance = "22.5 световых года"
	ruling_body = "Гильгамешская Колониальная Конфедерация"
	faction = FACTION_INDIE_CONFED

// Оверрайды для культур ЦПСС
/singleton/cultural_info/culture/human/theia
	nickname = "Тейец"
	description = "Тея - это обитаемая система на рубежах Центрального Правительства Солнечной Системы, известная в первую очередь как штаб-квартира Третьего флота. Благодаря своему стратегическому расположению у гейтвея, ведущего к ряду ключевых фронтирных систем, Тея еще на раннем этапе освоения прослыла важным узловым пунктом, достойным защиты. Сегодня как военные, так и гражданские специалисты называют систему Тея своим домом, неустанно трудясь над поддержанием её статуса «Крепости ЦПСС»."
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/culture/human/plutonian
	nickname = "Плутонец"
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/culture/human/lorrimanian
	nickname = "Лорриманец"
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/culture/human/lord_upper
	nickname = "Лорданиец, неоаристократ"
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/culture/human/lord_lower
	nickname = "Лорданиец, низший класс"
	faction = FACTION_SOL_CENTRAL

/singleton/cultural_info/culture/human/nyxian
	nickname = "Никсиец"
	faction = FACTION_SOL_CENTRAL

// Оверрайды для культур ГКК (+ добавлены и переведены культуры с оффбэя)
/singleton/cultural_info/culture/human/confederate_terra
	nickname = "Терранец"
	description = "Вы родом из столицы ГКК - Терры, землеподобной планеты. Жители все еще оправляются после множества потрясений, главным ударом по экономике колонии стал Гайский конфликт, многие небольшие поселения, в которых просто закончились ресурсы, деньги или люди, были заброшены, а те, кто остался, устремились в города. Правительство ГКК старается \"оживить\" планету, выдавая кредиты и гранты отраслям экономики, дабы скорее оправдаться от конфликта. Тем не менее, жизнь идет своим чередом, хоть и не без труда, но народ Терры в целом демонстрирует определенную твердость духа и нежелание терпеть неудачи. Терранцы - это гордые, патриотичные люди, способные пережить любые невзгоды."
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_zemlya
	name = CULTURE_HUMAN_CONFED_NOVOZEM
	nickname = "Новозем"
	description = "Вы с небольшой планеты в системе Гильгамеш - Новая Земля. Все поселения подземные или находятся под куполами. Основной работой, которой занято население - это работа на заводах. Колония пережила потрясения, принесенные войной и сейчас медленно поправляется, благодаря завезенным мигрантам со всей ГКК. У Новоземцев существует крепкая культура профсоюзных движений. Новоземцы - гордые и крепкие как сталь."
	economic_power = 0.9
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_sestris
	nickname = "Сестриец"
	description = "Вы из Союза Сестриса и Братиса - второго члена-государства по политической и экономической мощи в ГКК после Гильгамеша.\nГраждане Сестриса в основном являются представителями среднего и высшего класса среди других гржаданк ГКК, многие из них являются представителями колониального флота. Те, кто родом из Амелии, в самом Сестрисе, чрезвычайно гордятся своим франкоязычным наследием, и многие из них сохраняют часть своих культурных корней."
	economic_power = 1.3
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_putkari
	nickname = "Путкари"
	description = "Вы родом с Путкари в системе Барода. Заселенная на волне экспансии Терранского Содружества, планета Путкари была покинута ЦПСС после его основания и оставлена на произвол судьбы. Принятая недавно созданной ГКК, Путкари с тех пор является лояльным и преданным членом Конфедерации. Крайне враждебно настроенные по отношению к ЦПСС with момента своего забвения, путкари наиболее активно выражают недовольство поражением в Гайском конфликте; многие из них призывают к ненависти и разжигают пламя войны в надежде однажды совершить акт возмездия."
	language = null
	economic_power = 0.7
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_altair
	nickname = "Альтаирец"
	description = "Вы с Альтаира. В прошлом имевшая статус особой экономической зоны, потеряла её после разрушения луны Кабиль, принесшей на Альтаир радикальные и более авторитарные изменения. Будучи одними из самых материально обеспеченных членов Конфедерации (не считая её Основателей), альтаирцы не слишком заинтересованы в делах Конфедерации в целом: большинство альтаирцев предпочитают работать в государственном секторе, например парамедиками или специалистами по обслуживанию инфраструктуры, в течение всего срока обязательной государственной службы, отказываясь от прохождения воинской службы."
	language = null
	economic_power = 1.0
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_penglai
	nickname = "Пэнлаец"
	description = "Вы с Пэнлая, традиционалистского мира в составе ГКК. Это небольшая планета с разреженной атмосферой, пригодной для дыхания местных жителей. Ее основной экономический вклад в Конфедерацию заключается в добыче редкоземельных элементов, которыми она богата. Пэнлай - еще одна колония, нуждавшаяся в поддержке после основания ЦПСС и получившей её вовремя от ГКК; она является удовлетворенным членом Конфедерации, сохраняя при этом собственные традиции."
	language = null
	economic_power = 0.8
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_valy
	nickname = "Валиец"
	description = "Вы с Вали, «паршивой овцы» Конфедерации. Вали была включена в состав Конфедерации после того, как гражданская война на планете была прекращена вмешательством флотом ГКК, и с тех пор население сохраняет дух сопротивления. Появление Альянса Фронтира придало сил протестному движению; общественное желание присоединиться к Альянсу сдерживается лишь постоянным присутствием сил Конфедерации. Выходцы с Вали обычно озлоблены своим нынешним положением, а многие эмигранты продолжают поддерживать усилия Альянса по «освобождению Вали от оков»."
	language = null
	economic_power = 0.6
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_providence
	language = null
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_colony
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_providence_nomad
	name = CULTURE_HUMAN_CONFED_PROVIDENCE_NOMAD
	nickname = "Провиденец-кочевник"
	description = "Потомки колонистов компании Atlas Resources. Организовавшие свою конфедерацию до становления ГКК такой, какой мы её знаем. Кочевники Провиденса посвящают себя работе в самых разных её форматах. Кочевник Провиденса за свою жизнь может сменить порядка 50 работ: не потому что он непутёвый работник, а потому что \"цикл\" зовёт его к следующей станции или к следующей звезде. Быстрые в принятии решений, свирепые в их исполнении, хитрые в их достижении."
	economic_power = 1.0
	faction = FACTION_INDIE_CONFED

/singleton/cultural_info/culture/human/confederate_providence_colonist
	name = CULTURE_HUMAN_CONFED_PROVIDENCE_COLONIST
	nickname = "Провиденец-колонист"
	description = "Живя в системе Провиденс на одном из основных на одной из точек \"цикла\", представляют собой сборную солянку из множества народов. Дружественные мечтатели с Атлантиса, добропорядочные и суровые рабочие Нью-Виктории, подлые и ловкие обитатели Кровостока, хитрые и эмпатичные Вашингтонцы, а также закрытые в себе мудрые Нуэво-Мексиканцы. Представители \"конфдерации внутри конфедерации\" Провиденса являются одними из самых причудливых жителей ГКК."
	economic_power = 1.0
	faction = FACTION_INDIE_CONFED

// Hook to inject these cultures into the Human species available list
/hook/startup/proc/restore_human_gcc_cultures()
	var/singleton/species/human/H = GLOB.species_by_name[SPECIES_HUMAN]
	if(H)
		var/list/culs = H.available_cultural_info[TAG_CULTURE]
		culs |= list(
			CULTURE_HUMAN_CONFED_TERRA,
			CULTURE_HUMAN_CONFED_NOVOZEM,
			CULTURE_HUMAN_CONFED_SESTRIS,
			CULTURE_HUMAN_CONFED_PUTKARI,
			CULTURE_HUMAN_CONFED_ALTAIR,
			CULTURE_HUMAN_CONFED_PENGLAI,
			CULTURE_HUMAN_CONFED_PROVIDENCE_NOMAD,
			CULTURE_HUMAN_CONFED_PROVIDENCE_COLONIST,
			CULTURE_HUMAN_CONFED_VALY,
			CULTURE_HUMAN_CONFEDO,
			CULTURE_HUMAN_THEIA
		)
		var/list/homes = H.available_cultural_info[TAG_HOMEWORLD]
		homes |= list(
			HOME_SYSTEM_TERRA,
			HOME_SYSTEM_AMELIA,
			HOME_SYSTEM_PUTKARI,
			HOME_SYSTEM_QABIL,
			HOME_SYSTEM_PENGLAI,
			HOME_SYSTEM_PROVIDENCE,
			HOME_SYSTEM_VALY,
			HOME_SYSTEM_NOVAYA_ZEMLYA
		)
	return TRUE

/hook/startup/proc/restore_machine_cultures()
	var/singleton/species/human/H = GLOB.species_by_name[SPECIES_HUMAN]
	var/singleton/species/machine/M = GLOB.species_by_name[SPECIES_IPC]
	if(H && M)
		var/list/human_homes = H.available_cultural_info[TAG_HOMEWORLD]
		var/list/machine_homes = M.available_cultural_info[TAG_HOMEWORLD]
		machine_homes |= human_homes
	return TRUE

// Указатель культур для всех фракций
/singleton/cultural_info/culture/human/martian_surfacer/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/martian_tunneller/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/luna_poor/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/luna_rich/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/venusian_upper/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/venusian_surfacer/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/belter/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/kuiper_insider/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/kuiper_outsider/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/earthling/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/ceti_north/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/ceti_south/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/ceti_interstate/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/foster/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/tadmor/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/iolaus/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/brahe/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/eos/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/pirx_high/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/pirx_bug/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/pirx_frontier/faction = FACTION_SOL_CENTRAL
/singleton/cultural_info/culture/human/magnitka/faction = FACTION_OTHER
/singleton/cultural_info/culture/human/spacer/faction = FACTION_OTHER
/singleton/cultural_info/culture/human/offworld/faction = FACTION_OTHER
/singleton/cultural_info/culture/human/gaia/faction = FACTION_OTHER
/singleton/cultural_info/culture/human/other/faction = FACTION_OTHER
/singleton/cultural_info/culture/human/vatgrown/faction = FACTION_OTHER

// Skrell
/singleton/cultural_info/culture/skrell/faction = FACTION_SKRELL_OTHERSKRELLFAC
/singleton/cultural_info/culture/skrell/caste_malish/faction = FACTION_SKRELL_OTHERSKRELLFAC
/singleton/cultural_info/culture/skrell/caste_kanin/faction = FACTION_SKRELL_OTHERSKRELLFAC
/singleton/cultural_info/culture/skrell/caste_raskinta/faction = FACTION_SKRELL_OTHERSKRELLFAC
/singleton/cultural_info/culture/skrell/caste_talum/faction = FACTION_SKRELL_OTHERSKRELLFAC

// Unathi
/singleton/cultural_info/culture/unathi/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_yeosa_abyss/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_yeosa/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_polar/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_desert/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_savannah/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_salt_swamp/faction = FACTION_UNATHI_INDEPENDENT
/singleton/cultural_info/culture/unathi_space/faction = FACTION_UNATHI_INDEPENDENT

// IPC
/singleton/cultural_info/culture/ipc/faction = FACTION_OTHER
/singleton/cultural_info/culture/ipc/gen2/faction = FACTION_OTHER
/singleton/cultural_info/culture/ipc/gen3/faction = FACTION_OTHER

// Vox
/singleton/cultural_info/culture/vox/faction = FACTION_VOX_CREW
/singleton/cultural_info/culture/vox/salvager/faction = FACTION_VOX_CREW
/singleton/cultural_info/culture/vox/raider/faction = FACTION_VOX_RAIDER

// Serpentid
/singleton/cultural_info/culture/nabber/faction = FACTION_OTHER

// Diona
/singleton/cultural_info/culture/diona/faction = FACTION_OTHER

// Ascent
/singleton/cultural_info/culture/ascent/faction = FACTION_OTHER
