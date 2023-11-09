/obj/item/clothing/ears/headphones
	name = "наушники"
	desc = "Вероятно, слушать музыку на работе не соответствует политике компании... но да и хрен с ним."

/obj/item/clothing/ears/skrell
	name = "украшение хвостов скреллов"
	desc = "Некоторые вещи, которые носят скреллы для украшения своих головных хвостов."

/obj/item/clothing/ears/skrell/chain
	name = "золотые цепочки для хвостов скреллов"
	desc = "Изящная золотая цепочка, которую носят женщины-скреллы для украшения хвостов на голове."

/obj/item/clothing/ears/skrell/chain/silver
	name = "серебряные цепочки для хвостов скреллов"
	desc = "Изящная серебряная цепочка, которую носят женщины-скреллы для украшения хвоста на голове."

/obj/item/clothing/ears/skrell/chain/bluejewels
	name = "золотые цепочки для хвостов скреллов(альт)"
	desc = "Изящная золотая цепочка, украшенная голубыми драгоценными камнями, которую носят женщины-скреллы для украшения хвоста."

/obj/item/clothing/ears/skrell/chain/redjewels
	name = "золотые цепочки для головных хвостов скреллов(альт 2)"
	desc = "Изящная золотая цепочка, украшенная красными драгоценными камнями, которую носят женщины-скреллы для украшения хвоста."

/obj/item/clothing/ears/skrell/chain/ebony
	name = "цепочки для хвостов скреллов из черного дерева"
	desc = "Изящная цепочка из черного дерева, которую женщины-скреллы носят для украшения хвоста на голове."

/obj/item/clothing/ears/skrell/band
	name = "золотые ленты для хвостов скреллов"
	desc = "Золотые металлические ленты, которые носят мужчины-скреллы для украшения хвоста."

/obj/item/clothing/ears/skrell/band/silver
	name = "серебряные ленты для хвостов скреллов"
	desc = "Серебристые металлические ленты, которые носят мужчины-скреллы для украшения хвостов на голове."

/obj/item/clothing/ears/skrell/band/bluejewels
	name = "золотые ленты для хвостов скреллов(альт)"
	desc = "Золотые металлические ленты, украшенные голубыми драгоценными камнями, которые носят мужчины-скреллы для украшения хвостов."

/obj/item/clothing/ears/skrell/band/redjewels
	name = "золотые ленты для хвостов скреллов(альт 2)"
	desc = "Золотые металлические ленты, украшенные красными драгоценными камнями, которые носят мужчины-скреллы для украшения хвостов."

/obj/item/clothing/ears/skrell/band/ebony
	name = "повязки для хвостов скреллов из черного дерева"
	desc = "Ободки из черного дерева, которые носят мужчины-скреллы для украшения хвостов на голове."

/obj/item/clothing/ears/skrell/colored/band
	name = "цветные ленты для хвостов скреллов"
	desc = "Металлические ленты, которые носят мужчины-скреллы для украшения хвостов на голове."

/obj/item/clothing/ears/skrell/colored/chain
	name = "цветные цепочки для хвостов скреллов"
	desc = "Изящная цепочка, которую носят женщины-скреллы для украшения хвоста на голове."

/obj/item/clothing/ears/skrell/cloth_female
	name = "ткань для хвостов скреллов"
	desc = "Платок из ткани, который самки скреллов носят, задрапировав хвост на голове."

/obj/item/clothing/ears/skrell/cloth_male
	name = "ткань для хвостов скреллов"
	desc = "Тканевая лента, которую носят мужчины-скреллы вокруг хвоста головы."

/obj/item/clothing/ring/material/New(newloc, new_material)
	..(newloc)
	if(!new_material)
		new_material = MATERIAL_STEEL
	material = SSmaterials.get_material_by_name(new_material)
	if(!istype(material))
		qdel(src)
		return
	name = "[material.display_name] кольцо"
	desc = "Кольцо из [material.display_name]."

/obj/item/clothing/ring/engagement
	name = "обручальное кольцо"
	desc = "Обручальное кольцо. Выглядит дорого."

/obj/item/clothing/ring/cti
	name = "CTI ring"
	desc = "Кольцо в память об окончании CTI."

/obj/item/clothing/ring/mariner
	name = "кольцо университета Mariner"
	desc = "Кольцо в честь окончания университета Mariner."

/obj/item/clothing/ring/fleet
	name = "кольцо флота"
	desc = "Кольцо в память о почетной службе на флоте правительства Сол."

/obj/item/clothing/ring/ec
	name = "кольцо Экспедиционного Корпуса"
	desc = "Кольцо в память о почетной службе в Экспедиционном корпусе правительства Сола."

/obj/item/clothing/ring/magic
	name = "магическое кольцо"
	desc = "Странное кольцо с вырезанными на нем символами на каком-то арканном языке."

/obj/item/clothing/ring/reagent/sleepy
	name = "серебряное кольцо"
	desc = "Кольцо, сделанное, похоже, из серебра."

/obj/item/clothing/ring/seal/secgen
	name = "официальная печать Генерального секретаря"
	desc = "Официальная печать Генерального секретаря Центрального правительства Сола, изображенная на серебряном кольце."

/obj/item/clothing/ring/seal/mason
	name = "масонское кольцо"
	desc = "На этом масонском перстне изображены квадрат и компас."

/obj/item/clothing/ring/seal/signet
	name = "перстень с печаткой"
	desc = "Перстень-печатка для тех случаев, когда вы слишком искушены, чтобы подписывать письма."

/obj/item/clothing/ring/seal/signet/attack_self(mob/user)
	if(nameset)
		to_chat(user, SPAN_NOTICE("[src] приватезирован!"))
		return

	nameset = 1
	to_chat(user, SPAN_NOTICE("Вы приватизируете [src]!"))
	name = "перстень [user]"
	desc = "Перстень-печатка, принадлежащий [user], для тех случаев, когда вы слишком искушены, чтобы подписывать письма."
