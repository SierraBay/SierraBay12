/obj/item/mech_external_armor
	name = "Внешний бронеэлемент меха"
	desc = "В прошлых поколениях, броню на мехов ставили внутри корпуса, что имело мало смысла, т.к броня должна первой закрывать урон. \
	Сегодня же, бронеэлементы устанавливаются модульно, снаружи меха"
	///У каждого бронеэлемента есть текущая прочность
	var/current_health
	///И, соответственно, максимальная прочность
	var/max_health = 300
/* Принцип работы брони следующий. Мы смотрим на бронепробитие снаряда
(armor_penetration). Если он больше брони - броня игнорируется.
Если меньше - снаряд полностью блокируется за счёт current_health. Броне наносится
урон равный damage снаряда.
*/
	var/list/armors = list(
		bullet = 0,
		laser = 0,
		)


/*
Неэффективно:
/obj/item/projectile/bullet/shotgun
/obj/item/projectile/bullet/pellet/shotgun/flechette
/obj/item/projectile/bullet/rifle
/obj/item/projectile/bullet/rifle/military

Эффективно:
/obj/item/projectile/bullet/rifle/shell
/obj/item/projectile/bullet/rifle/shell/apds
/obj/item/projectile/beam/pulse/mid
/obj/item/projectile/beam/pulse/heavy
/obj/item/projectile/beam/pulse/destroy
/obj/item/projectile/beam/xray
/obj/item/projectile/beam/xray/midlaser
/obj/item/projectile/beam/sniper
/obj/item/projectile/beam/heavylaser
/obj/item/projectile/beam/midlaser
*/
/obj/item/mech_external_armor/buletproof
	name = "Противопульный бронеэлемент"
	desc = "Элемент способный отбивать самые разнообразые пулевые калибры. Малоэффективен против лазеров."
	armors = list(
		bullet = 50,
		laser = 15,
		)

/*
Неэффективно:
/obj/item/projectile/beam/pulse/mid
/obj/item/projectile/beam/pulse/heavy
/obj/item/projectile/beam/pulse/destroy
/obj/item/projectile/beam/xray
/obj/item/projectile/beam/xray/midlaser
/obj/item/projectile/beam/heavylaser
/obj/item/projectile/beam/midlaser

Эффективно:
/obj/item/projectile/bullet/shotgun
/obj/item/projectile/bullet/pellet/shotgun/flechette
/obj/item/projectile/bullet/rifle
/obj/item/projectile/bullet/rifle/military
/obj/item/projectile/bullet/rifle/shell
/obj/item/projectile/bullet/rifle/shell/apds
/obj/item/projectile/beam/sniper
/obj/item/projectile/beam/pulse/destroy
/obj/item/projectile/beam/xray
/obj/item/projectile/beam/xray/midlaser
*/
/obj/item/mech_external_armor/laserproof
	name = "Противолазерный бронеэлемент"
	desc = "Элемент способный поглащать практически все лазеры. Малоэффективен против пуль"
	armors = list(
		bullet = 15,
		laser = 50,
		)

//Деды
/obj/item/mech_external_armor/admin
	name = "Экспериментальный бронеэлемент"
	desc = "Элемент способный поглащать любой входящий снаряд. Сложная разработка внутренних лабораторий Нанотрейзен."
	max_health = 1000
	armors = list(
		bullet = 100,
		laser = 100,
		)


//УВЫ но все существующие параметры пуль и их пробития просто не имеет смысл и его будет КРАЙНЕ
//Сложно адаптировать, потому, мне пришлось создать новую переменную отвечающая за то как снаряд хорошо поражает технику
/obj/item/projectile
	///Бронепробитие брони меха
	var/mech_armor_penetration = 0
	///Урон по броне меха если не пробил
	var/mech_armor_damage = 0
