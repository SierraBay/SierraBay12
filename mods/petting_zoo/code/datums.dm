/// Commanded stances
#define COMMANDED_STOP 6 //basically 'do nothing'
#define COMMANDED_FOLLOW 7 //follows a target
#define COMMANDED_MISC 8 //catch all state for misc commands that need one.


/mob/living/carbon
	var/list/guards = list() // We need this list here

/mob/living/simple_animal/hostile/commanded
	name = "commanded"
	stance = COMMANDED_STOP
	natural_weapon = /obj/item/natural_weapon
	density = FALSE
	var/list/command_buffer = list()
	var/list/known_commands = list("иди за мной", "следуй", "ко мне", "стой", "место", "отставить", "атакуй", "охраняй", "слушайся", "забудь хозяина", "забудь цель", "голос", "сидеть", "лечь", "апорт", "бей", "фас", "тащи", "туда", "способность", "фу")
	var/mob/master = null //undisputed master. Their commands hold ultimate sway and ultimate power.
	var/list/allowed_targets = list() //WHO CAN I KILL D:
	var/retribution = 1 //whether or not they will attack us if we attack them like some kinda dick.
	var/list/protected_mobs  = list() // who under our protection

	ai_holder = /datum/ai_holder/simple_animal/melee/commanded

/datum/ai_holder/simple_animal/melee/commanded/can_attack(atom/movable/the_target, vision_required)
	var/mob/living/simple_animal/hostile/commanded/H = holder
	if(!(the_target in H.allowed_targets))
		return FALSE
	return ..()

/datum/ai_holder/simple_animal/melee/commanded/find_target(list/possible_targets, has_targets_list)
	ai_log("commanded/find_target() : Entered.", AI_LOG_TRACE)
	var/mob/living/simple_animal/hostile/commanded/C = holder
	if(!length(C.allowed_targets))
		return null
	var/mode = "specific"
	if(C.allowed_targets[1] == "everyone") //we have been given the golden gift of murdering everything. Except our master, of course. And our friends. So just mostly everyone.
		mode = "everyone"
	for(var/atom/A in list_targets())
		var/mob/M = null
		if(A == src)
			continue
		if(isliving(A))
			M = A
		if(M && M.stat)
			continue
		if(mode == "specific")
			if(!(A in C.allowed_targets))
				continue
			C.stance = STANCE_IDLE
			give_target(A)
			return A
		else
			C.allowed_targets += A
			if(M == C.master || (weakref(M) in C.friends))
				continue
			C.stance = STANCE_IDLE
			give_target(M)
			return A
	return ..()

/mob/living/simple_animal/hostile/commanded/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if(stat == DEAD)
		return FALSE
	if(((weakref(speaker) in friends) && !master) || speaker == master)
		command_buffer.Add(speaker)
		command_buffer.Add(lowertext(html_decode(message)))
	..() // Allow taming hear_say hook to run (talk-based trust, owner commands)
	return FALSE

/mob/living/simple_animal/hostile/commanded/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0)
	if(stat == DEAD)
		return FALSE
	if(((weakref(speaker) in friends) && !master) || speaker == master)
		command_buffer.Add(speaker)
		command_buffer.Add(lowertext(html_decode(message)))
	return FALSE

/mob/living/simple_animal/hostile/commanded/Life()
	. = ..()
	if(!.)
		return FALSE
	while(length(command_buffer) > 0)
		var/mob/speaker = command_buffer[1]
		var/text = command_buffer[2]
		var/filtered_name = lowertext(html_decode(name))
		var/substring = text
		if(dd_hasprefix(text, filtered_name))
			substring = copytext(text, length(filtered_name) + 1)
		if(speaker == master || dd_hasprefix(text, filtered_name) || dd_hasprefix(text, "все") || dd_hasprefix(text, "всем"))
			listen(speaker, substring)
		command_buffer.Remove(command_buffer[1], command_buffer[2])
	switch(stance)
		if(COMMANDED_FOLLOW)
			follow_target()
		if(COMMANDED_STOP)
			commanded_stop()


/mob/living/simple_animal/hostile/commanded/proc/follow_target()
	if(!target_mob || QDELETED(target_mob))
		stance = COMMANDED_STOP
		ai_holder.lose_follow()
		return


/mob/living/simple_animal/hostile/commanded/proc/commanded_stop() //basically a proc that runs whenever we are asked to stay put. Probably going to remain unused.
	return

/mob/living/simple_animal/hostile/commanded/proc/listen(mob/speaker, text)
	// Прямые keyword-проверки вместо цикла по known_commands — надёжнее для multi-word команд
	if(findtext(text, "забудь хозяина"))
		forget_master_command(speaker, text)
	else if(findtext(text, "забудь цель"))
		forget_target_command(speaker, text)
	else if(findtext(text, "стой") || findtext(text, "место"))
		stay_command(speaker, text)
	else if(findtext(text, "отставить") || findtext(text, "фу"))
		stop_command(speaker, text)
	else if(findtext(text, "атакуй"))
		attack_command(speaker, text)
	else if(findtext(text, "следуй") || findtext(text, "иди") || findtext(text, "ко мне"))
		follow_command(speaker, text)
	else if(findtext(text, "охраняй"))
		guard_command(speaker, text)
	else if(findtext(text, "слушайся"))
		obey_command(speaker, text)
	else if(findtext(text, "голос"))
		speak_command(speaker, text)
	else if(findtext(text, "сидеть") || findtext(text, "лечь"))
		sit_command(speaker, text)
	else if(findtext(text, "апорт"))
		fetch_command(speaker, text)
	else if(findtext(text, "бей"))
		hit_command(speaker, text)
	else if(findtext(text, "фас"))
		fas_command(speaker, text)
	else if(findtext(text, "тащи"))
		drag_command(speaker, text)
	else if(findtext(text, "туда"))
		goto_command(speaker, text)
	else if(findtext(text, "способность"))
		ability_command(speaker, text)
	else
		misc_command(speaker, text)
	return TRUE

//returns a list of everybody we wanna do stuff with.
/mob/living/simple_animal/hostile/commanded/proc/get_targets_by_name(text, filter_friendlies = 0)
	var/list/possible_targets = hearers(src,10)
	. = list()
	for(var/mob/M in possible_targets)
		if(filter_friendlies && ((weakref(M) in friends) || M.faction == faction || M == master || M == src))
			continue
		var/found = 0
		if(findtext(text, "[M]"))
			found = 1
		else
			var/list/parsed_name = splittext(replace_characters(lowertext(html_decode("[M]")),list("-"=" ", "."=" ", "," = " ", "'" = " ")), " ") //this big MESS is basically 'turn this into words, no punctuation, lowercase so we can check first name/last name/etc'
			for(var/a in parsed_name)
				if(a == "the" || length(a) < 2) //get rid of shit words.
					continue
				if(findtext(text,"[a]"))
					found = 1
					break
		if(found)
			. += M


/mob/living/simple_animal/hostile/commanded/proc/clear_protected_mobs()
	for(var/mob/living/carbon/guarded in protected_mobs)
		guarded.guards -= src
		friends -= weakref(guarded)

	protected_mobs = list()

/mob/living/simple_animal/hostile/commanded/proc/attack_command(mob/speaker, text)
	clear_protected_mobs()
	target_mob = null
	set_AI_busy(FALSE)
	walk_to(src,0)
	stance = STANCE_ATTACK
	if(findtext(text,"всех") || findtext(text,"всё") || findtext(text,"всё живое"))
		allowed_targets = list("everyone")
		return TRUE

	var/list/targets = get_targets_by_name(text)
	allowed_targets -= "everyone"
	for(var/target in targets)
		allowed_targets |= target

	return length(targets) != 0

/mob/living/simple_animal/hostile/commanded/proc/stay_command(mob/speaker, text)
	target_mob = null
	stance = COMMANDED_STOP
	set_AI_busy(TRUE)
	walk_to(src,0)
	ai_holder.lose_follow()
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/stop_command(mob/speaker, text)
	clear_protected_mobs()
	allowed_targets = list()
	walk_to(src,0)
	ai_holder.target  = null
	ai_holder.lose_follow()
	target_mob = null //gotta stop SOMETHIN
	stance = STANCE_IDLE
	set_AI_busy(FALSE)
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/follow_command(mob/speaker, text)
	clear_protected_mobs()
	var/mob/follow_who
	if(findtext(text,"мной") || findtext(text,"мне") || !length(get_targets_by_name(text)))
		follow_who = speaker
	else
		var/list/targets = get_targets_by_name(text)
		if(length(targets) != 1)
			return FALSE
		follow_who = targets[1]

	stance = COMMANDED_FOLLOW
	target_mob = follow_who
	friends |= weakref(follow_who)
	set_AI_busy(FALSE)
	ai_holder.set_follow(follow_who)
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/guard_command(mob/living/carbon/speaker, text)
	if(findtext(text,"меня") || findtext(text,"мне"))
		stance = COMMANDED_FOLLOW
		target_mob = speaker
		clear_protected_mobs()
		speaker.guards |= src
		friends |= weakref(target_mob)
		set_AI_busy(FALSE)
		ai_holder.set_follow(speaker)
		return TRUE

	var/list/targets = get_targets_by_name(text)
	if(!length(targets))
		return FALSE

	for(var/mob/living/carbon/guarded_mob in targets) // only carbon lives need protection
		if(!(src in guarded_mob.guards))
			guarded_mob.guards += src
			protected_mobs += guarded_mob
		friends |= weakref(guarded_mob)

	stance = COMMANDED_FOLLOW
	target_mob = pick(targets)
	set_AI_busy(FALSE)
	ai_holder.set_follow(target_mob)
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/forget_target_command(mob/speaker, text)
	allowed_targets = list()
	ai_holder.target  = null
	target_mob = null //gotta stop SOMETHIN
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/forget_master_command(mob/speaker, text)
	if(speaker != master)
		return FALSE
	friends -= weakref(master)

	master = null // I`m alone, again, maybe my name is Hachiko?
	owner_mob = null
	ai_holder.leader = null
	walk_to(src,0)
	target_mob = null //gotta stop SOMETHIN
	stance = STANCE_IDLE
	set_AI_busy(FALSE)
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/obey_command(mob/speaker, text)
	if(speaker != master)
		return FALSE

	var/list/targets =  list()
	for(var/mob/living/carbon/human/H in get_targets_by_name(text)) //I want to obey humans
		targets += H
	if(length(targets) > 1 || !length(targets)) //CONFUSED. WHO DO I OBEY?
		return FALSE
	master = targets[1]
	friends |= weakref(master)
	return TRUE

/// "голос" - animal makes its characteristic sound
/mob/living/simple_animal/hostile/commanded/proc/speak_command(mob/speaker, text)
	if(say_list)
		if(length(say_list.speak))
			say(pick(say_list.speak))
			return TRUE
		if(length(say_list.emote_hear))
			audible_emote(pick(say_list.emote_hear))
			return TRUE
		if(length(say_list.emote_see))
			visible_emote(pick(say_list.emote_see))
			return TRUE
	if(attack_sound)
		playsound(src, attack_sound, 50, 1)
		return TRUE
	visible_message(SPAN_NOTICE("\The [src] молчит."))
	return TRUE

/// "сидеть" / "лечь" - sit/lie down animation
/mob/living/simple_animal/hostile/commanded/proc/sit_command(mob/speaker, text)
	visible_message(SPAN_NOTICE("\The [src] послушно садится."))
	walk_to(src, 0)
	stance = COMMANDED_STOP
	set_AI_busy(TRUE)
	return TRUE

/// "апорт" - животное бежит к предмету на который указал мастер (middle-click), подбирает его, несёт обратно
/mob/living/simple_animal/hostile/commanded/proc/fetch_command(mob/speaker, text)
	var/mob/living/L = speaker
	var/obj/item/fetch_target = null
	if(L.pointed_atom && istype(L.pointed_atom, /obj/item) && !QDELETED(L.pointed_atom))
		fetch_target = L.pointed_atom
	L.pointed_atom = null

	if(!fetch_target || fetch_target.anchored)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на предмет (средняя кнопка мыши)."))
		return TRUE

	var/mob/fetch_master = master ? master : speaker
	stance = COMMANDED_MISC
	walk_to(src, 0)
	ai_holder.lose_follow()
	set_AI_busy(TRUE)
	visible_message(SPAN_NOTICE("\The [src] бежит за [fetch_target]!"))
	spawn(0)
		while(!QDELETED(src) && stance == COMMANDED_MISC && !QDELETED(fetch_target))
			if(get_dist(src, fetch_target) <= 1 && src.z == fetch_target.z)
				break
			step_to(src, fetch_target)
			sleep(5)

		if(QDELETED(src) || stance != COMMANDED_MISC || QDELETED(fetch_target))
			if(!QDELETED(src))
				stance = COMMANDED_STOP
				set_AI_busy(FALSE)
			return

		fetch_target.forceMove(src)
		visible_message(SPAN_NOTICE("\The [src] подбирает [fetch_target]."))

		if(!QDELETED(fetch_master))
			while(!QDELETED(src) && stance == COMMANDED_MISC && !QDELETED(fetch_master))
				if(get_dist(src, fetch_master) <= 1 && src.z == fetch_master.z)
					break
				step_to(src, fetch_master)
				sleep(5)

		if(!QDELETED(src) && !QDELETED(fetch_target))
			var/turf/drop_loc = get_turf(!QDELETED(fetch_master) ? fetch_master : src)
			fetch_target.forceMove(drop_loc)
			if(!QDELETED(fetch_master))
				visible_message(SPAN_NOTICE("\The [src] кладёт [fetch_target] у ног [fetch_master]."))
			else
				visible_message(SPAN_NOTICE("\The [src] роняет [fetch_target]."))

		if(!QDELETED(src))
			stance = COMMANDED_STOP
			set_AI_busy(FALSE)
	return TRUE

/// "бей" - животное атакует объект или структуру на которую указал мастер (middle-click)
/mob/living/simple_animal/hostile/commanded/proc/hit_command(mob/speaker, text)
	var/mob/living/L = speaker
	var/atom/hit_target = null
	if(L.pointed_atom && !QDELETED(L.pointed_atom) && !isliving(L.pointed_atom))
		hit_target = L.pointed_atom
	L.pointed_atom = null

	if(!hit_target)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на объект (средняя кнопка мыши)."))
		return TRUE

	var/target_name = "[hit_target]"
	stance = COMMANDED_MISC
	walk_to(src, 0)
	ai_holder.lose_follow()
	set_AI_busy(TRUE)
	visible_message(SPAN_NOTICE("\The [src] бросается на [hit_target]!"))
	spawn(0)
		while(!QDELETED(src) && stance == COMMANDED_MISC && !QDELETED(hit_target))
			if(get_dist(src, hit_target) <= 1 && src.z == hit_target.z)
				attack_target(hit_target)
			else
				step_to(src, hit_target)
			sleep(5)

		if(!QDELETED(src))
			stance = COMMANDED_STOP
			set_AI_busy(FALSE)
			if(QDELETED(hit_target))
				visible_message(SPAN_NOTICE("\The [src] расправляется с [target_name]."))
	return TRUE

/// "фас" - атаковать живого моба на которого указал мастер (middle-click)
/mob/living/simple_animal/hostile/commanded/proc/fas_command(mob/speaker, text)
	var/mob/living/L = speaker
	var/mob/living/target = null
	if(L.pointed_atom && isliving(L.pointed_atom) && !QDELETED(L.pointed_atom))
		target = L.pointed_atom
	L.pointed_atom = null

	if(!target)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на существо (средняя кнопка мыши)."))
		return TRUE
	if((weakref(target) in friends) || (target in friends))
		visible_message(SPAN_NOTICE("\The [src] отказывается нападать на друга."))
		return TRUE

	var/mob/living/T = target
	stance = COMMANDED_MISC
	walk_to(src, 0)
	ai_holder.lose_follow()
	set_AI_busy(TRUE)
	visible_message(SPAN_WARNING("\The [src] бросается на [T]!"))
	spawn(0)
		while(!QDELETED(src) && stance == COMMANDED_MISC && !QDELETED(T) && T.stat != DEAD)
			if(get_dist(src, T) <= 1 && src.z == T.z)
				attack_target(T)
			else
				step_to(src, T)
			sleep(5)

		if(!QDELETED(src))
			stance = COMMANDED_STOP
			set_AI_busy(FALSE)
	return TRUE

/// "тащи" - существо тащит указанного (middle-click) моба к мастеру
/mob/living/simple_animal/hostile/commanded/proc/drag_command(mob/speaker, text)
	var/mob/living/L = speaker
	var/mob/living/target = null
	if(L.pointed_atom && isliving(L.pointed_atom) && !QDELETED(L.pointed_atom))
		target = L.pointed_atom
	L.pointed_atom = null

	if(!target || target == src || target == speaker)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите на существо (средняя кнопка мыши)."))
		return TRUE
	if(target.mob_size > mob_size)
		visible_message(SPAN_NOTICE("\The [src] смотрит на [target] — слишком тяжёлый, не осилит."))
		return TRUE

	var/mob/living/T = target
	var/mob/dest = master ? master : speaker
	stance = COMMANDED_MISC
	walk_to(src, 0)
	ai_holder.lose_follow()
	set_AI_busy(TRUE)
	visible_message(SPAN_NOTICE("\The [src] бежит к [T] чтобы тащить его!"))
	spawn(0)
		// Фаза 1: добраться до цели
		while(!QDELETED(src) && stance == COMMANDED_MISC && !QDELETED(T))
			if(get_dist(src, T) <= 1 && src.z == T.z)
				break
			step_to(src, T)
			sleep(5)

		if(QDELETED(src) || stance != COMMANDED_MISC || QDELETED(T))
			if(!QDELETED(src))
				stance = COMMANDED_STOP
				set_AI_busy(FALSE)
			return

		visible_message(SPAN_NOTICE("\The [src] хватает [T] и тащит к [dest]."))

		// Фаза 2: тащить к мастеру — каждый шаг вручную тянем цель на предыдущую позицию
		while(!QDELETED(src) && stance == COMMANDED_MISC && !QDELETED(dest) && !QDELETED(T))
			if(get_dist(src, dest) <= 1 && src.z == dest.z)
				break
			var/turf/old_pos = get_turf(src)
			step_to(src, dest)
			if(!QDELETED(T) && get_turf(src) != old_pos)
				T.forceMove(old_pos)
			sleep(5)

		if(!QDELETED(src))
			visible_message(SPAN_NOTICE("\The [src] приводит [QDELETED(T) ? "добычу" : "[T]"] к [QDELETED(dest) ? "месту" : "[dest]"]."))
			stance = COMMANDED_STOP
			set_AI_busy(FALSE)
	return TRUE

/// "туда" - существо бежит к указанной точке и остаётся там
/mob/living/simple_animal/hostile/commanded/proc/goto_command(mob/speaker, text)
	var/mob/living/L = speaker
	var/atom/dest = L.pointed_atom
	L.pointed_atom = null

	if(!dest)
		visible_message(SPAN_NOTICE("\The [src] ждёт команды — укажите куда идти (средняя кнопка мыши)."))
		return TRUE

	var/turf/target_turf = get_turf(dest)
	if(!target_turf)
		return TRUE

	stance = COMMANDED_MISC
	walk_to(src, 0)
	ai_holder.lose_follow()
	set_AI_busy(TRUE)
	visible_message(SPAN_NOTICE("\The [src] бежит туда!"))
	spawn(0)
		while(!QDELETED(src) && stance == COMMANDED_MISC)
			if(get_turf(src) == target_turf)
				break
			step_to(src, target_turf)
			sleep(5)

		if(!QDELETED(src))
			if(stance == COMMANDED_MISC)
				stance = COMMANDED_STOP
			ai_holder.lose_follow()
			ai_holder.remove_target()
			visible_message(SPAN_NOTICE("\The [src] останавливается на месте."))
	return TRUE

/// "способность" - использовать спецатаку существа
/mob/living/simple_animal/hostile/commanded/proc/ability_command(mob/speaker, text)
	if(isnull(special_attack_cooldown) || isnull(special_attack_min_range))
		visible_message(SPAN_NOTICE("\The [src] не знает такой команды."))
		return TRUE

	if(last_special_attack + special_attack_cooldown > world.time)
		var/remaining = round((last_special_attack + special_attack_cooldown - world.time) / 10)
		visible_message(SPAN_NOTICE("\The [src] ещё не готов применить способность. ([remaining] сек.)"))
		return TRUE

	visible_message(SPAN_NOTICE("\The [src] применяет свою способность!"))
	special_attack_target(speaker)
	return TRUE

/mob/living/simple_animal/hostile/commanded/proc/misc_command(mob/speaker, text)
	return FALSE

/mob/living/simple_animal/hostile/commanded/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	//if they attack us, we want to kill them. None of that "you weren't given a command so free kill" bullshit.
	. = ..()
	if(. && retribution)
		target_mob = user
		allowed_targets |= target_mob //fuck this guy in particular.
		stance = STANCE_ATTACK
		friends -= weakref(user)
		set_AI_busy(FALSE)
		ai_holder.react_to_attack(user)


/mob/living/simple_animal/hostile/commanded/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if(M.a_intent == I_HURT && retribution) //assume he wants to hurt us.
		target_mob = M
		allowed_targets |= M //fuck this guy in particular.
		stance = STANCE_ATTACK
		friends -= weakref(M)
		set_AI_busy(FALSE)
		ai_holder.react_to_attack(M)


/mob/living/simple_animal/hostile/commanded/proc/hunt_on(mob/M)
	if(M in ai_holder.list_targets())
		friends -= weakref(M)
		set_AI_busy(FALSE)
		stance = STANCE_ATTACK
		allowed_targets |= M

#undef COMMANDED_STOP
#undef COMMANDED_FOLLOW
#undef COMMANDED_MISC
