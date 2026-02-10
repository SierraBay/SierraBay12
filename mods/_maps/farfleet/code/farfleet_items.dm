
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

//Voidsuit

/obj/item/clothing/head/helmet/space/void/farfleeticcgn
	name = "iccgn pioneer helmet"
	desc = "The deep orange visor recessed into the helmet provides a surprisingly wide view of the outside world while keeping everything inside safe and sound."
	icon_state = "iccgn_helm"
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN,SPECIES_IPC)
	light_overlay = "explorer_light"

/obj/item/clothing/suit/space/void/farfleeticcgn
	name = "iccgn pioneer voidsuit"
	desc = "Outfitted with a large pauldron intended to face towards danger, this Confederate suit is built to resist small arms fire while on patrol along the frontiers of space."
	icon_state = "rig_iccgn"
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword,/obj/item/handcuffs)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN,SPECIES_IPC)

/obj/item/clothing/suit/space/void/farfleeticcgn/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/farfleeticcgn
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON


//Ammo Box

/obj/item/storage/box/ammo/jaguar
	name = "box of Jaguar Stik"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_magazine/machine_pistol = 7)

/obj/item/storage/box/ammo/heavy
	name = "box of LA-700 Magazine"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_magazine/rifle = 7)
