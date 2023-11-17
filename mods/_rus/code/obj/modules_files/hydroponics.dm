/obj/machinery/beehive
	name = "пасека"
	desc = "Деревянный ящик, специально предназначенный для размещения наших жужжащих приятелей. Гораздо эффективнее традиционных ульев. Просто вставьте рамку и маточник, закройте его, и все готово!"

/obj/machinery/honey_extractor
	name = "экстрактор меда"
	desc = "Машина, используемая для извлечения меда и воска из рамок улья."

/obj/item/bee_smoker
	name = "окуриватель пчёл"
	desc = "Устройство, используемое для успокоения пчёл перед сбором меда."

/obj/item/honey_frame
	name = "рамка для улья"
	desc = "Рамка для улья, которую пчёлы заполняют сотами."

/obj/item/honey_frame/filled
	name = "заполненная рамка для улья"
	desc = "Рамка для улья, которую пчёлы заполнили сотами."

/obj/item/beehive_assembly
	name = "каркас улья"
	desc = "Содержит все необходимое для постройки улья."

/obj/item/stack/wax
	name = "воск"
	desc = "Мягкое вещество, вырабатываемое пчёлами. Используется для изготовления свечей."

/obj/item/bee_pack
	name = "пчёлопакет"
	desc = "Содержит королеву пчёл и несколько рабочих пчёл. Все, что нужно для создания улья!"

/obj/structure/closet/crate/hydroponics/beekeeping
	name = "ящик для пчёловодства"
	desc = "Все необходимое для создания собственного улья."

/obj/vine
	name = "лоза"

/obj/item/plantspray/weeds
	name = "анти-сорняк"
	desc = "Это токсичная смесь в виде спрея для уничтожения мелких сорняков."

/obj/item/plantspray/pests
	name = "пестициды"
	desc = "Это спрей для уничтожения вредителей! Не вдыхать!"

/obj/item/plantspray/pests/old
	name = "бутылка с уничтожителем вредителей"

/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "почва"
	desc = "Грядка. Здесь можно посадить несколько семян."

/obj/machinery/portable_atmospherics/hydroponics/soil/invisible
	name = "растение"

/obj/item/wirecutters/clippers
	name = "ножницы для растений"
	desc = "Инструмент, используемый для взятия образцов с растений."

/obj/machinery/portable_atmospherics/hydroponics
	name = "поддон для гидропоники"
	desc = "Механический резервуар, предназначенный для выращивания растений. Имеет различные полезные датчики."

/obj/item/bananapeel
	name = "Кожура от банана"
	desc = "Кожура от банана."

/obj/item/carvable/corncob
	name = "кукурузный початок"
	desc = "Напоминание о прошедшей трапезе."

/obj/item/carvable/corncob/hollowpineapple
	name = "полый ананас"

/obj/item/carvable/corncob/hollowcoconut
	name = "полый кокос"

/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris
	plantname = "амброзия"

/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus
	plantname = "амброзиядеус"

/obj/item/reagent_containers/food/snacks/grown
	name = "фрукт"
	desc = "Питательный! Возможно."

/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap
	plantname = "либертикап"

/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris
	plantname = "амброзия"

/obj/item/reagent_containers/food/snacks/fruit_slice
	name = "фруктовая нарезка"
	desc = "Долька какого-нибудь вкусного фрукта."

/obj/item/disk/botany
	name = "диск с данными растения"
	desc = "Небольшой диск, используемый для переноса данных по генетике растений."

/obj/item/storage/box/botanydisk
	name = "коробка с дисками данных растений"
	desc = "Коробка с дисками для хранения данных о растениях, видимо."

/obj/machinery/botany/extractor
	name = "центрифуга для лизиса-изоляции"
	desc = "По всей видимости, ящик с данными о флоре."

/obj/machinery/botany/editor
	name = "биобаллистическая система доставки"

/obj/item/seeds
	name = "пакет семян"

/obj/item/seeds/cutting
	name = "черенки"
	desc = "Черенки некоторых растений."

/obj/item/seeds/cutting/update_appearance()
	..()
	src.SetName("пакет черенков [seed.seed_name]")

/obj/item/seeds/replicapod
	seed_type = "диона"

/obj/item/seeds/chiliseed
	seed_type = "чили"

/obj/item/seeds/plastiseed
	seed_type = "пластик"

/obj/item/seeds/grapeseed
	seed_type = "виноград"

/obj/item/seeds/greengrapeseed
	seed_type = "зелёный виноград"

/obj/item/seeds/peanutseed
	seed_type = "арахис"

/obj/item/seeds/cabbageseed
	seed_type = "капуста"

/obj/item/seeds/lettuceseed
	seed_type = "салат-латук"

/obj/item/seeds/shandseed
	seed_type = "шанда"

/obj/item/seeds/mtearseed
	seed_type = "mtear"

/obj/item/seeds/berryseed
	seed_type = "ягоды"

/obj/item/seeds/blueberryseed
	seed_type = "черника"

/obj/item/seeds/glowberryseed
	seed_type = "светящиеся ягоды"

/obj/item/seeds/bananaseed
	seed_type = "банан"

/obj/item/seeds/eggplantseed
	seed_type = "баклажан"

/obj/item/seeds/bloodtomatoseed
	seed_type = "кровавый томат"

/obj/item/seeds/tomatoseed
	seed_type = "томат"

/obj/item/seeds/killertomatoseed
	seed_type = "томат убийца"

/obj/item/seeds/bluetomatoseed
	seed_type = "голубой томат"

/obj/item/seeds/bluespacetomatoseed
	seed_type = "bluespace томат"

/obj/item/seeds/cornseed
	seed_type = "кукуруза"

/obj/item/seeds/poppyseed
	seed_type = "мак"

/obj/item/seeds/potatoseed
	seed_type = "картофель"

/obj/item/seeds/icepepperseed
	seed_type = "ледяной чили"

/obj/item/seeds/soyaseed
	seed_type = "соя"

/obj/item/seeds/wheatseed
	seed_type = "пшеница"

/obj/item/seeds/riceseed
	seed_type = "рис"

/obj/item/seeds/carrotseed
	seed_type = "морковь"

/obj/item/seeds/reishimycelium
	seed_type = "рейши"

/obj/item/seeds/amanitamycelium
	seed_type = "аманита"

/obj/item/seeds/angelmycelium
	seed_type = "разрушение ангела"

/obj/item/seeds/libertymycelium
	seed_type = "либертикап"

/obj/item/seeds/chantermycelium
	seed_type = "грибы"

/obj/item/seeds/towermycelium
	seed_type = "башенка"

/obj/item/seeds/glowshroom
	seed_type = "светящийся гриб"

/obj/item/seeds/plumpmycelium
	seed_type = "плюмпмицелий"

/obj/item/seeds/walkingmushroommycelium
	seed_type = "шагающий гриб"

/obj/item/seeds/nettleseed
	seed_type = "крапива"

/obj/item/seeds/deathnettleseed
	seed_type = "смертельная крапива"

/obj/item/seeds/weeds
	seed_type = "сорняки"

/obj/item/seeds/harebell
	seed_type = "колокольчик"

/obj/item/seeds/sunflowerseed
	seed_type = "подсолнухи"

/obj/item/seeds/lavenderseed
	seed_type = "лаванда"

/obj/item/seeds/brownmold
	seed_type = "плесень"

/obj/item/seeds/appleseed
	seed_type = "яблоко"

/obj/item/seeds/poisonedappleseed
	seed_type = "отравленное яблоко"

/obj/item/seeds/goldappleseed
	seed_type = "золотое яблоко"

/obj/item/seeds/ambrosiavulgarisseed
	seed_type = "амброзия"

/obj/item/seeds/ambrosiadeusseed
	seed_type = "амрозиядеус"

/obj/item/seeds/whitebeetseed
	seed_type = "белокочанная капуста"

/obj/item/seeds/sugarcaneseed
	seed_type = "сахарный тростник"

/obj/item/seeds/watermelonseed
	seed_type = "арбуз"

/obj/item/seeds/pumpkinseed
	seed_type = "тыква"

/obj/item/seeds/limeseed
	seed_type = "лайм"

/obj/item/seeds/lemonseed
	seed_type = "лимон"

/obj/item/seeds
	seed_type = "апельсин"

/obj/item/seeds/poisonberryseed
	seed_type = "ягода"

/obj/item/seeds/deathberryseed
	seed_type = "смертоягода"

/obj/item/seeds/grassseed
	seed_type = "трава"

/obj/item/seeds/cocoapodseed
	seed_type = "какао"

/obj/item/seeds/cherryseed
	seed_type = "вишня"

/obj/item/seeds/tobaccoseed
	seed_type = "табак"

/obj/item/seeds/finetobaccoseed
	seed_type = "хороший табак"

/obj/item/seeds/puretobaccoseed
	seed_type = "нормальный табак"

/obj/item/seeds/badtobaccoseed
	seed_type = "плохой табак"

/obj/item/seeds/kudzuseed
	seed_type = "кудзу"

/obj/item/seeds/peppercornseed
	seed_type = "перчинка"

/obj/item/seeds/garlicseed
	seed_type = "чеснок"

/obj/item/seeds/onionseed
	seed_type = "лук"

/obj/item/seeds/algaeseed
	seed_type = "водоросли"

/obj/item/seeds/bamboo
	seed_type = "бамбук"

/obj/item/seeds/breather
	seed_type = "дыхалка"

/obj/item/seeds/resin
	seed_type = "смолосемянник"

/obj/item/seeds/melonseed
	seed_type = "дыня"

/obj/item/seeds/coffeeseed
	seed_type = "кофе"

/obj/item/seeds/whitegrapeseed
	seed_type = "виноград"

/obj/item/seeds/vanillaseed
	seed_type = "ваниль"

/obj/item/seeds/pineappleseed
	seed_type = "ананасы"

/obj/item/seeds/gukhe
	seed_type = "гухе"

/obj/item/seeds/hrukhza
	seed_type = "грюкза"

/obj/item/seeds/okrri
	seed_type = "окрри"

/obj/item/seeds/ximikoa
	seed_type = "цимикоа"

/obj/item/seeds/pearseed
	seed_type = "груши"

/obj/item/seeds/coconutseed
	seed_type = "кокос"

/obj/item/seeds/qokkloa
	seed_type = "куокклоа"

/obj/item/seeds/aghrassh
	seed_type = "аграшш"

/obj/item/seeds/cinnamon
	seed_type = "циннамон"

/obj/item/seeds/olives
	seed_type = "оливки"

/obj/item/seeds/gummen
	seed_type = "гуммен"

/obj/item/seeds/iridast
	seed_type = "иридаст"

/obj/item/seeds/affelerin
	seed_type = "аффелерин"

/obj/item/seeds/shellfish
	seed_type = "моллюск"

/obj/item/seeds/clam
	seed_type = "моллюск"

/obj/item/seeds/mussel
	seed_type = "мидия"

/obj/item/seeds/oyster
	seed_type = "устрица"

/obj/item/seeds/shrimp
	seed_type = "креветка"

/obj/item/seeds/crab
	seed_type = "краб"

/obj/item/seeds/almondseed
	seed_type = "миндаль"

/obj/machinery/seed_storage
	name = "хранилище семян"
	desc = "Хранит, сортирует и выдает семена."

/obj/machinery/seed_storage/random
	name = "хранилище случайных семян"

/obj/machinery/seed_storage/garden
	name = "садовое хранилище семян"

/obj/machinery/seed_storage/xenobotany
	name = "хранилище семян ксеноботаники"

/obj/machinery/seed_storage/all
	name = "хранилище семян отладки"
