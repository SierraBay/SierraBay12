/**
 * psi_fatigue.dm
 *
 * Механика пси-усталости.
 *
 * Псионик нагеняет усталость:
 *   - при использовании способностей (пропорционально стоимости)
 *   - при получении урона
 *
 * При значении = 0 псионик больше не может подавлять силы:
 * он виден на пси-плане, и пси-план виден ему.
 *
 * Восстанавливается через:
 *   - сон (быстро)
 *   - хорошее питание (скромный бонус сверх)
 *
 * Повторное подавление доступно, когда усталость поднимается
 * выше PSI_EXHAUSTION_RECOVER_THRESHOLD.
 */

#define PSI_EXHAUSTION_MAX              100
#define PSI_EXHAUSTION_RECOVER_THRESHOLD 25

// ── Переменные ────────────────────────────────────────────────
/datum/psi_complexus
	var/psi_exhaustion  = PSI_EXHAUSTION_MAX  // Текущий уровень (0..100), скрыт от игрока
	var/psi_exhausted   = FALSE               // Флаг: псионик истощён и не может подавить силы
	var/last_owner_hp   = -1                  // Суммарный урон прошлого тика (для дельты)

// ── Process override ──────────────────────────────────────────
/datum/psi_complexus/Process()
	. = ..()
	if(!owner) return

	// --- Дельта урона (брут + огонь + яд + кислород) ---
	var/cur_hp = owner.getBruteLoss() + owner.getFireLoss() + owner.getToxLoss() + owner.getOxyLoss()
	if(last_owner_hp < 0)
		last_owner_hp = cur_hp  // Инициализация в первом тике, без штрафа
	else
		var/dmg_delta = max(0, cur_hp - last_owner_hp)
		if(dmg_delta > 0)
			// 1 единица усталости за каждые 4 единицы полученного урона
			adjust_psi_exhaustion(-(dmg_delta * 0.25))
	last_owner_hp = cur_hp

	// --- Восстановление усталости ---
	var/regen = 0

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.sleeping > 0)
			// Глубокий сон — лучшее восстановление
			regen += 1.5
		else if(owner.stat == UNCONSCIOUS)
			// Без сознания, но не по своей воле — умеренно
			regen += 0.5

		// Бонус сытости
		if(H.nutrition > 300)
			regen += 1.0
		else if(H.nutrition < 100)
			regen -= 0.5
		if(H.hydration < 50)
			regen -= 0.5
	if(regen > 0)
		adjust_psi_exhaustion(regen)

// ── spend_power override ──────────────────────────────────────
/datum/psi_complexus/spend_power(value = 0, check_incapacitated)
	. = ..()
	if(.)
		// Трата пси-очков → расходуем усталость
		// 1 усталость за каждые 5 очков силы (минимум 1)
		adjust_psi_exhaustion(-max(1, round(value * 0.20)))

// ── Основная логика усталости ─────────────────────────────────
/datum/psi_complexus/proc/adjust_psi_exhaustion(delta)
	psi_exhaustion = clamp(psi_exhaustion + delta, 0, PSI_EXHAUSTION_MAX)

	// Только что истощились
	if(!psi_exhausted && psi_exhaustion <= 0)
		psi_exhausted = TRUE
		if(suppressed)
			suppressed = FALSE
			ui?.update_icon()
			// Обновляем видимость пси-плана
			owner?.update_sight()
			if(owner?.client)
				for(var/image/I in SSpsi.all_aura_images)
					owner.client.images |= I
			start_aura_pulse()
		if(owner)
			to_chat(owner, "<hr>")
			to_chat(owner, SPAN_DANGER(FONT_LARGE("Твой разум истощён — ты больше не можешь скрывать свои пси-силы!")))
			to_chat(owner, SPAN_DANGER("Чтобы восстановиться: <b>поспи, отдохни или хорошо поешь</b>."))
			to_chat(owner, "<hr>")
		return

	// Только что восстановились выше порога — снимаем блок
	if(psi_exhausted && psi_exhaustion >= PSI_EXHAUSTION_RECOVER_THRESHOLD)
		psi_exhausted = FALSE
		if(owner)
			to_chat(owner, SPAN_NOTICE("Твоя пси-усталость прошла — ты снова контролируешь свои способности."))

// ── Блок UI-переключения подавления ──────────────────────────
/obj/screen/psi/hub/Click(location, control, click_params)
	if(owner?.psi?.psi_exhausted)
		to_chat(owner, SPAN_WARNING("Твой разум слишком истощён, чтобы подавлять пси-силы! Отдохни или поешь."))
		return
	. = ..()
