
/* CARDS
 * ========
 */

/obj/item/card/id/farfleet/droptroops
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn, access_away_iccgn_droptroops)

/obj/item/card/id/farfleet/droptroops/sergeant
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn, access_away_iccgn_droptroops, access_away_iccgn_sergeant)

/obj/item/card/id/farfleet/fleet
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn)

/obj/item/card/id/farfleet/fleet/captain
	desc = "An identification card issued to ICCG crewmembers aboard the Farfleet Recon Craft."
	icon_state = "base"
	access = list(access_away_iccgn, access_away_iccgn_captain)

/* CLOTHING
 * ========
 */


/obj/item/clothing/under/iccgn/service_command
	accessories = list(
		/obj/item/clothing/accessory/iccgn_patch/pioneer
	)

/obj/item/clothing/under/iccgn/utility
	accessories = list(
		/obj/item/clothing/accessory/iccgn_patch/pioneer
	)

/obj/item/clothing/under/iccgn/pt
	accessories = list(
		/obj/item/clothing/accessory/iccgn_patch/pioneer
	)

/obj/item/storage/belt/holster/security/tactical/farfleet/New()
	..()
	new /obj/item/gun/projectile/pistol/optimus(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/ammo_magazine/pistol/double(src)

/obj/item/storage/belt/holster/security/farfleet/iccgn_pawn/New()
	..()
	new /obj/item/gun/projectile/pistol/bobcat(src)
	new /obj/item/ammo_magazine/pistol(src)
	new /obj/item/ammo_magazine/pistol(src)


/* WEAPONARY
 * ========
 */

/obj/item/gun/projectile/automatic/assault_rifle/heltek
	name = "LA-700"
	desc = "HelTek LA-700 is a standart equipment of ICCG Space-assault Forces. Looks very similiar to STS-35."
	icon = 'mods/maps/farfleet/icons/iccg_rifle.dmi'
	icon_state = "iccg_rifle"

/obj/item/gun/projectile/automatic/assault_rifle/heltek/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "iccg_rifle"
		wielded_item_state = "arifle-wielded"
	else
		icon_state = "iccg_rifle-empty"
		wielded_item_state = "arifle-wielded-empty"

/obj/item/gun/projectile/automatic/mr735
	name = "MR-735"
	desc = "A cheap rifle for close quarters combat, with an auto-firing mode available. HelTek MR-735 is a standard rifle for ICCG Space-assault Forces, designed without a stock for easier storage and combat in closed spaces. Perfect weapon for some ship's crew."
	icon = 'mods/maps/farfleet/icons/mr735.dmi'
	icon_state = "nostockrifle"
	item_state = "mr735nostockrifle"
	item_icons = list(
		icon_l_hand = 'mods/maps/farfleet/icons/mr735.dmi',
		icon_r_hand = 'mods/maps/farfleet/icons/mr735.dmi',
		)
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	bulk = GUN_BULK_RIFLE
	wielded_item_state = "mbr735nostockrifle_wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'

	//Assault rifle, burst fire degrades quicker than SMG, worse one-handing penalty, slightly increased move delay
	firemodes = list(
		list(mode_name="semi auto",      burst=1,    fire_delay=null, one_hand_penalty=8,  burst_accuracy=null,                dispersion=null),
		list(mode_name="2-round bursts", burst=2,    fire_delay=null, one_hand_penalty=9,  burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="full auto",      burst=1,    fire_delay=1.7,    burst_delay=1.3,     one_hand_penalty=7,  burst_accuracy=list(0,-1,-1), dispersion=list(1.3, 1.5, 1.7, 1.9, 2.2), autofire_enabled=1)
		)

/obj/item/gun/projectile/automatic/mr735/update_icon()
	..()
	if(ammo_magazine)
		icon_state = "nostockrifle"
		wielded_item_state = "mr735nostockrifle-wielded"
	else
		icon_state = "nostockrifle-empty"
		wielded_item_state = "mr735nostockrifle-wielded-empty"


/obj/item/gun/projectile/automatic/mbr
	name = "MBR"
	desc = "A shabby bullpup carbine. Despite its size, it looks a little uncomfortable, but it is robust. HelTek MBR is a standart equipment of ICCG Space-assault Forces, designed in a bullpup layout. Possesses autofire and is perfect for the ship's crew."
	icon = 'mods/maps/farfleet/icons/mbr.dmi'
	icon_state = "mbr_bullpup"
	item_state = "mbr_bullpup"
	item_icons = list(
		icon_l_hand = 'mods/maps/farfleet/icons/mbr.dmi',
		icon_r_hand = 'mods/maps/farfleet/icons/mbr.dmi',
		)
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	bulk = GUN_BULK_RIFLE + 1
	wielded_item_state = "mbr_bullpup-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'

	firemodes = list(
		list(mode_name="semi auto",      burst=1,    fire_delay=null, one_hand_penalty=8,  burst_accuracy=null,                dispersion=null),
		list(mode_name="2-round bursts", burst=2,    fire_delay=null, one_hand_penalty=9,  burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="full auto",      burst=1,    fire_delay=1.7,    burst_delay=1.3,     one_hand_penalty=7,  burst_accuracy=list(0,-1,-1), dispersion=list(1.3, 1.5, 1.7, 1.9, 2.2), autofire_enabled=1)
		)

/obj/item/gun/projectile/automatic/mbr/update_icon()
	..()
	if(ammo_magazine)
		icon_state = "mbr_bullpup"
	else
		icon_state = "mbr_bullpup-empty"

// CSS Anti-psionics stuff

/obj/item/ammo_casing/pistol/nullglass
	desc = "A 10mm bullet casing with a nullglass coating."
	projectile_type = /obj/item/projectile/bullet/nullglass

/obj/item/ammo_casing/pistol/nullglass/disrupts_psionics()
	return src

/obj/item/ammo_magazine/pistol/nullglass
	ammo_type = /obj/item/ammo_casing/pistol/nullglass

/* MISC
 * ========
 */

/obj/item/paper/farfleet/turrets
	name = "About Turrets"
	info = {"<h1>По поводу турелей.</h1>
			<p>Вася, я не знаю, как ты настраивал эти чёртовы турели, но у них слетает проверка доступа каждый раз как весь экипаж уходит в криосон. Да, я знаю, что они не должны сбоить из-за того, что все спят, но вот они так делают. Наше счастье, что они просто начинают оглушающим лучом бить,а не летальным режимом.</p>
			<h1>ПЕРЕЗАГРУЗИ КОНТРОЛЛЕР ТУРЕЛЕЙ, КАК ПОЙДЁШЬ В АНГАР.</h1>
		"}

/obj/item/paper/farfleet/engines
	name = "Engines Usage"
	info = {"
		<div style="text-align: center;">
			<p>Я не буду сейчас долго расписывать как работает атмосфера на Гарибальди, которую гайцы ТОЧНО не утащили у клятых марсиан, но принцип работы примерно следующий:</p>
			<p>Основные маршевые двигатели - ионные. Да, не слишком быстро, но надёжно если после затухания реакции в токамаке сможете нормально его настроить. А газовые двигатели - УСКОРИТЕЛИ. Но летать на них постоянно не советую, углекислота не бесконечная.</p>
		</div>
		<p><i>Ченков В.П.</i></p>
	"}
