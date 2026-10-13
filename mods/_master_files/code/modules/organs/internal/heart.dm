/obj/item/organ/internal/heart
	// --- Cardiac Rhythm System ---
	/// The current electrical rhythm state of the heart.
	var/cardiac_rhythm = RHYTHM_NSR
	/// Beats per minute — calculated from rhythm + modifiers each tick.
	var/bpm = 75
	/// Progress of Myocardial Infarction (heart attack).
	var/infarct_progress = 0

/obj/item/organ/internal/heart/Process()
	..()
	handle_infarct()

/obj/item/organ/internal/heart/proc/handle_infarct()
	if(!infarct_progress)
		return

	if(!owner || owner.stat == DEAD || owner.InStasis())
		return

	if(owner.chem_effects[CE_STABLE])
		infarct_progress = max(0, infarct_progress - 2)
		if(prob(5))
			to_chat(owner, SPAN_NOTICE("Вы чувствуете, что вам становится немного легче."))
		return

	infarct_progress++

	if(infarct_progress in 1 to 60)
		if(prob(6))
			if(owner.can_feel_pain())
				owner.custom_pain("Вам кажется, что дышать стало немного тяжелее, а в теле появился странный дискомфорт.", 30, affecting = owner.get_organ(BP_CHEST))
	else if(infarct_progress in 61 to 150)
		owner.add_chemical_effect(CE_BREATHLOSS, 0.4)
		if(prob(10))
			if(owner.can_feel_pain())
				owner.custom_pain("Вам становится нехорошо, какая-то тяжесть давит сверху, мешая вздохнуть полной грудью.", 60, affecting = owner.get_organ(BP_CHEST))
				owner.Weaken(2)
		if(prob(15))
			take_internal_damage(0.5)
	else if(infarct_progress > 150)
		if(pulse != PULSE_NONE)
			to_chat(owner, SPAN_DANGER("Дыхание спирает, перед глазами всё плывет и вы теряете контроль над телом..."))
			stop()
			owner.Weaken(10)

/obj/item/organ/internal/heart/handle_pulse()
	..()
	if(BP_IS_ROBOTIC(src) || (owner && (owner.status_flags & FAKEDEATH || owner.chem_effects[CE_NOPULSE])))
		cardiac_rhythm = RHYTHM_ASYSTOLE
		bpm = 0
		return
	update_rhythm()

/obj/item/organ/internal/heart/proc/update_rhythm()
	if(!owner)
		cardiac_rhythm = RHYTHM_ASYSTOLE
		bpm = 0
		return

	// Check for Pulseless Electrical Activity (PEA):
	// Blood volume critically low — the heart still fires electrically, but cannot pump anything.
	var/blood_circ = owner.get_blood_circulation()
	if(pulse && pulse != PULSE_NONE && blood_circ < BLOOD_VOLUME_SURVIVE)
		cardiac_rhythm = RHYTHM_PEA
		// PEA shows a normal-looking rhythm on ECG but no mechanical pulse
		bpm = rand(40, 80) // electrical rate looks normal-ish
		return

	// Check for Ventricular Fibrillation (V-Fib):
	// Triggered when the heart is severely damaged and beating erratically, or extreme shock.
	if(pulse == PULSE_THREADY && damage > (max_damage * 0.5))
		cardiac_rhythm = RHYTHM_VFIB
		bpm = 0 // no effective pumping in v-fib
		return

	switch(pulse)
		if(PULSE_NONE)
			cardiac_rhythm = RHYTHM_ASYSTOLE
			bpm = 0
		if(PULSE_SLOW)
			cardiac_rhythm = RHYTHM_BRADY
			bpm = rand(35, 55)
		if(PULSE_NORM)
			cardiac_rhythm = RHYTHM_NSR
			bpm = rand(60, 90)
		if(PULSE_FAST)
			cardiac_rhythm = RHYTHM_TACHY
			bpm = rand(95, 120)
		if(PULSE_2FAST)
			cardiac_rhythm = RHYTHM_TACHY
			bpm = rand(125, 160)
		if(PULSE_THREADY)
			// Thready pulse with moderate damage -> heart block
			if(damage > (max_damage * 0.3))
				cardiac_rhythm = RHYTHM_BLOCK
				bpm = rand(25, 45)
			else
				cardiac_rhythm = RHYTHM_TACHY
				bpm = min(rand(170, 220), PULSE_MAX_BPM)

	if(infarct_progress >= 60 && RHYTHM_HAS_PULSE(cardiac_rhythm))
		cardiac_rhythm = RHYTHM_STEMI

/obj/item/organ/internal/heart/stop()
	..()
	cardiac_rhythm = RHYTHM_ASYSTOLE
	bpm = 0

/obj/item/organ/internal/heart/is_working()
	if(!is_usable())
		return FALSE

	// Robotic hearts and fakedeath bypass rhythm checks
	if(BP_IS_ROBOTIC(src) || (owner && (owner.status_flags & FAKEDEATH)))
		return TRUE

	// Only rhythms that actually pump blood count as "working"
	return RHYTHM_HAS_PULSE(cardiac_rhythm)

/obj/item/organ/internal/heart/listen()
	if(owner && (owner.status_flags & FAKEDEATH))
		return "no pulse"

	switch(cardiac_rhythm)
		if(RHYTHM_VFIB)
			return "rapid, chaotic quivering — no discernible beat"
		if(RHYTHM_PEA)
			return "faint electrical impulses, but no mechanical beat"
		if(RHYTHM_BLOCK)
			return "slow, irregular pulse with long pauses"
		if(RHYTHM_ASYSTOLE)
			return "no pulse"

	return ..()
