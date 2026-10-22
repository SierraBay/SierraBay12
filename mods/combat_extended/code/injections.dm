/*
	COMBAT_EXTENDED — уколы в броню.

	В Bay укол решает `can_inject()`, а он смотрит только на толстую ткань одежды — не на рейтинги
	брони и не на аксессуары. Шприц колол сквозь наручи, гипоспрей — сквозь любой жилет не из толстой
	ткани. Удар шприцем на намерении вреда бросал монету: если броня зоны блокировала больше 10%,
	половина ударов отскакивала, и шприц пропадал.

	Теперь укол — острая атака без урона со своим пробитием (`ce_injection_pen` вещи, мм RHA). Слои
	брони зоны идут снаружи внутрь, каждый тратит пробитие на свой острый рейтинг против холодного
	оружия; слой, на котором оно кончилось, укол останавливает. Чистый запрос: броня не изнашивается.

	- Игла (шприц) встречает все слои: одежду, аксессуары, естественную броню.
	- Струя (`ce_injection_jet` — гипоспрей, автоинъектор, гипоспрей борга) естественную броню
	  проходит: хитину GAS она не помеха.
	- Подкожную броню не встречает никто: укол идёт в кожу, а сетка под ней (`ce_is_under_skin()`).
	- Порт скафандра (`INJECTION_PORT`) ведёт под броню: с ним правило не действует.

	В конечность того, кто недавно двигался, укол не попадает вовсе (`ce_dodges_injection()`).

	Правило стоит в `can_inject()` человека (оверрайд в `_master_files`), но действует только на
	вещи, которые объявили укол (`ce_announce_injection()`): `can_inject()` не знает, чем колют, а
	зовут его ещё и жало генокрада, дротики и ручка со снотворным — у них всё как в Bay. Объявляют
	оверрайды в `_master_files`: шприц, гипоспрей и гипоспрей борга.

	На намерении помощи отказ — сообщение колющему, игла цела. На намерении вреда (`syringestab()`,
	правка кор кода) игла ломается о броню, а по идущей цели удар в конечность мажет.
*/

/obj/item
	/// Острое пробитие укола этой вещью, мм RHA: столько острой брони против холодного оружия укол
	/// проходит на зоне. null — вещь колет по правилам Bay. Задаётся в блоке вещи в `code/items/`.
	var/ce_injection_pen
	/// Вещь колет струёй, без иглы: естественная броня цели ей не помеха. Задаётся там же.
	var/ce_injection_jet = FALSE

/mob/living
	/// Вещь, объявившая укол: по её числам ближайший `can_inject()` проверит броню и движение.
	var/obj/item/ce_injector


/**
 * Объявляет цели укол этой вещью. Зовётся прямо перед `..()` процедуры, которая колет: объявление
 * забирает первый же `can_inject()` цели. После `..()` его снимает `ce_retract_injection()` — на
 * случай, если до `can_inject()` дело не дошло.
 */
/obj/item/proc/ce_announce_injection(mob/living/target)
	if(istype(target) && !isnull(ce_injection_pen))
		target.ce_injector = src


/// Снимает объявление укола, которое так и не забрал `can_inject()`.
/obj/item/proc/ce_retract_injection(mob/living/target)
	if(istype(target) && target.ce_injector == src)
		target.ce_injector = null


/// Забирает объявленный укол: вещь, которой колют, или null. Объявление одноразовое.
/mob/living/proc/ce_take_injector()
	RETURN_TYPE(/obj/item)
	. = ce_injector
	ce_injector = null


/**
 * Уворачивается ли моб от укола в эту зону: зона — конечность (`ce_injection_dodge_zones`), а он
 * двигался не раньше `ce_injection_still_time` назад. Себя колют и на ходу. Лежащий, пристёгнутый,
 * связанный и оглушённый не уворачивается: его несут, а не он идёт.
 */
/mob/living/proc/ce_dodges_injection(mob/user, def_zone)
	if(user == src || lying || buckled || incapacitated())
		return FALSE
	if(!(def_zone in ce_injection_dodge_zones))
		return FALSE
	return world.time - l_move_time < ce_injection_still_time


/**
 * Слой брони, который останавливает укол вещью `injector` в зону, или null — укол проходит. Чистый
 * запрос: броня не изнашивается. Слой, на котором пробитие кончилось ровно, укол останавливает —
 * как в `ce_try_penetrate()`.
 */
/mob/living/proc/ce_get_injection_blocker(def_zone, obj/item/injector)
	RETURN_TYPE(/datum/extension/armor)
	ASSERT(!isnull(injector.ce_injection_pen))
	var/pen = injector.ce_injection_pen
	// Зональная броня читается по зоне укола, как в проходе по слоям.
	var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(def_zone))
	for(var/datum/extension/armor/armor_datum as anything in ce_order_armors(get_armors_by_zone(def_zone, DAMAGE_BRUTE, DAMAGE_FLAG_SHARP), def_zone))
		if(armor_datum.ce_is_under_skin())
			continue
		// Естественная броня — расширение на самом мобе.
		if(injector.ce_injection_jet && armor_datum.holder == src)
			continue
		var/rating = armor_datum.get_armor_sharp_melee()
		if(rating <= 0)
			continue
		pen -= rating
		if(pen <= 0)
			. = armor_datum
			break
	ce_set_hit_body_part(outer_body_part)


/// Текст для колющего, почему укол вещью `injector` в зону не удался, или null — удался.
/mob/living/carbon/human/proc/ce_get_injection_refusal(mob/user, def_zone, obj/item/injector)
	var/obj/item/organ/external/organ = get_organ(def_zone)
	if(ce_dodges_injection(user, def_zone))
		return "\The [src] is moving too much for you to hit the [organ.name] with \the [injector]."
	if(ce_get_injection_blocker(def_zone, injector))
		return "\The [injector] can't get through the armor on \the [src]'s [organ.name]."
	return null


/**
 * Срывает удар шприцем на намерении вреда: по идущей цели удар в конечность мажет, о броню игла
 * ломается. TRUE — удар сорван. Зовётся из кор `syringestab()` вместо броска Bay.
 */
/obj/item/reagent_containers/syringe/proc/ce_fail_stab(mob/living/carbon/human/target, mob/living/user, target_zone)
	var/obj/item/organ/external/organ = target.get_organ(target_zone)
	if(target.ce_dodges_injection(user, target_zone))
		user.visible_message(SPAN_DANGER("\The [user] tries to stab \the [target] in the [organ.name] with \the [src], but misses!"))
	else if(target.ce_get_injection_blocker(target_zone, src))
		user.visible_message(SPAN_DANGER("\The [user] tries to stab \the [target] in the [organ.name] with \the [src], but the needle snaps on armor!"))
		break_syringe(null, user)
	else
		return FALSE
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(target)
	admin_attack_log(user, target, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")
	return TRUE
