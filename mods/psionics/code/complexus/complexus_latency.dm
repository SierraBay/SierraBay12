/datum/psi_complexus/proc/check_latency_trigger(trigger_strength = 0, source, redactive = FALSE)

	if(!LAZYLEN(latencies) || world.time < next_latency_trigger || pending_awakening)
		return FALSE

	if(!prob(trigger_strength))
		next_latency_trigger = world.time + rand(100, 300)
		return FALSE

	var/faculty = pick(latencies)
	var/singleton/psionic_faculty/faculty_singleton = SSpsi.get_faculty(faculty)

	next_latency_trigger = world.time + 10 MINUTES
	var/datum/psi_awakening/awakening = new /datum/psi_awakening(src, faculty, source, redactive)

	to_chat(owner, SPAN_DANGER("Ты кричишь, не издав ни звука, во время того как дисциплина [faculty_singleton.name] пробуждается в тебе из-за [source]!"))
	if(!redactive)
		owner.adjustBrainLoss(rand(trigger_strength * 2, trigger_strength * 4))
	log_and_message_admins("начал пробуждение псионики [faculty_singleton.name] с помощью: [source].", owner)
	awakening.begin()
	return TRUE
