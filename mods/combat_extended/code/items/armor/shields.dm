/*
	COMBAT_EXTENDED — щиты: типы из `code/game/objects/items/weapons/shields.dm` и хитиновые щиты
	генокрада из `code/game/gamemodes/changeling/powers/armblade.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов». Механика — `code/shields.dm`.

	Своей брони у щитов Bay нет: там блок решает бросок. Броня задана по замыслу Bay — `max_block`,
	`can_block_lasers` и описаниям. Зоны не перечислены — у щита их закрывают зоны по умолчанию из
	`code/shields.dm`: большой щит.
*/

/obj/item/shield/riot
	// «Plastic shields do not stop bullets or lasers ... Will block beanbags, rubber bullets, and
	// stunshots just fine»: пули проходят, лучей нет вовсе, удар и тупые снаряды гасит.
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_MINOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
	)
	// Поднятый щит закрывает тело — видно, что носитель укрылся.
	ce_cover_sprite_moves = TRUE
	// Спрайт в правой руке лицом на запад нарисован задом наперёд: щит за спиной, а не перед собой, и
	// это не зеркало левой руки лицом на восток. Так же у пластасталевого щита, он наследует флаг.
	ce_flip_right_west_sprite = TRUE

/obj/item/shield/riot/metal
	// Пластасталь: `max_block = 50` останавливает пистолеты и винтовки, `can_block_lasers` — лучи.
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_RIFLES,
		energy = ARMOR_ENERGY_STRONG,
		bomb = ARMOR_BOMB_RESISTANT
	)

/obj/item/shield/buckler
	// «Not very good at stopping projectiles»: `max_block = 15`, дерево со сталью. Пулю деревянный
	// щит не держит, оси `bullet` нет.
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR
	)
	// Маленький: укрыться за ним нельзя, стойка одна. Держат его перед собой — он закрывает грудь,
	// руку и кисть со щитом.
	ce_stance_switchable = FALSE
	ce_aim_zones = list(BP_CHEST, CE_SHIELD_ARM, CE_SHIELD_HAND)

/obj/item/shield/energy
	// «Capable of stopping most projectile and melee attacks». Лучи держит лучше пуль: в Bay шанс
	// блока падает с уроном пули, а энергетические снаряды он блокирует всегда.
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_RIFLES,
		energy = ARMOR_ENERGY_SHIELDED,
		bomb = ARMOR_BOMB_PADDED
	)
	// Поднятый щит закрывает тело — видно, что носитель укрылся.
	ce_cover_sprite_moves = TRUE
	// Поле, а не плита: не изнашивается, а остановленное гасит целиком — руке передавать нечего.
	ce_armor_nonphysical = TRUE

/obj/item/shield/riot/changeling
	// Хитин не поднимается вслед за стойкой, а его спрайт в правой руке нарисован верно.
	ce_cover_sprite_moves = FALSE
	ce_flip_right_west_sprite = FALSE

/obj/item/shield/riot/changeling/greater
	// `max_block = 50` и `can_block_lasers`, как у пластасталевого щита.
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_RIFLES,
		energy = ARMOR_ENERGY_STRONG,
		bomb = ARMOR_BOMB_RESISTANT
	)
