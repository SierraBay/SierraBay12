/*
	COMBAT_EXTENDED — инъекторы: типы из `code/modules/reagents/reagent_containers/syringes.dm`,
	`hypospray.dm` и `borghypo.dm`. Как устроена папка `code/items/` — README, раздел «Числа
	предметов». Механика — `code/injections.dm`.

	0.5 мм — между одеждой с подбоем и кевларом: униформу охраны (0.4 мм) укол проходит, кевларовую
	вставку и скрытый жилет (0.6 мм), каски, плиты и наручи (от 1.1 мм) — нет.
*/

/obj/item/reagent_containers/syringe
	// Игла встречает и естественную броню: хитин GAS (1.6 мм) её останавливает.
	ce_injection_pen = 0.5

/obj/item/reagent_containers/hypospray
	// Струя вместо иглы: сквозь одежду бьёт не дальше иглы, а естественную броню проходит.
	// Наследуют гипоспрей с ампулой и автоинъекторы.
	ce_injection_pen = 0.5
	ce_injection_jet = TRUE

/obj/item/reagent_containers/borghypo
	// Тот же гипоспрей в манипуляторе борга.
	ce_injection_pen = 0.5
	ce_injection_jet = TRUE
