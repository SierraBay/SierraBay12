//В случае если атакующий сам лежит а цель нет, то при атаке предметом атаки направленные не на ноги автоматически направляются на ноги
/obj/item/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	if(user.lying && !target.lying)
		if(!(hit_zone in list(BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG)))
			hit_zone = pick(list(BP_L_LEG, BP_R_LEG))
	.=..()
