/proc/character_persist_apply_pay(mob/living/carbon/human/H)
	if (!istype(H) || H.character_persist_bonus_money <= 0)
		return
	if (!H.mind?.initial_account)
		return
	var/amount = H.character_persist_bonus_money
	if (!H.mind.initial_account.deposit(amount, "Выплата за пережитые смены", "Sierra payroll"))
		return
	H.character_persist_bonus_money = 0
	to_chat(H, SPAN_NOTICE("На счёт зачислено [amount] таллеров за пережитые смены."))


/datum/job/setup_account(mob/living/carbon/human/H)
	. = ..()
	character_persist_apply_pay(H)
