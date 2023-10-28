/datum/category_item/underwear/bottom
	underwear_gender = PLURAL
	underwear_name = "underwear"
	underwear_type = /obj/item/underwear/bottom

/datum/category_item/underwear/bottom/none
	name = "Нет"
	always_last = TRUE
	underwear_type = null

/datum/category_item/underwear/bottom/briefs
	name = "Треугольные трусы"
	underwear_name = "briefs"
	icon_state = "briefs"
	has_color = TRUE

/datum/category_item/underwear/bottom/briefs/is_default(gender)
	return gender != FEMALE

/datum/category_item/underwear/bottom/boxers_loveheart
	name = "Боксёрки в сердечко"
	underwear_name = "boxers"
	icon_state = "boxers_loveheart"

/datum/category_item/underwear/bottom/boxers
	name = "Боксёрки"
	underwear_name = "boxers"
	icon_state = "boxers"
	has_color = TRUE

/datum/category_item/underwear/bottom/boxers_green_and_blue
	name = "Боксёрки в зелёно-голубую полоску"
	underwear_name = "boxers"
	icon_state = "boxers_green_and_blue"

/datum/category_item/underwear/bottom/panties
	name = "Трусы"
	underwear_name = "panties"
	icon_state = "panties"
	has_color = TRUE

/datum/category_item/underwear/bottom/panties/is_default(gender)
	return gender == FEMALE

/datum/category_item/underwear/bottom/lacy_thong
	name = "Кружевные стринги"
	underwear_name = "thong"
	icon_state = "lacy_thong"

/datum/category_item/underwear/bottom/lacy_thong_alt
	name = "Кружевные стринги, другой"
	underwear_name = "thong"
	icon_state = "lacy_thong_alt"
	has_color = TRUE

/datum/category_item/underwear/bottom/panties_alt
	name = "Трусы, другой"
	underwear_name = "panties"
	icon_state = "panties_alt"
	has_color = TRUE

/datum/category_item/underwear/bottom/compression_shorts
	name = "Компрессионные шорты"
	icon_state = "compression_shorts"
	has_color = TRUE

/datum/category_item/underwear/bottom/thong
	name = "Стринги"
	underwear_name = "thong"
	icon_state = "thong"
	has_color = TRUE

/datum/category_item/underwear/bottom/expedition_pt_shorts
	name = "Свободные шорты экспедиционного корпуса"
	icon_state = "expedition_shorts"

/datum/category_item/underwear/bottom/fleet_pt_shorts
	name = "Свободные шорты флота"
	icon_state = "fleet_shorts"

/datum/category_item/underwear/bottom/army_pt_shorts
	name = "Свободные шорты армейские"
	icon_state = "army_shorts"

/datum/category_item/underwear/bottom/longjon
	name = "Бриджи"
	underwear_name = "long johns"
	icon_state = "ljonb"
	has_color = TRUE
