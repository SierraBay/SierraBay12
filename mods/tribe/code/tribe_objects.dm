/obj/machinery/artifact/mod_tribe/New()
	..()
	my_effect = new /datum/artifact_effect/heal(src)
	my_effect.trigger = new /datum/artifact_trigger/touch

	secondary_effect = new /datum/artifact_effect/heal(src)
	secondary_effect.effect = EFFECT_AURA
	secondary_effect.trigger = new /datum/artifact_trigger/force

	setup_destructibility()

/obj/machinery/artifact/mod_tribe/attack_hand(mob/living/user)
	//spam clicks are meaningless here, since it follows effect timeouts
	//basically a 5% chance at 5-20 seconds interval
	if(prob(5) && my_effect.activated == FALSE && user && user.stat != DEAD && get_current_health() > 0)
		user.rejuvenate()
		new/obj/effect/smoke/illumination(src.loc, 5, range=30, power=1, color="#ffffff")
		playsound(get_turf(src),'sound/magic/staff_healing.ogg',50,1)
		to_chat(user, SPAN_NOTICE("Upon contact with \the [src], a brilliant light radiates from it, and you are filled with an overwhelming sense of vitality."))
		visible_message(SPAN_NOTICE("\The [src] brightens up momentarily."))
	..()

/obj/machinery/crystal/mod_tribe
	var/default_light_power = 0.8
	var/default_light_range = 5
	var/default_light_color = "#008000"

/obj/machinery/crystal/mod_tribe/New()
	..()

	if(icon_state == "crystal2")
		default_light_color = "#ffa500"
	else if(icon_state == "crystal3")
		default_light_color = "#ffc0cb"

	set_light(default_light_range, default_light_power, default_light_color)

/obj/machinery/replicator/mod_tribe/New()
	set_stat_immunity(MACHINE_STAT_NOPOWER, TRUE)
	..()

/obj/machinery/acting/changer/mod_tribe
	name = "Totem of change"
	icon = 'icons/obj/xenoarchaeology_finds.dmi'
	icon_state = "ano51"
	anchored = FALSE

/obj/machinery/acting/changer/mod_tribe/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user) || user.species.name != SPECIES_ALIEN)
		to_chat(user, "Nothing happens.")

	var/mob/living/carbon/human/H = user
	H.change_appearance(APPEARANCE_BASIC, state = GLOB.z_state)
	var/getName = sanitize(input(H, "Would you like to change your name to something else?", "Name change") as null|text, MAX_NAME_LEN)
	if(getName)
		H.real_name = getName
		H.SetName(getName)
		H.dna.real_name = getName
		if(H.mind)
			H.mind.name = H.name

/obj/item/material/twohanded/spear/mod_tribe
	default_material = MATERIAL_STEEL

/obj/item/stack/material/generic/bone/mod_tribe
	default_type = MATERIAL_BONE_GENERIC
	amount = 50

/obj/item/stack/material/generic/skin/mod_tribe
	default_type = MATERIAL_SKIN_GENERIC
	amount = 50

/obj/item/reagent_containers/glass/bottle/mod_tribe
	name = "\improper Fertilizer bottle"
	desc = "A small bottle."
	preset_reagent = /datum/reagent/toxin/fertilizer/potash