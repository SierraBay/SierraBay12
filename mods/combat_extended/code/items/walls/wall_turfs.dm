/*
	COMBAT_EXTENDED — клетки-стены без материала: типы из `code/game/turfs/simulated/wall_shuttle.dm`,
	`code/game/turfs/unsimulated/walls.dm` и `code/modules/mining/mine_turfs.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Шанс рикошета пули от клетки под 45° к ней, % (`projectile_ricochet.dm`). У стены
	`/turf/simulated/wall` шанс даёт материал (`wall_materials.dm`); у этих клеток материала нет, и
	число стоит на самой клетке. Подтип без своего значения берёт значение родителя.
*/

/turf/simulated/shuttle/wall
	// Обшивка шаттла: как обычная армированная стена — сталь и пласталь.
	ce_ricochet_chance = 42

/turf/unsimulated/wall
	// Несокрушимая стена ЦК, админской зоны и VR: как обычная армированная.
	ce_ricochet_chance = 42

/turf/unsimulated/wall/fakeglass
	// Нарисованное окно: голое стекло не рикошетит.
	ce_ricochet_chance = 0

/turf/unsimulated/wall/cult
	// Камень культа: как его материал.
	ce_ricochet_chance = 16

/turf/unsimulated/mineral
	// Непроходимая порода: как песчаник.
	ce_ricochet_chance = 9

/turf/simulated/mineral
	// Порода астероидов и планет: как песчаник.
	ce_ricochet_chance = 9
