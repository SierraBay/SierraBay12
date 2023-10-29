/obj/item/storage/firstaid
	name = "стандартная аптечка"

/obj/item/storage/firstaid/empty
	name = "пустая аптечка"
	desc = "Это аптечка для людей, которые любят суп надежды."

/obj/item/storage/firstaid/regular
	name = "аптечка"
	desc = "Это аптечка для оказания неотложной помощи при серьезных болях."

/obj/item/storage/firstaid/trauma
	name = "первая помощь при травмах"
	desc = "Это аптечка на случай, когда люди принесли на лазерную перестрелку огнестрел."

/obj/item/storage/firstaid/fire
	name = "первая помощь при ожогах"
	desc = "Это аптечка на случай <i>-самопроизвольного-</i> возгорания лаборатории токсинов."

/obj/item/storage/firstaid/toxin
	name = "первая помощь при токсинах"
	desc = "Используется для лечения при повышенном содержании токсинов в организме."

/obj/item/storage/firstaid/o2
	name = "первая помощь при кислородном голодании"
	desc = "Коробка с принадлежностями для лечения кислородного голодания."

/obj/item/storage/firstaid/radiation
	name = "первая помощь при облучении"
	desc = "Это аптечка на случай, если вы попытаетесь обнять реактор."

/obj/item/storage/firstaid/adv
	name = "продвинутая аптечка"
	desc = "Содержит передовые методы лечения."

/obj/item/storage/firstaid/combat
	name = "боевая аптечка"
	desc = "Содержит передовые методы лечения."

/obj/item/storage/firstaid/stab
	name = "стабилизационная аптечка"
	desc = "Укомплектована медицинскими пакетами."

/obj/item/storage/firstaid/sleekstab
	name = "тонкий стабилизационный набор"
	desc = "Изящный и дорогой на вид медицинский набор."

/obj/item/storage/firstaid/light
	name = "легкая аптечка"
	desc = "Это небольшая аптечка для оказания первой помощи."

/obj/item/storage/firstaid/surgery
	name = "набор для хирургии"
	desc = "Содержит инструменты для проведения хирургических операций. Имеет точную пенопластовую подгонку для безопасной транспортировки и автоматически стерилизует содержимое между использованиями."

/obj/item/storage/box/freezer
	name = "портативный морозильник"
	desc = "Это замечательное ударопрочное самозамораживающееся устройство сохранит ваши 'продукты' в целости и сохранности."

/obj/item/storage/med_pouch
	name = "медицинский подсумок для экстренных случаев"
	desc = "Только для использования в чрезвычайных ситуациях."

/obj/item/storage/med_pouch/trauma
	name = "подсумок для лечения травм"

/obj/item/storage/med_pouch/burn
	name = "подсумок для лечения ожогов"

/obj/item/storage/med_pouch/oxyloss
	name = "подсумок для лечения кислородного голодания"
	injury_type = "кислородном голодании"

/obj/item/storage/med_pouch/Initialize()
	. = ..()
	name = "экстренный подсумок при [injury_type]"

/obj/item/storage/med_pouch/toxin
	name = "подсумок для лечения отравлений"

/obj/item/storage/med_pouch/radiation
	name = "подсумок для лечения облучения"

/obj/item/reagent_containers/pill/pouch_pill
	name = "таблетка для экстренной помощи"
	desc = "Таблетка экстренной помощи из медицинского подсумка."

/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto
	name = "экстренный автоинъектор"
	desc = "Автоинъектор из подсумка для оказания неотложной медицинской помощи."

/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/inaprovaline
	name = "автоинъектор экстренного введения инапровалина"

/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/deletrathol
	name = "автоинъектор экстренного введения делетратола"

/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/dylovene
	name = "автоинъектор экстренного введения диловена"

/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/dexalin
	name = "автоинъектор экстренного введения дексалина"

/obj/item/reagent_containers/hypospray/autoinjector/pouch_auto/adrenaline
	name = "автоинъектор экстренного введения адреналина"

/obj/item/storage/pill_bottle
	name = "бутылка для таблеток"
	desc = "Это герметичный контейнер для хранения лекарств."

/obj/item/storage/pill_bottle/antitox
	name = "бутылка для таблеток (Антитокс)"
	desc = "Содержит таблетки, используемые для лечения отравления."

/obj/item/storage/pill_bottle/bicaridine
	name = "бутылка для таблеток (Бикаридин)"
	desc = "Содержит таблетки, используемые для стабилизации состояния тяжелораненых."

/obj/item/storage/pill_bottle/dexalin_plus
	name = "бутылка для таблеток (Дексалин Плюс)"
	desc = "Содержит таблетки, используемые для лечения тяжёлых случаев кислородного голодания."

/obj/item/storage/pill_bottle/dexalin
	name = "бутылка для таблеток (Дексалин)"
	desc = "Содержит таблетки, используемые для лечения кислородного голодания."

/obj/item/storage/pill_bottle/dermaline
	name = "бутылка для таблеток (Дермалин)"
	desc = "Содержит таблетки, используемые для лечения ожогов."

/obj/item/storage/pill_bottle/dylovene
	name = "бутылка для таблеток (Диловен)"
	desc = "Содержит таблетки, используемые для нейтрализации токсических веществ в крови."

/obj/item/storage/pill_bottle/inaprovaline
	name = "бутылка для таблеток (Инапровалин)"
	desc = "Содержит таблетки, используемые для стабилизации состояния пациентов."

/obj/item/storage/pill_bottle/kelotane
	name = "флакон для таблеток (Келотан)"
	desc = "Содержит таблетки, используемые для лечения ожогов."

/obj/item/storage/pill_bottle/spaceacillin
	name = "флакон для таблеток (Спейсациллин)"
	desc = "Тета-лактамный антибиотик. Эффективен против многих заболеваний, с которыми можно столкнуться в космосе."

/obj/item/storage/pill_bottle/tramadol
	name = "флакон для таблеток (Трамадол)"
	desc = "Содержит таблетки, используемые для снятия боли."

/obj/item/storage/pill_bottle/citalopram
	name = "флакон для таблеток (Циталопрам)"
	desc = "Антидепрессант мягкого действия. Применяется у лиц, страдающих депрессией или тревогой. Доза 15ед. в одной таблетке."

/obj/item/storage/pill_bottle/methylphenidate
	name = "бутылочка для таблеток (Метилфенидат)"
	desc = "Стимулятор умственной деятельности. Применяется у лиц, страдающих СДВГ или общими нарушениями концентрации внимания. Доза 15ед. в одной таблетке."

/obj/item/storage/pill_bottle/paroxetine
	name = "бутылка для таблеток (Пароксетин)"
	desc = "Сильнодействующий антидепрессант. Применяется только при тяжелых депрессиях. Доза 10ед. в одной таблетке. <span class='warning'>ВНИМАНИЕ: побочные эффекты могут включать галлюцинации.</span>"

/obj/item/storage/pill_bottle/antidexafen
	name = "бутылка для таблеток (лекарство от простуды)"
	desc = "Универсальное лекарство от простуды. Доза 15кд. в одной таблетке. Безопасно для таких малышей, как вы!"

/obj/item/storage/pill_bottle/paracetamol
	name = "бутылка для таблеток (Парацетамол)"
	desc = "Слабое болеутоляющее средство, известное также как тайленол. Не устраняет причину головной боли (в отличие от цианида), но может сделать ее более терпимой."

/obj/item/storage/pill_bottle/assorted
	name = "бутылка для таблеток (Ассорти)"
	desc = "Эти бутылочки с таблетками, часто встречающиеся у фельдшеров, содержат все самое необходимое."
