/*
	COMBAT_EXTENDED — лучи: типы из `code/modules/projectiles/projectile/beams.dm` и
	`packs/infinity/items/projectile/guns/energy/laser_handmade.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Множитель жара луча (`laser_heat.dm`): сколько жара несёт единица урона, остановленная жёсткой
	бронёй. Пистолеты греют слабее карабинов: тяжёлую броню пистолет только греет, а печёт носителя
	карабин. AP луча срезает жар и сам, поэтому у рентгена и импульса множитель полный.

	Подтип без своего значения берёт значение родителя. Базовый луч — луч «Перуна», поэтому 0.6
	достаётся и лучам, которых здесь нет.
*/

/obj/item/projectile/beam
	// LAEP90 «Перун», смартган, ретро-лазер, энергоревольвер: 40 урона без AP.
	ce_laser_heat_mult = 0.6

/obj/item/projectile/beam/smalllaser
	// LAEP90-C «Стригой» — карманный: 35 урона и греет меньше всех.
	ce_laser_heat_mult = 0.45

/obj/item/projectile/beam/midlaser
	// Карабин G40E: мерка всей шкалы. Остановленное попадание несёт 36 жара.
	ce_laser_heat_mult = 1

/obj/item/projectile/beam/xray
	// Рентген-пистолет G56E-s и карабин G56E (`xray/midlaser`). AP 30 и 50 срезают жар сами.
	ce_laser_heat_mult = 1

/obj/item/projectile/beam/pulse
	// Импульсные пистолет, карабин и винтовка: AP 25–35.
	ce_laser_heat_mult = 1

/obj/item/projectile/beam/sniper
	// Марксманская 9E: 60 урона раз в 3 секунды.
	ce_laser_heat_mult = 1.25

/obj/item/projectile/beam/heavylaser
	// Лазерная пушка: 60 урона, AP 30.
	ce_laser_heat_mult = 1.25

// Самодельный лазер лежит в паке `infinity`, а его подключает только карта Sierra. Карта
// подключается раньше модов, поэтому дефайн пака здесь уже виден.
#ifdef CONTENT_PACK_INFINITY
/obj/item/projectile/beam/lkw
	// Самодельный лазер, средний режим: 30 урона, AP 20.
	ce_laser_heat_mult = 0.9
#endif
