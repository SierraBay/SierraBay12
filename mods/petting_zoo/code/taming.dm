/*
 * Taming system for simple_animal mobs. Opt-in: only animals with
 * tame_datum = /datum/taming on their type participate.
 *
 * Trust: single 0–100 scale. Thresholds:
 *   25 → Cautious: ignores only the feeder; others still hostile/scary
 *   50 → Curious:  doesn't attack or flee unless provoked
 *   75 → Tamed:    has an owner, obeys commands
 *
 * When hostile mobs reach TAMED, their ai_holder is replaced with
 * /datum/ai_holder/tamed — a peaceful AI that only defends, never hunts.
 * Original AI is restored when trust drops to WILD (below 25).
 *
 * Rex/Boo use decay_exempt = TRUE so they never lose trust.
 */

#define TAME_WILD     0
#define TAME_CAUTIOUS 1
#define TAME_CURIOUS  2
#define TAME_TAMED    3

#define TAME_THRESHOLD_CAUTIOUS  25
#define TAME_THRESHOLD_CURIOUS   50
#define TAME_THRESHOLD_TAMED     75

// ============================================================
// TAMED AI — replaces hostile AI on fully tamed animals
// ============================================================

/datum/ai_holder/tamed
	hostile = FALSE         // never proactively seeks targets
	retaliate = TRUE        // still defends itself if attacked
	flee_from_allies = FALSE
	speak_chance = 10       // prob(10) per 2s tick — actual rate gated by idle_emote cooldown
	/// Tracks owner presence for greeting logic
	var/owner_was_in_range = FALSE
	var/last_owner_disappeared = 0
	var/last_greeting = 0
	var/last_idle_emote = 0

/// Ignore faction when checking pursuit — only respect the friends list.
/// This allows attacking former faction-mates if owner commands it.
/datum/ai_holder/tamed/can_pursue(atom/movable/target)
	if(isliving(target))
		var/mob/living/L = target
		if(ishuman(L) || issilicon(L))
			if(L.key && !L.client)
				return FALSE
			if(L.status_flags & NOTARGET)
				return FALSE
		if(L.stat)
			if(L.is_dead() && !handle_corpse)
				return FALSE
			if(L.stat == UNCONSCIOUS && !mauling)
				return FALSE
		// Friends list only — faction is irrelevant for tamed mobs
		if(istype(holder, /mob/living/simple_animal))
			var/mob/living/simple_animal/SA = holder
			if((L in SA.friends) || (weakref(L) in SA.friends))
				return FALSE
		return TRUE
	return ..()

// ============================================================
// TAMED AI — BEHAVIOUR OVERRIDES
// ============================================================

/// Every 2s: detect when owner returns after absence and greet them
/datum/ai_holder/tamed/handle_special_strategical()
	if(busy)
		return
	var/mob/living/simple_animal/SA = holder
	if(!istype(SA) || !SA.owner_mob || QDELETED(SA.owner_mob))
		owner_was_in_range = FALSE
		return

	var/mob/owner = SA.owner_mob
	var/in_range = get_dist(SA, owner) <= 7 && SA.z == owner.z

	if(in_range)
		if(!owner_was_in_range && last_owner_disappeared > 0)
			// Owner just came back — greet if they were gone long enough
			if((world.time - last_owner_disappeared) > 10 MINUTES && (world.time - last_greeting) > 10 MINUTES)
				last_greeting = world.time
				SA.visible_emote(pick(list(
					"радостно бросается к [owner]!",
					"завидев [owner], оживляется.",
					"виляет хвостом, встречая [owner].",
					"радостно крутится вокруг [owner]."
				)))
				if(SA.say_list && length(SA.say_list.speak))
					SA.ISay(pick(SA.say_list.speak))
		owner_was_in_range = TRUE
	else
		if(owner_was_in_range)
			last_owner_disappeared = world.time
		owner_was_in_range = FALSE

/// Contextual idle emotes: different behavior near owner vs. alone
/datum/ai_holder/tamed/handle_idle_speaking()
	if(world.time - last_idle_emote < 5 MINUTES)
		return
	if(!check_listeners())
		return
	last_idle_emote = world.time

	var/mob/living/simple_animal/SA = holder
	if(!istype(SA))
		return emote_random()

	var/mob/owner = SA.owner_mob
	var/owner_nearby = owner && !QDELETED(owner) && get_dist(SA, owner) <= 5 && SA.z == owner.z

	if(owner_nearby)
		// Near owner — mix of happy companion behaviors and regular emotes
		switch(pick("say_list", "companion", "idle"))
			if("say_list")
				emote_random()
			if("companion")
				SA.visible_emote(pick(list(
					"смотрит на [owner] с доверием.",
					"держится рядом с [owner].",
					"тыкается носом в [owner].",
					"виляет хвостом рядом с [owner].",
					"прижимается к [owner]."
				)))
			if("idle")
				SA.visible_emote(pick(list(
					"потягивается.",
					"зевает.",
					"принюхивается к воздуху.",
					"чешется.",
					"смотрит по сторонам."
				)))
	else if(owner && !QDELETED(owner))
		// Has owner but they're not nearby — restless/searching
		if(prob(40))
			SA.visible_emote(pick(list(
				"беспокойно смотрит по сторонам.",
				"нюхает воздух.",
				"тихо поскуливает.",
				"ищет взглядом знакомое лицо."
			)))
		else
			emote_random()
	else
		// No owner — just regular emotes
		emote_random()

// ============================================================
// TAMING DATUM
// ============================================================

/datum/taming
	var/mob/living/simple_animal/owner
	/// Trust level 0–100
	var/trust = 0
	/// Who is currently building trust with this animal
	var/weakref/current_tamer
	/// Timestamps for cooldowns
	var/last_fed = 0
	var/last_petted = 0
	var/last_talked = 0
	/// Cooldowns in ticks
	var/feed_cooldown = 300    // 30 sec
	var/pet_cooldown = 60      // 6 sec
	var/talk_cooldown = 200    // 20 sec
	/// If TRUE, trust never decays (for Rex, Boo)
	var/decay_exempt = FALSE
	/// Whether we've already asked for a name
	var/named_already = FALSE
	/// Original AI type — restored when going fully wild (for hostile mobs)
	var/original_ai_holder_type = null
	/// Original can_flee — restored for passive mobs going wild
	var/original_can_flee = TRUE

/datum/taming/New(mob/living/simple_animal/animal)
	owner = animal
	if(owner.ai_holder)
		original_ai_holder_type = owner.ai_holder.type
		original_can_flee = owner.ai_holder.can_flee
	addtimer(new Callback(src, PROC_REF(decay_loop)), 10 * 10)

/datum/taming/Destroy()
	owner = null
	current_tamer = null
	. = ..()

/// Returns current tier: TAME_WILD / TAME_CAUTIOUS / TAME_CURIOUS / TAME_TAMED
/datum/taming/proc/get_tier()
	if(trust >= TAME_THRESHOLD_TAMED)    return TAME_TAMED
	if(trust >= TAME_THRESHOLD_CURIOUS)  return TAME_CURIOUS
	if(trust >= TAME_THRESHOLD_CAUTIOUS) return TAME_CAUTIOUS
	return TAME_WILD

/// Localised name for xenobio scanner display
/datum/taming/proc/stage_name()
	switch(get_tier())
		if(TAME_WILD)     return "дикое"
		if(TAME_CAUTIOUS) return "осторожное"
		if(TAME_CURIOUS)  return "любопытное"
		if(TAME_TAMED)    return "приручённое"
	return "неизвестно"

// ============================================================
// TRUST CORE
// ============================================================

/datum/taming/proc/add_trust(amount, mob/source)
	if(!owner || QDELETED(owner))
		return
	var/old_tier = get_tier()
	trust = clamp(trust + round(amount), 0, 100)
	var/new_tier = get_tier()
	if(new_tier != old_tier)
		on_tier_change(old_tier, new_tier, source)

/datum/taming/proc/on_tier_change(old_tier, new_tier, mob/source)
	if(!owner || QDELETED(owner))
		return

	if(new_tier > old_tier)
		// === ASCENDING ===

		if(new_tier >= TAME_CAUTIOUS && old_tier < TAME_CAUTIOUS)
			if(source) owner.friends |= weakref(source)
			if(owner.ai_holder)
				owner.ai_holder.flee_from_allies = FALSE
				if(source && owner.ai_holder.target == source)
					owner.ai_holder.lose_target()
			owner.visible_message(SPAN_NOTICE("\The [owner] перестаёт смотреть на [source ? source : "вас"] с подозрением."))

		if(new_tier >= TAME_CURIOUS && old_tier < TAME_CURIOUS)
			// For hostile non-commanded: stop proactive attacks while approaching TAMED.
			// The AI will be fully replaced at TAMED; this just prevents attacks in the interim.
			if(owner.ai_holder && !istype(owner, /mob/living/simple_animal/hostile/commanded))
				if(istype(owner, /mob/living/simple_animal/hostile))
					owner.ai_holder.hostile = FALSE
					owner.ai_holder.remove_target()
				else
					owner.ai_holder.can_flee = FALSE
			owner.visible_message(SPAN_NOTICE("\The [owner] с любопытством оглядывается вокруг, не проявляя агрессии."))

		if(new_tier >= TAME_TAMED && old_tier < TAME_TAMED)
			var/mob/tamer = source ? source : (current_tamer ? current_tamer.resolve() : null)
			if(tamer)
				assign_owner(tamer)

	else
		// === DESCENDING ===

		if(new_tier < TAME_TAMED && old_tier >= TAME_TAMED)
			var/mob/old_owner = owner.owner_mob
			if(old_owner)
				owner.friends -= weakref(old_owner)
				owner.owner_mob = null
				if(old_owner.client)
					to_chat(old_owner, SPAN_WARNING("\The [owner] больше не слушается вас."))
				if(istype(owner, /mob/living/simple_animal/hostile/commanded))
					var/mob/living/simple_animal/hostile/commanded/C = owner
					if(C.master == old_owner)
						C.master = null
						C.owner_mob = null
			// Remove leader so tamed AI stops following (wanders as CURIOUS)
			if(owner.ai_holder && istype(owner.ai_holder, /datum/ai_holder/tamed))
				owner.ai_holder.lose_follow()
				owner.ai_holder.remove_target()
			owner.visible_message(SPAN_WARNING("\The [owner] ведёт себя всё более дико..."))

		if(new_tier < TAME_CURIOUS && old_tier >= TAME_CURIOUS)
			owner.visible_message(SPAN_WARNING("\The [owner] всё меньше доверяет людям..."))

		if(new_tier < TAME_CAUTIOUS && old_tier >= TAME_CAUTIOUS)
			// Fully wild — restore original AI for hostile mobs, restore flee for passive
			var/mob/tamer = current_tamer ? current_tamer.resolve() : null
			if(tamer) owner.friends -= weakref(tamer)

			if(!istype(owner, /mob/living/simple_animal/hostile/commanded))
				if(istype(owner, /mob/living/simple_animal/hostile) && original_ai_holder_type && istype(owner.ai_holder, /datum/ai_holder/tamed))
					// Swap tamed AI back to original hostile AI
					QDEL_NULL(owner.ai_holder)
					owner.ai_holder = new original_ai_holder_type(owner)
				else if(owner.ai_holder)
					owner.ai_holder.can_flee = original_can_flee
					owner.ai_holder.flee_from_allies = TRUE

			owner.visible_message(SPAN_WARNING("\The [owner] смотрит на людей с прежней враждебностью."))

/// Assign owner and swap AI to tamed version for hostile mobs.
/datum/taming/proc/assign_owner(mob/living/tamer)
	if(!owner || QDELETED(owner) || !tamer)
		return

	owner.friends |= weakref(tamer)
	owner.owner_mob = tamer
	current_tamer = weakref(tamer)

	if(istype(owner, /mob/living/simple_animal/hostile/commanded))
		var/mob/living/simple_animal/hostile/commanded/C = owner
		if(!C.master)
			C.master = tamer
	else if(istype(owner, /mob/living/simple_animal/hostile) && original_ai_holder_type)
		// Replace hostile AI with peaceful tamed AI
		QDEL_NULL(owner.ai_holder)
		owner.ai_holder = new /datum/ai_holder/tamed(owner)

	owner.visible_message(SPAN_NOTICE("\The [owner] смотрит на [tamer] с полным доверием. Он теперь ваш питомец!"))
	to_chat(tamer, SPAN_NOTICE("Вы приручили [owner.name]! Он будет слушаться ваших команд."))

	if(!named_already)
		named_already = TRUE
		addtimer(new Callback(src, PROC_REF(prompt_pet_name), tamer), 0)

/datum/taming/proc/prompt_pet_name(mob/tamer)
	set background = TRUE
	if(QDELETED(src) || !owner || QDELETED(owner) || QDELETED(tamer))
		return
	var/mob/living/simple_animal/O = owner
	var/new_name = input(tamer, "Как назвать питомца? (оставьте пустым для имени по умолчанию)", "Имя питомца", O.name) as text|null
	if(new_name && length(sanitize(new_name)) && !QDELETED(O))
		O.name = sanitize(new_name)

// ============================================================
// FEEDING
// ============================================================

/datum/taming/proc/try_feed(mob/living/feeder, obj/item/food)
	if(!owner || QDELETED(owner) || owner.stat == DEAD || !feeder || !food)
		return FALSE

	var/mob/tamer_mob = current_tamer ? current_tamer.resolve() : null
	if(tamer_mob && tamer_mob != feeder && (world.time - last_fed) < feed_cooldown * 3)
		to_chat(feeder, SPAN_WARNING("\The [owner] уже привыкает к кому-то другому и не обращает на вас внимания."))
		return FALSE

	if((world.time - last_fed) < feed_cooldown)
		to_chat(feeder, SPAN_WARNING("\The [owner] пока не голоден."))
		return TRUE

	var/food_class = classify_food(food)
	if(food_class == "forbidden")
		owner.visible_message(SPAN_WARNING("\The [owner] отказывается от [food] и выглядит недовольным!"))
		last_fed = world.time
		add_trust(-20 * owner.tame_difficulty, null)
		qdel(food)
		return TRUE

	owner.visible_message(SPAN_NOTICE("\The [feeder] предлагает \the [owner] [food]..."))
	if(!do_after(feeder, 20, owner))
		return TRUE
	if(QDELETED(owner) || QDELETED(food))
		return TRUE

	var/gained = (food_class == "preferred") ? (15 / owner.tame_difficulty) : (8 / owner.tame_difficulty)
	owner.visible_message(SPAN_NOTICE("\The [owner] съедает [food]."))
	last_fed = world.time
	current_tamer = weakref(feeder)
	add_trust(gained, feeder)
	qdel(food)
	return TRUE

/datum/taming/proc/classify_food(obj/item/food)
	if(is_type_in_list(food, owner.preferred_foods))
		return "preferred"
	if(is_type_in_list(food, owner.forbidden_foods))
		return "forbidden"

	var/is_meat  = istype(food, /obj/item/reagent_containers/food/snacks/meat)
	var/is_snack = istype(food, /obj/item/reagent_containers/food/snacks)

	switch(owner.diet_type)
		if(DIET_CARNIVORE)
			return is_meat ? "acceptable" : "forbidden"
		if(DIET_HERBIVORE)
			return (is_snack && !is_meat) ? "acceptable" : "forbidden"
		if(DIET_OMNIVORE)
			return is_snack ? "acceptable" : "forbidden"

	return is_snack ? "acceptable" : "forbidden"

// ============================================================
// PETTING
// ============================================================

/datum/taming/proc/try_pet(mob/living/petter)
	if(!owner || QDELETED(owner) || owner.stat == DEAD)
		return FALSE

	if(get_tier() < TAME_CAUTIOUS)
		return FALSE

	if(get_tier() == TAME_CAUTIOUS)
		petter.visible_message(SPAN_NOTICE("\The [owner] напряжённо смотрит на [petter], не подпуская к себе."))
		return TRUE

	if((world.time - last_petted) < pet_cooldown)
		return TRUE
	petter.visible_message(SPAN_NOTICE("\The [petter] гладит \the [owner]."))
	last_petted = world.time
	if(!current_tamer || !current_tamer.resolve())
		current_tamer = weakref(petter)
	add_trust(3 / owner.tame_difficulty, petter)
	// Happy reaction to being petted
	if(owner.say_list && length(owner.say_list.speak) && prob(50))
		owner.ISay(pick(owner.say_list.speak))
	else
		owner.visible_emote(pick(list(
			"довольно жмурится.",
			"мурлычет от удовольствия.",
			"виляет хвостом.",
			"тычется мордой в руку [petter].",
			"прикрывает глаза."
		)))
	return TRUE

// ============================================================
// TALKING NEARBY
// ============================================================

/datum/taming/proc/try_talk(mob/living/speaker)
	if(!owner || QDELETED(owner) || owner.stat == DEAD)
		return FALSE
	if(get_tier() < TAME_CAUTIOUS)
		return FALSE

	var/mob/tamer_mob = current_tamer ? current_tamer.resolve() : null
	if(tamer_mob && tamer_mob != speaker)
		return FALSE
	if((world.time - last_talked) < talk_cooldown)
		return FALSE

	if(get_tier() >= TAME_CURIOUS && prob(30))
		owner.visible_message(SPAN_NOTICE("\The [owner] смотрит на [speaker]."))

	last_talked = world.time
	if(!current_tamer)
		current_tamer = weakref(speaker)
	add_trust(1, speaker)
	return TRUE

// ============================================================
// DECAY
// ============================================================

/datum/taming/proc/decay_loop()
	while(owner && !QDELETED(owner) && !QDELETED(src))
		sleep(10 * 50)  // 5 minutes
		if(!owner || QDELETED(owner))
			return
		decay_tick()

/datum/taming/proc/decay_tick()
	if(decay_exempt || owner.stat == DEAD || trust <= 0)
		return
	add_trust(-1, null)

// ============================================================
// HOOKS ON mobs
// ============================================================

/// Store last pointed-at atom for fetch command
/mob/living
	var/atom/movable/pointed_atom

/mob/living/pointed(atom/A as mob|obj|turf in view())
	. = ..()
	if(.)
		pointed_atom = A

/mob/living/simple_animal
	/// Set when this animal is fully tamed
	var/mob/owner_mob = null
	/// Guard against stacked fetch spawns causing AI freeze
	var/fetch_in_progress = FALSE

/// Talking nearby builds trust; tamed animals respond to owner commands
/mob/living/simple_animal/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	. = ..()
	if(stat == DEAD)
		return
	if(!speaker || QDELETED(speaker))
		return

	if(tame_datum && tame_datum.get_tier() < TAME_TAMED)
		tame_datum.try_talk(speaker)
		return

	// Commanded subtypes handle commands through command_buffer → listen() in Life()
	if(istype(src, /mob/living/simple_animal/hostile/commanded))
		return

	// Name recognition — react when anyone nearby says our name (even non-owners)
	var/pet_name = lowertext(html_decode(name))
	if(length(pet_name) >= 3 && findtext(lowertext(html_decode(message)), pet_name))
		if(get_dist(src, speaker) <= 7 && z == speaker.z)
			if(!fetch_in_progress && (!ai_holder || !ai_holder.busy))
				face_atom(speaker)
				visible_emote(pick(list(
					"смотрит на [speaker].",
					"поднимает голову, услышав своё имя.",
					"навострил уши, глядя на [speaker].",
					"косит глазом на [speaker]."
				)))

	if(!owner_mob || speaker != owner_mob || QDELETED(owner_mob))
		return

	var/text = lowertext(html_decode(message))
	var/filtered_name = lowertext(html_decode(name))
	var/substring = text
	if(dd_hasprefix(text, filtered_name))
		substring = copytext(text, length(filtered_name) + 1)

	handle_owner_command(owner_mob, substring)

/// Commands for tamed simple_animal (non-commanded) mobs
/mob/living/simple_animal/proc/handle_owner_command(mob/speaker, text)
	if(findtext(text, "забудь хозяина"))
		visible_message(SPAN_NOTICE("\The [src] смотрит потерянно..."))
		friends -= weakref(owner_mob)
		owner_mob = null
		fetch_in_progress = FALSE
		if(ai_holder)
			ai_holder.lose_follow()
			ai_holder.remove_target()
			set_AI_busy(FALSE)
		if(tame_datum)
			tame_datum.current_tamer = null
		return

	if(findtext(text, "атакуй") && istype(ai_holder, /datum/ai_holder/tamed))
		var/list/possible_targets = list()
		for(var/mob/living/M in hearers(src, 10))
			if(M == src || M == speaker || M.stat == DEAD)
				continue
			if((weakref(M) in friends) || (M in friends))
				continue
			if(findtext(text, lowertext("[M]")))
				possible_targets += M
		if(!length(possible_targets))
			for(var/mob/living/M in hearers(src, 10))
				if(M == src || M == speaker || M.stat == DEAD)
					continue
				if((weakref(M) in friends) || (M in friends))
					continue
				possible_targets += M
		if(length(possible_targets))
			do_attack_mob_command(possible_targets[1])
		else
			visible_message(SPAN_NOTICE("\The [src] смотрит по сторонам, но не видит врагов."))
		return

	if(findtext(text, "фас"))
		do_fas_command(speaker)
		return

	if(findtext(text, "туда"))
		do_goto_command(speaker)
		return

	if(findtext(text, "охраняй") || findtext(text, "защищай"))
		fetch_in_progress = FALSE
		ai_holder.hostile = TRUE
		ai_holder.leader = speaker
		ai_holder.remove_target()
		set_AI_busy(FALSE)
		friends |= weakref(speaker)
		visible_message(SPAN_NOTICE("\The [src] встаёт на защиту [speaker]."))
		return

	if(findtext(text, "отставить") || findtext(text, "фу"))
		fetch_in_progress = FALSE
		if(ai_holder)
			ai_holder.hostile = FALSE
			ai_holder.remove_target()
			if(owner_mob)
				ai_holder.leader = owner_mob
			else
				ai_holder.lose_follow()
			set_AI_busy(FALSE)
		walk_to(src, 0)
		visible_message(SPAN_NOTICE("\The [src] прекращает свои действия."))
		return

	if(findtext(text, "следуй") || findtext(text, "иди") || findtext(text, "ко мне"))
		fetch_in_progress = FALSE
		if(ai_holder)
			ai_holder.hostile = FALSE
			ai_holder.remove_target()
			ai_holder.leader = speaker
			set_AI_busy(FALSE)
		walk_to(src, 0)
		visible_message(SPAN_NOTICE("\The [src] начинает следовать за [speaker]."))

	else if(findtext(text, "стой") || findtext(text, "место"))
		fetch_in_progress = FALSE
		if(ai_holder)
			ai_holder.hostile = FALSE
			ai_holder.remove_target()
			ai_holder.lose_follow()
			set_AI_busy(TRUE)
		walk_to(src, 0)
		visible_message(SPAN_NOTICE("\The [src] останавливается."))

	else if(findtext(text, "голос"))
		if(say_list)
			if(length(say_list.speak))
				say(pick(say_list.speak))
				return
			if(length(say_list.emote_hear))
				audible_emote(pick(say_list.emote_hear))
				return
			if(length(say_list.emote_see))
				visible_emote(pick(say_list.emote_see))
				return
		if(attack_sound)
			playsound(src, attack_sound, 50, 1)
			return
		visible_message(SPAN_NOTICE("\The [src] молчит."))

	else if(findtext(text, "сидеть") || findtext(text, "лечь"))
		fetch_in_progress = FALSE
		if(ai_holder)
			ai_holder.hostile = FALSE
			ai_holder.remove_target()
			ai_holder.lose_follow()
			set_AI_busy(TRUE)
		walk_to(src, 0)
		visible_message(SPAN_NOTICE("\The [src] послушно садится."))

	else if(findtext(text, "апорт"))
		do_fetch_command(speaker)

	else if(findtext(text, "тащи"))
		do_drag_command(speaker)

	else if(findtext(text, "бей"))
		do_hit_command(speaker)

	else if(findtext(text, "способность"))
		do_ability_command(speaker)

/// Сбросить текущее движение и AI-следование перед ручной командой
/mob/living/simple_animal/proc/begin_manual_command()
	fetch_in_progress = FALSE
	fetch_in_progress = TRUE
	walk_to(src, 0)
	if(ai_holder)
		ai_holder.lose_follow()
		ai_holder.remove_target()
		set_AI_busy(TRUE)

/// Завершить ручную команду — разморозить AI и вернуть следование за хозяином
/mob/living/simple_animal/proc/end_manual_command()
	fetch_in_progress = FALSE
	if(ai_holder)
		if(owner_mob && !QDELETED(owner_mob))
			ai_holder.leader = owner_mob
		set_AI_busy(FALSE)

/// Тащи — животное бежит к указанному мобу (middle-click) и тащит его к мастеру
/mob/living/simple_animal/proc/do_drag_command(mob/speaker)
	var/mob/living/L = speaker
	var/mob/living/target = null
	if(L.pointed_atom && isliving(L.pointed_atom) && !QDELETED(L.pointed_atom))
		target = L.pointed_atom
	L.pointed_atom = null

	if(!target || target == src || target == speaker)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на существо (средняя кнопка мыши)."))
		return
	if(target.mob_size > mob_size)
		visible_message(SPAN_NOTICE("\The [src] смотрит на [target] — слишком тяжёлый, не осилит."))
		return

	begin_manual_command()
	visible_message(SPAN_NOTICE("\The [src] бежит к [target] чтобы тащить его сюда!"))

	addtimer(new Callback(src, PROC_REF(do_drag_loop), target, speaker), 0)

/mob/living/simple_animal/proc/do_drag_loop(mob/living/T, mob/dest)
	set background = TRUE
	if(QDELETED(src)) return
	// Фаза 1: идти к цели
	while(!QDELETED(src) && fetch_in_progress && !QDELETED(T))
		if(get_dist(src, T) <= 1 && z == T.z)
			break
		step_to(src, T)
		sleep(5)

	if(QDELETED(src) || !fetch_in_progress || QDELETED(T))
		if(!QDELETED(src)) end_manual_command()
		return

	visible_message(SPAN_NOTICE("\The [src] хватает [T] и тащит к [dest]."))

	// Фаза 2: тащить к мастеру — каждый шаг вручную тянем цель на предыдущую позицию животного
	while(!QDELETED(src) && fetch_in_progress && !QDELETED(dest) && !QDELETED(T))
		if(get_dist(src, dest) <= 1 && z == dest.z)
			break
		var/turf/old_pos = get_turf(src)
		step_to(src, dest)
		if(!QDELETED(T) && get_turf(src) != old_pos)
			T.forceMove(old_pos)
		sleep(5)

	if(!QDELETED(src))
		visible_message(SPAN_NOTICE("\The [src] приводит [QDELETED(T) ? "добычу" : "[T]"] к [QDELETED(dest) ? "месту" : "[dest]"]."))
		end_manual_command()

/// Бей — бежит к объекту на который указал мастер (middle-click) и атакует до уничтожения или отмены
/mob/living/simple_animal/proc/do_hit_command(mob/speaker)
	var/mob/living/L = speaker
	var/atom/hit_target = null
	if(L.pointed_atom && !QDELETED(L.pointed_atom) && !isliving(L.pointed_atom))
		hit_target = L.pointed_atom
	L.pointed_atom = null

	if(!hit_target)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на объект (средняя кнопка мыши)."))
		return

	var/target_name = "[hit_target]"
	begin_manual_command()
	visible_message(SPAN_NOTICE("\The [src] бросается на [hit_target]!"))

	addtimer(new Callback(src, PROC_REF(do_hit_loop), hit_target, target_name), 0)

/mob/living/simple_animal/proc/do_hit_loop(atom/hit_target, target_name)
	set background = TRUE
	if(QDELETED(src)) return
	// Фаза 1: добраться до цели
	while(!QDELETED(src) && fetch_in_progress && !QDELETED(hit_target))
		if(get_dist(src, hit_target) <= 1 && z == hit_target.z)
			break
		step_to(src, hit_target)
		sleep(5)

	if(QDELETED(src) || !fetch_in_progress || QDELETED(hit_target))
		if(!QDELETED(src)) end_manual_command()
		return

	// Фаза 2: атаковать до уничтожения или отмены
	while(!QDELETED(src) && fetch_in_progress && !QDELETED(hit_target))
		attack_target(hit_target)
		sleep(10)

	if(!QDELETED(src))
		if(QDELETED(hit_target))
			visible_message(SPAN_NOTICE("\The [src] расправляется с [target_name]."))
		end_manual_command()

/// Общий проц атаки моба — ручной цикл без AI
/mob/living/simple_animal/proc/do_attack_mob_command(mob/living/attack_target)
	if(!attack_target || QDELETED(attack_target))
		return

	begin_manual_command()
	visible_message(SPAN_WARNING("\The [src] бросается на [attack_target]!"))

	addtimer(new Callback(src, PROC_REF(do_attack_loop), attack_target), 0)

/mob/living/simple_animal/proc/do_attack_loop(mob/living/T)
	set background = TRUE
	if(QDELETED(src)) return
	while(!QDELETED(src) && fetch_in_progress && !QDELETED(T) && T.stat != DEAD)
		if(get_dist(src, T) <= 1 && z == T.z)
			attack_target(T)
		else
			step_to(src, T)
		sleep(5)

	if(!QDELETED(src))
		end_manual_command()

/// Фас — атаковать живого моба на которого указал мастер (middle-click)
/mob/living/simple_animal/proc/do_fas_command(mob/speaker)
	var/mob/living/L = speaker
	var/mob/living/target = null
	if(L.pointed_atom && isliving(L.pointed_atom) && !QDELETED(L.pointed_atom))
		target = L.pointed_atom
	L.pointed_atom = null

	if(!target)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на существо (средняя кнопка мыши)."))
		return
	if((weakref(target) in friends) || (target in friends))
		visible_message(SPAN_NOTICE("\The [src] отказывается нападать на друга."))
		return

	do_attack_mob_command(target)

/// Туда — прирученное существо бежит к указанной точке и остаётся там
/mob/living/simple_animal/proc/do_goto_command(mob/speaker)
	var/mob/living/L = speaker
	var/atom/dest = L.pointed_atom
	L.pointed_atom = null

	if(!dest)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите куда идти (средняя кнопка мыши)."))
		return

	var/turf/target_turf = get_turf(dest)
	if(!target_turf)
		return

	begin_manual_command()
	visible_message(SPAN_NOTICE("\The [src] бежит туда!"))

	addtimer(new Callback(src, PROC_REF(do_goto_loop), target_turf), 0)

/mob/living/simple_animal/proc/do_goto_loop(turf/target_turf)
	set background = TRUE
	if(QDELETED(src)) return
	while(!QDELETED(src) && fetch_in_progress)
		if(get_turf(src) == target_turf)
			break
		step_to(src, target_turf)
		sleep(5)

	if(!QDELETED(src))
		// Остаться на месте — AI заморожен
		if(ai_holder)
			ai_holder.lose_follow()
			ai_holder.remove_target()
		fetch_in_progress = FALSE
		visible_message(SPAN_NOTICE("\The [src] останавливается на месте."))

/// Способность — использовать спецатаку если она есть у этого существа
/mob/living/simple_animal/proc/do_ability_command(mob/speaker)
	if(isnull(special_attack_cooldown) || isnull(special_attack_min_range))
		visible_message(SPAN_NOTICE("\The [src] не знает такой команды."))
		return

	if(last_special_attack + special_attack_cooldown > world.time)
		var/remaining = round((last_special_attack + special_attack_cooldown - world.time) / 10)
		visible_message(SPAN_NOTICE("\The [src] ещё не готов применить способность. ([remaining] сек.)"))
		return

	visible_message(SPAN_NOTICE("\The [src] применяет свою способность!"))
	special_attack_target(speaker)

/// Апорт — животное бежит к предмету на который указал мастер (middle-click), подбирает его, несёт обратно
/mob/living/simple_animal/proc/do_fetch_command(mob/speaker)
	var/mob/living/L = speaker
	var/obj/item/F = null
	if(L.pointed_atom && istype(L.pointed_atom, /obj/item) && !QDELETED(L.pointed_atom))
		F = L.pointed_atom
	L.pointed_atom = null

	if(!F)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на предмет (средняя кнопка мыши)."))
		return
	if(F.anchored)
		visible_message(SPAN_NOTICE("\The [src] пытается схватить [F], но тот прикреплён к полу."))
		return

	begin_manual_command()
	visible_message(SPAN_NOTICE("\The [src] бежит за [F]!"))

	addtimer(new Callback(src, PROC_REF(do_fetch_loop), F, speaker), 0)

/mob/living/simple_animal/proc/do_fetch_loop(obj/item/F, mob/fetch_owner)
	set background = TRUE
	if(QDELETED(src)) return
	// Фаза 1: дойти до предмета
	while(!QDELETED(src) && fetch_in_progress && !QDELETED(F))
		if(get_dist(src, F) <= 1 && z == F.z)
			break
		step_to(src, F)
		sleep(5)

	if(QDELETED(src) || !fetch_in_progress || QDELETED(F))
		if(!QDELETED(src)) end_manual_command()
		return

	// Подбирает
	F.forceMove(src)
	visible_message(SPAN_NOTICE("\The [src] подбирает [F]."))

	// Фаза 2: нести к мастеру
	if(!QDELETED(fetch_owner))
		while(!QDELETED(src) && fetch_in_progress && !QDELETED(fetch_owner))
			if(get_dist(src, fetch_owner) <= 1 && z == fetch_owner.z)
				break
			step_to(src, fetch_owner)
			sleep(5)

	// Кладёт у ног
	if(!QDELETED(src) && !QDELETED(F))
		var/turf/drop_loc = get_turf(!QDELETED(fetch_owner) ? fetch_owner : src)
		F.forceMove(drop_loc)
		if(!QDELETED(fetch_owner))
			visible_message(SPAN_NOTICE("\The [src] кладёт [F] у ног [fetch_owner]."))
		else
			visible_message(SPAN_NOTICE("\The [src] роняет [F]."))

	if(!QDELETED(src)) end_manual_command()

/// Intercept food use for taming
/mob/living/simple_animal/can_use_item(obj/item/O, mob/user)
	if(tame_datum && istype(O, /obj/item/reagent_containers/food/snacks) && stat != DEAD)
		return tame_datum.try_feed(user, O)
	return ..()

#undef TAME_WILD
#undef TAME_CAUTIOUS
#undef TAME_CURIOUS
#undef TAME_TAMED
#undef TAME_THRESHOLD_CAUTIOUS
#undef TAME_THRESHOLD_CURIOUS
#undef TAME_THRESHOLD_TAMED
