/datum/event/minispasm
	var/alarm_sound = 'packs/infinity/sound/misc/foundation_alarm.ogg'

/datum/event/minispasm/announce()
	priority_announcement.Announce( \
		"PRIORITY ALERT: SIGMA-[rand(50,80)] PSIONIC SIGNAL LOCAL TRAMISSION DETECTED (97% MATCH, NONVARIANT) \
		(SIGNAL SOURCE TRIANGULATED ADJACENT LOCAL SITE): All personnel are advised to avoid \
		exposure to active audio transmission equipment including radio headsets and intercoms \
		for the duration of the signal broadcast.", \
		"Cuchulain Sensor Array Automated Message" \
	)
	sound_to(world, sound(alarm_sound))

/datum/event/minispasm/end()
	priority_announcement.Announce( \
		"PRIORITY ALERT: SIGNAL BROADCAST HAS CEASED. Personnel are cleared to resume use of non-hardened radio transmission equipment. Have a nice day.", \
		"Cuchulain Sensor Array Automated Message", \
		new_sound = 'packs/infinity/sound/misc/foundation_restore.ogg' )

/datum/event/minispasm/do_spasm(mob/living/victim, obj/item/device/radio/source)
	set waitfor = 0

	if(iscarbon(victim) && !victim.isSynthetic())
		var/list/disabilities = list(NEARSIGHTED, EPILEPSY, NERVOUS)
		for(var/disability in disabilities)
			if(victim.disabilities & disability)
				disabilities -= disability
		if(length(disabilities))
			victim.disabilities |= pick(disabilities)

	if(victim.psi)
		to_chat(victim, SPAN_DANGER("A hauntingly familiar sound hisses from [icon2html(source, victim)] \the [source], and your vision flickers!"))
		victim.psi.backblast(rand(5,15))
		victim.Paralyse(5)
		victim.make_jittery(100)
	else
		to_chat(victim, SPAN_DANGER("An indescribable, brain-tearing sound hisses from [icon2html(source, victim)] \the [source], and you collapse in a seizure!"))
		victim.seizure()
		victim.adjustBrainLoss(rand(5,15))
	sleep(45)

	if(victim.psi)
		victim.psi.check_latency_trigger(100, "a psionic scream", redactive = TRUE)

	if(!victim.psi && prob(5))
		var/new_latencies = rand(1,4)
		var/list/faculties = list(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS)
		for(var/i = 1 to new_latencies)
			to_chat(victim, SPAN_DANGER(FONT_LARGE(pick(psi_operancy_messages))))
			victim.adjustBrainLoss(rand(5,10))
			victim.set_psi_rank(pick_n_take(faculties), 1)
			sleep(30)
		if(victim.psi)
			victim.psi.update()