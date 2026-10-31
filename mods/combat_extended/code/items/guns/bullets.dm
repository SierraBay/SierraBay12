/*
	COMBAT_EXTENDED — пули: типы из `code/modules/projectiles/projectile/bullets.dm`,
	`code/game/objects/items/weapons/grenades/explosive.dm`, `code/modules/spells/hand/blood_shards.dm`
	и `mods/guns/code/ammo.dm`, гильзы — из `code/modules/projectiles/ammunition/bullets.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Сколько раз снаряд рикошетит от стен (`projectile_ricochet.dm`). По умолчанию — ни разу: ракета,
	гироджет, дротик, электрод и всё, чего здесь нет, в стену попадают. Рикошетят семейства цельных
	пуль; внутри семейства ноль снова получают мягкие пули, как в OnyxBay (`can_ricochet`), и
	противоматериальные.

	Собственный удар (`ce_blunt_penetration`, `attack_penetration.dm`) — у патронов, чей удар,
	выведенный из урона, далёк от CE: картечи и обоих патронов 7mmR. Числа — из `Defs/Ammo` CE, в
	настоящих МПа, переведённых в Бэй МПа. Пистолеты и остальное оставлены на выводе нарочно: их удар
	откалиброван по бронеплитам (README, «Собственный удар патронов»).

	Подтип без своего значения берёт значение родителя: новый патрон в семействе рикошетит, пока ему
	здесь не поставлен ноль, и бьёт ударом родителя, пока его не сбросить в null.
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

/obj/item/projectile/bullet/pellet/shotgun
	// Картечь 12 калибра, на дробину — `Bullet_12Gauge_Buck`, 4.52 МПа. Вывод из урона давал 16.5:
	// дробина лёгкая, а урон у неё как у половины пистолета. Шесть остановленных дробин в упор
	// наносили через medium-вставку около 42 урона; с ударом CE дробину останавливает и тупая ось.
	ce_blunt_penetration = 4.52 * CE_BLUNT_DISPLAY_DIVISOR

/obj/item/projectile/bullet/pellet/shotgun/flechette
	// Флешетта — бронебойная стрелка, не картечь: у CE для неё числа нет, удар — выводом из урона.
	ce_blunt_penetration = null

/obj/item/projectile/bullet/rifle
	// Винтовочные пули обоих калибров.
	ce_ricochets_max = 1

/obj/item/projectile/bullet/rifle/military
	// Ослабленный патрон 7mmR, «low-power» — `Bullet_762x51mmNATO_FMJ_SB`, 7.62 из короткого
	// ствола, 37.82 МПа. Вывод давал 33.0, а штатный 7mmR — тот же удар, что у 5mmR.
	ce_blunt_penetration = 37.82 * CE_BLUNT_DISPLAY_DIVISOR

/obj/item/projectile/bullet/rifle/military_standard
	// Штатный патрон 7mmR. В коре он стреляет той же пулей, что и 5mmR (`bullet/rifle`), и тяжелее
	// бил бы только с отдельной пулей: урон и AP прежние, свой только удар — `Bullet_762x51mmNATO_FMJ`,
	// 66.72 МПа против 37.1 у 5mmR. В CE 7.62 NATO несёт почти вдвое больше 5.56.
	ce_blunt_penetration = 66.72 * CE_BLUNT_DISPLAY_DIVISOR

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
	// Учебная пуля на 5 урона удара ослабленного патрона не наследует.
	ce_blunt_penetration = null

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

/obj/item/ammo_casing/rifle/military
	// Штатный патрон 7mmR — со своей пулей, см. `bullet/rifle/military_standard` выше. Ослабленный и
	// учебный задают свою пулю сами.
	projectile_type = /obj/item/projectile/bullet/rifle/military_standard
