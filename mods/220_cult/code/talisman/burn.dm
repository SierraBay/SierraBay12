/obj/item/paper/talisman/burn
	talisman_name = "burning"
	talisman_desc = "ignites a mob, which is useful for disposing of bodies, or heavily damages a silicon mob"
	valid_target_type = list(
		/mob/living/carbon,
		/mob/living/silicon,
		/mob/living/simple_animal
	)

/obj/item/paper/talisman/burn/invoke(mob/living/target, mob/user)
	if(!iscultist(user))
		return
	var/obj/item/nullrod/nrod = locate() in target
	if(nrod)
		return
	else
		if(issilicon(target))
			target.apply_damage(50, DAMAGE_BURN)
		else if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.adjust_fire_stacks(rand(1,3))
			C.IgniteMob()
		user.unEquip(src)
		qdel(src)
