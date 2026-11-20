/*
	COMBAT_EXTENDED: спрайты магазинов (`code/ammo_sprites.dm`), типы из
	`code/modules/projectiles/ammunition/boxes.dm`, затем
	`mods/mechs_by_shegar/code/equipment/combat/ballistic_weapon/machinegun.dm` и
	`mods/mechs_by_shegar/code/premades/death_squad.dm`. Как устроена папка `code/items/`: README,
	раздел "Числа предметов".

	Шесть магазинов и спидлоадеров с основой, перекрашенной Хонком, берут её из `ce_ammo.dmi`: там
	все их кадры наполнения и метки. Подтипы с другим спрайтом возвращаются на кор файл. Метки
	остальных магазинов, у которых они нарисованы, лежат поверх кор спрайта сами
	(`ce_get_mark_overlay()`).
*/

/obj/item/ammo_magazine/speedloader
	icon = CE_AMMO_ICON

/obj/item/ammo_magazine/speedloader/small
	icon = 'icons/obj/weapons/ammo.dmi'

/obj/item/ammo_magazine/speedloader/pclip
	icon = 'icons/obj/weapons/ammo.dmi'

/obj/item/ammo_magazine/speedloader/hpclip
	icon = 'icons/obj/weapons/ammo.dmi'

/obj/item/ammo_magazine/speedloader/clip
	icon = 'icons/obj/weapons/ammo.dmi'

/obj/item/ammo_magazine/machine_pistol
	icon = CE_AMMO_ICON

/obj/item/ammo_magazine/box/emp
	// Коробки россыпи с ионными патронами не задавали спрайт и показывали зелёную `357` по
	// умолчанию. Синяя `empbox` лежала в кор файле без дела.
	icon_state = "empbox"

/obj/item/ammo_magazine/rifle
	icon = CE_AMMO_ICON

/obj/item/ammo_magazine/mil_rifle
	icon = CE_AMMO_ICON

/*
	No player source gives the light 5.56x45 magazine now. It held 14 low-power rounds, the
	heavy one holds 18 standard rounds, and the cost is the same. All 5.56x45 rifles take both.
	The light types stay for admins. The one magazine left has no "heavy" label. The low-power
	rounds stay: their crate is cheaper.
*/

/obj/item/ammo_magazine/mil_rifle/heavy
	labels = null

/obj/item/ammo_magazine/mil_rifle/heavy/practice
	labels = list("practice")

/obj/item/gun/projectile/automatic/bullpup_rifle/light
	magazine_type = /obj/item/ammo_magazine/mil_rifle/heavy

/obj/item/storage/box/ammo/heavy_bullpup
	name = "box of bullpup magazines"

// The ERT ship map places this box.
/obj/item/storage/box/ammo/light_bullpup
	name = "box of bullpup magazines"
	startswith = list(/obj/item/ammo_magazine/mil_rifle/heavy = 6)

/datum/fabricator_recipe/arms_ammo/hidden/magazine_bullpupheavy
	name = "ammunition (bullpup rifle)"

// SSfabrication skips a recipe with no name. Without a path, New() gives it no name.
/datum/fabricator_recipe/arms_ammo/hidden/magazine_bullpuplight
	name = null
	path = null

/obj/item/ammo_magazine/rifle/mech_machinegun
	icon = 'icons/obj/weapons/ammo.dmi'

/obj/item/ammo_magazine/rifle/mech_minigun
	icon = 'icons/obj/weapons/ammo.dmi'
