/datum/category_item/underwear/top
	underwear_name = "bra"
	underwear_type = /obj/item/underwear/top

/datum/category_item/underwear/top/none
	name = "Нет"
	always_last = TRUE
	underwear_type = null

/datum/category_item/underwear/top/none/is_default(gender)
	return gender != FEMALE

/datum/category_item/underwear/top/bra
	is_default = TRUE
	name = "Бюстгалтер"
	icon_state = "bra"
	has_color = TRUE

/datum/category_item/underwear/top/bra/is_default(gender)
	return gender == FEMALE

/datum/category_item/underwear/top/sports_bra
	name = "Спортивное бра"
	icon_state = "sports_bra"
	has_color = TRUE

/datum/category_item/underwear/top/sports_bra_alt
	name = "Спортивное бра, другой"
	icon_state = "sports_bra_alt"
	has_color = TRUE

/datum/category_item/underwear/top/lacy_bra
	name = "Кружевной бюстгалтер"
	icon_state = "lacy_bra"

/datum/category_item/underwear/top/lacy_bra_alt
	name = "Кружевной бюстгалтер, другой"
	icon_state = "lacy_bra_alt"

/datum/category_item/underwear/top/halterneck_bra
	name = "Халтернек бюстгалтер"
	icon_state = "halterneck_bra"
	has_color = TRUE

/datum/category_item/underwear/top/tube_top
	name = "Топ"
	underwear_name = "tube top"
	icon_state = "tubetop"
	has_color = TRUE
