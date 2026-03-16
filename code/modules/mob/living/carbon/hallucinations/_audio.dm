// Playing a random sound
/datum/hallucination/sound
	category = "ambient"
	base_weight = 10
	category_cooldown = 8 SECONDS
	var/list/sounds = list('sound/machines/airlock.ogg', 'sound/effects/explosionfar.ogg', 'sound/machines/windowdoor.ogg', 'sound/machines/twobeep.ogg')

/datum/hallucination/sound/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	return null

/datum/hallucination/sound/start()
	var/turf/T = locate(holder.x + rand(6, 11), holder.y + rand(6, 11), holder.z)
	var/sound_to_play = pick(sounds)
	feedback_details = " Sound: [sound_to_play]"
	holder.playsound_local(T, sound_to_play, 70)

/datum/hallucination/sound/tools
	sounds = list('sound/items/Ratchet.ogg', 'sound/items/Welder.ogg', 'sound/items/Crowbar.ogg', 'sound/items/Screwdriver.ogg')

/datum/hallucination/sound/danger
	min_power = 30
	sounds = list('sound/effects/Explosion1.ogg', 'sound/effects/Explosion2.ogg', 'sound/effects/Glassbr1.ogg', 'sound/effects/Glassbr2.ogg', 'sound/effects/Glassbr3.ogg', 'sound/weapons/smash.ogg')

/datum/hallucination/sound/spooky
	min_power = 50
	sounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
		'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
		'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
		'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
		'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')

// Hearing someone being shot twice
/datum/hallucination/gunfire
	category = "threat"
	base_weight = 5
	category_cooldown = 18 SECONDS
	theme_tags = list("aftermath", "emergency")
	var/gunshot
	var/turf/origin
	duration = 15
	min_power = 30

/datum/hallucination/gunfire/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	return null

/datum/hallucination/gunfire/start()
	gunshot = pick('sound/weapons/gunshot/gunshot_strong.ogg', 'sound/weapons/gunshot/gunshot2.ogg', 'sound/weapons/gunshot/shotgun.ogg', 'sound/weapons/gunshot/gunshot.ogg', 'sound/weapons/Taser.ogg')
	origin = locate(holder.x + rand(4, 8), holder.y + rand(4, 8), holder.z)
	feedback_details = " Gunshot: [gunshot]"
	holder.playsound_local(origin, gunshot, 50)

/datum/hallucination/gunfire/end()
	if(!holder?.can_hear())
		return
	holder.playsound_local(origin, gunshot, 50)

// Hearing someone talking to/about you.
/datum/hallucination/talking
	category = "social"
	base_weight = 8
	category_cooldown = 12 SECONDS
	theme_tags = list("social")

/datum/hallucination/talking/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	for(var/mob/living/M in oview(C))
		if(!M.stat)
			return null
	return "no speakers nearby"

/datum/hallucination/talking/start()
	var/sanity = 5
	for(var/mob/living/talker in oview(holder))
		if(talker.stat)
			continue
		var/message
		var/display_name = talker.fake_name ? talker.fake_name : talker.real_name
		if(!display_name)
			continue
		feedback_details = " Speaker: [display_name]"
		if(prob(80))
			var/list/names = list()
			var/lastname = copytext(holder.real_name, findtext(holder.real_name, " ") + 1)
			var/firstname = copytext(holder.real_name, 1, findtext(holder.real_name, " "))
			if(lastname)
				names += lastname
			if(firstname)
				names += firstname
			if(!length(names))
				names += holder.real_name
			var/add = prob(20) ? ", [pick(names)]" : ""
			var/list/phrases = list(
				"[prob(50) ? "Hey, " : ""][pick(names)]!",
				"[prob(50) ? "Hey, " : ""][pick(names)]?",
				"Get out[add]!",
				"Go away[add].",
				"What are you doing[add]?",
				"Where is your ID[add]?",
				holder.random_hallucinated_phrase()
			)
			if(holder.hallucination_power > 50)
				phrases += list(
					"What did you come here for[add]?",
					"Do not touch me[add].",
					"You are not getting out of here[add].",
					"You are a failure, [pick(names)].",
					"Just leave already, [pick(names)].",
					"[pick(names)], [holder.random_hallucinated_phrase()]"
				)
			message = pick(phrases)
			to_chat(holder, "[SPAN_CLASS("game say", "[SPAN_CLASS("name", display_name)] [holder.say_quote(message)], [SPAN_CLASS("message", "[SPAN_CLASS("body", "\"[message]\"")]")]")]")
		else
			message = "..."
			to_chat(holder, "<B>[display_name]</B> [holder.random_hallucinated_action()]")
			to_chat(holder, "[SPAN_CLASS("game say", "[SPAN_CLASS("name", display_name)] says something softly.")]")
		var/image/speech_bubble = image('icons/mob/talk.dmi', talker, "h[holder.say_test(message)]")
		spawn(30)
			qdel(speech_bubble)
		image_to(holder, speech_bubble)
		sanity--
		if(!sanity)
			return

// Spiderling skitters
/datum/hallucination/skitter
	category = "ambient"
	base_weight = 10
	category_cooldown = 8 SECONDS
	theme_tags = list("predator")

/datum/hallucination/skitter/start()
	to_chat(holder, SPAN_NOTICE("The spiderling skitters[pick(" away", " around", "")]."))

// Fake local alarms and station faults
/datum/hallucination/facility_warning
	abstract_hallucination = TRUE
	category = "machinery"
	base_weight = 9
	category_cooldown = 12 SECONDS
	theme_tags = list("machinery")
	min_power = 30
	allow_duplicates = FALSE

/datum/hallucination/facility_warning/air_alarm/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	if(context?.alarm_count)
		return null
	for(var/obj/machinery/alarm/alarm in view(C))
		return null
	return "no air alarm nearby"

/datum/hallucination/facility_warning/air_alarm/get_context_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	. = ..()
	if(context.alarm_count)
		. *= 2
		debug_factors += "air alarm nearby x2"

/datum/hallucination/facility_warning/air_alarm/start()
	var/obj/machinery/alarm/alarm = locate(/obj/machinery/alarm) in view(holder)
	if(!alarm)
		return FALSE
	feedback_details = " Facility warning: Air alarm at [get_area(alarm)]"
	holder.playsound_local(get_turf(alarm), 'sound/machines/twobeep.ogg', 50)
	to_chat(holder, SPAN_WARNING("The air alarm by [get_area(alarm)] flashes and chirps, \"Hazardous atmospheric conditions detected.\""))
	return TRUE

/datum/hallucination/facility_warning/fire_alarm/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	if(context?.firealarm_count)
		return null
	for(var/obj/machinery/firealarm/alarm in view(C))
		return null
	return "no fire alarm nearby"

/datum/hallucination/facility_warning/fire_alarm/get_context_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	. = ..()
	if(context.firealarm_count)
		. *= 2
		debug_factors += "fire alarm nearby x2"

/datum/hallucination/facility_warning/fire_alarm/start()
	var/obj/machinery/firealarm/alarm = locate(/obj/machinery/firealarm) in view(holder)
	if(!alarm)
		return FALSE
	feedback_details = " Facility warning: Fire alarm at [get_area(alarm)]"
	holder.playsound_local(get_turf(alarm), 'sound/obj/machinery/rotating_alarm/alert_red.ogg', 40)
	to_chat(holder, SPAN_CLASS("alert", "The fire alarm starts pulsing red. You smell smoke for a moment."))
	return TRUE

/datum/hallucination/facility_warning/decompression
	min_power = 40
	theme_tags = list("machinery", "emergency")

/datum/hallucination/facility_warning/decompression/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	return null

/datum/hallucination/facility_warning/decompression/start()
	var/turf/T = holder.random_hallucination_turf(2, 6)
	feedback_details = " Facility warning: False decompression"
	holder.playsound_local(T, 'sound/effects/explosionfar.ogg', 35)
	to_chat(holder, SPAN_WARNING("A rush of wind tears through the corridor. Your ears pop as if the room just depressurized."))
	return TRUE

/datum/hallucination/facility_warning/lights
	min_power = 35
	base_weight = 10

/datum/hallucination/facility_warning/lights/get_context_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	. = ..()
	if(context.apc_count)
		. *= 2
		debug_factors += "APC nearby x2"

/datum/hallucination/facility_warning/lights/start()
	var/obj/machinery/power/apc/apc = locate(/obj/machinery/power/apc) in view(holder)
	if(apc)
		feedback_details = " Facility warning: Power fluctuation near [get_area(apc)]"
	else
		feedback_details = " Facility warning: Power fluctuation"
	to_chat(holder, SPAN_WARNING("The lights flicker and brown out for a split second."))
	if(holder.can_hear())
		holder.playsound_local(get_turf(holder), 'sound/machines/apc_nopower.ogg', 40)
	return TRUE

// Fake radio chatter
/datum/hallucination/radio
	category = "social"
	base_weight = 8
	category_cooldown = 12 SECONDS
	theme_tags = list("social")
	min_power = 35

/datum/hallucination/radio/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	return null

/datum/hallucination/radio/start()
	var/display_name = holder.random_crewmember_name(10)
	if(!display_name)
		display_name = pick("Unknown", "Static", "CentCom", "Bridge")
	var/channel_name = holder.random_radio_channel()
	var/frequency = radiochannels[channel_name]
	var/span_class = frequency_span_class(frequency)
	var/list/messages = list(
		"Anyone else hear that in maintenance?",
		"I just lost cameras for a second.",
		"Check the south corridor. Something moved.",
		"We have a possible hull issue.",
		"Why are the lights flickering over here?",
		"Medical, stand by. I think someone just got jumped.",
		"Do not go into maintenance alone.",
		"I swear that APC was emagged a second ago.",
		holder.random_hallucinated_phrase()
	)
	var/message = pick(messages)
	feedback_details = " Radio: [channel_name], Speaker: [display_name]"
	to_chat(holder, "[SPAN_CLASS(span_class, "[display_name] [channel_name] radio crackles, \"[message]\"")]")
	holder.playsound_local(get_turf(holder), 'sound/machines/twobeep.ogg', 25)
	return TRUE

// Fake maintenance noise
/datum/hallucination/maint_noise
	category = "ambient"
	base_weight = 11
	category_cooldown = 8 SECONDS
	theme_tags = list("machinery", "predator")
	min_power = 20

/datum/hallucination/maint_noise/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	return null

/datum/hallucination/maint_noise/start()
	var/turf/T = holder.random_hallucination_turf(2, 8)
	var/list/noises = list(
		'sound/items/Ratchet.ogg',
		'sound/items/Welder.ogg',
		'sound/items/Crowbar.ogg',
		'sound/machines/airlock.ogg',
		'sound/machines/windowdoor.ogg',
		'sound/weapons/smash.ogg'
	)
	var/list/descriptions = list(
		"You hear a tool clatter in maintenance.",
		"Something scrapes against metal just beyond the wall.",
		"You hear slow footsteps pacing in maintenance.",
		"An airlock clunks open somewhere nearby.",
		"Something bangs hard against a pipe."
	)
	var/sound_to_play = pick(noises)
	feedback_details = " Maintenance noise: [sound_to_play]"
	holder.playsound_local(T, sound_to_play, 45)
	to_chat(holder, SPAN_NOTICE("[pick(descriptions)]"))
	return TRUE

// Airlock-specific hallucinations
/datum/hallucination/airlock
	abstract_hallucination = TRUE
	category = "machinery"
	base_weight = 9
	category_cooldown = 12 SECONDS
	theme_tags = list("machinery")
	min_power = 30

/datum/hallucination/airlock/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	if(context?.airlock_count)
		return null
	for(var/obj/machinery/door/airlock/door in view(C))
		return null
	return "no airlock nearby"

/datum/hallucination/airlock/get_context_multiplier(mob/living/carbon/C, datum/hallucination_context/context, list/debug_factors = null)
	. = ..()
	if(context.airlock_count)
		. *= 2
		debug_factors += "airlock nearby x2"

/datum/hallucination/airlock/proc/pick_airlock()
	for(var/obj/machinery/door/airlock/door in shuffle(view(holder)))
		return door

/datum/hallucination/airlock/deny/start()
	var/obj/machinery/door/airlock/door = pick_airlock()
	if(!door)
		return FALSE
	holder.playsound_local(get_turf(door), 'sound/machines/door_locked.ogg', 45)
	to_chat(holder, SPAN_WARNING("\The [door] flashes red and denies access."))
	feedback_details = " Airlock deny: [door] in [get_area(door)]"
	return TRUE

/datum/hallucination/airlock/bolts/start()
	var/obj/machinery/door/airlock/door = pick_airlock()
	if(!door)
		return FALSE
	holder.playsound_local(get_turf(door), 'sound/machines/bolts_down.ogg', 45)
	to_chat(holder, SPAN_WARNING("You hear \the [door]'s bolts slam down."))
	feedback_details = " Airlock bolts: [door] in [get_area(door)]"
	return TRUE

/datum/hallucination/airlock/open/start()
	var/obj/machinery/door/airlock/door = pick_airlock()
	if(!door)
		return FALSE
	holder.playsound_local(get_turf(door), 'sound/obj/machinery/door/airlock/open.ogg', 45)
	to_chat(holder, SPAN_NOTICE("\The [door] hisses open."))
	feedback_details = " Airlock open: [door] in [get_area(door)]"
	return TRUE

// A nearby airlock briefly opens onto a corridor that does not belong there.
/datum/hallucination/airlock/impossible_corridor
	base_weight = 10
	min_power = 45
	max_power = 95
	duration = 5 SECONDS
	theme_tags = list("machinery", "predator")
	var/list/fake_images = list()

/datum/hallucination/airlock/impossible_corridor/proc/add_copied_image(atom/source, atom/location, layer_override = null)
	if(!holder?.client || !source || !location)
		return
	var/image/fake = image(source, location)
	if(!isnull(layer_override))
		fake.layer = layer_override
	fake_images += fake

/datum/hallucination/airlock/impossible_corridor/proc/find_source_corridor(direction, require_other_z = TRUE)
	var/list/candidates = list()
	for(var/turf/simulated/floor/F in world)
		if(require_other_z && F.z == holder.z)
			continue
		if(!require_other_z && F.z == holder.z && get_area(F) == get_area(holder))
			continue
		var/area/A = get_area(F)
		if(!A || istype(A, /area/space))
			continue
		var/turf/simulated/floor/next = get_step(F, direction)
		var/turf/simulated/floor/third = istype(next) ? get_step(next, direction) : null
		if(!istype(next) || !istype(third))
			continue
		candidates += list(list(F, next, third))
		if(length(candidates) >= 12 && prob(20))
			break
	if(!length(candidates) && require_other_z)
		return find_source_corridor(direction, FALSE)
	return length(candidates) ? pick(candidates) : null

/datum/hallucination/airlock/impossible_corridor/proc/copy_source_tile(turf/source, turf/target)
	if(!istype(source) || !istype(target))
		return
	add_copied_image(source, target, TURF_LAYER)
	for(var/obj/O in source)
		if(istype(O, /obj/effect))
			add_copied_image(O, target)
			continue
		if(istype(O, /obj/machinery) || istype(O, /obj/structure) || istype(O, /obj/item))
			add_copied_image(O, target)
			break

/datum/hallucination/airlock/impossible_corridor/start()
	if(!holder?.client)
		return FALSE
	var/obj/machinery/door/airlock/door = pick_airlock()
	if(!door)
		return FALSE

	var/turf/door_turf = get_turf(door)
	var/toward_dir = get_dir(holder, door)
	if(!(toward_dir in GLOB.cardinal))
		toward_dir = (door.dir in GLOB.cardinal) ? door.dir : NORTH

	var/turf/segment_one = get_step(door_turf, toward_dir)
	var/turf/segment_two = istype(segment_one) ? get_step(segment_one, toward_dir) : null
	var/turf/segment_three = istype(segment_two) ? get_step(segment_two, toward_dir) : null
	if(!istype(segment_one) || !istype(segment_two))
		return FALSE

	var/list/source_corridor = find_source_corridor(toward_dir)
	if(!islist(source_corridor) || length(source_corridor) < 2)
		return FALSE

	var/turf/source_one = source_corridor[1]
	var/turf/source_two = source_corridor[2]
	var/turf/source_three = length(source_corridor) >= 3 ? source_corridor[3] : null

	copy_source_tile(source_one, segment_one)
	copy_source_tile(source_two, segment_two)
	if(istype(source_three) && istype(segment_three))
		copy_source_tile(source_three, segment_three)

	var/turf/left_one = get_step(segment_one, turn(toward_dir, 90))
	var/turf/right_one = get_step(segment_one, turn(toward_dir, -90))
	var/turf/left_two = get_step(segment_two, turn(toward_dir, 90))
	var/turf/right_two = get_step(segment_two, turn(toward_dir, -90))
	var/turf/source_left_one = get_step(source_one, turn(toward_dir, 90))
	var/turf/source_right_one = get_step(source_one, turn(toward_dir, -90))
	var/turf/source_left_two = get_step(source_two, turn(toward_dir, 90))
	var/turf/source_right_two = get_step(source_two, turn(toward_dir, -90))
	copy_source_tile(source_left_one, left_one)
	copy_source_tile(source_right_one, right_one)
	copy_source_tile(source_left_two, left_two)
	copy_source_tile(source_right_two, right_two)

	if(!length(fake_images))
		return FALSE

	holder.client.images += fake_images
	holder.playsound_local(door_turf, 'sound/obj/machinery/door/airlock/open.ogg', 35)
	var/area/source_area = get_area(source_one)
	to_chat(holder, SPAN_WARNING("As \the [door] opens, it seems to lead straight into [source_area ? source_area.name : "another corridor"] for a split second."))
	feedback_details = " Impossible corridor via [door] in [get_area(door)] copied from [source_area ? source_area.name : "unknown area"]"
	return TRUE

/datum/hallucination/airlock/impossible_corridor/end()
	holder?.client?.images -= fake_images
	fake_images.Cut()

// PDA-style personal message
/datum/hallucination/pda_message
	category = "social"
	base_weight = 9
	category_cooldown = 12 SECONDS
	theme_tags = list("social")
	min_power = 25

/datum/hallucination/pda_message/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	return null

/datum/hallucination/pda_message/start()
	var/sender = holder.random_crewmember_name(6)
	if(!sender)
		sender = pick("Unknown", "Cargo", "Bridge", "Medical")
	var/list/messages = list(
		"where are you?",
		"don't go into maintenance alone",
		"i saw something following you",
		"come to medbay now",
		"call me back",
		"why are you not answering?",
		"someone is looking for you",
		lowertext(holder.random_hallucinated_phrase())
	)
	var/message = pick(messages)
	holder.playsound_local(get_turf(holder), 'sound/machines/pda_click.ogg', 35)
	to_chat(holder, SPAN_NOTICE("Your PDA vibrates. New message from [sender]: \"[message]\""))
	feedback_details = " PDA message from [sender]"
	return TRUE

// Intrusive thoughts
/datum/hallucination/intrusive_thought
	category = "ambient"
	base_weight = 9
	category_cooldown = 8 SECONDS
	theme_tags = list("psychedelic", "cosmic")
	min_power = 15

/datum/hallucination/intrusive_thought/start()
	var/message = holder.random_hallucinated_thought()
	to_chat(holder, SPAN_NOTICE("<i>[message]</i>"))
	feedback_details = " Thought: [message]"
	return TRUE

// A vivid memory of something that never happened.
/datum/hallucination/alien_memory
	category = "ambient"
	base_weight = 7
	category_cooldown = 10 SECONDS
	theme_tags = list("social", "aftermath", "cosmic")
	min_power = 25
	max_power = 85

/datum/hallucination/alien_memory/start()
	var/name = holder.random_crewmember_name(4)
	if(!name)
		name = pick("someone", "a crewmember", "a stranger")
	var/area_name = holder.random_station_area_name()
	var/list/memories = list(
		"You remember [name] pulling you aside in [area_name] and urgently warning you not to come back.",
		"A memory that is not yours flashes by: [name] sprinting through [area_name], looking over their shoulder.",
		"You vividly remember [name] dying in [area_name]. The image vanishes before you can place when it happened.",
		"For a split second, you remember blood smeared across [area_name] while [name] begged you for help.",
		"You remember hiding with [name] in [area_name], listening to something heavy move past the door.",
		"A borrowed memory surfaces: [name] quietly handing you something in [area_name], then walking away into the dark.",
		"You suddenly remember a tense conversation with [name] in [area_name]. You are certain it never happened."
	)
	var/message = pick(memories)
	to_chat(holder, SPAN_NOTICE("<i>[message]</i>"))
	feedback_details = " Alien memory: [message]"
	return TRUE

// Senses blur together under a chemical haze.
/datum/hallucination/synesthesia
	category = "ambient"
	base_weight = 8
	category_cooldown = 10 SECONDS
	theme_tags = list("psychedelic")
	min_power = 20
	max_power = 75

/datum/hallucination/synesthesia/start()
	var/list/messages = list(
		"The lights suddenly taste sweet and metallic.",
		"You can hear the color of the floor humming under your feet.",
		"Every sound leaves a bright smear across your vision.",
		"The air feels loud enough to touch.",
		"For a moment, shadows smell like hot wires and citrus."
	)
	var/message = pick(messages)
	to_chat(holder, SPAN_NOTICE("<i>[message]</i>"))
	feedback_details = " Synesthesia: [message]"
	return TRUE

// Brief impossible insight associated with heavier narcotics.
/datum/hallucination/cosmic_revelation
	category = "ambient"
	base_weight = 6
	category_cooldown = 12 SECONDS
	theme_tags = list("cosmic", "body")
	min_power = 35
	max_power = 100

/datum/hallucination/cosmic_revelation/start()
	var/list/messages = list(
		"You suddenly understand that something vast is looking back through your eyes.",
		"For a second, your heartbeat seems synchronized with something impossibly distant.",
		"You glimpse a pattern behind the world, and instinctively know you were never meant to see it.",
		"It feels as if another mind briefly mistakes your body for its own.",
		"You become certain that the dark space behind your ribs is occupied."
	)
	var/message = pick(messages)
	to_chat(holder, SPAN_WARNING("<i>[message]</i>"))
	feedback_details = " Cosmic revelation: [message]"
	return TRUE

// Seeing other people do impossible or unsettling things
/datum/hallucination/paranoia
	category = "social"
	base_weight = 8
	category_cooldown = 12 SECONDS
	theme_tags = list("social", "predator")
	min_power = 25

/datum/hallucination/paranoia/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	for(var/mob/living/M in oview(C))
		if(!M.stat)
			return null
	return "no people nearby"

/datum/hallucination/paranoia/start()
	var/list/candidates = list()
	for(var/mob/living/M in oview(holder))
		if(!M.stat)
			candidates += M
	if(!length(candidates))
		return FALSE
	var/mob/living/target = pick(candidates)
	var/action = holder.random_hallucinated_action()
	feedback_details = " Paranoia target: [target]"
	to_chat(holder, SPAN_WARNING("[target] [action]"))
	return TRUE

// Nearby whispers and half-heard comments
/datum/hallucination/whisper
	category = "social"
	base_weight = 7
	category_cooldown = 12 SECONDS
	theme_tags = list("social", "predator")
	min_power = 30

/datum/hallucination/whisper/extra_blocking_reason(mob/living/carbon/C, datum/hallucination_context/context = null)
	if(!C.can_hear())
		return "deaf"
	for(var/mob/living/M in oview(C, 1))
		if(!M.stat)
			return null
	return "no whisper source nearby"

/datum/hallucination/whisper/start()
	var/list/candidates = list()
	for(var/mob/living/M in oview(holder, 1))
		if(!M.stat)
			candidates += M
	if(!length(candidates))
		return FALSE
	var/mob/living/whisperer = pick(candidates)
	var/message = holder.random_hallucinated_phrase()
	feedback_details = " Whisper source: [whisperer]"
	if(prob(70))
		to_chat(holder, "<B>[whisperer]</B> whispers, <I>\"[message]\"</I>")
	else
		to_chat(holder, "<B>[whisperer]</B> [pick("leans in toward", "brushes past", "taps", "gently nudges")] [holder].")
	return TRUE
