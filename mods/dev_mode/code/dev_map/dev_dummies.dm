/*
	Манекены для обстрела.

	Обычный `/mob/living/carbon/human/dummy` бессмертен (`GODMODE`), и урон по нему не виден. Эти
	подтипы смертны и одеты в броню: лестница плит, тактический комплект из карго и два рига.
	Ставятся руками через спавн или редактор карты.
*/

/mob/living/carbon/human/dummy/mortal
	real_name = "Test Dummy (mortal)"
	status_flags = CANPUSH
	/// Экипировка при появлении. null — голый.
	var/singleton/hierarchy/outfit/outfit_type

// Без клиента манекен засыпал бы как SSD и падал.
/mob/living/carbon/human/dummy/mortal/ssd_check()
	return FALSE

/mob/living/carbon/human/dummy/mortal/Initialize(mapload, new_species)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	if(outfit_type)
		return INITIALIZE_HINT_LATELOAD

// Одевается после инициализации всего остального: риг герметизируется на владельце.
/mob/living/carbon/human/dummy/mortal/LateInitialize(mapload)
	var/singleton/hierarchy/outfit/outfit = outfit_by_type(outfit_type)
	outfit.equip(src)

/mob/living/carbon/human/dummy/mortal/light
	real_name = "Test Dummy (light plate)"
	outfit_type = /singleton/hierarchy/outfit/dev_dummy/light

/mob/living/carbon/human/dummy/mortal/medium
	real_name = "Test Dummy (medium plate)"
	outfit_type = /singleton/hierarchy/outfit/dev_dummy/medium

/mob/living/carbon/human/dummy/mortal/tactical
	real_name = "Test Dummy (tactical)"
	outfit_type = /singleton/hierarchy/outfit/dev_dummy/tactical

/mob/living/carbon/human/dummy/mortal/merc
	real_name = "Test Dummy (merc plate)"
	outfit_type = /singleton/hierarchy/outfit/dev_dummy/merc

/mob/living/carbon/human/dummy/mortal/crimson_rig
	real_name = "Test Dummy (crimson hardsuit)"
	outfit_type = /singleton/hierarchy/outfit/dev_dummy/crimson_rig

/mob/living/carbon/human/dummy/mortal/eod_rig
	real_name = "Test Dummy (crimson EOD hardsuit)"
	outfit_type = /singleton/hierarchy/outfit/dev_dummy/eod_rig


/singleton/hierarchy/outfit/dev_dummy
	name = "Dev test dummy"
	hierarchy_type = /singleton/hierarchy/outfit/dev_dummy

/singleton/hierarchy/outfit/dev_dummy/light
	name = "Dev test dummy - light plate"
	suit = /obj/item/clothing/suit/armor/pcarrier/light

/singleton/hierarchy/outfit/dev_dummy/medium
	name = "Dev test dummy - medium plate"
	suit = /obj/item/clothing/suit/armor/pcarrier/medium/guards
	head = /obj/item/clothing/head/helmet

// Состав `/singleton/hierarchy/supply_pack/security/tacticalarmor`, кроме модуля ПНВ: это
// аксессуар для очков, брони он не даёт.
/singleton/hierarchy/outfit/dev_dummy/tactical
	name = "Dev test dummy - tactical"
	uniform = /obj/item/clothing/under/tactical
	suit = /obj/item/clothing/suit/armor/pcarrier/tan/tactical
	head = /obj/item/clothing/head/helmet/tactical
	mask = /obj/item/clothing/mask/balaclava/tactical
	belt = /obj/item/storage/belt/holster/security/tactical
	shoes = /obj/item/clothing/shoes/tactical
	gloves = /obj/item/clothing/gloves/tactical

/singleton/hierarchy/outfit/dev_dummy/merc
	name = "Dev test dummy - merc plate"
	suit = /obj/item/clothing/suit/armor/pcarrier/merc
	head = /obj/item/clothing/head/helmet/merc

// Риг из `back` герметизируется самим `equip()`.
/singleton/hierarchy/outfit/dev_dummy/crimson_rig
	name = "Dev test dummy - crimson hardsuit"
	back = /obj/item/rig/merc

/singleton/hierarchy/outfit/dev_dummy/eod_rig
	name = "Dev test dummy - crimson EOD hardsuit"
	back = /obj/item/rig/merc/heavy


/obj/item/clothing/suit/armor/pcarrier/medium/guards
	accessories = list(/obj/item/clothing/accessory/armor_plate/medium, /obj/item/clothing/accessory/arm_guards, /obj/item/clothing/accessory/leg_guards)
