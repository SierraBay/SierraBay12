/obj/item/projectile/bullet/nullglass
	name = "nullglass bullet"
	// Против псиоников, а не против брони: урон низкий, но заметная его часть проходит пластины, а с
	// ним и осколок, глушащий псионику. Сквозь medium-вставку проходит 14 урона, сквозь
	// tactical-пластину 5, merc-плита держит. Осколок застревает только у пробившей пули, с шансом
	// `0.5 × урон раны × penetration_modifier`: с 2 это четверть без брони (COMBAT_EXTENDED, README,
	// «Нульглас и стальное холодное оружие»). Здесь, а не в моде: модпак подключается позже мода.
	damage = 25
	armor_penetration = 50
	penetration_modifier = 2
	shrapnel_type = /obj/item/material/shard/nullglass

/obj/item/projectile/bullet/nullglass/disrupts_psionics()
	return src

/obj/item/ammo_casing/pistol/magnum/nullglass
	desc = "A revolver bullet casing with a nullglass coating."
	projectile_type = /obj/item/projectile/bullet/nullglass

/obj/item/ammo_casing/pistol/magnum/nullglass/disrupts_psionics()
	return src

/obj/item/ammo_magazine/speedloader/magnum/nullglass
	ammo_type = /obj/item/ammo_casing/pistol/magnum/nullglass
