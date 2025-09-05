/obj/item/paper/talisman/wrath
	talisman_name = "wrath burning"
	talisman_desc = "deals heavy damage and shocks mob, while you invoke the talisman magic"
	valid_target_type = list(
		/mob/living/carbon,
		/mob/living/silicon,
		/mob/living/simple_animal
	)

/obj/item/paper/talisman/wrath/invoke(mob/living/target, mob/user)
	if(!iscultist(user))
		return
	user.say("Ощути гнев моего Бога!")
	var/obj/item/nullrod/nrod = locate() in target
	if(nrod)
		user.visible_message("<span class='danger'>\The [user] invokes \the [src] at [target], but they are unaffected.</span>", "<span class='danger'>You invoke \the [src] at [target], but they are unaffected.</span>")
		return
	else
		user.visible_message("<span class='danger'>\The [user] invokes \the [src] at [target].</span>", "<span class='danger'>You invoke \the [src] at [target].</span>")

	if(issilicon(target))
		target.apply_damage(30, DAMAGE_BRUTE)
		target.apply_damage(30, DAMAGE_BURN)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.apply_damage(25, DAMAGE_BRUTE)
		C.apply_damage(25, DAMAGE_SHOCK)
	admin_attack_log(user, target, "Used a wrathburning talisman.", "Was victim of a wrathburning talisman.", "used a wrathburning talisman on")
	user.unEquip(src)
	qdel(src)
