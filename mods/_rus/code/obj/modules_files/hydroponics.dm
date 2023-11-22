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

/obj/item/seeds/update_appearance()
	if(!seed) return

	// Update icon.
	ClearOverlays()
	var/is_seeds = ((seed.seed_noun in list(SEED_NOUN_SEEDS, SEED_NOUN_PITS, SEED_NOUN_NODES)) ? 1 : 0)
	var/image/seed_mask
	var/seed_base_key = "base-[is_seeds ? seed.get_trait(TRAIT_PLANT_COLOUR) : "spores"]"
	if(plant_seed_sprites[seed_base_key])
		seed_mask = plant_seed_sprites[seed_base_key]
	else
		seed_mask = image('icons/obj/flora/seeds.dmi',"[is_seeds ? "seed" : "spore"]-mask")
		if(is_seeds) // Spore glass bits aren't coloured.
			seed_mask.color = seed.get_trait(TRAIT_PLANT_COLOUR)
		plant_seed_sprites[seed_base_key] = seed_mask

	var/image/seed_overlay
	var/seed_overlay_key = "[seed.get_trait(TRAIT_PRODUCT_ICON)]-[seed.get_trait(TRAIT_PRODUCT_COLOUR)]"
	if(plant_seed_sprites[seed_overlay_key])
		seed_overlay = plant_seed_sprites[seed_overlay_key]
	else
		seed_overlay = image('icons/obj/flora/seeds.dmi',"[seed.get_trait(TRAIT_PRODUCT_ICON)]")
		seed_overlay.color = seed.get_trait(TRAIT_PRODUCT_COLOUR)
		plant_seed_sprites[seed_overlay_key] = seed_overlay

	AddOverlays(seed_mask)
	AddOverlays(seed_overlay)

	if(is_seeds)
		src.SetName("пакет [seed.seed_name] [seed.seed_noun]")
		src.desc = "На лицевой стороне изображен [seed.display_name]."
	else
		src.SetName("sample of [seed.seed_name] [seed.seed_noun]")
		src.desc = "Он помечен как происходящий из [seed.seed_name]."

/datum/seed/chili
	display_name = "растение чили"
	seed_name = "чили"

/datum/seed/chili/ice
	seed_name = "ледяной перец чили"
	display_name = "растение ледяного перца чили"

/datum/seed/berry
	seed_name = "ягода"
	display_name = "ягодный куст"

/datum/seed/berry/blue
	seed_name = "черника"
	display_name = "куст черники"

/datum/seed/berry/glow
	seed_name = "светящаяся ягода"
	display_name = "куст светящийся ягоды"

/datum/seed/berry/poison
	seed_name = "ядовитая ягода"
	display_name = "куст ядовитых ягод"

/datum/seed/berry/poison/death
	seed_name = "смертельная ягода"
	display_name = "куст смертельной ягоды"

/datum/seed/nettle
	seed_name = "крапива"
	display_name = "крапива"

/datum/seed/nettle/death
	seed_name = "смертельная крапива"
	display_name = "смертельная крапива"

/datum/seed/tomato
	seed_name = "помидор"
	display_name = "растение помидора"

/datum/seed/tomato/blood
	seed_name = "кровавый помидор"
	display_name = "растение кровавого помидора"

/datum/seed/tomato/killer
	seed_name = "помидор-убийца"
	display_name = "растение помидора-убийцы"

/datum/seed/tomato/blue
	seed_name = "синий помидор"
	display_name = "растение синего помидора"

/datum/seed/tomato/blue/teleport
	seed_name = "блюспейс помидор"
	display_name = "растение блюспейс помидора"

/datum/seed/eggplant
	seed_name = "баклажан"
	display_name = "баклажан"
/datum/seed/apple
	seed_name = "яблоко"
	display_name = "яблоня"

/datum/seed/apple/gold
	seed_name = "золотое яблоко"
	display_name = "золотая яблоня"

/datum/seed/ambrosia
	seed_name = "амброзия вульгарис"
	display_name = "амброзия вульгарис"

/datum/seed/ambrosia/deus
	seed_name = "амброзия деус"
	display_name = "амброзия деус"

/datum/seed/mushroom
	seed_name = "лисичка"
	display_name = "грибница лисичек"

/datum/seed/mushroom/mold
	seed_name = "коричневая плесень"
	display_name = "коричневая плесень"

/datum/seed/mushroom/plump
	seed_name = "шлемник пухлый"
	display_name = "шлемник пухлый"

/datum/seed/mushroom/plump/walking
	seed_name = "ходячий гриб"
	display_name = "грибница ходячих грибов"

/datum/seed/mushroom/hallucinogenic
	seed_name = "рейши"
	display_name = "грибница рейши"

/datum/seed/mushroom/hallucinogenic/strong
	seed_name = "гриб свободы"
	display_name = "грибница гриба свободы"

/datum/seed/mushroom/poison
	seed_name = "мухомор аманита"
	display_name = "грибница мухомора аманита"

/datum/seed/mushroom/poison/death
	seed_name = "разрушающий ангел"
	display_name = "грибница разрушающего ангела"

/datum/seed/mushroom/towercap
	seed_name = "башенка"
	display_name = "грибница башенки"

/datum/seed/mushroom/glowshroom
	seed_name = "светящийся гриб"
	display_name = "грибница светящихся грибов"

/datum/seed/mushroom/plastic
	seed_name = "пластеллиум"
	display_name = "грибница пластеллиума"

/datum/seed/flower
	seed_name = "колокольчик"
	display_name = "грядка колокольчика"

/datum/seed/flower/poppy
	seed_name = "мак"
	display_name = "маковая грядка"

/datum/seed/flower/sunflower
	seed_name = "подсолнух"
	display_name = "подсолнечная грядка"

/datum/seed/flower/lavender
	seed_name = "лаванда"
	display_name = "лавандовая грядка"

/datum/seed/grapes
	seed_name = "виноград"
	display_name = "виноградная лоза"

/datum/seed/grapes/green
	seed_name = "зеленый виноград"
	display_name = "лоза зеленого винограда"
/datum/seed/peanuts
	seed_name = "арахис"
	display_name = "растение арахис"

/datum/seed/peppercorn
	seed_name = "чёрный перец"
	display_name = "растение чёрного перца"

/datum/seed/cabbage
	seed_name = "капуста"
	display_name = "капустная грядка"

/datum/seed/lettuce
	seed_name = "латук"
	display_name = "растение латука"

/datum/seed/banana
	seed_name = "банан"
	display_name = "банановое дерево"

/datum/seed/corn
	seed_name = "кукуруза"
	display_name = "растение кукурузы"

/datum/seed/potato
	seed_name = "картофель"
	display_name = "картофельное растение"

/datum/seed/garlic
	seed_name = "чеснок"
	display_name = "растение чеснока"

/datum/seed/onion
	seed_name = "лук"
	display_name = "луковичное растение"

/datum/seed/soybean
	seed_name = "соя"
	display_name = "растение сои"

/datum/seed/wheat
	seed_name = "пшеница"
	display_name = "росток пшеницы"

/datum/seed/rice
	seed_name = "рис"
	display_name = "грядка риса"

/datum/seed/carrots
	seed_name = "морковь"
	display_name = "морковная грядка"

/datum/seed/weeds
	seed_name = "сорняк"
	display_name = "грядка сорняков"

/datum/seed/whitebeets
	seed_name = "белая свекла"
	display_name = "грядка белой свеклы"

/datum/seed/sugarcane
	seed_name = "сахарный тростник"
	display_name = "грядка сахарного тростника"

/datum/seed/watermelon
	seed_name = "арбуз"
	display_name = "арбузная лоза"

/datum/seed/pumpkin
	seed_name = "тыква"
	display_name = "тыквенная лоза"

/datum/seed/citrus
	seed_name = "лайм"
	display_name = "лаймовое дерево"

/datum/seed/citrus/lemon
	seed_name = "лимон"
	display_name = "лимонное дерево"

/datum/seed/citrus/orange
	seed_name = "апельсин"
	display_name = "апельсиновое дерево"

/datum/seed/grass
	seed_name = "трава"
	display_name = "участок травы"

/datum/seed/cocoa
	seed_name = "какао"
	display_name = "дерево какао"

/datum/seed/cherries
	seed_name = "вишня"
	display_name = "вишневое дерево"

/datum/seed/kudzu
	seed_name = "кудзу"
	display_name = "лиана кудзу"

/datum/seed/diona
	seed_name = "диона"
	display_name = "стручок-репликант"

/datum/seed/shand
	seed_name = "рука Стендарра"
	display_name = "растение рука Стендарра"

/datum/seed/mtear
	seed_name = "слеза Мессы"
	display_name = "Растение слеза Мессы"

/datum/seed/tobacco
	seed_name = "табак"
	display_name = "растение табака"

/datum/seed/tobacco/finetobacco
	seed_name = "мелкий табак"
	display_name = "растение мелкого табака"

/datum/seed/tobacco/puretobacco
	seed_name = "сочный табак"
	display_name = "растение сочного табака"

/datum/seed/tobacco/bad
	seed_name = "низкосортный табак"
	display_name = "растение низкосортного табака"

/datum/seed/algae
	seed_name = "водоросль"
	display_name = "водоросль"

/datum/seed/bamboo
	seed_name = "бамбук"
	display_name = "бамбуковая грядка"

/datum/seed/resin
	seed_name = "растение смолы"
	display_name = "растение смолы"

/datum/seed/breather
	seed_name = "дыхалка"
	display_name = "дыхалка"

/datum/seed/melon
	seed_name = "дыня"
	display_name = "дынная лоза"

/datum/seed/coffee
	seed_name = "кофейное зерно"
	display_name = "кофейное растение"

/datum/seed/grapes/white
	seed_name = "белый виноград"
	display_name = "лоза белого винограда"

/datum/seed/vanilla
	seed_name = "цветок ванили"
	display_name = "цветок ванили"

/datum/seed/pineapple
	seed_name = "ананас"
	display_name = "растение ананас"

/datum/seed/pear
	seed_name = "груша"
	display_name = "грушевое дерево"

/datum/seed/coconut
	seed_name = "кокос"
	display_name = "кокосовое дерево"

/datum/seed/cinnamon
	seed_name = "корица"
	display_name = "коричное дерево"

/datum/seed/olives
	seed_name = "оливки"
	display_name = "оливковое дерево"

/datum/seed/gukhe
	seed_name = "цветение гухе"
	display_name = "цветение гухе"

/datum/seed/hrukhza
	seed_name = "цветок крукза"
	display_name = "цветок крузка"

/datum/seed/okrri
	seed_name = "гриб о'крри"
	display_name = "гриб о'крри"

/datum/seed/ximikoa
	seed_name = "стебли ксими'коа"
	display_name = "грядка ксими'коа"

/datum/seed/qokkloa
	seed_name = "куокк'лоа мох"
	display_name = "куокк'лоа мох"

/datum/seed/aghrassh
	seed_name = "аграсш"
	display_name = "дерево аграсш"

/datum/seed/gummen
	seed_name = "гуммен"
	display_name = "бобовое растение гуммен"

/datum/seed/flower/affelerin
	seed_name = "аффелерин"
	display_name = "цветок аффелерин"

/datum/seed/berry/iridast
	seed_name = "иридаст"
	display_name = "куст иридаста"

/datum/seed/shellfish
	seed_name = "моллюск"
	display_name = "грядка моллюсков"

/datum/seed/shellfish/clam
	seed_name = "моллюск"
	display_name = "грядка с моллюсками"

/datum/seed/shellfish/mussel
	seed_name = "мидия"
	display_name = "грядка с мидиями"

/datum/seed/shellfish/oyster
	seed_name = "устрица"
	display_name = "грядка с устрицами"

/datum/seed/shellfish/shrimp
	seed_name = "креветка"
	display_name = "грядка с креветками"

/datum/seed/shellfish/crab
	seed_name = "краб"
	display_name = "грядка с крабами"

/datum/seed/almond
	seed_name = "миндаль"
	display_name = "растение миндаля"

/obj/item/seeds/cutting
	name = "черенки"
	desc = "Черенки некоторых растений."

/obj/item/seeds/cutting/update_appearance()
	..()
	src.SetName("пакет черенков растения [seed.seed_name]")

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
