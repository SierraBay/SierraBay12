// Contact uses torso difficulty; precision uses the selected zone's difficulty.
// Both rolls retain Bay's skill, condition and weapon accuracy modifiers.
/mob/living/carbon/human/proc/ce_resolve_melee_zone(mob/living/attacker, target_zone, accuracy_penalty)
	var/contact_miss = clamp(base_miss_chance[BP_CHEST] + accuracy_penalty, 0, 100)
	if(prob(contact_miss))
		to_chat(attacker, SPAN_WARNING("Your swing goes wide."))
		return null
	if(target_zone == BP_CHEST)
		return BP_CHEST
	// Bay required two successful zone rolls for a clean aimed hit. Preserve that
	// probability across the new contact and precision rolls; do not buff foot hits.
	var/zone_miss = clamp(base_miss_chance[target_zone] + accuracy_penalty, 0, 100)
	var/precision_hit = (100 - zone_miss) ** 2 / (100 - contact_miss)
	if(!prob(precision_hit))
		to_chat(attacker, SPAN_WARNING("Your strike misses the [parse_zone(target_zone)] and veers toward the chest."))
		return BP_CHEST
	return target_zone
