/mob/living/carbon/human
	var/venom_cooldown = 0

/mob/living/carbon/human/unathi/yeosa/proc/decant_venom()
	set category = "Abilities"
	set name = "Decant Venom"
	set desc = ""
	var/obj/item/target = usr.get_active_hand()
	var/poison_type = /datum/reagent/toxin/yeosvenom


	if(venom_cooldown > world.time)
		to_chat(usr, SPAN_WARNING("Your venom glands are too exhausted, it will take some time before you can decant your innate venom again."))
		return
	if(istype(target, /obj/item/reagent_containers))
		if(target.reagents)
			target.reagents.add_reagent(poison_type, 8)
			src.adjust_nutrition(-25)
			src.adjust_hydration(-15)
			usr.visible_message(
			SPAN_NOTICE("\The [usr] sticks their fangs into the side of the [target], dripping thick, green-ish substance into the container."),
			SPAN_NOTICE("You stick your fangs into the side of the \the [target], allowing some of your innate venom to drip into the container.")
			)
			venom_cooldown = world.time + (30 SECONDS)
