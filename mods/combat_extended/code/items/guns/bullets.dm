/*
	COMBAT_EXTENDED — пули: типы из `code/modules/projectiles/projectile/bullets.dm`,
	`code/game/objects/items/weapons/grenades/explosive.dm`, `code/modules/spells/hand/blood_shards.dm`
	и `mods/guns/code/ammo.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Сколько раз снаряд рикошетит от стен (`projectile_ricochet.dm`). По умолчанию — ни разу: ракета,
	гироджет, дротик, электрод и всё, чего здесь нет, в стену попадают. Рикошетят семейства цельных
	пуль; внутри семейства ноль снова получают мягкие пули, как в OnyxBay (`can_ricochet`), и
	противоматериальные.

	Подтип без своего значения берёт значение родителя: новый патрон в семействе рикошетит, пока ему
	здесь не поставлен ноль.
*/

/obj/item/projectile/bullet/pellet
	// Дробь и картечь: облако отскакивает целиком, один раз.
	ce_ricochets_max = 1

/obj/item/projectile/bullet/pistol
	// Пистолетные пули, в том числе holdout и скоростные.
	ce_ricochets_max = 1

/obj/item/projectile/bullet/pistol/rubber
	// Резина слишком мягкая: плющится о стену.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/flechette
	// 4-мм стрелка: `penetrating = 1`, сквозь стены не проходит.
	ce_ricochets_max = 1

/obj/item/projectile/bullet/shotgun
	// Слаг, в том числе слаг автодробовика меха.
	ce_ricochets_max = 1

/obj/item/projectile/bullet/shotgun/beanbag
	// Мешочек с дробью, а с ним и сеть: мягкие.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/rifle
	// Винтовочные пули обоих калибров.
	ce_ricochets_max = 1

/obj/item/projectile/bullet/rifle/shell
	// Противоматериальная, а с ней APDS и хитскан-трассер: рикошет не трогает AP, и отскочившая
	// сохраняла бы AP 70 — 19 мм пробития из 20.5 — и оглушение со сбиванием с ног.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/pistol/practice
	// Учебные пули крошатся о стену.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/rifle/practice
	ce_ricochets_max = 0

/obj/item/projectile/bullet/rifle/military/practice
	ce_ricochets_max = 0

/obj/item/projectile/bullet/shotgun/practice
	ce_ricochets_max = 0

/obj/item/projectile/bullet/pistol/cap
	// Пистон: пули нет.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/pellet/fragment
	// Осколки гранат и баллонов: два рикошета, как в Aurora. В закрытой комнате граната страшнее.
	ce_ricochets_max = 2

/obj/item/projectile/bullet/pellet/blood
	// Осколки крови — заклинание, а не металл.
	ce_ricochets_max = 0

// Модпак `guns` подключается глобально, но позже мода: его дефайна здесь ещё не видно.
/obj/item/projectile/bullet/shotgun/manstopper
	// Менстоппер — мягкий экспансивный слаг: плющится о стену, как резина.
	ce_ricochets_max = 0
