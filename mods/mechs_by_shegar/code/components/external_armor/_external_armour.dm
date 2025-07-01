#include "damage_armour.dm"
/*
Принцип работы брони следующий. Мы смотрим на бронепробитие снаряда
(mech_armor_penetration). Если он больше брони - броня игнорируется.
Если меньше - снаряд полностью блокируется за счёт current_health. Броне наносится
урон равный mech_armor_damage снаряда.
*/
/obj/item/mech_external_armor
	name = "Внешний бронеэлемент меха"
	desc = "В прошлых поколениях, броню на мехов ставили внутри корпуса, что имело мало смысла, т.к броня должна первой закрывать урон. \
	Сегодня же, бронеэлементы устанавливаются модульно, снаружи меха"
	icon = 'mods/mechs_by_shegar/icons/mech_parts_held.dmi'
	icon_state = "external_armor"
	var/broken_icon_state = "external_armor_broken"
	///У каждого бронеэлемента есть текущая прочность
	var/current_health
	///И, соответственно, максимальная прочность
	var/max_health = 300
	var/obj/item/mech_component/owner
	var/list/armors = list(
		bullet = 0,
		laser = 0
		)
	///Приписывается к айкон стейту части меха чтоб получить спрайт брони. Если хотите чтоб
	///Броня была без спрайта - оставьте это поле пустым.
	var/icon_state_suffix

/obj/item/mech_external_armor/Initialize()
	. = ..()
	current_health = max_health

/obj/item/mech_external_armor/examine(mob/user)
	. = ..()
	if(user.skill_check(SKILL_DEVICES, SKILL_TRAINED)) //Снимать и закреплять броню явно проще чем самого меха
		to_chat(user, SPAN_GOOD("Состояние этого бронеэлемента: [current_health]/[max_health]."))
	else
		var/percent = current_health/max_health * 100
		switch(percent)
			if(99 to 100)
				to_chat(user, SPAN_GOOD("Как новый, ни царапинки."))
			if(75 to 98)
				to_chat(user, SPAN_GOOD("Выглядит целым, заметны сколы."))
			if(25 to 75)
				to_chat(user, SPAN_NOTICE("Видны серьёзные повреждения и трещины, но бронеэлемент ещё справится судя по всему."))
			if(0 to 24)
				to_chat(user, SPAN_BAD("Бронеэлемент держится на честном слове, ещё чучуть и лопнет."))
			if(0)
				to_chat(user, SPAN_BAD("РАЗРУШЕН, применению не подлежит."))




/obj/item/mech_external_armor/civil
	name = "Civil mech external armour"
	desc = "This isn't even armor, just part of the mechanical structure. It doesn't provide real protection except against pistol rounds."
	armors = list(
		bullet = 15,
		laser = 15
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
	name = "Buletproof mech external armour"
	desc = "This armour can deflect a wide variety of bullet calibers. It's not very effective against lasers, but it can still stop weaker lasers like the LAEP."
	armors = list(
		bullet = 50,
		laser = 15
		)
	icon_state_suffix = "bullet_armour"


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
	name = "Laserproof mech external armour"
	desc = "This armour designed to absorb nearly all laser fire. While ineffective against most bullets, it offers some resistance to pistol-caliber rounds."
	armors = list(
		bullet = 15,
		laser = 50
		)
	icon_state_suffix = "laser_armour"


//Деды
/obj/item/mech_external_armor/admin
	name = "Experementral mech external armour"
	desc = "Absorbs any projectile. A complex internal Nanotrasen lab development."
	max_health = 1000
	armors = list(
		bullet = 100,
		laser = 100
		)
