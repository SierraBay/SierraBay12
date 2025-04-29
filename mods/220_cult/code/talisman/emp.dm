/obj/item/paper/talisman/emp

	talisman_name = "emp"
	talisman_desc = "invokes a localized EMP effect on the target. Can be used on machinery or mobs"
	talisman_sound = 'sound/effects/EMPulse.ogg'
	valid_target_type = list(
		/mob,
		/obj/machinery,
		/obj/machinery/door
	)
/obj/item/paper/talisman/emp/invoke(atom/target, mob/user)
	user.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!", all_languages[LANGUAGE_CULT])
	user.visible_message("<span class='danger'>\The [user] invokes \the [src] at [target].</span>", "<span class='danger'>You invoke \the [src] at [target].</span>")
	target.emp_act(1)
