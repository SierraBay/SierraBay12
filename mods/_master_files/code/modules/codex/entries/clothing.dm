/*
	COMBAT_EXTENDED — точные рейтинги брони в кодексе одежды и, в самом низу, чем её латать
	(`mods/combat_extended/code/armor_repair.dm`).

	Оверрайд нужен именно здесь: кор версия `/obj/item/clothing/get_mechanics_info()` собирает
	свой текст сама и `..()` не зовёт, поэтому общий вариант на `/obj/item` до неё не доходит.

	Аксессуары ловятся этим же оверрайдом: `/obj/item/clothing/accessory` — подтип одежды,
	так что бронепластины плитоноски показывают свои числа наравне с жилетами.
*/
/obj/item/clothing/get_mechanics_info()
	return ce_codex_join(ce_append_codex(..()), ce_get_repair_codex())
