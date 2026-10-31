/*
	UTILITY_ITEMS — юнит-тесты.

	Имплант адреналина: кнопка выдаётся и жмётся без сознания, рывок приводит в себя, держит
	стан, отключку и сбивание с ног, гасит замешательство, шагает так, будто тело цело, и вдвое
	быстрее, не валит на сломанных ногах, доливает опиаты до 30 в начале и в конце и возвращает
	только те флаги, что снял. Тест синхронный: Life не идёт, нужные его части
	(`handle_actions()`, `handle_regular_status_updates()`, `handle_stance()`) зовутся руками, а
	конец рывка — `end_adrenalin_burst()` напрямую, без ожидания таймера.

	Звук падения из кор `human/Weaken()` тест не видит: `playsound()` слышат только мобы с
	клиентом. Что `Weaken()` в рывке до него не доходит, держит только чтение кода.
*/

#ifdef UNIT_TEST

// Тестовый человек не засыпает как SSD: без клиента `handle_regular_status_updates()` иначе
// кладёт его спать, и он остаётся без сознания при любом рывке.
/mob/living/carbon/human/adrenalin_test_dummy
	/// Эмоции, которые моб пытался сделать: `act` у `emote()` и текст у `custom_emote()`.
	var/list/emotes_seen = list()

/mob/living/carbon/human/adrenalin_test_dummy/ssd_check()
	return FALSE

/mob/living/carbon/human/adrenalin_test_dummy/emote(act, m_type, message)
	emotes_seen += act
	return ..()

/mob/living/carbon/human/adrenalin_test_dummy/custom_emote(m_type = VISIBLE_MESSAGE, message = null)
	emotes_seen += message
	return ..()

/datum/unit_test/adrenalin_implant
	name = "UTILITY: Adrenaline implant wakes, holds up, speeds up and leaves opiates"
	var/list/failures = list()

/datum/unit_test/adrenalin_implant/proc/check(condition, message)
	if(!condition)
		failures += message

/datum/unit_test/adrenalin_implant/proc/implant_into(mob/living/carbon/human/host, uses)
	RETURN_TYPE(/obj/item/implant/adrenalin)
	var/obj/item/implant/adrenalin/implant = new(host)
	implant.uses = uses
	implant.imp_in = host
	implant.implanted = TRUE
	var/obj/item/organ/external/chest = host.get_organ(BP_CHEST)
	implant.part = chest
	chest.implants += implant
	return implant

/datum/unit_test/adrenalin_implant/proc/opiates(mob/living/carbon/human/host)
	return host.metabolized.get_reagent_amount(/datum/reagent/opiate)

/datum/unit_test/adrenalin_implant/start_test()
	var/list/made = create_test_mob_with_mind(null, /mob/living/carbon/human/adrenalin_test_dummy)
	var/mob/living/carbon/human/host = locate(made["mobref"])
	if(!istype(host))
		fail("Test human was not created: [made["msg"]]")
		return 1
	var/obj/item/implant/adrenalin/implant = implant_into(host, 2)

	check_button(host, implant)
	check_burst(host, implant)
	check_repeat_and_kept_flags(host, implant)
	check_removal(host, implant)
	check_ignored_body_state()
	check_broken_legs_hold()

	qdel(implant)
	qdel(host)
	if(length(failures))
		fail(jointext(failures, "\n"))
	else
		pass("The implant fires while unconscious, holds the host up for the burst and gives back what it took.")
	return 1

/datum/unit_test/adrenalin_implant/proc/check_button(mob/living/carbon/human/host, obj/item/implant/adrenalin/implant)
	host.handle_actions()
	var/datum/action/item_action/adrenalin_implant/action = implant.action
	check(istype(action) && (action in host.actions), "Button: handle_actions() did not give the host the implant's action ([implant.action?.type]).")
	if(!istype(action))
		return
	check(action.check_flags == 0, "Button: check_flags is [action.check_flags], not 0, so it may refuse an unconscious host.")

	var/obj/screen/movable/action_button/button = new(null, action)
	action.button = button
	action.UpdateName()
	check(findtext(button.maptext, ">[implant.uses]<"), "Button: maptext '[button.maptext]' does not show [implant.uses] charges.")
	action.button = null
	qdel(button)

/datum/unit_test/adrenalin_implant/proc/check_burst(mob/living/carbon/human/host, obj/item/implant/adrenalin/implant)
	var/datum/action/item_action/adrenalin_implant/action = implant.action
	if(!istype(action))
		return
	host.Paralyse(10)
	host.shock_stage = 130
	host.handle_regular_status_updates()
	check(host.stat == UNCONSCIOUS, "Knockout: Paralyse(10) left the host at stat [host.stat], test setup broken.")

	action.Trigger()
	check(implant.uses == 1, "Trigger: an unconscious host's button left [implant.uses] charges, expected 1.")
	check(host.stat == CONSCIOUS, "Trigger: host is at stat [host.stat] right after the burst, expected conscious.")
	check(!host.paralysis && !host.shock_stage, "Trigger: paralysis [host.paralysis] and shock_stage [host.shock_stage] not cleared.")
	check(opiates(host) == 30, "Trigger: [opiates(host)] metabolized opiates at the start, expected 30.")

	host.Paralyse(10)
	host.Weaken(10)
	host.Stun(10)
	check(!host.paralysis && !host.weakened && !host.stunned, "Burst: Paralyse/Weaken/Stun went through ([host.paralysis]/[host.weakened]/[host.stunned]).")
	host.handle_regular_status_updates()
	check(host.stat == CONSCIOUS, "Burst: a Life status update put the host at stat [host.stat].")

	var/burst_delay = host.movement_delay()
	var/burst_until = host.adrenalin_burst_until
	host.adrenalin_burst_until = 0
	var/normal_delay = host.movement_delay()
	host.adrenalin_burst_until = burst_until
	check(burst_delay == normal_delay * 0.5, "Burst: movement delay [burst_delay], expected half of [normal_delay].")

	host.metabolized.remove_reagent(/datum/reagent/opiate, 12)
	host.end_adrenalin_burst()
	check(opiates(host) == 30, "End: [opiates(host)] metabolized opiates after the burst, expected 30.")
	var/stun_flags = CANSTUN | CANWEAKEN | CANPARALYSE
	check((host.status_flags & stun_flags) == stun_flags, "End: status_flags [host.status_flags] lack stun flags after the burst.")
	host.Paralyse(10)
	check(host.paralysis, "End: Paralyse(10) does nothing after the burst.")
	host.SetParalysis(0)
	host.handle_regular_status_updates()

/datum/unit_test/adrenalin_implant/proc/check_repeat_and_kept_flags(mob/living/carbon/human/host, obj/item/implant/adrenalin/implant)
	var/datum/action/item_action/adrenalin_implant/action = implant.action
	if(!istype(action))
		return
	implant.uses = 2
	host.status_flags &= ~CANSTUN
	host.metabolized.add_reagent(/datum/reagent/opiate, 50 - opiates(host))
	action.Trigger()
	action.Trigger()
	check(opiates(host) == 50, "Repeat: [opiates(host)] metabolized opiates, a top-up must not lower 50 or stack past it.")
	check(!implant.uses && !action.IsAvailable(), "Repeat: [implant.uses] charges left and button available [action.IsAvailable()] after spending both.")
	action.Trigger()
	check(!implant.uses, "Repeat: an empty implant fired.")

	host.end_adrenalin_burst()
	check((host.status_flags & (CANWEAKEN | CANPARALYSE)) == (CANWEAKEN | CANPARALYSE), "Repeat: two bursts in a row lost flags [host.status_flags] at the end.")
	check(!(host.status_flags & CANSTUN), "Repeat: the burst gave back CANSTUN, which the host did not have.")
	host.status_flags |= CANSTUN

// Свой носитель: раны и химия ниже испортили бы остальные проверки.
/datum/unit_test/adrenalin_implant/proc/check_ignored_body_state()
	var/list/made = create_test_mob_with_mind(null, /mob/living/carbon/human/adrenalin_test_dummy)
	var/mob/living/carbon/human/host = locate(made["mobref"])
	if(!istype(host))
		failures += "Body state: second test human was not created: [made["msg"]]"
		return
	var/obj/item/implant/adrenalin/implant = implant_into(host, 1)
	host.handle_actions()
	// Свежий человек держит `health` с создания, пока его не пересчитают: без этого «здоровая»
	// задержка уже несёт слагаемое нехватки здоровья.
	host.updatehealth()
	var/healthy_delay = host.movement_delay()

	// Брут даёт боль; нехватку здоровья даёт только мозг: `health = maxHealth - getBrainLoss()`.
	host.apply_damage(70, DAMAGE_BRUTE, BP_CHEST)
	host.adjustBrainLoss(60)
	host.updatehealth()
	check(host.maxHealth - host.health >= 40, "Body state: health deficiency [host.maxHealth - host.health] is below the slowdown threshold, test setup broken.")
	var/obj/item/organ/external/leg = host.get_organ(BP_L_LEG)
	leg.fracture()
	host.drowsyness = 5
	host.add_chemical_effect(CE_SLOWDOWN, 2)
	host.mod_confused(10)
	var/injured_delay = host.movement_delay()
	check(injured_delay > healthy_delay + 5, "Body state: wounds, brain damage, a broken leg, drowsiness and CE_SLOWDOWN only took the delay from [healthy_delay] to [injured_delay], test setup broken.")

	implant.action?.Trigger()
	check(host.is_in_adrenalin_burst(), "Body state: the burst did not start.")
	// Trigger() снимает сонливость не сам: её слагаемое должно вычесться.
	host.drowsyness = 5
	var/burst_delay = host.movement_delay()
	check(abs(burst_delay - healthy_delay * 0.5) < 0.01, "Body state: burst delay [burst_delay] with wounds, expected half the healthy [healthy_delay].")
	check(!host.is_confused(), "Body state: confused [host.confused] still counts during the burst.")

	host.end_adrenalin_burst()
	check(host.is_confused(), "Body state: confusion [host.confused] does not come back after the burst.")
	check(host.movement_delay() > healthy_delay + 5, "Body state: wound slowdown [host.movement_delay()] does not come back after the burst.")
	qdel(implant)
	qdel(host)

// Сломанные ноги и стопы дают `stance_damage` 4: стоящий падает каждый тик. В рывке — ни крика,
// ни «collapses!», ни падения; после рывка — падает, как раньше. Бег: шагом стойка на 1 меньше.
/datum/unit_test/adrenalin_implant/proc/check_broken_legs_hold()
	var/list/made = create_test_mob_with_mind(null, /mob/living/carbon/human/adrenalin_test_dummy)
	var/mob/living/carbon/human/adrenalin_test_dummy/host = locate(made["mobref"])
	if(!istype(host))
		failures += "Stance: third test human was not created: [made["msg"]]"
		return
	var/obj/item/implant/adrenalin/implant = implant_into(host, 1)
	host.handle_actions()
	host.set_moving_quickly()
	for(var/organ_name in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
		var/obj/item/organ/external/leg = host.get_organ(organ_name)
		leg.fracture()

	implant.action?.Trigger()
	host.emotes_seen.Cut()
	for(var/i = 1 to 3)
		host.handle_stance()
	check(!length(host.emotes_seen), "Stance: broken legs made the host emote [english_list(host.emotes_seen)] during the burst.")
	check(!host.lying && !host.weakened, "Stance: broken legs put the host down during the burst (lying [host.lying], weakened [host.weakened]).")

	host.end_adrenalin_burst()
	host.handle_stance()
	check(host.weakened && ("collapses!" in host.emotes_seen), "Stance: after the burst broken legs do not collapse the host (weakened [host.weakened], emotes [english_list(host.emotes_seen)]), test setup broken.")
	qdel(implant)
	qdel(host)

/datum/unit_test/adrenalin_implant/proc/check_removal(mob/living/carbon/human/host, obj/item/implant/adrenalin/implant)
	var/datum/action/action = implant.action
	if(!action)
		return
	implant.removed()
	implant.forceMove(host.loc)
	host.handle_actions()
	check(!(action in host.actions), "Removal: the host kept the button of a removed implant.")

#endif
