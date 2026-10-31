/*
	COMBAT_EXTENDED — материалы стен: типы из `code/modules/materials/definitions/` —
	`materials_metal.dm`, `materials_stone.dm`, `materials_mineral.dm`, `materials_other.dm`,
	`materials_glass.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Шанс рикошета пули от стены из материала под 45° к ней, % (`projectile_ricochet.dm`). Числа — из
	OnyxBay (`resilience`), для материалов, которых там нет, — по ближайшему. У армированной стены —
	среднее геометрическое двух материалов: обычная армированная (сталь и пласталь) даёт 42.

	Подтип без своего значения берёт значение родителя. Всё, чего здесь нет, — стекло, дерево,
	пластик, ткань, руды — не рикошетит: ноль у базового `/material`.

	Тем же шансом рикошетит закрытая дверь из материала. У стекла шанс стены — ноль, а своё число —
	для армированного окна во всю клетку (`ce_reinforced_window_ricochet_chance`): стекло с арматурой
	пулю вскользь иногда отбивает. Числа — тоже из OnyxBay.
*/

/material/uranium
	ce_ricochet_chance = 16

/material/gold
	// Мягкое. Бронза — подтип — берёт то же.
	ce_ricochet_chance = 4

/material/copper
	// В OnyxBay меди нет: мягкая, как золото.
	ce_ricochet_chance = 4

/material/silver
	ce_ricochet_chance = 9

/material/steel
	// Обычная стена: мерка всей шкалы.
	ce_ricochet_chance = 36

/material/aluminium
	// В OnyxBay алюминия нет: мягкий металл, как серебро.
	ce_ricochet_chance = 9

/material/plasteel
	// Пласталь, а с ней подтипы — титан и OCP: в OnyxBay у всех трёх 49.
	ce_ricochet_chance = 49

/material/osmium
	// В OnyxBay осмия нет: твёрже и плотнее пластали, берёт её число.
	ce_ricochet_chance = 49

/material/platinum
	ce_ricochet_chance = 16

/material/iron
	ce_ricochet_chance = 25

/material/voxalloy
	ce_ricochet_chance = 49

/material/aliumium
	// В OnyxBay чужого сплава нет, а твёрдость у него случайная: как сталь.
	ce_ricochet_chance = 36

/material/diamond
	ce_ricochet_chance = 25

/material/stone
	// Песчаник, а с ним мрамор и бетон.
	ce_ricochet_chance = 9

/material/phoron
	ce_ricochet_chance = 4

/material/cult
	ce_ricochet_chance = 16

/material/cult/reinf
	ce_ricochet_chance = 25

/material/glass
	// Армированное стекло: в OnyxBay 9. Стена и шлюз из голого стекла не рикошетят.
	ce_reinforced_window_ricochet_chance = 9

/material/glass/boron
	// Армированное боросиликатное стекло: в OnyxBay это армированное фороновое, 36.
	ce_reinforced_window_ricochet_chance = 36
