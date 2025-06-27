//Применяется для теста стойкости мехов, для расстрелов короче говоря

//Лёгкие
//Пули
/mob/living/exosuit/premade/light/buletproof //Сталь
	external_armor_type = /obj/item/mech_external_armor/buletproof

/mob/living/exosuit/premade/light/buletproof/plasteel //Плассталь лёгкий
	material_type = MATERIAL_PLASTEEL

/mob/living/exosuit/premade/light/buletproof/diamonds //Алмазы лёгкий
	material_type = MATERIAL_DIAMOND
//Лазеры

/mob/living/exosuit/premade/light/laserproof //Сталь лазеры
	external_armor_type = /obj/item/mech_external_armor/laserproof

/mob/living/exosuit/premade/light/laserproof/plasteel //Пласталь лазеры
	material_type = MATERIAL_PLASTEEL

/mob/living/exosuit/premade/light/laserproof/diamonds //Алмазы лазеры
	material_type = MATERIAL_DIAMOND

//Комбаты
// /mob/living/exosuit/premade/combat //Комбат булетпруфф с сталью
//Пули
/mob/living/exosuit/premade/combat/plasteel //Комбат булетпруфф с плассталью
	material_type = MATERIAL_PLASTEEL

/mob/living/exosuit/premade/combat/diamonds //Комбат булетпруфф с плассталью
	material_type = MATERIAL_DIAMOND

//Лазеры
/mob/living/exosuit/premade/combat/laserproof //Стальной комбат с лазеркой
	external_armor_type = /obj/item/mech_external_armor/laserproof

/mob/living/exosuit/premade/combat/laserproof/plasteel //Комбат лазерпруфф с плассталью
	material_type = MATERIAL_PLASTEEL

/mob/living/exosuit/premade/combat/laserproof/diamonds //Комбат лазерпруфф с алмазами
	material_type = MATERIAL_DIAMOND


//Тяжёлые мехи
//Пули
// /mob/living/exosuit/premade/heavy //Тяж булетпруфф с сталью

/mob/living/exosuit/premade/heavy/plasteel //Тяж булетпруфф с пласталью
	material_type = MATERIAL_PLASTEEL

/mob/living/exosuit/premade/heavy/diamonds //Тяж булетпруфф с алмазами
	material_type = MATERIAL_DIAMOND

//Лазеры
/mob/living/exosuit/premade/heavy/laserproof  //Тяж лазерпруфф с сталью
	external_armor_type = /obj/item/mech_external_armor/laserproof

/mob/living/exosuit/premade/heavy/laserproof/plasteel //Тяж лазерпруфф с плассталью
	material_type = MATERIAL_PLASTEEL

/mob/living/exosuit/premade/heavy/laserproof/diamonds //Тяж лазерпруфф с алмазами
	material_type = MATERIAL_DIAMOND


/obj/item/gun/projectile/shotgun/magshot/test
	magazine_type = /obj/item/ammo_magazine/shotgunmag/test
	allowed_magazines = /obj/item/ammo_magazine/shotgunmag/test

/obj/item/ammo_magazine/shotgunmag/test
	max_ammo = 1000
