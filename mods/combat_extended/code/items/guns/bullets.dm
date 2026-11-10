/*
	COMBAT_EXTENDED. Пули: типы из `code/modules/projectiles/projectile/bullets.dm`,
	`code/game/objects/items/weapons/grenades/explosive.dm`, `code/modules/spells/hand/blood_shards.dm`
	и `mods/guns/code/ammo.dm`, гильзы из `code/modules/projectiles/ammunition/bullets.dm`.
	Как устроена папка `code/items/`: README, раздел "Числа предметов".

	Сколько раз снаряд рикошетит от стен (`projectile_ricochet.dm`). По умолчанию ни разу: ракета,
	гироджет, дротик, электрод и всё, чего здесь нет, в стену попадают. Рикошетят семейства цельных
	пуль. Внутри семейства ноль снова получают мягкие пули, как в OnyxBay (`can_ricochet`), и
	противоматериальные.

	Own impact (`ce_blunt_penetration`, `attack_penetration.dm`) is set where the derived value is far
	from CE: buckshot and standard 7.62x39. Other rounds use derived impact, calibrated against armor plates.

	The rifle families keep their core paths, but `rifle` is 7.62x39 and `mil_rifle` is 5.56x45.
	New AP and HP rounds are in `code/items/ammo/`.

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
	// Картечь 12 калибра, на дробину: `Bullet_12Gauge_Buck`, 4.52 МПа. Вывод из урона давал 16.5:
	// дробина лёгкая, а урон у неё как у половины пистолета. Шесть остановленных дробин в упор
	// наносили через medium-вставку около 42 урона. С ударом CE дробину останавливает и тупая ось.
	ce_blunt_penetration = 4.52

/obj/item/projectile/bullet/pellet/shotgun/flechette
	// Флешетта это бронебойная стрелка, не картечь: у CE для неё числа нет, удар выводом из урона.
	ce_blunt_penetration = null

/obj/item/projectile/bullet/rifle
	// Standard 7.62x39: 55 / AP 20 gives 10.0 mm RHA. CE impact is 41.08 MPa.
	damage = 55
	armor_penetration = 20
	ce_ricochets_max = 1
	ce_blunt_penetration = 41.08

/obj/item/projectile/bullet/rifle/military
	// Low-power 5.56x45: below the standard round in damage, sharp penetration, and impact.
	damage = 40
	armor_penetration = 15
	ce_blunt_penetration = null

/obj/item/projectile/bullet/rifle/military_standard
	// Standard 5.56x45: 45 / AP 25 gives 10.5 mm RHA and derived impact.
	damage = 45
	armor_penetration = 25
	ce_blunt_penetration = null

/obj/item/projectile/bullet/rifle/shell
	// Противоматериальная, а с ней APDS и хитскан-трассер: рикошет не трогает AP, и отскочившая
	// сохраняла бы AP 70 (19 мм пробития из 20.5) и оглушение со сбиванием с ног.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/rifle/shell/apds
	// Подкалиберный должен пробивать на тир выше обычного снаряда. С кор AP 80 он брал 21.8 мм
	// против 20.5 и по любой броне бил слабее обычного: урона у него меньше, а пробитие почти то
	// же. У CE подкалиберный пробивает в 1.75 раза глубже бронебойного. С AP 125 выходит 29.8 мм:
	// проходит и верх лестницы, `ARMOR_BALLISTIC_HEAVY` (26 мм), и от rifle-плиты вверх бьёт
	// сильнее обычного снаряда. По голому и по лёгкой броне он слабее, урон прежний, 70 против 80.
	armor_penetration = 125

/obj/item/projectile/bullet/pistol/practice
	// Учебные пули крошатся о стену.
	ce_ricochets_max = 0

/obj/item/projectile/bullet/rifle/practice
	ce_ricochets_max = 0
	ce_blunt_penetration = null

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
	// Осколки крови: заклинание, а не металл.
	ce_ricochets_max = 0

// Модпак `guns` подключается глобально, но позже мода: его дефайна здесь ещё не видно.
/obj/item/projectile/bullet/shotgun/manstopper
	// Менстоппер это мягкий экспансивный слаг: плющится о стену, как резина.
	ce_ricochets_max = 0

/obj/item/ammo_casing/rifle/military
	// Standard 5.56x45. Low-power and practice casings select their own projectiles.
	projectile_type = /obj/item/projectile/bullet/rifle/military_standard
