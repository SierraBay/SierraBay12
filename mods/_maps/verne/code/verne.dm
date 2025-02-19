/obj/submap_landmark/joinable_submap/verne
	name = "SRV Verne"
	archetype = /singleton/submap_archetype/derelict/verne

/singleton/submap_archetype/derelict/verne
	descriptor = "active research vessel"
	map = "SRV Verne"
	crew_jobs = list(
		/datum/job/submap/CTI_professor,
		/datum/job/submap/CTI_pilot,
		/datum/job/submap/CTI_engineer,
		/datum/job/submap/CTI_Undergraduate_Xenoscience_Researcher,
		/datum/job/submap/CTI_Exchange_Student
	)

/obj/overmap/visitable/ship/verne
	name = "SRV Verne"
	scanner_desc = @{"
		<center><img src = sollogo.png></center><br>
		<i>Registration</i>: Sol Research Vessel Verne<br>
		<i>Transponder</i>: Transmitting (SCI), SCGRV<br>
		<b>Notice</b>: Sensor array detects a medium-sized research vessel. It is owned by Ceti Institute of Technology and registered as Sol Central Government ship."}
	contact_class = /decl/ship_contact_class/srv
	vessel_mass = 10000
	known_ships = list(/obj/overmap/visitable/ship/landable/verne)
	max_speed = 1/(3 SECONDS)
	burn_delay = 2 SECONDS
	fore_dir = NORTH
	initial_restricted_waypoints = list(
			"SRV Venerable Catfish" = list("nav_hangar_verne", "nav_verne_4"),
			"Mule" = list("nav_verne_mule")
	)
	initial_generic_waypoints = list(
		"nav_verne_1",
		"nav_verne_2",
		"nav_verne_3",
	)

/decl/ship_contact_class/srv
	class_short = "SRV"
	class_long = "Sol Research Vessel"
	max_ship_mass = 12000

/datum/map_template/ruin/away_site/verne
	name = "Active University Ship (CTI Verne)"
	id = "awaysite_verne"
	description = "Active CTI research ship"
	prefix = "mods/_maps/verne/maps/"
	suffixes = list("verne-1.dmm", "verne-2.dmm", "verne-3.dmm")
	spawn_cost = 0.5
	player_cost = 4
	spawn_weight = 1
	area_usage_test_exempted_root_areas = list(/area/verne)
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/overmap/verne,
		/datum/shuttle/autodock/ferry/verne,
	)
	apc_test_exempt_areas = list(
		/area/verne/engineering/external = NO_SCRUBBER|NO_VENT,
		/area/verne/engineering/powergen = NO_SCRUBBER|NO_VENT,
		/area/verne/engineering/thrusters = NO_SCRUBBER|NO_VENT,
		/area/verne/catfish/engineering = NO_SCRUBBER|NO_VENT,
		/area/verne/lift = NO_SCRUBBER|NO_VENT|NO_APC,
	)
	area_coherency_test_subarea_count = list(
		/area/verne/engineering/external = 20,
	)

var/global/const/access_verne = "ACCESS_VERNE"

/datum/access/verne
	id = access_verne
	desc = "Verne Access"
	region = ACCESS_REGION_NONE

/obj/item/card/id/verne
	access = list(access_verne)

/obj/machinery/alarm/verne
	req_access = list(access_verne)

/obj/machinery/power/apc/verne
	req_access = list(access_verne)
	cell_type = /obj/item/cell/hyper

/obj/machinery/power/supermatter/randomsample
	name = "experimental supermatter sample"
	icon_state = "darkmatter_shard"
	base_icon_state = "darkmatter_shard"

/obj/machinery/power/supermatter/randomsample/Initialize()
	. = ..()
	nitrogen_retardation_factor = rand(0.01, 1)	//Higher == N2 slows reaction more
	thermal_release_modifier = rand(100, 1000000)		//Higher == more heat released during reaction
	phoron_release_modifier = rand(0, 100000)		//Higher == less phoron released by reaction
	oxygen_release_modifier = rand(0, 100000)		//Higher == less oxygen released at high temperature/power
	radiation_release_modifier = rand(0, 100)    //Higher == more radiation released with more power.
	reaction_power_modifier =  rand(0, 100)			//Higher == more overall power

	power_factor = rand(0, 20)
	decay_factor = rand(50, 70000)			//Affects how fast the supermatter power decays
	critical_temperature = rand(3000, 5000)	//K
	charging_factor = rand(0, 1)
	damage_rate_limit = rand( 1, 10)		//damage rate cap at power = 300, scales linearly with power

/obj/machinery/power/supermatter/inert
	name = "experimental supermatter sample"
	icon_state = "darkmatter_shard"
	base_icon_state = "darkmatter_shard"
	thermal_release_modifier = 0 //Basically inert
	phoron_release_modifier = 100000000000
	oxygen_release_modifier = 100000000000
	radiation_release_modifier = 1

/obj/structure/closet/crate/secure/large/phoron/experimentalsm
	name = "experimental supermatter crate"
	desc = "Are you sure you want to open this?"

/obj/structure/closet/crate/secure/large/phoron/experimentalsm/WillContain()
	return list(/obj/machinery/power/supermatter/randomsample)

/obj/floor_decal/cti
	name = "\improper CTI logo"
	desc = "Logo of the famed Ceti Technical Institute. Just looking at it makes you feel ashamed of your alma mater."
	icon = 'mods/_maps/verne/icons/verne.dmi'
	icon_state = "CTILogo"

/datum/reagent/toxin/phoron/safe
	name = "tericadone"
	description = "Phoron substitute currently in laboratory testing"
	taste_mult = 1.5
	reagent_state = LIQUID
	color = "#ffc4ff"

/obj/item/reagent_containers/glass/bottle/tericadone
	name = "tericadone bottle"
	desc = "A small bottle."
	icon_state = "bottle-3"

/obj/item/reagent_containers/glass/bottle/tericadone/New()
	..()
	reagents.add_reagent(/datum/reagent/toxin/phoron/safe , 60)
	update_icon()

/datum/reagent/toxin/phoron/safe/touch_mob(mob/living/L, amount)
	return

/datum/reagent/toxin/phoron/safe/affect_blood(mob/living/carbon/M, alien, removed)
	return

/datum/reagent/toxin/phoron/safe/affect_touch(mob/living/carbon/M, alien, removed)
	return

/datum/reagent/toxin/phoron/safe/touch_turf(turf/simulated/T)
	return

/singleton/reaction/oxycodone/nophoron
	catalysts = list(/datum/reagent/toxin/phoron/safe = 5)

/singleton/reaction/peridaxon/nophoron
	catalysts = list(/datum/reagent/toxin/phoron/safe = 5)

/singleton/reaction/leporazine/nophoron
	catalysts = list(/datum/reagent/toxin/phoron/safe = 5)

/singleton/reaction/dexalin/nophoron
	required_reagents = list(/datum/reagent/acetone = 2, /datum/reagent/toxin/phoron/safe = 0.1)

/singleton/reaction/clonexadone/nophoron
	required_reagents = list(/datum/reagent/cryoxadone = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/phoron/safe = 0.1)

/obj/machinery/suit_storage_unit/engineering/verne
	req_access = list(access_verne)

/obj/machinery/suit_storage_unit/ceti/verne
	name = "CTI Voidsuit Storage Unit"
	suit= /obj/item/clothing/suit/space/void/ceti
	helmet = /obj/item/clothing/head/helmet/space/void/ceti
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	mask = /obj/item/clothing/mask/breath
	req_access = list(access_xenoarch)
	islocked = 1
	req_access = list(access_verne)

/obj/machinery/suit_storage_unit/ceti/verne/alt
	name = "CTI Research Voidsuit Storage Unit"
	suit= /obj/item/clothing/suit/space/void/ceti/alt
	helmet = /obj/item/clothing/head/helmet/space/void/ceti/alt
	ssu_color = "#282b27"

/obj/machinery/turretid/verne
	name = "turret control panel"
	enabled = 1
	lethal = 1
	icon_state = "control_kill"
	locked = 1
	check_arrest = 0
	check_records = 0
	check_weapons = 0
	check_access = 1
	check_anomalies = 1
	req_access = list(access_verne)

/obj/machinery/power/smes/buildable/preset/verne
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_io = 2,
		/obj/item/stock_parts/smes_coil/super_capacity = 2,
	)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/power/smes/buildable/preset/verne/shuttle
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_io = 1,
		/obj/item/stock_parts/smes_coil/super_capacity = 1,
	)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/item/taperoll/research/verne
	name = "CTI research tape"
	desc = "A roll of research tape used to block off working areas from the public."
	tape_type = /obj/item/tape/research/verne
	color = COLOR_BOTTLE_GREEN

/obj/item/tape/research/verne
	name = "CTI research tape"
	desc = "A length of research tape. Better not cross it. This one is green and has Ceti Technical Institute labels printed on it"
	req_access = list(access_verne)
	color = COLOR_BOTTLE_GREEN

/obj/item/paper/verne
	name = "power usage"
	info = "Verne Pilots and Engineers, remember to turn off the thrusters when you're done with maneuvers.\
	<BR>Power usage settles at 137 kW with them off, just under the ICRER-2 150 kW standard operating range.\
	<BR>When you're performing maneuvers, put the ICRER-2 up to 180 kW, turn the gas cooler on, and remember to feed it Coolant!\
	<BR>After you're done with maneuvers or if an hour has passed, drop it down to 150 kW and turn the gas cooler off. \
	<BR>Otherwise it'll explode. \
	<BR>If it explodes, you'll totally destroy the aft Engineering Stack, stranding us. \
	<BR><b>Your follow up to this matter is required and appreciated.</b>"

/obj/item/paper/verne/manifest
	name = "crew manifest"
	info = "<center><b>SRV Verne</b><br>\
			Crew roster</center><br>\
			<b>Command</b><br>\
			\[list]\
			\[*]Co-Consul Professor, A Shift: Dr. Andre Richardson\
			\[*]Co-Consul Professor, B Shift: Dr. David Schoonhoven\
			\[*]Senior Phsyician: Dr. Remaldo-12\
			\[*]Head Engineer: Jonah French\
			\[*]Security Officer: Chantel Osborne\
			\[/list]<br>\
			<b>Medical Department.</b><br>\
			\[list]\
			\[*]Physician: Dr. Milli Newman\
			\[*]Nurse: Fatimah Hayes\
			\[/list]<br>\
			<b>Service Department.</b><br>\
			\[list]\
			\[*]Cook, A Shift: Cavan Kaur\
			\[*]Cook, A Shift: Jibril-59\
			\[*]Cook, B Shift: Lilly-Ann Mora\
			\[*]Cook, B Shift: Malaikah Owen\
			\[/list]<br>\
			\[*]Non-Essential Systems Technician: Neel Barrett\
			\[list]\
			<b>Supermatter Undergraduate Teams.</b><br>\
			\[*]Reactor Team Manhattan, A Shift: 4 Students, 2 Employees.\
			\[*]Reactor Team Neutrino, B Shift: 2 Students, 1 Employee.\
			\[*]Reactor Team Pluton, A2 Shift: 6 Students, 3 Employees.\
			\[*]Reactor Team Euphrate, B2 Shift: 4 Students, 3 Employees.\
			\[/list]\
			<b>Xenoscience Undergraduate Teams.</b><br>\
			\[list]\
			\[*]Survey Team Theta, A Shift: 3 Students, 2 Employees.\
			\[*]Survey Team Promethia, B Shift: 2 Students, 2 Employees.\
			\[*]Survey Team Delphi, A2 Shift: 2 Students, 2 Employees.\
			\[*]Survey Team Cyrenica, B2 Shift: 2 Students, 2 Employees.\
			\[/list]"

/obj/item/paper/verne/briefing
	name = "Survey Team Cyrenica briefing"
	info = "Good waking, Survey Team Cyrenica.<BR>\
		Dr. Schoonhoven and I have been negotiating the routing we intended to take the SRV Verne for this expedition.<BR>\
		This matter was improperly discussed during the initial expedition planning, and I promise, we will be making amends upon our return to Tau-Ceti.\
		After your last shift, the executive decision was made to put the SRV Verne onto extended automation.<BR>\
		You will be alone during the initial day of your shift. <BR>\
		The routing Dr. Schoonhoven and I negotiated will take us further than ever before. This comes with consequences; I trust you will be careful during your Survey missions. <BR>\
		We will be making history with this expedition. You will have earned the honor of having chased the God of the Sun.<BR>\
		I have scheduled support staff to awake during the second day of your shift. They will be awake for 48 hours, to provide overlapping coverage to Survey Team Theta, after you have entered stasis.<BR>\
		Your scheduled support staff are;<BR>\
		Physician Dr. Milli Newman<BR>\
		Non-Essential Systems Technician Neel Barrett.<BR>\
		They will awake 24 hours after your shift begins.<BR>\
		Your shift will last for the standard 48 hours.<BR>\
		Your duties remain unchanged;<BR>\
		Survey the Exoplanet you have been brought to.<BR>\
		The students will be performing their studies as required.<BR>\
		If you feel any nearby sites are of value, you have my permission to divert to them.<BR>\
		Given our tenuous staffing, it comes with my highest recommendations that you are aware of any other active vessels in your system if they are amenable to working with you or to assist you if required. <BR>\
		I firmly request you do not touch the Supermatter Testing facilities, as I have scheduled later classes to awake to perform their studies using the stock we have remaining.<BR>\
		Our supplies remain at acceptable levels at this time, but I will permit barter or trading if required. \
		Do not sell the resources your fellow students will require.<BR>\
		I await your results.<BR>\
		Dr. Andre Richardson"

/obj/item/paper/verne/supermatter
	name = "supermatter"
	info = "Хей, я конечно понимаю что вам может быть любопытно, даже <i>ОЧЕНЬ</i> любопытно это все, но пожалуйста, оставьте наши дорогие осколки в покое, если вы не имеете представления как тут все должно работать. \
		Нам не нужны случайные взрывы.<BR>\
		<h3>И я напомню, если кто-то забыл, что суперматерия не питает наше судно! Найдите ядерный реактор, если вам нужен свет!</h3><BR>\
		С уважением,<BR>\
		<i>Реакторная команда Евфрат</i>"

/obj/item/paper/verne/combustion
	name = "engineering memo"
	info = "<b>Кому:</b> Технический Персонал<BR>\
		<b>От:</b> Главный Инженер<BR>\
		<b>Тема:</b> Напоминание о технике безопасности при нагреве топлива<BR>\
		<hr><BR>\
		Внесу немного ясности для техников, которые еще не освоились с нашей системой. Нагревать топливо в камере сгорания нужно <u>крайне аккуратно</u>. \
		Если закачать слишком много газа в камеру, температура горения будет слишком высокой, и она разобьет это стекло и возможно даже поплавит стенки камеры.<BR>\
		Если вы не можете рассчитать безопасные значения, возможно вам не стоит переключать топливную систему. Она работает в 'холодном' режиме по умолчанию.<BR>\
		Если все же хотите попробовать, вот моя установка, на всякий случай:<BR><BR>\
		<b>Настройки газового фильтра:</b><BR>\
		North Port: -<BR>\
		South Port: 20%<BR>\
		East Port: 60%<BR>\
		West Port: 20%<BR><BR>\
		<b>Консоль управления инжектором:</b><BR>\
		Input Flow Rate: 50 L/s<BR><BR>\
		<center><h3>Техника безопасности это важно. Прежде чем уходить по делам, убедитесь, что температура горения не выходит за критические значения. Не забывайте закрывать окно створками.</h3></center><BR>\
		Если вы заметили, что стекло начинает трескаться или уже разбилось, немедленно отключите инжектор и откройте створки в космос для вентилирования камеры сгорания. \
		Убедитесь, что окно также защищено створками. Ни в коем случае не допускайте пожар в этом отсеке.<BR>\
		<hr><BR>\
		<small>Подпись:</small> <i>Д. Френч</i>"

/obj/item/paper/verne/atmos
	name = "air refill guide"
	info = "Ладно, я хочу быть уверен, что если у нас что-то случится, и весь воздух в цистернах внезапно куда-то пропадет, то вы там сможете восполнить запасы газа, чтобы мы тут все не задохнулись.<BR>\
		Итак, вы как-то умудрились потратить все запасы воздуха в атмосферном. Вот суперполезный гайд что вам делать:<BR><BR>\
		1. Позовите инженера и скажите ему что вам очень срочно нужен новый воздух.<BR><BR>\
		Если вы и есть инженер, но не знаете откуда взять воздух, то я вас глубоко осуждаю. Если же инженер недоступен (я даже не хочу знать что с ним могло случиться), то вот подробная инструкция, по шагам. \
		<u>Просто четко следуйте ей:</u><BR><BR>\
		1. Нажмите кнопку в инженерном отделе, чтобы поднять створки для обслуживания и доступа во внешние хранилища (она в комнате с вендорами).<BR><BR>\
		2. Крутите вентиль в атмосе, который находится рядом с внешним шлюзом, пока он не откроется и индикатор не станет зеленым.<BR><BR>\
		3. Выйдите на обшивку.<BR><BR>\
		4. Постарайтесь не улететь куда-то в открытый космос, и найдите одно из хранилищ, внутри которого много азота (красные цистерны). <i>Если ни одно из них уже не с вами, см. Примечание 1.</i><BR><BR>\
		5. Включите насос хранилища на максимум.<BR><BR>\
		6. Найдите любое хранилище, внутри которого дофига кислорода (синие резервуары). <i>Если они все взорвались/опустошились/отвалились, см. Примечание 2.</i><BR><BR>\
		7. Включите насос хранилища на максимум.<BR><BR>\
		8. Вернитесь в атмос. В белой трубе должно появиться давление.<BR><BR>\
		9. Дождитесь, пока на датчике воздушной трубы (голубая) не будет достаточно высокое давление.<BR><BR>\
		9. Выйдите на обшивку.<BR><BR>\
		10. Вернитесь к внешнему хранилищу азота и выключите насос там.<BR><BR>\
		11. Вернитесь к внешнему хранилищу кислорода и тоже выключите насос.<BR><BR>\
		12. Вернитесь на судно.<BR><BR>\
		13. Нажмите на кнопку в инженерном, чтобы закрыть створки обратно. Поздравляю, вы черт возьми сделали это, и возможно сможете спокойно дышать и продолжать наслаждаться своим существованием на Верне. \
		На этом ваш гайд заканчивается, не забудьте потом угостить меня пивом за ваше спасение.<BR><BR>\
		<b>Примечание 1.</b> Окей, если вы читаете это, то азота нет. Не спешите паниковать, это не проблема. Продолжайте выполнять инструкцию и откройте хранилище с О2.<BR>\
		<u>Дополнительно</u> настройте газовый миксер в атмосе так, чтобы он пропускал только кислород в трубу для воздуха (голубой цвет). Да, вы можете дышать воздухом без азота в его составе. \
		Да, так можно делать, и мои поздравления, если для вас это стало открытием.<BR>\
		<b>Примечание 2.</b> Если вы читаете это, то вам совсем скоро станет нечем дышать. Да... Вам конец. Надевайте маски, запасайтесь карманными баллонами с кислородом. \
		Начинайте паниковать и осознавать, как хорошо вам было жить.<BR><BR>\
			- инженер Джим Коллет"

/obj/item/paper/verne/prefix
	name = "Professor's memo"
	info = "<center>Технологический Университет Тау Кита</center><BR><BR>\
		<center><b>ПАМЯТКА</b></center><BR>\
		<hr><BR>\
		<b>Кому:</b> Сотрудники и студенты ГНС Верне<BR>\
		<b>От:</b> д-р Андрэ Ричардсон, д-р Дэвид Чунховен<BR>\
		<b>Тема:</b> Пояснения к аббревиатурам ГНС и SRV<BR>\
		<hr><BR>\
		У многих возникает вопрос о наименовании нашего судна. Всего мы используем два вида: SRV Verne и ГНС Верне. Хоть они и отличаются по названию, но несут один и тот же смысл.<BR><BR>\
		<hr><center><b>SRV</b> Verne - <b>ГНС</b> Верне<BR>\
		Sol Research Vessel - Государственное научное судно</center><BR><BR>\
		<b>Sol или Государственное</b> в данной аббривиатуре означает ЦПСС в сокращенной форме, указывая на свой официальный статус. ЦПСС на данный момент является самым крупным государством. \
		Если вы говорите слово <b>государство</b> без подводки и контекста - это всегда имеется ввиду ПСС,<BR>\
		<b>Research или Научное</b> указывает на научный уклон какого-либо объекта,<BR>\
		<b>Vessel или Судно</b> указывает на тип объекта, в данном случае объектом является судно или же корабль."

/obj/item/paper/verne/science
	name = "note for students"
	info = "Напоминалка для студента:<BR><BR>\
		Вот вы отучились несколько лет в душных кабинетах, и пришла пора изучать глубокий и необъятный космос! Каждый из вас уникален, каждый имеет различные научные направления, \
		начиная от химии и ксеноботаники, заканчивая ксенобиологией, археологией и изучением артефактов.<BR>\
		Мы рады и всегда поддерживаем стремление наших учеников!<BR><BR>\
		ГНС Верне предоставляет широкий спектр возможностей для достижения новых знаний и дает свободу в творчестве, <b>но помните, нельзя:</b><BR>\
		\[list]\
		\[*]Подвергать опасности себя и других своими действиями или бездействием,\
		\[*]Проводить заведомо провальные эксперименты, которые могут кончиться катастрофой,\
		\[*]Производить оружие для личного пользования, не в рамках научной деятельности.\
		\[/list]\
		<small> - д-р Дэвид Чунховен</small>"

/obj/item/paper/verne/airlocks
	name = "exterior airlocks"
	info = "Как бы вам не казалось, но космос очень тесен. Гости на государственном борту не приветствуются, но если появится необходимость, не спешите ломать окна и пускать разгерметизацию корабля.<BR><BR>\
		<i>Инженерам это очень не нравится, к тому же нарушает ТБ.</i><BR><BR>\
		На судне имеется несколько безопасных, во всех смыслах, входов. Они охраняются турелями, так что думаю стоит их отключать при приёме гостей.<BR><BR>\
		<center>Удачи найти их всех!</center>"

/obj/item/paper/verne/turrets
	name = "turrets warning"
	info = "Главный инженер на связи.<BR><BR>\
		Я перелопатил всю проводку на этом чертовом корабле, но так и не понял, почему турели вечно сбрасывают свои настройки! Поэтому всему экипажу быть ПРЕДЕЛЬНО осторожным с ними.<BR><BR>\
		<center><b>Первым делом после выхода с крио сна, мы бежим к контролерам турелей и перезапускаем их, предварительно разблокировав картой.</b><BR>\
		<i>(Доступ имеется у всех)</i></center><BR>\
		Всего у нас их 4:<BR>\
		\[list]\
		\[*]Первый - на мостике первой палубы,\
		\[*]Второй - в ангаре на второй палубе, левее шлюза мастерской,\
		\[*]Третий - рядом же, на челноке Сом. <u>БОИМСЯ СИЛЬНЕЕ ВСЕХ</u>, турель чуть ли не по центру ангара стоит. Заходим с правой стороны, если не хотим бегать перед турелью,\
		\[*]Четвертый -  третья палуба, тестовая камера СМ. Поворот направо после входа в саму камеру. <b>Сама материя плотно закрыта, опасности не представляет. \
		Если вдруг материя в рабочем состоянии не забываем перед входом надевать РХБЗ.</b>\
		\[/list]\
		<small>Подпись:</small> <i>Д. Френч</i>"
