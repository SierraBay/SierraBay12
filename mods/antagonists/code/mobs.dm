/obj/landmark/corpse/pirate/space
	name = "Space Pirate"
	corpse_outfits = list(/singleton/hierarchy/outfit/pirate/space)
	spawn_flags = CORPSE_SPAWNER_RANDOM_NAMELESS | CORPSE_SPAWNER_ALL_SKIPS

/singleton/hierarchy/outfit/pirate/space
	name = "Space Pirate"
	mask = /obj/item/clothing/mask/gas/half
	glasses =  null
	uniform =  /obj/item/clothing/under/color/black
	back = /obj/item/tank/jetpack/carbondioxide
	gloves = /obj/item/clothing/gloves/thick
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/void/pirate
	head = /obj/item/clothing/head/helmet/space/void/pirate
	l_hand =   null
	l_ear =    null
	r_hand =   null
	l_pocket = /obj/item/tank/oxygen_emergency_extended
	r_pocket = null
	holster =  null
	belt =     null

/obj/item/melee/energy/machete/activated
	active = TRUE

/mob/living/simple_animal/hostile/human/pirate/space
	name = "\improper Space Pirate"
	desc = "An ominous figure in a clad-black voidsuit. Mauve glass of the helmet conceals their face, but you have no doubt about their intentions."
	icon = 'mods/antagonists/icons/mob/pirates.dmi'
	icon_state = "pirate_melee"
	icon_living = "pirate_melee"
	icon_dead = "fleetassault_dead"
	icon_gib = "fleetarmsman_gib"
	turns_per_move = 5
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "hits"
	natural_armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	speed = 8
	maxHealth = 150
	health = 150
	harm_intent_damage = 5
	natural_weapon = /obj/item/melee/energy/machete/activated
	can_escape = TRUE
	a_intent = I_HURT
	corpse = null
	weapon1 = /obj/item/shield/energy
	var/weapon2 = /obj/item/melee/energy/machete/activated
	min_gas = null
	max_gas = null
	environment_smash = 1
	faction = "space_pirates"
	status_flags = FLAGS_OFF
	flash_vulnerability = 0

	corpse = /obj/landmark/corpse/pirate/space
	ignore_hazard_flags = HAZARD_FLAG_SHARD



	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile/pirate/space
	say_list_type = /datum/say_list/pirate/space/melee
	ranged = FALSE

/mob/living/simple_animal/hostile/human/pirate/space/death(gibbed, deathmessage, show_dead_message)
	..(gibbed, deathmessage, show_dead_message)
	if(corpse)
		new corpse (loc)
	if(weapon1)
		new weapon1 (loc)
	if(weapon2)
		new weapon2 (loc)
	qdel(src)
	return

/mob/living/simple_animal/hostile/human/pirate/space/Process_Spacemove(allow_movement)
	return TRUE

///////////////Space Pirate - SMG////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged
	icon_state = "pirate_smg"
	icon_living = "pirate_smg"
	maxHealth = 100
	health = 100

	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile/pirate/space/ranged
	casingtype = /obj/item/ammo_casing/pistol
	projectiletype = /obj/item/projectile/bullet/pistol
	natural_weapon = /obj/item/gun/projectile/automatic/merc_smg
	weapon1 = /obj/item/gun/projectile/automatic/merc_smg
	weapon2 = null
	ranged = TRUE

	say_list_type = /datum/say_list/pirate/space

///////////////Space Pirate - USI////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/usi
	icon_state = "pirate_uzi"
	icon_living = "pirate_uzi"
	maxHealth = 100
	health = 100

	casingtype = /obj/item/ammo_casing/pistol
	projectiletype = /obj/item/projectile/bullet/pistol
	natural_weapon = /obj/item/gun/projectile/automatic/machine_pistol/usi
	weapon1 = /obj/item/gun/projectile/automatic/machine_pistol/usi

//////////////Space Pirate - G-40////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/laser
	icon_state = "pirate_laser"
	icon_living = "pirate_laser"
	casingtype = null
	projectiletype = /obj/item/projectile/beam/midlaser
	natural_weapon = /obj/item/gun/energy/laser
	weapon1 = /obj/item/gun/energy/laser

//////////////Space Pirate - Perun\Shield////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/egun
	icon_state = "pirate_shield"
	icon_living = "pirate_shield"
	maxHealth = 200
	health = 200
	casingtype = null
	projectiletype = /obj/item/projectile/beam
	natural_weapon = /obj/item/gun/energy/gun
	weapon1 = /obj/item/gun/energy/gun
	weapon2 = /obj/item/shield/riot/metal

//////////////Space Pirate - Battlerifle////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/rifle
	icon_state = "pirate_battlerifle"
	icon_living = "pirate_battlerifle"
	casingtype = /obj/item/ammo_casing/rifle/military
	projectiletype = /obj/item/projectile/bullet/rifle
	natural_weapon = /obj/item/gun/projectile/automatic/battlerifle
	weapon1 = /obj/item/gun/projectile/automatic/battlerifle

//////////////Space Pirate - Shotgun////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/shotgun
	icon_state = "pirate_shotgun"
	icon_living = "pirate_shotgun"
	casingtype = /obj/item/ammo_casing/shotgun
	projectiletype = /obj/item/projectile/bullet/shotgun
	natural_weapon = /obj/item/gun/projectile/shotgun/pump/combat
	weapon1 = /obj/item/gun/projectile/shotgun/pump/combat

//////////////Space Pirate - Z8////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/assault_rifle
	icon_state = "pirate_sts"
	icon_living = "pirate_sts"
	casingtype = /obj/item/ammo_casing/rifle/military
	projectiletype = /obj/item/projectile/bullet/rifle
	natural_weapon = /obj/item/gun/projectile/automatic/assault_rifle
	weapon1 = /obj/item/gun/projectile/automatic/assault_rifle

//////////////Space Pirate - Magshot////////////////

/mob/living/simple_animal/hostile/human/pirate/space/ranged/magshot
	icon_state = "pirate_magshot"
	icon_living = "pirate_magshot"
	casingtype = /obj/item/ammo_casing/shotgun/pellet
	projectiletype = /obj/item/projectile/bullet/pellet/shotgun
	natural_weapon = /obj/item/gun/projectile/shotgun/magshot
	weapon1 = /obj/item/gun/projectile/shotgun/magshot

//////////////Frontirra////////////////

/mob/living/simple_animal/hostile/human/pirate/space/frontirra
	name = "\improper Frontirra"
	desc = "An ominous figure in a clad-black voidsuit. He wields a two-handed jackhammer. Oh, shit!"
	icon_state = "pirate_frontirra"
	icon_living = "pirate_frontirra"
	maxHealth = 200
	health = 200
	natural_weapon = /obj/item/material/twohanded/jack/titanium
	weapon1 = /obj/item/material/twohanded/jack/titanium
	say_list_type = /datum/say_list/pirate/space/frontirra
	status_flags = FLAGS_OFF
	corpse = /obj/landmark/corpse/pirate/space

/* AI */

/datum/ai_holder/simple_animal/humanoid/hostile/pirate/space
	intelligence_level = AI_NORMAL
	threaten_delay = 2 SECOND
	threaten_timeout = 30 SECONDS
	violent_breakthrough = FALSE
	speak_chance = 5
	base_wander_delay = 5

/datum/ai_holder/simple_animal/humanoid/hostile/pirate/space/ranged
	threaten_delay = 2 SECOND
	threaten_timeout = 30 SECONDS
	speak_chance = 5
	base_wander_delay = 3
	returns_home = FALSE
	violent_breakthrough = TRUE
	conserve_ammo = FALSE
	destructive = TRUE
	pointblank = TRUE

/* SAY LIST */

/datum/say_list/pirate/space
	speak = list(
		"Не нравится мне всё это.",
		"Ещё один хороший рейд и завяжу. А там хоть с того света доставайте.",
		"...надо ещё ширнуться Глазом потом, вообще думать не могу без него.",
		"Сколько там ещё ждать-то?"
	)
	emote_hear = list(
		"беспокойно проверяет своё оружие.",
		"осматривает область на наличие угроз.",
		"вскидывает оружие, прицеливаясь куда-то в пустоту, после чего раздражённо опускает."
	)
	say_threaten = list(
		"А вот и добыча.",
		"У меня контакт! Ко мне, ребята!",
		"Руки вверх!",
		"Сейчас посмотрим что там у тебя в карманах."
	)
	say_maybe_target = list(
		"Это чё было?",
		"Видел? Пробежал кто-то.",
		"Мы тут похоже не одни, смотрите в оба, ребята.",
		"Я кажется кого-то слышу."
	)
	say_escalate = list(
		"Всё, что на этом ублюдке - моё!",
		"Навались!",
		"Грабь, убивай!",
		"Йаррр!",
		"Огонь! Огонь по мудачью!"
	)
	say_stand_down = list(
		"Как думаешь, он тут один был?",
		"Лут с этого - мой",
		"Ниче-ниче, то ли ещё будет.",
		"Наверное ветер."
	)

/datum/say_list/pirate/space/melee
	speak = list(
		"А я бы её да этим ножиком...",
		"И куда старшому весь этот форон потом сбагривать? Полгода с ним летать будем.",
		"Туда-сюда, туда-сюда."
	)
	emote_hear = list(
		"прекращает вертеть кортиком.",
		"выставляет энергощит перед собой."
	)
	say_threaten = list(
		"Оп-па, кто это тут у нас?",
		"Навались, парни!",
	)
	say_maybe_target = list(
		"Это кто там такой смелый?",
		"Парни, тут похоже кто-то ещё есть!",
		"А? Наверное ветер."
	)
	say_escalate = list(
		"На ножи!",
		"Вали их!",
		"Большая ошибка, приятель!"
	)
	say_stand_down = list(
		"Всех порешаем, всё вынесем.",
		"Последний неплохо потрепыхался.",
		"Жесткий свет... Даже иногда жаль, что крови не остаётся."
	)

/datum/say_list/pirate/space/frontirra
	speak = list(
		"Ничерта не работает!",
		"Грааа!",
	)
	emote_hear = list(
		"берёт молот в обе руки."
	)
	say_threaten = list(
		"Это кто тут такой?! Стоять!"
	)
	say_maybe_target = list(
		"А?",
		"А ну иди сюда!",
	)
	say_escalate = list(
		"Сейчас будет тебе, прямо в пятку!",
		"Урою!!!",
		"Лучше беги, сука!"
	)
	say_stand_down = list(
		"Ну и кто тут лучше всех дерется?",
		"Не связывайся со мной!"
	)
