/obj/machinery/appliance/cooker/fryer
	name = "deep fryer"
	desc = "Deep fried everything!!!"
	icon_state = "fryer_off"
	can_cook_mobs = 1
	cook_type = "deep fried"
	on_icon = "fryer_on"
	off_icon = "fryer_off"
	food_color = "#ffad33"
	can_burn_food = TRUE
	appliancetype = COOKING_APPLIANCE_FRYER
	obj_flags = OBJ_FLAG_ANCHORABLE
	active_power_usage = 12 KILOWATTS
	heating_power = 12000
	optimal_power = 1.35
	idle_power_usage = 3.6 KILOWATTS
	//Power used to maintain temperature once it's heated.
	//Going with 25% of the active power. This is a somewhat arbitrary value
	resistance = 10000	// Approx. 4 minutes.
	max_contents = 2
	starts_with = list(
		/obj/item/reagent_containers/cooking_container/fryer,
		/obj/item/reagent_containers/cooking_container/fryer
	)

	var/datum/reagents/oil
	var/optimal_oil = 9000//90 litres of cooking oil

/obj/machinery/appliance/cooker/fryer/empty
	starts_with = list()

/obj/machinery/appliance/cooker/fryer/examine(mob/user, distance)
	. = ..()
	if (distance <= 1)
		to_chat(user, "The oil gauge displays: [oil.total_volume]u/[optimal_oil].")

/obj/machinery/appliance/cooker/fryer/Initialize()
	. = ..()
	oil = new/datum/reagents(optimal_oil * 1.25, src)
	var/variance = rand()*0.15
	//Fryer is always a little below full, but its usually negligible

	if (prob(20))
		//Sometimes the fryer will start with much less than full oil, significantly impacting efficiency until filled
		variance = rand()*0.5
	oil.add_reagent(/datum/reagent/nutriment/cornoil, optimal_oil*(1 - variance))

/obj/machinery/appliance/cooker/fryer/Destroy()
	QDEL_NULL(oil)
	return ..()

/obj/machinery/appliance/cooker/fryer/update_cooking_power()
	..()//In addition to parent temperature calculation
	//Fryer efficiency also drops when oil levels arent optimal
	var/oil_level = 0
	var/datum/reagent/nutriment/cornoil/cornoil = oil.get_master_reagent()
	if (cornoil && istype(cornoil))
		oil_level = cornoil.volume

	var/oil_efficiency = 0
	if (oil_level)
		oil_efficiency = oil_level / optimal_oil

		if (oil_efficiency > 1)
			//We're above optimal, efficiency goes down as we pass too much over it
			oil_efficiency = 1 - (oil_efficiency - 1)

	cooking_power *= oil_efficiency

/obj/machinery/appliance/cooker/fryer/on_update_icon()
	..()
	ClearOverlays()
	var/list/pans = list()
	for(var/obj/item/reagent_containers/cooking_container/cooking_container in contents)
		var/image/pan_overlay
		if(cooking_container.appliancetype == COOKING_APPLIANCE_FRYER)
			pan_overlay = image('icons/obj/machines/cooking_machines.dmi', "basket[clamp(length(pans)+1, 1, 2)]")
		pan_overlay.color = cooking_container.color
		pans += pan_overlay
	if(!length(pans))
		return
	AddOverlays(pans)

//Fryer gradually infuses any cooked food with oil. Moar calories
//This causes a slow drop in oil levels, encouraging refill after extended use
/obj/machinery/appliance/cooker/fryer/do_cooking_tick(datum/cooking_item/cooking_item)
	if(..() && (cooking_item.oil < cooking_item.max_oil) && prob(20))
		var/datum/reagents/buffer = new /datum/reagents(2, GLOB.temp_reagents_holder)
		oil.trans_to_holder(buffer, min(0.5, cooking_item.max_oil - cooking_item.oil))
		cooking_item.oil += buffer.total_volume
		cooking_item.container.soak_reagent(buffer)

//To solve any odd logic problems with results having oil as part of their compiletime ingredients.
//Upon finishing a recipe the fryer will analyse any oils in the result, and replace them with our oil
//As well as capping the total to the max oil
/obj/machinery/appliance/cooker/fryer/finish_cooking(datum/cooking_item/cooking_item)
	..()
	var/total_oil = 0
	var/total_our_oil = 0
	var/total_removed = 0
	var/datum/reagent/our_oil = oil.get_master_reagent()

	for (var/obj/item/item in cooking_item.container)
		if (item.reagents && item.reagents.total_volume)
			for (var/datum/reagent/reagent in item.reagents.reagent_list)
				if (istype(reagent, /datum/reagent/nutriment/cornoil))
					total_oil += reagent.volume
					if (reagent != our_oil.type)
						total_removed += reagent.volume
						item.reagents.remove_reagent(reagent.type, reagent.volume)
					else
						total_our_oil += reagent.volume

	if (total_removed > 0 || total_oil != cooking_item.max_oil)
		total_oil = min(total_oil, cooking_item.max_oil)

		if (total_our_oil < total_oil)
			//If we have less than the combined total, then top up from our reservoir
			var/datum/reagents/buffer = new /datum/reagents(INFINITY, GLOB.temp_reagents_holder)
			oil.trans_to_holder(buffer, total_oil - total_our_oil)
			cooking_item.container.soak_reagent(buffer)
		else if (total_our_oil > total_oil)
			//If we have more than the maximum allowed then we delete some.
			//This could only happen if one of the objects spawns with the same type of oil as ours
			var/portion = 1 - (total_oil / total_our_oil) //find the percentage to remove
			for (var/thing in cooking_item.container)
				var/obj/item/item = thing
				if (item.reagents && item.reagents.total_volume)
					for (var/datum/reagent/reagent in item.reagents.reagent_list)
						if (reagent == our_oil.type)
							item.reagents.remove_reagent(reagent.type, reagent.volume * portion)
					item.temperature = T0C + 40 + rand(-5, 5) // warm, but not hot; avoiding aftereffects of the hot oil

/obj/machinery/appliance/cooker/fryer/cook_mob(mob/living/victim, mob/user)
	if(!istype(victim))
		return

	//Removed delay on this action in favour of a cooldown after it
	//If you can lure someone close to the fryer and grab them then you deserve success.
	//And a delay on this kind of niche action just ensures it never happens
	//Cooldown ensures it can't be spammed to instakill someone
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*3)

	if(!victim || !victim.Adjacent(user))
		to_chat(user, SPAN_DANGER("Your victim slipped free!"))
		return

	var/damage = rand(7,13)
	//Though this damage seems reduced, some hot oil is transferred to the victim and will burn them for a while after

	var/datum/reagent/nutriment/cornoil/cornoil = oil.get_master_reagent()
	if(istype(cornoil))
		damage *= cornoil.heatdamage(victim, temperature)

	var/obj/item/organ/external/external_organ
	var/nopain
	if(ishuman(victim) && user.zone_sel.selecting != BP_GROIN && user.zone_sel.selecting != BP_CHEST)
		var/mob/living/carbon/human/human = victim
		external_organ = human.get_organ(user.zone_sel.selecting)
		if(!external_organ || !human.can_feel_pain())
			nopain = 2
		else if(BP_IS_ROBOTIC(external_organ))
			nopain = 1

	var/part = external_organ ? "'s [external_organ.name]" : ""
	user.visible_message(SPAN_DANGER("[user] shoves [victim][part] into [src]!"))
	if (damage > 0)
		if(external_organ)

			if(LAZYLEN(external_organ.children))
				for(var/child in external_organ.children)
					var/obj/item/organ/external/child_organ = child
					if(nopain && nopain < 2 && !BP_IS_ROBOTIC(child_organ))
						nopain = 0
					child_organ.take_general_damage(damage)
					damage -= (damage*0.5)//IF someone's arm is plunged in, the hand should take most of it

			external_organ.take_general_damage(damage)
		else
			victim.apply_damage(damage, DAMAGE_BURN, user.zone_sel.selecting)

		if(!nopain)
			var/arrows_var1 = external_organ ? external_organ.name : "flesh"
			to_chat(victim, SPAN_DANGER("Agony consumes you as searing hot oil scorches your [arrows_var1] horribly!"))
			victim.emote("scream")
		else
			var/arrows_var2 = external_organ ? external_organ.name : "flesh"
			to_chat(victim, SPAN_DANGER("Searing hot oil scorches your [arrows_var2]!"))

		admin_attack_log(user, victim, "[cook_type]", "Was [cook_type]", cook_type)

	//Coat the victim in some oil
	oil.trans_to(victim, 40)

/obj/machinery/appliance/cooker/fryer/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(istype(item, /obj/item/reagent_containers/glass) && item.reagents)
		if (item.reagents.total_volume <= 0 && oil)
			//Its empty, handle scooping some hot oil out of the fryer
			oil.trans_to(item, item.reagents.maximum_volume)
			user.visible_message("[user] scoops some oil out of [src].", SPAN_NOTICE("You scoop some oil out of [src]."))
			return TRUE
	//It contains stuff, handle pouring any oil into the fryer
	//Possibly in future allow pouring non-oil reagents in, in  order to sabotage it and poison food.
	//That would really require coding some sort of filter or better replacement mechanism first
	//So for now, restrict to oil only
		var/amount = 0
		for (var/datum/reagent/reagent in item.reagents.reagent_list)
			if (istype(reagent, /datum/reagent/nutriment/cornoil))
				var/delta = oil.maximum_volume - oil.total_volume
				delta = min(delta, reagent.volume)
				oil.add_reagent(reagent, delta)
				item.reagents.remove_reagent(reagent, delta)
				amount += delta
		if (amount > 0)
			user.visible_message("[user] pours some oil into [src].", SPAN_NOTICE("You pour [amount]u of oil into [src]."), SPAN_NOTICE("You hear something viscous being poured into a metal container."))
			return TRUE
	//If neither of the above returned, then call parent as normal
	..()
