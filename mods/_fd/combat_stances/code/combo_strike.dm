#define STRIKE_MULT_DMG_LIGHT 0.6
#define STRIKE_MULT_DMG_MEDIUM 0.8
#define STRIKE_MULT_DMG_STANDARD 1
#define STRIKE_MULT_DMG_HEAVY 1.2
#define STRIKE_MULT_DMG_SUPERHEAVY 2

#define STRIKE_MULT_SPEED_FAST 0.6
#define STRIKE_MULT_SPEED_MEDIUM 0.8
#define STRIKE_MULT_SPEED_STANDARD 1
#define STRIKE_MULT_SPEED_SLOW 1.3
#define STRIKE_MULT_SPEED_SUPERSLOW 1.5

/singleton/combo_strike
	var/list/strike_verbs = null // Сообщение, которое выводит конкретная атака при использовании
	var/strike_dmg = 1  // Множитель дамага
	var/strike_speed = 1 // Множитель скорости, чем выше - тем больше делей между атаками
	var/strike_range = 1 // Расстояние для совершения удара в тайлах, числа больше одного чаще всего используются в afterattack() - всякие рывки и так далее
	var/strike_switch_text = "Вы готовы к бою."

	//Путь следующей необходимой атаки. Можно использовать для создания комбинаций из нескольких разных ударов к ряду. Если не прописана - то просто возвращает оружие к его базовой стойке
	var/next_strike = null
	//Время для совершения комбо. Если момент упущен, и цепь не продолжена - возвращает оружие к базовой стойке
	var/chain_timeframe = 2 SECONDS
	var/chain_expire_at = 0
	var/chain_base_strike = null
	var/stamina_cost = 0

/singleton/combo_strike/proc/strike_active(mob/user)
	if(strike_switch_text)
		to_chat(user,"<span class = 'danger'>[strike_switch_text]</span>")

/singleton/combo_strike/proc/strike_invalid_target(mob/user, obj/item/striker)
	to_chat(user,SPAN_DANGER("[user] совершает оборонительный выпад, используя [striker]"))
	user.setClickCooldown(striker.attack_cooldown)

/singleton/combo_strike/proc/do_pre_strike(mob/user, atom/target, obj/item/striker, click_params)
	var/singleton/combo_strike/strike_use = src
	if(chain_base_strike)
		if(!chain_expire_at)
			chain_expire_at = world.time + chain_timeframe
		else if(world.time >= chain_expire_at) //Если время на создание цепи атак проёбано - возвращаем всё к дефолтной стойке
			chain_expire_at = 0
			strike_use = create_new_strike(user,striker,chain_base_strike)
			strike_use.strike_active(user)

	//Применение свойств атаки
	var/list/old_verbs = striker.attack_verb
	var/old_dmg = striker.force
	var/old_speed = striker.attack_cooldown
	if(strike_verbs)
		old_verbs = old_verbs.Copy()
		striker.attack_verb = strike_verbs
	if(strike_dmg != 1)
		striker.force *= strike_dmg
	if(strike_speed != 1)
		striker.attack_cooldown *= strike_speed

	if(!strike_use.do_strike(user,target,striker,click_params))
		strike_invalid_target(user,striker)
	strike_use.post_strike(user,target,striker,click_params)

	striker.attack_verb = old_verbs
	striker.force = old_dmg
	striker.attack_cooldown = old_speed
	return 1

/singleton/combo_strike/proc/do_strike_targ(mob/user, mob/living/m, obj/item/striker, click_params)
	m.use_weapon(striker, user, click_params)
	if(stamina_cost)
		user.adjust_stamina(-stamina_cost)

/singleton/combo_strike/proc/do_strike(mob/user, atom/target, obj/item/striker, click_params)

/singleton/combo_strike/proc/post_strike(mob/user, atom/target, obj/item/striker, click_params)
	if(next_strike)
		var/singleton/combo_strike/strike = create_new_strike(user,striker,next_strike)
		strike.strike_active(user)

/singleton/combo_strike/proc/create_new_strike(mob/user, obj/item/striker, new_path)
	var/singleton/combo_strike/new_strike = new new_path ()
	striker.melee_strike = new_strike
	new_strike.chain_expire_at = world.time + chain_timeframe
	new_strike.chain_base_strike = chain_base_strike
	if(chain_base_strike && type != chain_base_strike)
		qdel(src)
	return new_strike

//БАЗОВАЯ АТАКА//

/singleton/combo_strike/precise_strike/do_strike(mob/user, turf/target, obj/item/striker, click_params)
	if(user.get_stamina() < stamina_cost)
		to_chat(user, SPAN_WARNING("Вы слишком устали!"))
		return FALSE
	if(istype(target))
		var/list/turf_mobs = list()
		for(var/mob/living/m in target.contents)
			turf_mobs += m
		if(turf_mobs.len != 0)
			target = pick(turf_mobs)
		else
			return 0

	if(ismob(target) && target != user)
		do_strike_targ(user,target,striker,click_params)

	return 1

/singleton/combo_strike/swipe_strike/do_strike(mob/user, turf/target, obj/item/striker, click_params)
	if(user.get_stamina() < stamina_cost)
		to_chat(user, SPAN_WARNING("Вы слишком устали!"))
		return FALSE
	var/list/targets = list()
	var/turf/targ_turf = get_turf(target)
	if(istype(targ_turf))
		var/list/turfs_search = list(targ_turf)
		var/attack_dir = get_dir(user,targ_turf)
		turfs_search += list( get_step(targ_turf,turn(attack_dir,90)),get_step(targ_turf,turn(attack_dir,-90)) )
		for(var/turf/search in turfs_search)
			for(var/mob/living/m in search.contents)
				targets += m

	if(targets.len != 0)
		for(var/mob in targets)
			if(user == mob)
				continue
			do_strike_targ(user,mob,striker,click_params)
	else
		return 0

	return 1

/singleton/combo_strike/circle_strike/do_strike(mob/user, turf/target, obj/item/striker, click_params)
	if(user.get_stamina() < stamina_cost)
		to_chat(user, SPAN_WARNING("Вы слишком устали!"))
		return FALSE
	var/list/targets = list()
	for(var/turf/search in orange(1, user))
		for(var/mob/living/M in search.contents)
			targets += M

	if(targets.len != 0)
		for(var/mob in targets)
			if(user == mob)
				continue
			do_strike_targ(user,mob,striker,click_params)
	else
		return 0

	return 1

/singleton/combo_strike/circle_strike/do_strike_targ(mob/user, mob/living/m, obj/item/striker, click_params)
	m.use_weapon(striker, user, click_params)
	user.dir = turn(SOUTH,0)
	sleep(1)
	user.dir = turn(WEST, 0)
	sleep(1)
	user.dir = turn(NORTH, 0)
	sleep(1)
	user.dir = turn(EAST, 0)
	sleep(1)
	user.dir = turn(SOUTH,0)
	if(stamina_cost)
		user.adjust_stamina(-stamina_cost)

/singleton/combo_strike/blunt_strike/do_strike(mob/user, turf/target, obj/item/striker, click_params)
	if(user.get_stamina() < stamina_cost)
		to_chat(user, SPAN_WARNING("Вы слишком устали!"))
		return FALSE
	if(istype(target))
		var/list/turf_mobs = list()
		for(var/mob/living/m in target.contents)
			turf_mobs += m
		if(turf_mobs.len != 0)
			target = pick(turf_mobs)
		else
			return 0

	if(ismob(target) && target != user)
		do_strike_targ(user,target,striker,click_params)

	return 1

/singleton/combo_strike/blunt_strike/do_strike_targ(mob/user, mob/living/m, obj/item/striker, click_params)
	var/throw_dir = get_dir(user,m)

	m.use_weapon(striker, user, click_params)
	m.throw_at(get_edge_target_turf(m, throw_dir),2,4,user)
	if(stamina_cost)
		user.adjust_stamina(-stamina_cost)

//НОЖИ И ДРУГОЕ КОРОТКОЕ РЕЖУЩЕЕ

//Три быстрых взмаха, оканчивающихся тяжёлым ударом
/singleton/combo_strike/precise_strike/fast_attacks
	strike_switch_text = "Вы приготовились к совершению нескольких мониеносных атак..."
	strike_dmg = STRIKE_MULT_DMG_LIGHT
	strike_speed = STRIKE_MULT_SPEED_MEDIUM
	strike_verbs = list("slashed","sliced","cut")
	next_strike = /singleton/combo_strike/precise_strike/fast_attacks/c1
	chain_base_strike = /singleton/combo_strike/precise_strike/fast_attacks
	stamina_cost = 5

/singleton/combo_strike/precise_strike/fast_attacks/c1
	strike_switch_text = null
	next_strike = /singleton/combo_strike/precise_strike/fast_attacks/c2

/singleton/combo_strike/precise_strike/fast_attacks/c2
	strike_switch_text = null
	strike_speed = STRIKE_MULT_SPEED_SUPERSLOW //Следующая атака будет крайне смертоносной, так что имеет смысл дать жертве возможность уйти от неё
	next_strike = /singleton/combo_strike/precise_strike/fast_attacks/finalone

/singleton/combo_strike/precise_strike/fast_attacks/finalone
	strike_dmg = STRIKE_MULT_DMG_SUPERHEAVY
	strike_speed = STRIKE_MULT_SPEED_MEDIUM
	strike_verbs = list("shanked","stabbed","pierced")
	strike_switch_text = "Вы готовитесь проткнуть вашу цель!"
	//Позволяет повторять данное комбо до бесконечности, если хватит сноровки. 28 УДАРОВ НОЖОМ, ТЫ ДЕЙСТВОВАЛ НАВЕРНЯКА?
	next_strike = /singleton/combo_strike/precise_strike/fast_attacks
	stamina_cost = 10

//Один взмах

/singleton/combo_strike/swipe_strike/harrying_strike
	strike_dmg = STRIKE_MULT_DMG_LIGHT
	strike_speed = STRIKE_MULT_SPEED_MEDIUM
	strike_verbs = list("shallowly cut","lacerated")
	strike_switch_text = "Вы подготовились для совершения одного широкого взмаха..."
	stamina_cost = 5

//МЕЧИ И ДРУГОЕ ДЛИННОЕ РЕЖУЩЕЕ

//Смешанное комбо

/singleton/combo_strike/swipe_strike/mixed_combo
	strike_dmg = STRIKE_MULT_DMG_LIGHT
	strike_verbs = list("shallowly slashed","shallowly cut")
	strike_switch_text = "Вы собираетесь с духом, готовясь совершить серию из плавных рубящих ударов..."
	next_strike = /singleton/combo_strike/precise_strike/mixed_combo
	chain_base_strike = /singleton/combo_strike/swipe_strike/mixed_combo
	stamina_cost = 15

/singleton/combo_strike/precise_strike/mixed_combo
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_MEDIUM
	strike_verbs = list("hewed","chopped")
	strike_switch_text = null
	next_strike = /singleton/combo_strike/precise_strike/mixed_combo/c1
	chain_base_strike = /singleton/combo_strike/swipe_strike/mixed_combo
	stamina_cost = 10

/singleton/combo_strike/precise_strike/mixed_combo/c1
	next_strike = /singleton/combo_strike/swipe_strike/mixed_combo

//Два тяжёлых удара

/singleton/combo_strike/swipe_strike/sword_slashes
	strike_dmg = STRIKE_MULT_DMG_MEDIUM
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_verbs = list("shallowly slashed","shallowly cut")
	strike_switch_text = "Вы готовитесь совершить несколько последовательных тяжёлых замахов..."
	next_strike = /singleton/combo_strike/swipe_strike/sword_slashes/slow
	chain_base_strike = /singleton/combo_strike/swipe_strike/sword_slashes
	stamina_cost = 15

/singleton/combo_strike/swipe_strike/sword_slashes/slow
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SUPERSLOW
	strike_verbs = list("shallowly slashed","shallowly cut")
	strike_switch_text = null
	next_strike = /singleton/combo_strike/swipe_strike/sword_slashes
	chain_base_strike = /singleton/combo_strike/swipe_strike/sword_slashes
	stamina_cost = 15

//ДРЕВКОВОЕ ОРУЖИЕ

//Смешанное комбо

/singleton/combo_strike/swipe_strike/polearm_mixed
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_verbs = list("slashed","cut","lacerated")
	strike_switch_text = "Ты хватаешься за своё оружие поудобнее, готовясь к совершению нескольких рубящих и колющих атак..."
	next_strike = /singleton/combo_strike/precise_strike/polearm_mixed
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed
	stamina_cost = 15

/singleton/combo_strike/precise_strike/polearm_mixed
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_STANDARD
	strike_verbs = list("stabbed","impaled")
	strike_range = 2
	strike_switch_text = null
	next_strike = /singleton/combo_strike/precise_strike/polearm_mixed/c1
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed
	stamina_cost = 10

/singleton/combo_strike/precise_strike/polearm_mixed/c1
	strike_dmg = STRIKE_MULT_DMG_LIGHT
	strike_speed = STRIKE_MULT_SPEED_MEDIUM
	strike_verbs = list("grazingly stabbed","grazingly jabbed")
	strike_switch_text = null
	next_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/finale
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed

/singleton/combo_strike/swipe_strike/polearm_mixed/finale
	strike_dmg = STRIKE_MULT_DMG_SUPERHEAVY
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_verbs = list("slashed","cut","lacerated")
	strike_switch_text = null
	next_strike = /singleton/combo_strike/swipe_strike/polearm_mixed
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed
	stamina_cost = 20

//Круговые замахи

/singleton/combo_strike/swipe_strike/polearm_slash
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_range = 2
	strike_verbs = list("slashed","cut","lacerated")
	strike_switch_text = "Вы размахиваете своим оружием во все стороны!"
	next_strike = /singleton/combo_strike/swipe_strike/polearm_slash/slow
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_slash
	stamina_cost = 15

/singleton/combo_strike/swipe_strike/polearm_slash/slow
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SUPERSLOW
	strike_verbs = list("slashed","cut","lacerated")
	strike_switch_text = null
	next_strike = /singleton/combo_strike/swipe_strike/polearm_slash
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_slash
	stamina_cost = 15

//Разносим всё вокруг

/singleton/combo_strike/swipe_strike/polearm_wide
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SUPERSLOW
	strike_verbs = list("slashed","cut","lacerated")
	strike_switch_text = "Вы приготовились к совершению медленной круговой атаки..."
	next_strike = /singleton/combo_strike/circle_strike/polearm
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_wide
	stamina_cost = 10

/singleton/combo_strike/circle_strike/polearm
	strike_dmg = STRIKE_MULT_DMG_SUPERHEAVY
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_verbs = list("smashed","crushed","whacked")
	strike_switch_text = "Вы размахиваете своим оружием во все стороны!"
	stamina_cost = 30
	next_strike = /singleton/combo_strike/swipe_strike/polearm_wide
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_wide

//МОЛОТЫ

//В целом, всё то же самое, что и у древкового, но с иными логами ударов

/singleton/combo_strike/swipe_strike/polearm_mixed/hammer
	strike_verbs = list("smashed","crushed","whacked")
	next_strike = /singleton/combo_strike/precise_strike/polearm_mixed/hammer
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/hammer

/singleton/combo_strike/precise_strike/polearm_mixed/hammer
	strike_verbs = list("jabbed","poked")
	next_strike = /singleton/combo_strike/precise_strike/polearm_mixed/c1/hammer
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/hammer

/singleton/combo_strike/precise_strike/polearm_mixed/c1/hammer
	strike_verbs = list("grazingly jabbed","grazingly poked")
	next_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/finale/hammer
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/hammer

/singleton/combo_strike/swipe_strike/polearm_mixed/finale/hammer
	strike_verbs = list("smashed","crushed","whacked")
	next_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/hammer
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_mixed/hammer

//Размашистые удары

/singleton/combo_strike/swipe_strike/polearm_slash/hammer
	strike_verbs = list("smashed","crushed","whacked")
	next_strike = /singleton/combo_strike/swipe_strike/polearm_slash/slow/hammer
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_slash/hammer

/singleton/combo_strike/swipe_strike/polearm_slash/slow/hammer
	strike_verbs = list("smashed","crushed","whacked")
	next_strike = /singleton/combo_strike/swipe_strike/polearm_slash/hammer
	chain_base_strike = /singleton/combo_strike/swipe_strike/polearm_slash/hammer

//ДУБИНЫ

//Запускаем мяч на орбиту

/singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo
	strike_dmg = STRIKE_MULT_DMG_LIGHT
	strike_speed = STRIKE_MULT_SPEED_MEDIUM
	strike_verbs = list("smashed","crushed","whacked")
	strike_switch_text = "Вы разминаетесь, готовясь к 'отбиванию мяча'..."
	next_strike = /singleton/combo_strike/blunt_strike/mixed_combo
	chain_base_strike = /singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo
	stamina_cost = 5

/singleton/combo_strike/blunt_strike/mixed_combo
	strike_dmg = STRIKE_MULT_DMG_HEAVY
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_verbs = list("smashed","crushed","whacked")
	next_strike = /singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo
	chain_base_strike = /singleton/combo_strike/swipe_strike/blunt_swing/mixed_combo
	stamina_cost = 25

//Разносим всё вокруг

/singleton/combo_strike/swipe_strike/blunt_swing/wide
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SUPERSLOW
	strike_verbs = list("smashed","crushed","whacked")
	strike_switch_text = "Вы размахиваете своим оружием, готовясь к тяжёлой круговой атаке..."
	next_strike = /singleton/combo_strike/circle_strike/blunt
	chain_base_strike = /singleton/combo_strike/swipe_strike/blunt_swing/wide
	stamina_cost = 10

/singleton/combo_strike/circle_strike/blunt
	strike_dmg = STRIKE_MULT_DMG_STANDARD
	strike_speed = STRIKE_MULT_SPEED_SLOW
	strike_verbs = list("smashed","crushed","whacked")
	strike_switch_text = "Вы размахиваете своим оружием во все стороны!"
	stamina_cost = 30
	next_strike = /singleton/combo_strike/swipe_strike/blunt_swing/wide
	chain_base_strike = /singleton/combo_strike/swipe_strike/blunt_swing/wide

#undef STRIKE_MULT_DMG_LIGHT
#undef STRIKE_MULT_DMG_MEDIUM
#undef STRIKE_MULT_DMG_STANDARD
#undef STRIKE_MULT_DMG_HEAVY
#undef STRIKE_MULT_DMG_SUPERHEAVY

#undef STRIKE_MULT_SPEED_FAST
#undef STRIKE_MULT_SPEED_MEDIUM
#undef STRIKE_MULT_SPEED_STANDARD
#undef STRIKE_MULT_SPEED_SLOW
#undef STRIKE_MULT_SPEED_SUPERSLOW
