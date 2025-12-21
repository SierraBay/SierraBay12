/obj/landmark/corpse/foundation
	name = "Foundation Operative"
	corpse_outfits = list(/singleton/hierarchy/outfit/foundation/hostile)
	spawn_flags = CORPSE_SPAWNER_RANDOM_NAMELESS | CORPSE_SPAWNER_ALL_SKIPS

/obj/landmark/corpse/foundation/pilot
	name = "Foundation Pilot"
	corpse_outfits = list(/singleton/hierarchy/outfit/foundation/hostile/pilot)

/obj/landmark/corpse/foundation/space
	name = "Foundation Assault Operative"
	corpse_outfits = list(/singleton/hierarchy/outfit/foundation/hostile/voidsuit)

/mob/living/simple_animal/hostile/human/foundation
	name = "\improper Foundation Operative"
	desc = "An armsman wearing Cuchulain Foundation garbs. They have a Radiotelescope patch on their uniform, and paranoia in his head."
	icon = 'mods/psionics/icons/foundation/foundation_mobs.dmi'
	icon_state = "ops"
	icon_living = "ops"
	icon_dead = "fleetassault_dead"
	icon_gib = "fleetarmsman_gib"
	turns_per_move = 5
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "hits"
	natural_armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_SMALL,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_RESISTANT
		)
	speed = 8
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	natural_weapon = /obj/item/natural_weapon/punch
	can_escape = TRUE
	a_intent = I_HURT
	var/corpse = null
	var/weapon1
	var/weapon2
	unsuitable_atmos_damage = 15
	environment_smash = 1
	faction = "hearershand"
	status_flags = CANPUSH
	flash_vulnerability = 0

	ignore_hazard_flags = HAZARD_FLAG_SHARD

	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile/foundation
	say_list_type = /datum/say_list/foundation/traitor
	ranged = TRUE

/mob/living/simple_animal/hostile/human/foundation/death(gibbed, deathmessage, show_dead_message)
	..(gibbed, deathmessage, show_dead_message)
	if(corpse)
		new corpse (loc)
	if(weapon1)
		new weapon1 (loc)
	if(weapon2)
		new weapon2 (loc)
	qdel(src)
	return

///////////////SMG////////////////

/mob/living/simple_animal/hostile/human/foundation/ranged
	name = "\improper Foundation Operative"
	icon_state = "opsarmed"
	icon_living = "opsarmed"

	corpse = /obj/landmark/corpse/foundation

	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile/foundation/ranged
	casingtype = /obj/item/ammo_casing/pistol
	projectiletype = /obj/item/projectile/bullet/pistol
	natural_weapon = /obj/item/gun/projectile/automatic/sol_smg
	weapon1 = /obj/item/gun/projectile/automatic/sol_smg
	status_flags = FLAGS_OFF

/mob/living/simple_animal/hostile/human/foundation/ranged/neutral
	say_list_type = /datum/say_list/foundation/friendly
	faction = MOB_FACTION_CREW

//////////////Bullpup////////////////

/mob/living/simple_animal/hostile/human/foundation/ranged/bullpup
	name = "\improper Foundation Fire Support Operative"
	icon_state = "opsrifle"
	icon_living = "opsrifle"
	casingtype = /obj/item/ammo_casing/rifle
	projectiletype = /obj/item/projectile/bullet/rifle
	natural_weapon = /obj/item/gun/projectile/automatic/bullpup_rifle/light
	weapon1 = /obj/item/gun/projectile/automatic/bullpup_rifle/light
	status_flags = FLAGS_OFF

/mob/living/simple_animal/hostile/human/foundation/ranged/bullpup/neutral
	say_list_type = /datum/say_list/foundation/friendly
	faction = MOB_FACTION_CREW


// These guys are chonky. Use them for BIG fights. Or sparingly.

//////////////Voidsuit////////////////

/mob/living/simple_animal/hostile/human/foundation/space
	name = "\improper Foundation Assault Operative"
	desc = "A Foundation Operative clad in a black voidsuit. They seem ready for space combat."
	icon_state = "opsvoid"
	icon_living = "opsvoid"
	icon_dead = "fleetassault_dead"
	corpse = /obj/landmark/corpse/foundation/space
	ranged = TRUE
	natural_armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_MINOR
		)
	speed = 4
	maxHealth = 200
	health = 200
	min_gas = null
	max_gas = null
	minbodytemp = 0

	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile/foundation/ranged/space

/mob/living/simple_animal/hostile/human/foundation/space/neutral
	say_list_type = /datum/say_list/foundation/friendly
	faction = MOB_FACTION_CREW

/mob/living/simple_animal/hostile/human/foundation/space/Process_Spacemove(allow_movement)
	return TRUE

//////////////Voidsuit - SMG////////////////

/mob/living/simple_animal/hostile/human/foundation/space/ranged
	icon_state = "opsvoidsmg"
	icon_living = "opsvoidsmg"
	casingtype = /obj/item/ammo_casing/pistol
	projectiletype = /obj/item/projectile/bullet/pistol
	natural_weapon = /obj/item/gun/projectile/automatic/sol_smg
	weapon1 = /obj/item/gun/projectile/automatic/sol_smg
	status_flags = FLAGS_OFF

/mob/living/simple_animal/hostile/human/foundation/space/ranged/neutral
	say_list_type = /datum/say_list/foundation/friendly
	faction = MOB_FACTION_CREW

//////////////Voidsuit - Z8////////////////

/mob/living/simple_animal/hostile/human/foundation/space/ranged/rifle
	icon_state = "opsvoidrifle"
	icon_living = "opsvoidrifle"
	casingtype = /obj/item/ammo_casing/rifle
	projectiletype = /obj/item/projectile/bullet/rifle
	natural_weapon = /obj/item/gun/projectile/automatic/bullpup_rifle
	weapon1 = /obj/item/gun/projectile/automatic/bullpup_rifle
	status_flags = FLAGS_OFF

	say_list_type = /datum/say_list/foundation/heavy

/mob/living/simple_animal/hostile/human/foundation/space/ranged/rifle/neutral
	say_list_type = /datum/say_list/foundation/friendly
	faction = MOB_FACTION_CREW

//////////////Rigsuit - Pilot////////////////

/mob/living/simple_animal/hostile/human/foundation/space/pilot
	name = "\improper Foundation Pilot"
	desc = "A Foundation Pilot clad in a null rigsuit. Unarmed, but ready to fight back."
	icon_state = "opspilot"
	icon_living = "opspilot"
	natural_weapon = /obj/item/crowbar
	weapon1 = /obj/item/crowbar
	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile/foundation/pilot
	say_list_type = /datum/say_list/foundation/pilot
	status_flags = FLAGS_OFF
	corpse = /obj/landmark/corpse/foundation/pilot

/mob/living/simple_animal/hostile/human/foundation/space/pilot/neutral

	say_list_type = /datum/say_list/foundation/pilot
	faction = MOB_FACTION_CREW

/* AI */

/datum/ai_holder/simple_animal/humanoid/hostile/foundation
	threaten_delay = 2 SECOND
	threaten_timeout = 30 SECONDS
	violent_breakthrough = FALSE
	speak_chance = 5
	base_wander_delay = 5

/datum/ai_holder/simple_animal/humanoid/hostile/foundation/ranged
	threaten_delay = 2 SECOND
	threaten_timeout = 30 SECONDS
	base_wander_delay = 3
	conserve_ammo = FALSE
	pointblank = TRUE

/datum/ai_holder/simple_animal/humanoid/hostile/foundation/ranged/space
	threaten_delay = 2 SECOND
	threaten_timeout = 30 SECONDS
	speak_chance = 5
	base_wander_delay = 3
	returns_home = FALSE
	violent_breakthrough = TRUE
	conserve_ammo = FALSE
	destructive = TRUE
	pointblank = TRUE

/datum/ai_holder/simple_animal/humanoid/hostile/foundation/pilot
	threaten_delay = 2 SECOND
	threaten_timeout = 30 SECONDS
	violent_breakthrough = FALSE
	speak_chance = 5
	base_wander_delay = 5

/* SAY LIST */

/datum/say_list/foundation/friendly
	speak = list(
		"Пока всё тихо. Не расслабляться.",
		"Ненавижу ждать, просто добивает...",
		"Если нас сюда прислали, значит что-то пойдёт наперекосяк.",
		"Вот так готовишься, готовишься, а потом всё. Отбой.",
		"Проклятая Клеть Разума. Вообще ни о чём думать не могу. И голова болит.",
		"Вот бы кто случайно пальцем сигарету подкурил. Я бы ему тогда..."
	)
	emote_hear = list(
		"беспокойно ёрзает.",
		"разряжает оружие, чтобы проверить магазин, затем перезаряжает.",
		"встает на цыпочки и готов идти, подпрыгивая в своих ботинках.",
		"осматривает область на наличие угроз."
	)
	say_threaten = list(
		"Не двигаться, руки так, чтобы я их видел!",
		"Контакт!",
		"Обнаружен противник!"
	)
	say_maybe_target = list(
		"Погоди, ты это слышал?",
		"Визуальный контакт, проверяю ауру.",
		"Эй, ты, стоять!",
		"Я точно что-то слышал.",
		"Движение в моей зоне."
	)
	say_escalate = list(
		"Огонь по цели!!",
		"Вступаю в бой!",
		"КОНТАКТ!!!",
		"Веду преследование противника!",
		"Зачищаю зону!",
		"К чёрту пси-статус, положите этого ублюдка!"
	)
	say_stand_down = list(
		"Сектор чист! Не расслабляемся.",
		"Все цели устранены.",
		"Доложите, что мы столкнулись с сопротивлением!",
		"Чёрт, явно будут ещё!",
		"Контакт потерян. Требуется подтверждение устранения цели!",
		"Не вижу противника, продолжаем зачистку!"
	)

/datum/say_list/foundation/traitor
	speak = list(
		"Не нравится мне это.",
		"Единый Хор, дай сил продолжить песнь.",
		"...чёрт, что-то не так.",
		"До сих пор слышу эти крики... Не вернусь на Нептун, лучше застрелюсь."
	)
	emote_hear = list(
		"беспокойно проверяет своё оружие.",
		"разряжает оружие, чтобы проверить магазин, затем перезаряжает.",
		"осматривает область на наличие угроз.",
		"вскидывает оружие, прицеливаясь куда-то в пустоту, после чего раздражённо опускает."
	)
	say_threaten = list(
		"Знал, что здесь кто-то есть!",
		"Контакт!",
		"Стой на месте! Сука, стой. На. Месте!",
		"Мне же не показалось!",
		"Бросай оружие, бросай я сказал!"
	)
	say_maybe_target = list(
		"Блять! Опять этот звук...",
		"Здесь кто-то есть!",
		"Кажется я кого-то видел!",
		"Я что-то слышал!",
		"Только не невидимки. Только не проклятые невидимки снова!"
	)
	say_escalate = list(
		"Убейте этого ублюдка!",
		"КОНТАКТ!!!",
		"Сволочи, я вам не дамся!",
		"Я вижу тела! Я вижу тела в воде!",
		"Огонь! Огонь!"
	)
	say_stand_down = list(
		"Он был здесь явно не один! Сколько их там?!",
		"Держимся, сейчас ещё подвалят!",
		"Нас обещали вытащить! Не расслабляемся!",
		"Ни следа. Ищите, ищите!",
		"Визуальный контакт потерян, предположительно ещё цели!",
		"Проверьте чёртов периметр!"
	)

/datum/say_list/foundation/heavy
	speak = list(
		"Как обычно, ничего. Ни-че-го...",
		"У меня всё под контролем. Никто не входит и не выходит.",
		"Не путайтесь под ногами, целее будете."
	)
	say_threaten = list(
		"Есть контакт!",
		"Работаем!",
	)
	say_maybe_target = list(
		"Пусть проверят периметр. Кажется что-то было.",
		"Что там мельтишит? Как резоми в гетто, ей-богу..",
		"А? Ничего..",
		"У меня всё чи... погоди секунду."
	)
	say_escalate = list(
		"Попались!",
		"Стой смирно!",
		"Большая ошибка, приятель!",
		"Всем с линии огня, работаем!"
	)
	say_stand_down = list(
		"Да, как резоми в гетто. Только кишки и перья. Мерзость.",
		"Гори-гори ясно.",
		"Они поют. Мы слушаем. А эти не слушают. Жалко..."
	)

/datum/say_list/foundation/pilot
	speak = list(
		"Этот идёт сюда, а этот - сюда. А толку-то, всю электронику вынесло.",
		"У меня нет пока идей. Только молиться, что внутри что-то ещё уцелело.",
		"Ты это слышал?",
		"Проклятые Рассинхронизаторы. Вроде сдох, а головняка больше чем от живого."
	)
	emote_hear = list(
		"быстро вынимает монтировку с пояса.",
		"чуть наклоняется и замирает на месте, прислушиваясь.",
		"осматривает область на наличие угроз.",
		"судорожно перебирает пояс в поисках чего-то, похожего на оружие."
	)
	say_threaten = list(
		"Уходи, слышишь, уходи пока живой!",
		"Контакт!",
		"Эй, ты, не приближайся, я вооружен!",
		"Парни! Кто-нибудь! Сюда!",
		"Помогите, блять!"
	)
	say_maybe_target = list(
		"Нахер-нахер-нахер, это просто мусор перекатился...",
		"Здесь кто-то есть!",
		"Эй, есть там кто?",
		"Я что-то слышал!",
		"Лишь бы не Сознанщик, лишь бы не треклятый Сознанщик."
	)
	say_escalate = list(
		"Кто-нибудь, помогите мне!",
		"Контааааакт!!!",
		"Я на Нептуне служил, я контуженный!",
		"Ну ты напросился!",
		"Я так просто не дамся!"
	)
	say_stand_down = list(
		"Лишь бы отвалили, и так починиться не можем.",
		"Они же должны были на чём-то прилететь? Ну или хотя бы знать где есть какой-то корабль?",
		"Маяк должен работать, нужно просто держаться и нас вытащат.",
		"Проверяйте кто-то ещё. Не я.",
		"Просто представим, что там никого не было. Просто вот... на секунду.",
		"И всё. И никого."
	)
