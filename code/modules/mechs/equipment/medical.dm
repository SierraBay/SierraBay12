/obj/item/mech_equipment/sleeper
	name = "exosuit sleeper"
	desc = "An exosuit-mounted sleeper designed to mantain patients stabilized on their way to medical facilities."
	icon_state = "mech_sleeper"
	disturb_passengers = TRUE
	restricted_hardpoints = list(HARDPOINT_BACK)
	restricted_software = list(MECH_SOFTWARE_MEDICAL)
	equipment_delay = 30 //don't spam it on people pls
	active_power_use = 0 //Usage doesn't really require power. We don't want people stuck inside
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	passive_power_use = 0 //Raised to 1.5 KW when patient is present.
	var/list/apply_sounds = list('sound/effects/spray.ogg', 'sound/effects/spray2.ogg', 'sound/effects/spray3.ogg')
	var/obj/machinery/sleeper/mounted/sleeper = null
	var/obj/item/device/scanner/health/scanner = null

/obj/item/mech_equipment/sleeper/Initialize()
	. = ..()
	sleeper = new /obj/machinery/sleeper/mounted(src)
	scanner = new /obj/item/device/scanner/health(src)
	sleeper.forceMove(src)

/obj/item/mech_equipment/sleeper/Destroy()
	sleeper.go_out() //If for any reason you weren't outside already.
	QDEL_NULL(sleeper)
	. = ..()

/obj/item/mech_equipment/sleeper/uninstalled()
	. = ..()
	sleeper.go_out()

/obj/item/mech_equipment/sleeper/attack_self(mob/user)
	. = ..()
	if(.)
		sleeper.ui_interact(user)

//Альт + ЛКМ
/obj/item/mech_equipment/sleeper/AltClick(mob/user)
	if (istype(sleeper.occupant, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = sleeper.occupant
		medical_scan_action(H, user, scanner)

/obj/item/mech_equipment/sleeper/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/glass))
		sleeper.use_tool(I, user)
	else return ..()

/obj/item/mech_equipment/sleeper/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if(.)
		if(ishuman(target) && !sleeper.occupant)
			owner.visible_message(SPAN_NOTICE("\The [src] is lowered down to load [target]"))
			sleeper.go_in(target, user)
		else to_chat(user, SPAN_WARNING("You cannot load that in!"))

/obj/item/mech_equipment/sleeper/get_hardpoint_maptext()
	if(sleeper && sleeper.occupant)
		return "[sleeper.occupant]"

/obj/machinery/sleeper/mounted
	name = "mounted sleeper"
	density = FALSE
	anchored = FALSE
	idle_power_usage = 0
	var/obj/item/mech_equipment/sleeper/owner = null
	synth_modifier = 0
	stasis_power = 0
	interact_offline = TRUE
	stat_immune = MACHINE_STAT_NOPOWER
	var/list/apply_sounds = list('sound/effects/spray.ogg', 'sound/effects/spray2.ogg', 'sound/effects/spray3.ogg')
	base_chemicals = list("Inaprovaline" = /datum/reagent/inaprovaline, "Paracetamol" = /datum/reagent/paracetamol, "Dylovene" = /datum/reagent/dylovene, "Dexalin" = /datum/reagent/dexalin, "Kelotane" = /datum/reagent/kelotane, "Hyronalin" = /datum/reagent/hyronalin)

/obj/machinery/sleeper/mounted/Initialize()
	. = ..()
	owner = loc

/obj/machinery/sleeper/mounted/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.mech_state)
	. = ..()

/obj/machinery/sleeper/mounted/nano_host()
	var/obj/item/mech_equipment/sleeper/S = loc
	if(istype(S))
		return S.owner
	return null

/obj/machinery/sleeper/mounted/go_in(atom/target, mob/living/user)
	..()
	//Как только мы помещаем внутрь человка - пытаемся ему оказать мед помощь
	if(target != occupant)
		return //Анти-абуз
	to_chat(user, SPAN_NOTICE("Patient detected, initianting scanning protocol."))
	if (istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		//Цикл, проверяющий все-все части
		var/list/parts = list(BP_HEAD, BP_CHEST, BP_L_LEG, BP_L_FOOT, BP_R_LEG, BP_R_FOOT, BP_L_ARM, BP_L_HAND, BP_R_ARM,BP_R_HAND)
		for(var/part in parts)
			var/obj/item/organ/external/affecting = H.get_organ(part)
			if(affecting.is_bandaged() && affecting.is_disinfected() && affecting.is_salved())
				//nothing :}
				continue
			else
				to_chat(user, SPAN_NOTICE("Autodoc system detected damage in[affecting.name]. Autodoc manapulators ingaged."))
				if(!LAZYLEN(affecting.wounds))
					return
				owner.visible_message(SPAN_NOTICE("\The [src] extends medical autodoc manipulators towards \the [H]'s [affecting.name]."))
				var/large_wound = FALSE
				for (var/datum/wound/W as anything in affecting.wounds)
					if (W.bandaged && W.disinfected && W.salved)
						continue
					var/delay = (W.damage / 4) * owner.owner.skill_delay_mult(SKILL_MEDICAL, 0.8)
					if(!do_after(user, delay, target))
						break

					if (W.current_stage <= W.max_bleeding_stage)
						owner.visible_message(SPAN_NOTICE("Medical autodoc manipulators of [src] covers \a [W.desc] on \the [H]'s [affecting.name] with large globs of medigel."))
						large_wound = TRUE
					else if (W.damage_type == INJURY_TYPE_BRUISE)
						owner.visible_message(SPAN_NOTICE("Medical autodoc manipulators of [src] sprays \a [W.desc] on \the [H]'s [affecting.name] with a fine layer of medigel."))
					else
						owner.visible_message(SPAN_NOTICE("Medical autodoc manipulators of [src] drizzles some medigel over \a [W.desc] on \the [H]'s [affecting.name]."))
					playsound(owner, pick(apply_sounds), 20)
					W.bandage()
					W.disinfect()
					W.salve()
					if (H.stat == UNCONSCIOUS && prob(25))
						to_chat(H, SPAN_NOTICE(SPAN_BOLD("... [pick("feels better", "hurts less")] ...")))
				if(large_wound)
					owner.visible_message(SPAN_NOTICE("\The [src]'s UV autodoc matrix glows faintly as it cures the medigel."))
					playsound(owner, 'sound/items/Welder2.ogg', 10)
				affecting.update_damages()
				H.update_bandages(TRUE)
	//
	var/obj/item/mech_equipment/sleeper/S = loc
	if(istype(S) && occupant)
		S.passive_power_use = 1.5 KILOWATTS

/obj/machinery/sleeper/mounted/go_out()
	..()
	var/obj/item/mech_equipment/sleeper/S = loc
	if(istype(S))
		S.passive_power_use = 0 //No passive power drain when the sleeper is empty. Set to 1.5 KW when patient is inside.

//You cannot modify these, it'd probably end with something in nullspace. In any case basic meds are plenty for an ambulance
/obj/machinery/sleeper/mounted/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(istype(I, /obj/item/reagent_containers/glass))
		if(!user.unEquip(I, src))
			return TRUE

		if(beaker)
			beaker.forceMove(get_turf(src))
			user.visible_message(SPAN_NOTICE("\The [user] removes \the [beaker] from \the [src]."), SPAN_NOTICE("You remove \the [beaker] from \the [src]."))
		beaker = I
		user.visible_message(SPAN_NOTICE("\The [user] adds \a [I] to \the [src]."), SPAN_NOTICE("You add \a [I] to \the [src]."))
		return TRUE

	return ..()
