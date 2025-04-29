/proc/electra_borg_effect(mob/living/silicon/robot/borg)
	borg.apply_damage(50, DAMAGE_BURN, def_zone = BP_CHEST)
	to_chat(borg, SPAN_DANGER("<b>Powerful electric shock detected!</b>"))
