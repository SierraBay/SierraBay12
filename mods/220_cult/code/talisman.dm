/obj/item/paper/talisman/use_after(atom/target, mob/living/user, click_parameters)
	if (!can_invoke(target, user))
		return TRUE

	// Null rods block the talisman's effect but still consume it
	var/obj/item/nullrod/nullrod = locate() in target
	if (nullrod)
		user.visible_message(
			SPAN_DANGER("\The [user] invokes \the [src] at \the [target]!"),
			SPAN_DANGER("You invoke \the [talisman_name] talisman at \the [target], but it fails and falls to dust!"),
		)
	else
		user.visible_message(
			SPAN_DANGER("\The [user] invokes \the [src] at \the [target]!"),
			SPAN_DANGER("You invoke \the [talisman_name] talisman at \the [target]!")
		)
		admin_attack_log(user, target, "Used a talisman ([type]).", "Was victim of a talisman ([type]).", "used a talisman ([type]) on")
		invoke(target, user)
	//user.say("Talisman [talisman_name]!", all_languages[LANGUAGE_CULT]) // нет мы не будем кричать одновременно разные кричалки на культистском
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(target)
	if (talisman_sound)
		playsound(src, talisman_sound, 100, 1)
	qdel(src)
	return TRUE
