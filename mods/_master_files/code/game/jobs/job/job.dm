/datum/job
	/// Optional fixed salary override; null uses the payroll configuration. Never a wealth modifier.
	var/payroll_rate

/datum/job/setup_account(mob/living/carbon/human/H)
	. = ..()
	if(!H?.mind || H.mind.initial_account || !H.client || !SSpayroll.ledger.settings.rate_for(src))
		return
	H.mind.initial_account = create_account("[H.real_name]'s account", H.real_name, 0)
	H.StoreMemory("Payroll account: #[H.mind.initial_account.account_number], PIN: [H.mind.initial_account.remote_access_pin].", /singleton/memory_options/system)
