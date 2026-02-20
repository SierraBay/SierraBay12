
/* CARDS
 * ========
 */

/obj/item/card/id/farfleet/droptroops
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn, access_away_iccgn_droptroops)

/obj/item/card/id/farfleet/droptroops/sergeant
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn, access_away_iccgn_droptroops, access_away_iccgn_sergeant)

/obj/item/card/id/farfleet/fleet
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn)

/obj/item/card/id/farfleet/fleet/captain
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn, access_away_iccgn_captain)

/* CLOTHING
 * ========
 */


/obj/item/clothing/under/iccgn/service_command
	accessories = list(
		/obj/item/clothing/accessory/iccgn_patch/pioneer
	)

/obj/item/clothing/under/iccgn/utility
	accessories = list(
		/obj/item/clothing/accessory/iccgn_patch/pioneer
	)

/obj/item/clothing/under/iccgn/pt
	accessories = list(
		/obj/item/clothing/accessory/iccgn_patch/pioneer
	)

/obj/item/storage/belt/holster/security/tactical/farfleet/New()
	..()
	new /obj/item/gun/projectile/pistol/optimus(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/ammo_magazine/pistol/double(src)

/obj/item/storage/belt/holster/security/farfleet/iccgn_pawn/New()
	..()
	new /obj/item/gun/projectile/pistol/bobcat(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)

/* MISC
 * ========
 */

/obj/item/paper/farfleet/shield
	name = "About Shield Generator"
	language = "Pan-Slavic"
	info = {"<h1>По поводу генератора щита</h1>
	<p>Я не знаю кто нам срезал комнату отдыха, но тут теперь Генератор щита.<br /><br />Раз ты это читаешь, значит ты не знаешь как его настроить, или после Криокамеры тебе начисто отбило память.</p>
	<ol><li>Выставь мощность 1500 Киловатт.</li>
	<li>Выставь Радиус Щитов на 36 Единиц.</li>
	<li>Включи Генератор Щита.</li>
	<li>Настрой требуемые функции в нём.&nbsp;</li>
	</ol><p>Поздравляю!<br />Теперь Генератор Щита настроен и он набирает заряд, как только тебе дадут приказ о Проецировании Щитов, ты его Активируешь, там будет вторая кнопочка, но более правее.</p>
	<p><em>Якоб З.Д</em> "}

/obj/item/paper/farfleet/reactor
	name = "About Reactor"
	language = "Pan-Slavic"
	info = {" <p><strong>По поводу нашего реактора</strong></p>
	<p><br />Если БЛЯТЬ ВАЛЕРА опять решил покурить в реакторе, то там наверняка Кислород, который нужно продуть дабы не было лишних проблем со смесью. <br />Номинальная:</p>
	<ol>
	<li>Ты же не забыл продуть Реактор? Если продул камеру Реактора, то закрывай её.</li>
	<li>Выставь в Газовой Помпе пропуск давления на 10 Кило паскалей и включить.</li>
	<li>Выставь в Газовом Миксере на одном любом порте максимальный пропуск и включить.</li>
	<li>Поставь на Любом из портов канистру с водородом и прикрутить.</li>
	<li>Возьми с ящика Диски Дейтерия и сделать 4 Дейтериевых Стержня в специальной машине.</li>
	<li>Вставь в каждый инжектор по Дейтериевому Стержню.</li>
	<li>В консоли управления Инжекторами, выставь у всех по 4% использования и включи.</li>
	<li>Включи Тритиевый Генератор на второй или третей мощности.</li>
	<li>Включи реактор и выставить 50 Тесел.</li>
	<li>Включи гиротрон на силе выстрела в 50 Единиц с отсечкой в 2 секунды.</li>
	<li>Дай ему время нагреться до 5-6 тысяч Кельвинов.</li>
	<li>Выруби гиротрон.</li>
	<li>Выруби Тритиевый Генератор.</li>
	</ol>
	<p>Теперь вы можете номинально барражировать, пока в следующий раз не придёт снова БЛЯТЬ ВАЛЕРА и не решит покурить в Реакторе.</p>
	<p><strong>ЕСЛИ РЕАКТОР НАЧНЕТ ТУХНУТЬ, </strong></p>
	<p><strong>ПРОВЕРЬ ПОСТУПАЕТ ЛИ В РЕАКТОР СМЕСЬ</strong></p>
	<p><em>Якоб З.Д</em></p> "}

/obj/item/paper/farfleet/engine
	name = "About Warming Engine"
	language = "Pan-Slavic"
	info = {" <h1><strong> По поводу прогрева наших Ускорителей</strong></h1>
	<p>Топливные двигатели, они у нас&nbsp;используются&nbsp;<strong>ТОЛЬКО</strong> как <strong>УСКОРИТЕЛИ</strong> и не более, углекислота не вечная, так что использовать нужно с умом.<br />В Газовом Миксере всё уже настроено, тебе остается сделать пару манипуляций чтобы всё заработало, самое главное, <strong>не прожги</strong> наш Атмосферный Отсек, за всё время он ни разу не прогорал....<br /><br /><strong>Именно топливные</strong>&nbsp;трубы Выдерживают 40 Мегапаскалей, у нас хоть и установлен Предохранительный Клапан, но он может не успеть сбросить требуемое количество Газа.<br /><br />Как прогреть:</p>
	<ol>
	<li>Поставь на Голубой порт Канистру с Кислородом и прикрути.</li>
	<li>Поставь на Фиолетовый порт Канистру с Водородом и прикрути.</li>
	<li>Выставь в Углекислотной линии на Газовой Помпе подачу смеси на 1 мегапаскаль и включи. <br />(1 мегапаскаль = 1000 Кило Паскалей)</li>
	<li>Включи миксер Смеси Кислорода и Водорода.</li>
	<li>Закрой смотровое окно в камере Сгорания и <strong>НЕ ОТКРЫВАЙ</strong>.</li>
	<li>Выставь подачу Горючей Смеси на 250 Кило Паскалей и включи</li>
	</ol>
	<p><em>Поздравляю, ты прогрел Топливные Ускорители!<br />Если ты начинаешь слышать как что-то Шипит, или подозрительно трескается и лопается, нажми кнопку продуваки камеры сгорания&nbsp;<strong>-</strong></em><strong>&nbsp;БЕГИ ИЗ АТМОСФЕРНОГО ОТСЕКА.<br /><br /></strong>Всё зависит от тебя Юный Бортовой Техник, не проеби наше судно, и не забудь потом вырубить подачу горючей смаси, иначе ты просто потратишь всю углекислоту в пустую, а она <strong>НЕ</strong> вечная.</p>
	<p><em>Якоб З.Д</em></p> "}

/obj/item/paper/farfleet/money
	name = "About money"
	language = "Pan-Slavic"
	info = {" <h1>По поводу Талеров</h1>
	<p>Вам выданы целых <strong>Десять Тысяч Талеров</strong> (10 000 Талеров)</p>
	<p>Растрата данных дорогостоящих ценностей остаются за капитаном, или его заместителем, в случае отсутствия энного.</p>
	<p>Денежные средства выделены на поддержание целостности выданного вам под пользование судна для оплаты ремонтных работ в случае повреждения и отсутствия возможности произвести ремонт в полевых условиях.<br />Данные средства не являются собственностью или жалованием Экипажа.</p>
	<p><br /><strong>Данные Денежные Средства - Часть Конфедерации.</strong></p>
	<p>Растрата, или потеря дорогостоящих Денежных Средств, будет приравнена к потере дорогостоящего обмундирования, данная сумма будет вычтена из жалования экипажа, так же будет выписан выговор, в каждое личное дело провинившегося.</p>
	<p><em>Андропов М.Д</em></p> "}

/obj/item/paper/farfleet/shuttle
	name = "About Shuttle Baydarka"
	language = "Pan-Slavic"
	info = {" <h1>По поводу Шаттла Байдарка</h1>
	<p>Каждый ёбанный Сонный Цикл, ВАЛЕРА продувает канистры с воздушной смесью, водородом и углекислотой.</p>
	<p><br /><strong>В СИСТЕМЕ И КАНИСТРАХ БЛЯТЬ ВАКУУМ, КАК? - НЕ ЕБУ.</strong></p>
	<p>Так что если ты это читаешь, значит тебе придётся всё подготовить дабы байдарка могла сделать номинальный вылет.</p>
	<p>Сначало сходи в атмосферный отсек и включи подачу углекислоты на заправочную станцию.</p>
	<p>На заправочной станции имеется 3 порта.<br />Фиолетовый это Водород.<br />Коричневый Это Углекислота.<br />Голубой Это воздушная смесь.</p>
	<p>Теперь по пунктам:</p>
	<ol>
	<li>Отсоедени все канистры с байдарки, и транспортирую те на заправочную станцию.</li>
	<li>Активируй подачу газа на всех портах.</li>
	<li>Установи канистры в требуемые порты и заправь на требуемое тебе давления.</li>
	</ol>
	<p>Поздравляю, ты заправил канистры и теперь можешь их вернуть на место, если увидишь валеру, передай ему лично что он еблан.</p>
	<p><em>Якоб З.Д</em></p> "}

//Ammo Box

/obj/item/storage/box/ammo/jaguar
	name = "box of Jaguar Stik"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_magazine/machine_pistol = 7)

/obj/item/storage/box/ammo/heavy
	name = "box of LA-700 Magazine"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_magazine/rifle = 7)
