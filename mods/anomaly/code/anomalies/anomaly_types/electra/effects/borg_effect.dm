/mob/living/silicon/robot/electra_mob_effect()
	apply_damage(50, DAMAGE_BURN, def_zone = BP_CHEST)
	to_chat(src, SPAN_DANGER("<b>Powerful electric shock detected!</b>"))
