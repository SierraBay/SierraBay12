// Genes a replicant pod can pass on to the nymph it births.
// Yield, gases, climate and water use stay on the tray. These do not.

#define NYMPH_SLIP_COST 25
#define NYMPH_SLIP_COOLDOWN 6 SECONDS
#define NYMPH_STING_COST 15
#define NYMPH_THORN_COST 10
#define NYMPH_CONTACT_COOLDOWN 4 SECONDS
#define NYMPH_BURST_COST 180
#define NYMPH_BURST_COOLDOWN 30 SECONDS
#define NYMPH_SAP_COST 30
#define NYMPH_SAP_COOLDOWN 12 SECONDS
#define NYMPH_GENERATE_COST 8
#define NYMPH_GENERATE_COOLDOWN 10 SECONDS
#define NYMPH_BLINK_COST 60
#define NYMPH_BLINK_COOLDOWN 12 SECONDS
#define NYMPH_EXHALE_COST 30
#define NYMPH_EXHALE_COOLDOWN 10 SECONDS
#define NYMPH_TEMPER_COST 30
#define NYMPH_TEMPER_COOLDOWN 10 SECONDS
#define NYMPH_SHOCK_COST 25
#define NYMPH_SHOCK_COOLDOWN 8 SECONDS

/datum/nymph_genome
	var/potency = 1
	var/juicy = 0
	var/stings = 0
	var/explosive = 0
	var/carnivorous = 0
	var/biolum = 0
	var/teleporting = 0
	var/alter_temp = 0
	var/parasite = 0
	var/produces_power = 0
	var/large = 0
	var/spread = 0
	var/uses_ideal_light = 0
	var/ideal_light = 5
	var/light_tolerance = 3
	var/biolum_colour
	var/body_colour
	var/flesh_colour
	var/list/chems
	var/list/exude_gasses
	var/list/consume_gasses
	var/datum/seed/line
	var/next_slip = 0
	var/next_contact = 0
	var/next_burst = 0
	var/next_secrete = 0
	var/next_generate = 0
	var/next_blink = 0
	var/next_exhale = 0
	var/next_temper = 0
	var/next_shock = 0

/datum/nymph_genome/New(datum/seed/seed)
	if(!istype(seed))
		return
	potency = max(1, seed.get_trait(TRAIT_POTENCY))
	juicy = seed.get_trait(TRAIT_JUICY) || 0
	stings = seed.get_trait(TRAIT_STINGS) || 0
	explosive = seed.get_trait(TRAIT_EXPLOSIVE) || 0
	carnivorous = seed.get_trait(TRAIT_CARNIVOROUS) || 0
	biolum = seed.get_trait(TRAIT_BIOLUM) || 0
	teleporting = seed.get_trait(TRAIT_TELEPORTING) || 0
	alter_temp = seed.get_trait(TRAIT_ALTER_TEMP) || 0
	parasite = seed.get_trait(TRAIT_PARASITE) || 0
	produces_power = seed.get_trait(TRAIT_PRODUCES_POWER) || 0
	large = seed.get_trait(TRAIT_LARGE) || 0
	spread = seed.get_trait(TRAIT_SPREAD) || 0
	uses_ideal_light = seed.nymph_uses_ideal_light
	ideal_light = seed.get_trait(TRAIT_IDEAL_LIGHT) || 5
	light_tolerance = max(1, seed.get_trait(TRAIT_LIGHT_TOLERANCE) || 1)
	line = seed
	if(istext(seed.get_trait(TRAIT_BIOLUM_COLOUR)))
		biolum_colour = seed.get_trait(TRAIT_BIOLUM_COLOUR)
	if(istext(seed.get_trait(TRAIT_FLESH_COLOUR)))
		flesh_colour = seed.get_trait(TRAIT_FLESH_COLOUR)
	if(islist(seed.exude_gasses) && length(seed.exude_gasses))
		exude_gasses = seed.exude_gasses.Copy()
	if(islist(seed.consume_gasses) && length(seed.consume_gasses))
		consume_gasses = seed.consume_gasses.Copy()
	if(seed.nymph_body_pigment)
		for(var/trait in list(TRAIT_PRODUCT_COLOUR, TRAIT_PLANT_COLOUR, TRAIT_LEAVES_COLOUR, TRAIT_FLESH_COLOUR))
			if(istext(seed.get_trait(trait)))
				body_colour = seed.get_trait(trait)
				break
	if(islist(seed.chems) && length(seed.chems))
		chems = list()
		for(var/rid in seed.chems)
			var/list/chem_profile = seed.chems[rid]
			if(islist(chem_profile))
				chems[rid] = chem_profile.Copy()
			else
				chems[rid] = chem_profile

/datum/nymph_genome/proc/expressed()
	return juicy || stings || explosive || carnivorous || biolum || teleporting || body_colour || flesh_colour || length(chems) || length(exude_gasses) || length(consume_gasses) || alter_temp || parasite || produces_power || large || spread || uses_ideal_light

/datum/nymph_genome/proc/supports(kind)
	switch(kind)
		if("burst")
			return explosive
		if("sap")
			return length(chems)
		if("slip")
			return juicy
		if("contact")
			return stings || carnivorous
		if("blink")
			return teleporting
		if("exhale")
			return length(exude_gasses)
		if("temper")
			return alter_temp
		if("vine")
			return spread

/datum/nymph_genome/proc/glow_power()
	var/scale = clamp(potency, 1, 200) / 200
	return (1.2 * scale) / (0.2 + scale)

/datum/nymph_genome/proc/apply_appearance(mob/living/carbon/alien/diona/nymph)
	if(body_colour)
		nymph.color = body_colour
		if(nymph.eyes)
			nymph.eyes.appearance_flags |= RESET_COLOR
		var/image/petals = image(icon = nymph.icon, icon_state = "flower_fore")
		petals.color = body_colour
		petals.appearance_flags = RESET_COLOR
		nymph.flower = image(icon = nymph.icon, icon_state = "flower_back")
		nymph.flower.appearance_flags = RESET_COLOR
		nymph.flower.AddOverlays(petals)
		nymph.update_icons()
	if(large)
		nymph.maxHealth = initial(nymph.maxHealth) + 30
		nymph.health = nymph.maxHealth
		nymph.SetTransform(scale = 1.2)
	if(biolum && !nymph.expression_host())
		apply_light(nymph)

/datum/nymph_genome/proc/apply_light(atom/target)
	if(!biolum || !target)
		return
	var/power = glow_power()
	var/colour = biolum_colour || body_colour || "#b6ff9a"
	target.set_light(6 * power, power, l_color = colour)

/datum/nymph_genome/proc/describe(mob/living/carbon/alien/diona/nymph, mob/user)
	var/list/notes = list()
	if(body_colour)
		notes += "dyed blossoms"
	if(juicy)
		notes += "slick sap"
	if(carnivorous)
		notes += "thorns"
	if(stings)
		notes += "stingers"
	if(explosive)
		notes += "volatile sap"
	if(biolum)
		notes += "a soft glow"
	if(teleporting)
		notes += "a bluespace twitch"
	if(length(chems))
		var/list/names = list()
		for(var/rid in chems)
			var/datum/reagent/produced = rid
			names += initial(produced.name)
		notes += "sap of [english_list(names)]"
	if(length(notes))
		to_chat(user, SPAN_NOTICE("It shows signs of [english_list(notes)]."))

/datum/nymph_genome/proc/try_slip(mob/living/carbon/alien/diona/nymph, atom/mover)
	if(!juicy || nymph.stat == DEAD || !isliving(mover) || mover == nymph)
		return FALSE
	if(world.time < next_slip || nymph.nutrition < NYMPH_SLIP_COST)
		return FALSE
	var/mob/living/slipped = mover
	if(!slipped.slip("the slick sap", 6))
		return FALSE
	nymph.adjust_nutrition(-NYMPH_SLIP_COST)
	next_slip = world.time + NYMPH_SLIP_COOLDOWN
	return TRUE

/datum/nymph_genome/proc/try_contact(mob/living/carbon/alien/diona/nymph, atom/target)
	if(nymph.stat == DEAD || (!stings && !carnivorous))
		return FALSE
	if(!isliving(target) || target == nymph || target == nymph.loc)
		return FALSE
	var/mob/living/victim = target
	if(victim.stat == DEAD)
		return FALSE
	if(world.time < next_contact)
		return FALSE
	var/cost = 0
	if(stings)
		cost += NYMPH_STING_COST
	if(carnivorous)
		cost += NYMPH_THORN_COST
	if(!nymph.spend_nutrients(cost, silent = TRUE))
		return FALSE
	next_contact = world.time + NYMPH_CONTACT_COOLDOWN
	if(carnivorous)
		inflict_thorns(nymph, target)
	if(stings)
		inflict_sting(nymph, target)
	return TRUE

/datum/nymph_genome/proc/inflict_thorns(mob/living/carbon/alien/diona/nymph, mob/living/target)
	var/shown = nymph.expression_host() || nymph
	var/damage = carnivorous >= 2 ? max(5, round(15 * potency / 100)) : max(1, round(5 * potency / 100))
	if(ishuman(target) && sting_blocked(target))
		damage = max(1, round(damage / 2))
		to_chat(target, SPAN_DANGER("\The [shown]'s thorns scrape against your armour!"))
	else
		to_chat(target, SPAN_DANGER("\The [shown]'s thorns dig into you!"))
	target.apply_damage(damage, DAMAGE_BRUTE, damage_flags = DAMAGE_FLAG_SHARP)

/datum/nymph_genome/proc/inflict_sting(mob/living/carbon/alien/diona/nymph, mob/living/target)
	var/shown = nymph.expression_host() || nymph
	if(!length(chems) || !target.reagents)
		to_chat(target, SPAN_DANGER("\The [shown]'s spines prick you!"))
		return
	if(ishuman(target) && sting_blocked(target))
		to_chat(target, SPAN_DANGER("\The [shown]'s spines scrape against your armour!"))
		return
	var/injecting = min(5, max(1, round(potency / 5)))
	to_chat(target, SPAN_DANGER("\The [shown]'s spines sting you!"))
	for(var/rid in chems)
		target.reagents.add_reagent(rid, injecting)

/datum/nymph_genome/proc/sting_blocked(mob/living/carbon/human/target)
	if(!istype(target) || !length(target.organs))
		return FALSE
	var/obj/item/organ/external/affecting = pick(target.organs)
	if(!affecting)
		return FALSE
	for(var/obj/item/clothing/clothes in list(target.head, target.wear_mask, target.wear_suit, target.w_uniform, target.gloves, target.shoes))
		if(clothes && (clothes.body_parts_covered & affecting.body_part) && (clothes.item_flags & ITEM_FLAG_THICKMATERIAL))
			return TRUE
	return FALSE

/datum/nymph_genome/proc/burst(mob/living/carbon/alien/diona/nymph)
	if(!explosive)
		return FALSE
	if(nymph.incapacitated())
		nymph.tell_expression(SPAN_WARNING("You can't rupture like this right now."))
		return FALSE
	if(world.time < next_burst)
		nymph.tell_expression(SPAN_WARNING("Your sap hasn't built up again yet."))
		return FALSE
	if(!nymph.spend_nutrients(NYMPH_BURST_COST))
		return FALSE
	next_burst = world.time + NYMPH_BURST_COOLDOWN

	var/atom/movable/anchor = nymph.expression_host() || nymph
	var/turf/origin = get_turf(anchor)
	if(!origin)
		return TRUE
	origin.visible_message(SPAN_DANGER("\The [anchor] ruptures, spraying volatile sap!"))
	spray(origin, anchor, nymph, clamp(round(potency / 25), 1, 3))
	for(var/mob/living/hit in range(clamp(round(potency / 25), 1, 3), origin))
		if(hit == anchor || hit == nymph || hit.loc == anchor)
			continue
		hit.apply_damage(max(4, 14 - get_dist(origin, hit) * 4), DAMAGE_BRUTE)
	nymph.adjustBruteLoss(12)
	if(isliving(anchor) && anchor != nymph)
		var/mob/living/host = anchor
		host.adjustBruteLoss(8)
	return TRUE

/datum/nymph_genome/proc/blink(mob/living/carbon/alien/diona/nymph)
	if(!teleporting)
		return FALSE
	if(nymph.incapacitated())
		nymph.tell_expression(SPAN_WARNING("You can't step through bluespace right now."))
		return FALSE
	if(world.time < next_blink)
		nymph.tell_expression(SPAN_WARNING("The bluespace twitch hasn't settled yet."))
		return FALSE

	var/atom/movable/anchor = nymph.expression_host() || nymph
	var/outer = clamp(round(potency / 5), 2, 8)
	var/inner = min(clamp(round(potency / 15), 1, 3), outer)
	var/turf/destination = get_random_turf_in_range(anchor, outer, inner)
	if(!destination || destination == get_turf(anchor))
		nymph.tell_expression(SPAN_WARNING("The fold fails to find anywhere to open."))
		return FALSE
	if(!nymph.spend_nutrients(NYMPH_BLINK_COST))
		return FALSE
	next_blink = world.time + NYMPH_BLINK_COOLDOWN

	if(isliving(anchor))
		var/mob/living/body = anchor
		if(body.buckled)
			body.buckled.unbuckle_mob()

	var/turf/origin = get_turf(anchor)
	var/datum/effect/spark_spread/leaving = new
	leaving.set_up(3, 1, origin)
	leaving.start()
	anchor.forceMove(destination)
	var/datum/effect/spark_spread/arriving = new
	arriving.set_up(3, 1, destination)
	arriving.start()
	destination.visible_message(SPAN_WARNING("\The [anchor] folds through a pinch of bluespace."))
	return TRUE

/datum/nymph_genome/proc/secrete(mob/living/carbon/alien/diona/nymph)
	if(!length(chems))
		return FALSE
	if(nymph.incapacitated())
		nymph.tell_expression(SPAN_WARNING("You can't secrete sap right now."))
		return FALSE
	if(world.time < next_secrete)
		nymph.tell_expression(SPAN_WARNING("Your sap hasn't built up again yet."))
		return FALSE
	if(!nymph.spend_nutrients(NYMPH_SAP_COST))
		return FALSE
	next_secrete = world.time + NYMPH_SAP_COOLDOWN

	var/atom/movable/anchor = nymph.expression_host() || nymph
	var/turf/origin = get_turf(anchor)
	if(!origin)
		return TRUE
	origin.visible_message(SPAN_NOTICE("\The [anchor] sweats a film of sap."))
	spray(origin, anchor, nymph, 0)
	return TRUE

/datum/nymph_genome/proc/spray(turf/origin, atom/anchor, mob/nymph, radius)
	if(!origin || !length(chems))
		return
	var/datum/reagents/sap = sap_holder()
	if(radius <= 0)
		sap.splash(origin, sap.total_volume, 1, 1)
		for(var/mob/living/hit in origin)
			if(hit == anchor || hit == nymph || hit.loc == anchor)
				continue
			sap.splash(hit, sap.total_volume, 1, 1)
	else
		for(var/mob/living/hit in range(radius, origin))
			if(hit == anchor || hit == nymph || hit.loc == anchor)
				continue
			sap.splash(hit, sap.total_volume, 1, 1)
		sap.splash(origin, sap.total_volume, 1, 1)
	qdel(sap)

/datum/nymph_genome/proc/sap_holder()
	var/datum/reagents/sap = new(100, GLOB.temp_reagents_holder)
	var/dose = min(5, max(1, round(potency / 5)))
	for(var/rid in chems)
		sap.add_reagent(rid, dose)
	return sap

/datum/nymph_genome/proc/try_shock(mob/living/carbon/alien/diona/nymph, atom/target)
	if(!produces_power || !isliving(target) || target == nymph || target == nymph.loc)
		return FALSE
	if(world.time < next_shock)
		return FALSE
	if(!nymph.spend_nutrients(NYMPH_SHOCK_COST, TRUE))
		return FALSE
	next_shock = world.time + NYMPH_SHOCK_COOLDOWN
	var/mob/living/victim = target
	victim.electrocute_act(12, nymph)
	victim.apply_damage(8, DAMAGE_BURN)
	to_chat(victim, SPAN_DANGER("\The [nymph.expression_host() || nymph] shocks you!"))
	return TRUE

/datum/nymph_genome/proc/feed_from_air(mob/living/carbon/alien/diona/nymph, datum/gas_mixture/air)
	if(!air || !length(consume_gasses))
		return
	for(var/gas in consume_gasses)
		if(air.gas[gas] < 0.5)
			continue
		air.adjust_gas(gas, -0.5)
		nymph.adjust_nutrition(3)
		return

/datum/nymph_genome/proc/light_adjustment(light_amount)
	if(!uses_ideal_light)
		return 0
	var/distance = abs(light_amount - ideal_light)
	if(distance <= light_tolerance)
		return round(light_amount * 0.5)
	return -round(light_amount * 0.5)

/datum/nymph_genome/proc/exhale(mob/living/carbon/alien/diona/nymph)
	if(!length(exude_gasses))
		return FALSE
	if(nymph.incapacitated())
		nymph.tell_expression(SPAN_WARNING("You can't exhale right now."))
		return FALSE
	if(world.time < next_exhale)
		nymph.tell_expression(SPAN_WARNING("Your sap hasn't built up another breath."))
		return FALSE
	var/turf/origin = get_turf(nymph.expression_host() || nymph)
	var/datum/gas_mixture/air = origin?.return_air()
	if(!air)
		return FALSE
	if(!nymph.spend_nutrients(NYMPH_EXHALE_COST))
		return FALSE
	next_exhale = world.time + NYMPH_EXHALE_COOLDOWN
	for(var/gas in exude_gasses)
		air.adjust_gas(gas, min(10, max(1, round(exude_gasses[gas]))))
	origin.visible_message(SPAN_WARNING("\The [nymph.expression_host() || nymph] exhales a strange breath."))
	return TRUE

/datum/nymph_genome/proc/temper(mob/living/carbon/alien/diona/nymph)
	if(!alter_temp)
		return FALSE
	if(nymph.incapacitated())
		nymph.tell_expression(SPAN_WARNING("You can't shift the air right now."))
		return FALSE
	if(world.time < next_temper)
		nymph.tell_expression(SPAN_WARNING("The air around you has not settled yet."))
		return FALSE
	var/turf/origin = get_turf(nymph.expression_host() || nymph)
	var/datum/gas_mixture/air = origin?.return_air()
	if(!air)
		return FALSE
	if(!nymph.spend_nutrients(NYMPH_TEMPER_COST))
		return FALSE
	next_temper = world.time + NYMPH_TEMPER_COOLDOWN
	air.temperature = clamp(air.temperature + (alter_temp > 0 ? 20 : -20), 80, 400)
	air.update_values()
	origin.visible_message(SPAN_WARNING("\The [nymph.expression_host() || nymph] [alter_temp > 0 ? "warms" : "chills"] the air."))
	return TRUE

/datum/nymph_genome/proc/generate(mob/living/carbon/alien/diona/nymph)
	if(!length(chems) || world.time < next_generate || !nymph.reagents)
		return
	var/mob/living/carbon/human/host = nymph.expression_host()
	var/nymph_room = nymph.reagents.total_volume < 80
	var/host_room = istype(host) && host.bloodstr && host.bloodstr.total_volume < 80
	if(!nymph_room && !host_room)
		next_generate = world.time + NYMPH_GENERATE_COOLDOWN
		return
	if(!nymph.spend_nutrients(NYMPH_GENERATE_COST, silent = TRUE))
		return
	next_generate = world.time + NYMPH_GENERATE_COOLDOWN
	var/added = 0
	for(var/rid in chems)
		if(added >= 4)
			break
		if(nymph_room)
			nymph.reagents.add_reagent(rid, 1)
		if(host_room)
			host.bloodstr.add_reagent(rid, 1)
		added++

/mob/living/carbon/alien/diona
	var/datum/nymph_genome/genome

/mob/living/carbon/alien/diona/proc/inherit_plant_genome(datum/seed/seed)
	var/datum/nymph_genome/born = new(seed)
	if(!born.expressed())
		qdel(born)
		return
	genome = born
	genome.apply_appearance(src)
	sync_expression_verbs()

/mob/living/carbon/alien/diona/proc/expression_host()
	if(ishuman(loc))
		var/mob/living/carbon/human/host = loc
		if(host.species?.name == SPECIES_DIONA)
			return host
	if(istype(loc, /obj/structure/diona_gestalt))
		return loc
	return null

/mob/living/carbon/alien/diona/proc/tell_expression(message)
	to_chat(src, message)
	var/atom/host = expression_host()
	if(ishuman(host))
		to_chat(host, message)

/mob/living/carbon/alien/diona/proc/spend_nutrients(amount, silent)
	if(nutrition < amount)
		if(!silent)
			tell_expression(SPAN_WARNING("Your nutrients are too thin for that."))
		return FALSE
	adjust_nutrition(-amount)
	return TRUE

/mob/living/carbon/alien/diona/proc/express_contact(atom/target)
	if(!genome)
		return
	genome.try_contact(src, target)
	genome.try_shock(src, target)

/mob/living/carbon/alien/diona/proc/process_plant_genome()
	if(!genome || stat == DEAD)
		return
	genome.generate(src)
	var/turf/here = get_turf(src)
	genome.feed_from_air(src, here?.return_air())
	if(genome.uses_ideal_light && here)
		adjust_nutrition(genome.light_adjustment(here.get_lumcount() * 5))
	var/atom/host = expression_host()
	if(host)
		set_light(0)
		return
	if(radiation > 20)
		return
	if(genome.biolum)
		genome.apply_light(src)
	else if(!last_glow)
		set_light(0)

/mob/living/carbon/alien/diona/proc/describe_plant_genome(mob/user)
	if(genome)
		genome.describe(src, user)

/mob/living/carbon/alien/diona/proc/sync_expression_verbs()
	if(genome?.explosive)
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_sap_burst
	else
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_sap_burst
	if(length(genome?.chems))
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_secrete_sap
	else
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_secrete_sap
	if(genome?.teleporting)
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_bluespace_step
	else
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_bluespace_step
	if(length(genome?.exude_gasses))
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_exhale
	else
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_exhale
	if(genome?.alter_temp)
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_temper
	else
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_temper
	if(genome?.spread)
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_guide_vine
		verbs |= /mob/living/carbon/alien/diona/proc/nymph_sever_vine
	else
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_guide_vine
		verbs -= /mob/living/carbon/alien/diona/proc/nymph_sever_vine

/mob/living/carbon/alien/diona/proc/nymph_sap_burst()
	set name = "Sap Burst"
	set category = "Abilities"
	set desc = "Rupture volatile sap around yourself. Spends your nutrients."
	if(genome)
		genome.burst(src)

/mob/living/carbon/alien/diona/proc/nymph_secrete_sap()
	set name = "Secrete Sap"
	set category = "Abilities"
	set desc = "Sweat the chemicals grown into you. Spends your nutrients."
	if(genome)
		genome.secrete(src)

/mob/living/carbon/alien/diona/proc/nymph_bluespace_step()
	set name = "Bluespace Step"
	set category = "Abilities"
	set desc = "Fold a short distance through bluespace. Spends your nutrients."
	if(genome)
		genome.blink(src)

/mob/living/carbon/alien/diona/proc/nymph_exhale()
	set name = "Exhale Gas"
	set category = "Abilities"
	set desc = "Breathe out the gases grown into you. Spends your nutrients."
	if(genome)
		genome.exhale(src)

/mob/living/carbon/alien/diona/proc/nymph_temper()
	set name = "Shift Air"
	set category = "Abilities"
	set desc = "Warm or chill the air on your tile. Spends your nutrients."
	if(genome)
		genome.temper(src)

/mob/living/carbon/alien/diona/proc/nymph_guide_vine()
	set name = "Guide Vine"
	set category = "Abilities"
	set desc = "Root a vine you can steer. Spends your nutrients as it grows."
	if(guided_vine)
		tell_expression(SPAN_NOTICE("Green grows the tip or walks you along it. Blue shifts a captive. Yellow grabs. Red cuts a vine you click, and strikes anything else."))
		return
	plant_guided_root()

/mob/living/carbon/alien/diona/proc/nymph_sever_vine()
	set name = "Sever Vine"
	set category = "Abilities"
	set desc = "Let go of the guided vine. It withers at once."
	if(!guided_vine)
		tell_expression(SPAN_WARNING("You are not guiding a vine."))
		return
	guided_vine.wither()

/mob/living/carbon/alien/diona/Crossed(atom/movable/arrived)
	..()
	if(isturf(loc) && genome)
		genome.try_slip(src, arrived)

/mob/living/carbon/alien/diona/attack_hand(mob/living/carbon/attacker)
	..()
	if(attacker && attacker.a_intent == I_HURT && genome)
		genome.try_contact(src, attacker)

/proc/nymph_expression_blossoms(list/things)
	var/list/blossoms = list()
	var/spot = 0
	var/static/list/spots = list(
		list(0, 8),
		list(-8, 2),
		list(8, 2),
		list(-5, -4),
		list(6, -6),
		list(0, -8)
	)
	for(var/mob/living/carbon/alien/diona/nymph in things)
		if(nymph.stat == DEAD || !nymph.genome?.body_colour)
			continue
		var/list/offset = spots[(spot % length(spots)) + 1]
		spot++
		var/image/petals = image(icon = 'icons/mob/gestalt.dmi', icon_state = "flower_fore")
		petals.color = nymph.genome.body_colour
		petals.appearance_flags = RESET_COLOR
		petals.pixel_x = offset[1]
		petals.pixel_y = offset[2]
		blossoms += petals
	return blossoms

/proc/apply_nymph_glow(atom/target, list/things)
	var/best = 0
	var/best_colour = "#b6ff9a"
	for(var/mob/living/carbon/alien/diona/nymph in things)
		if(nymph.stat == DEAD || !nymph.genome?.biolum)
			continue
		var/power = nymph.genome.glow_power()
		if(power < best)
			continue
		best = power
		best_colour = nymph.genome.biolum_colour || nymph.genome.body_colour || "#b6ff9a"
	if(best > 0)
		target.set_light(6 * best, best, l_color = best_colour)
	else
		target.set_light(0)

/mob/living/carbon/human/proc/first_expressed_nymph(kind)
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.stat != DEAD && nymph.genome?.supports(kind))
			return nymph

/mob/living/carbon/human/proc/sync_nymph_expression()
	if(!species || species.name != SPECIES_DIONA)
		return
	var/want_burst = FALSE
	var/want_sap = FALSE
	var/want_blink = FALSE
	var/want_exhale = FALSE
	var/want_temper = FALSE
	var/want_vine = FALSE
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.stat == DEAD || !nymph.genome)
			continue
		if(nymph.genome.explosive)
			want_burst = TRUE
		if(length(nymph.genome.chems))
			want_sap = TRUE
		if(nymph.genome.teleporting)
			want_blink = TRUE
		if(length(nymph.genome.exude_gasses))
			want_exhale = TRUE
		if(nymph.genome.alter_temp)
			want_temper = TRUE
		if(nymph.genome.spread)
			want_vine = TRUE
		nymph.set_light(0)
	if(want_burst)
		verbs |= /mob/living/carbon/human/proc/diona_sap_burst
	else
		verbs -= /mob/living/carbon/human/proc/diona_sap_burst
	if(want_sap)
		verbs |= /mob/living/carbon/human/proc/diona_secrete_sap
	else
		verbs -= /mob/living/carbon/human/proc/diona_secrete_sap
	if(want_blink)
		verbs |= /mob/living/carbon/human/proc/diona_bluespace_step
	else
		verbs -= /mob/living/carbon/human/proc/diona_bluespace_step
	if(want_exhale)
		verbs |= /mob/living/carbon/human/proc/diona_exhale
	else
		verbs -= /mob/living/carbon/human/proc/diona_exhale
	if(want_temper)
		verbs |= /mob/living/carbon/human/proc/diona_temper
	else
		verbs -= /mob/living/carbon/human/proc/diona_temper
	if(want_vine)
		verbs |= /mob/living/carbon/human/proc/diona_guide_vine
		verbs |= /mob/living/carbon/human/proc/diona_sever_vine
	else
		verbs -= /mob/living/carbon/human/proc/diona_guide_vine
		verbs -= /mob/living/carbon/human/proc/diona_sever_vine
	apply_nymph_glow(src, contents)
	paint_nymph_foliage()
	queue_icon_update()

/mob/living/carbon/human/proc/nymph_expression_struck(mob/living/attacker)
	if(!species || species.name != SPECIES_DIONA || !isliving(attacker))
		return
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.genome?.try_contact(nymph, attacker))
			return

/mob/living/carbon/human/proc/nymph_expression_strike(mob/living/target)
	if(!species || species.name != SPECIES_DIONA || !isliving(target))
		return
	for(var/mob/living/carbon/alien/diona/nymph in src)
		var/handled = nymph.genome?.try_contact(nymph, target)
		if(nymph.genome?.try_shock(nymph, target))
			handled = TRUE
		if(handled)
			return

/mob/living/carbon/human/proc/diona_sap_burst()
	set name = "Sap Burst"
	set category = "Abilities"
	set desc = "A nymph ruptures volatile sap. It spends that nymph's nutrients."
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.stat == DEAD || !nymph.genome?.explosive)
			continue
		if(nymph.nutrition < NYMPH_BURST_COST || world.time < nymph.genome.next_burst)
			continue
		nymph.genome.burst(nymph)
		return
	var/mob/living/carbon/alien/diona/fallback = first_expressed_nymph("burst")
	if(!fallback)
		to_chat(src, SPAN_WARNING("No nymph in the gestalt can rupture sap."))
		return
	fallback.genome.burst(fallback)

/mob/living/carbon/human/proc/diona_secrete_sap()
	set name = "Secrete Sap"
	set category = "Abilities"
	set desc = "A nymph sweats the chemicals grown into it. It spends that nymph's nutrients."
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.stat == DEAD || !length(nymph.genome?.chems))
			continue
		if(nymph.nutrition < NYMPH_SAP_COST || world.time < nymph.genome.next_secrete)
			continue
		nymph.genome.secrete(nymph)
		return
	var/mob/living/carbon/alien/diona/fallback = first_expressed_nymph("sap")
	if(!fallback)
		to_chat(src, SPAN_WARNING("No nymph in the gestalt is producing sap."))
		return
	fallback.genome.secrete(fallback)

/mob/living/carbon/human/proc/diona_bluespace_step()
	set name = "Bluespace Step"
	set category = "Abilities"
	set desc = "A nymph folds the gestalt a short distance through bluespace. It spends that nymph's nutrients."
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.stat == DEAD || !nymph.genome?.teleporting)
			continue
		if(nymph.nutrition < NYMPH_BLINK_COST || world.time < nymph.genome.next_blink)
			continue
		nymph.genome.blink(nymph)
		return
	var/mob/living/carbon/alien/diona/fallback = first_expressed_nymph("blink")
	if(!fallback)
		to_chat(src, SPAN_WARNING("No nymph in the gestalt can step through bluespace."))
		return
	fallback.genome.blink(fallback)

/mob/living/carbon/human/proc/diona_exhale()
	set name = "Exhale Gas"
	set category = "Abilities"
	set desc = "A nymph breathes out the gases grown into it. It spends that nymph's nutrients."
	var/mob/living/carbon/alien/diona/nymph = first_expressed_nymph("exhale")
	if(!nymph)
		to_chat(src, SPAN_WARNING("No nymph in the gestalt can exhale."))
		return
	nymph.genome.exhale(nymph)

/mob/living/carbon/human/proc/diona_temper()
	set name = "Shift Air"
	set category = "Abilities"
	set desc = "A nymph warms or chills the air. It spends that nymph's nutrients."
	var/mob/living/carbon/alien/diona/nymph = first_expressed_nymph("temper")
	if(!nymph)
		to_chat(src, SPAN_WARNING("No nymph in the gestalt can shift the air."))
		return
	nymph.genome.temper(nymph)

/mob/living/carbon/human/proc/diona_guide_vine()
	set name = "Guide Vine"
	set category = "Abilities"
	set desc = "A nymph roots a vine you can steer. Growth spends that nymph's nutrients."
	var/mob/living/carbon/alien/diona/nymph = first_expressed_nymph("vine")
	if(!nymph)
		to_chat(src, SPAN_WARNING("No nymph in the gestalt can root a vine."))
		return
	if(nymph.guided_vine)
		to_chat(src, SPAN_NOTICE("Green grows the tip or walks you along it. Blue shifts a captive. Yellow grabs. Red cuts a vine you click, and strikes anything else."))
		return
	nymph.plant_guided_root()

/mob/living/carbon/human/proc/diona_sever_vine()
	set name = "Sever Vine"
	set category = "Abilities"
	set desc = "Let go of the guided vine. It withers at once."
	var/severed = FALSE
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(!nymph.guided_vine)
			continue
		nymph.guided_vine.wither()
		severed = TRUE
	if(!severed)
		to_chat(src, SPAN_WARNING("No vine is rooted."))

/mob/living/carbon/human/Bumped(atom/bumper)
	..()
	if(!species || species.name != SPECIES_DIONA || !isliving(bumper))
		return
	if(istype(bumper, /mob/living/carbon/alien/diona))
		return
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.genome?.try_slip(nymph, bumper))
			return

/obj/item/organ/external/head/diona/get_eye_overlay()
	var/show_eyes = glowing_eyes
	if(show_eyes && owner)
		for(var/obj/item/equipped as anything in owner.get_equipped_items())
			if(HAS_FLAGS(equipped.body_parts_covered, EYES))
				show_eyes = FALSE
				break

	var/image/eye_glow
	if(show_eyes)
		eye_glow = image(get_eyes())
		eye_glow.AddOverlays(emissive_appearance(eye_icon_location, ""))
		eye_glow.layer = FLOAT_LAYER

	if(!owner)
		return eye_glow

	var/list/blossoms = nymph_expression_blossoms(owner.contents)
	if(!length(blossoms))
		return eye_glow
	if(!eye_glow)
		eye_glow = blossoms[1]
		blossoms.Cut(1, 2)
	if(length(blossoms))
		eye_glow.AddOverlays(blossoms)
	return eye_glow

/obj/structure/diona_gestalt/proc/refresh_nymph_expression()
	var/list/blossoms = nymph_expression_blossoms(nymphs)
	if(length(blossoms))
		AddOverlays(blossoms)
	apply_nymph_glow(src, nymphs)
	for(var/mob/living/carbon/alien/diona/nymph in nymphs)
		if(nymph.genome?.biolum)
			nymph.set_light(0)

/obj/structure/diona_gestalt/proc/try_expression_slip(atom/bumper)
	if(!isliving(bumper) || istype(bumper, /mob/living/carbon/alien/diona))
		return
	for(var/mob/living/carbon/alien/diona/nymph in nymphs)
		if(nymph.genome?.try_slip(nymph, bumper))
			return

/obj/structure/diona_gestalt/proc/try_expression_retaliation(mob/living/user)
	if(!isliving(user))
		return
	for(var/mob/living/carbon/alien/diona/nymph in nymphs)
		if(nymph.genome?.try_contact(nymph, user))
			return

/singleton/species/diona/get_blood_colour(mob/living/carbon/human/H)
	if(H)
		for(var/mob/living/carbon/alien/diona/nymph in H)
			if(nymph.stat != DEAD && nymph.genome?.flesh_colour)
				return nymph.genome.flesh_colour
	return ..()

/obj/item/organ/external
	var/nymph_foliage_colour

/mob/living/carbon/human/proc/paint_nymph_foliage()
	if(!species || species.name != SPECIES_DIONA)
		return
	var/list/colours = list()
	for(var/mob/living/carbon/alien/diona/nymph in src)
		if(nymph.stat == DEAD || !nymph.genome?.body_colour)
			continue
		colours += nymph.genome.body_colour
	var/static/list/limb_tags = list(
		BP_HEAD, BP_CHEST, BP_GROIN,
		BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG,
		BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT
	)
	var/index = 1
	for(var/tag in limb_tags)
		var/obj/item/organ/external/limb = organs_by_name[tag]
		if(!limb)
			continue
		limb.nymph_foliage_colour = length(colours) ? colours[((index - 1) % length(colours)) + 1] : null
		index++
	update_body(0)

/obj/item/organ/external/diona/get_icon_key()
	. = ..()
	if(nymph_foliage_colour)
		. += nymph_foliage_colour

/obj/item/organ/external/head/diona/get_icon_key()
	. = ..()
	if(nymph_foliage_colour)
		. += nymph_foliage_colour

/obj/item/organ/external/diona/on_update_icon(regenerate = 0)
	..()
	add_nymph_foliage_overlay()

/obj/item/organ/external/head/diona/on_update_icon(regenerate = 0)
	..()
	add_nymph_foliage_overlay()

/obj/item/organ/external/proc/add_nymph_foliage_overlay()
	if(!nymph_foliage_colour || is_stump() || !icon_name)
		return
	var/mutable_appearance/leaves = mutable_appearance('icons/mob/human_races/species/diona/foliage.dmi', icon_name, flags = RESET_COLOR)
	leaves.color = nymph_foliage_colour
	mob_overlays += leaves

#undef NYMPH_SLIP_COST
#undef NYMPH_SLIP_COOLDOWN
#undef NYMPH_STING_COST
#undef NYMPH_THORN_COST
#undef NYMPH_CONTACT_COOLDOWN
#undef NYMPH_BURST_COST
#undef NYMPH_BURST_COOLDOWN
#undef NYMPH_SAP_COST
#undef NYMPH_SAP_COOLDOWN
#undef NYMPH_GENERATE_COST
#undef NYMPH_GENERATE_COOLDOWN
#undef NYMPH_BLINK_COST
#undef NYMPH_BLINK_COOLDOWN
#undef NYMPH_EXHALE_COST
#undef NYMPH_EXHALE_COOLDOWN
#undef NYMPH_TEMPER_COST
#undef NYMPH_TEMPER_COOLDOWN
#undef NYMPH_SHOCK_COST
#undef NYMPH_SHOCK_COOLDOWN
