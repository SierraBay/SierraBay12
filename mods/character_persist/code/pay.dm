/proc/character_persist_apply_pay(mob/living/carbon/human/H)
	if (!istype(H) || !H.mind?.initial_account)
		return
	if (!isnull(H.odyssey_account_money))
		var/amount = max(0, H.odyssey_account_money)
		H.mind.initial_account.money = amount
		H.odyssey_account_money = null
		to_chat(H, SPAN_NOTICE("Баланс счёта восстановлен: [amount] таллеров."))
	if (H.character_persist_bonus_money <= 0)
		return
	var/bonus_amount = H.character_persist_bonus_money
	if (!H.mind.initial_account.deposit(bonus_amount, "Выплата за пережитые смены", "Sierra payroll"))
		return
	H.character_persist_bonus_money = 0
	to_chat(H, SPAN_NOTICE("На счёт зачислено [bonus_amount] таллеров за пережитые смены."))


/datum/job/setup_account(mob/living/carbon/human/H)
	. = ..()
	character_persist_apply_pay(H)
