/*
	COMBAT_EXTENDED — подкожная броня: типы из `code/modules/augment/passive/armor.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов». Механика —
	`code/subdermal_armor.dm`.

	В Bay сетка режет физический урон множителем: 0.8 у обычной, 0.75 у хитина генокрада. Здесь
	множитель снят, а броня подобрана так, чтобы против обычного оружия выходило близко к нему.
	Лучей и огня сетка не держит, как и в Bay: `burn_mult` там единица, а описание силы генокрада
	прямо говорит, что от лазеров она не защищает.
*/

/obj/item/organ/internal/augment/armor
	// «Prevent tearing and puncturing»: мягкая сетка. 1.0 мм против пуль пропускает 77% пистолета,
	// 0.4 мм против клинков — 74% ножа, 16 МПа — удар чуть слабее.
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_SMALL
	)
	brute_mult = 1
	// Почти ещё один слой плоти человека (0.22 мм): органы за сеткой задеть труднее.
	ce_density_rha = 0.2

/obj/item/organ/internal/augment/armor/changeling
	// Кость и хитин — жёсткая броня. 1.6 мм против клинков останавливают нож, 60 МПа гасят удар
	// как лёгкая плита, против пуль — те же 1.0 мм, что у сетки.
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR
	)
	brute_mult = 1
