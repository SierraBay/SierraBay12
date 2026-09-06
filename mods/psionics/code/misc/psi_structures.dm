/obj/psi_plane/psinomaly
	name = "Psionic breach"
	desc = "Breach in fabric of reality itself, leading to realm on infinite possibilities and dangers."
	icon = 'mods/psionics/icons/effects/psi_effects.dmi'
	icon_state = "reality_smash"

	blend_mode = BLEND_ADD

	layer = ABOVE_HUMAN_LAYER
	density = TRUE
	anchored = TRUE
	var/charged = TRUE
	var/aura_color = COLOR_CIVIE_GREEN

	invisibility = INVISIBILITY_PSI_PLANE


/obj/psi_plane/psinomaly/Initialize()
	. = ..()

	update_icon()

/obj/psi_plane/psinomaly/on_update_icon()
	ClearOverlays()
	if(charged)
		var/image/I = image(icon, "plane_glow")
		I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
		I.color = aura_color
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		AddOverlays(I)
		set_light(2, 0.3, l_color = I.color)

/obj/psi_plane/psinomaly/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()

/obj/psi_plane/psinomaly/use_weapon(obj/item/weapon, mob/living/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	if (istype(weapon, /obj/item/nullrod))
		playsound(src, 'sound/effects/psi/power_feedback.ogg', 100, 1)
		new /obj/temporary(get_turf(src),3, 'icons/effects/effects.dmi', "purple_electricity_constant")
		qdel(src)
		return TRUE
	else
		return TRUE

/obj/psi_plane/psinomaly/bullet_act(obj/item/projectile/P)
	if (istype(P) && P.disrupts_psionics())
		playsound(src, 'sound/effects/psi/power_feedback.ogg', 100, 1)
		new /obj/temporary(get_turf(src),3, 'icons/effects/effects.dmi', "purple_electricity_constant")
		qdel(src)
		return FALSE
	else
		return FALSE

// Базовый тип аномалии - вызывает при активации глобальный мини-ивент

/obj/psi_plane/psinomaly/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				to_chat(H, SPAN_WARNING("After you interacted with anomaly it started to fade away!"))
				if(prob(50))
					var/datum/event_meta/EM = new(EVENT_LEVEL_MUNDANE, "Psionic anomaly - Balm", add_to_queue = 0)
					new/datum/event/psi/balm(EM)
					to_chat(H, SPAN_NOTICE("You feel invigorated with energies of anomaly"))
				else
					var/datum/event_meta/EM = new(EVENT_LEVEL_MUNDANE, "Psionic anomaly - Wail", add_to_queue = 0)
					new/datum/event/psi/wail(EM)
					to_chat(H, SPAN_WARNING("You have a bad feeling about this..."))
				return
			else
				to_chat(H, SPAN_DANGER("A wave of uncontrolled energy emerges from the [src], and your vision flickers!"))
				H.psi.backblast(rand(5,15))
				H.Paralyse(5)
				H.make_jittery(100)
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

// Подтипы аномалий разных вкусов и цветов, ассоциированы со школами псионики

// Принуждение. При провале - будто блайндстрайком по лицу

/obj/psi_plane/psinomaly/coercion
	aura_color = "#3333cc"

/obj/psi_plane/psinomaly/coercion/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				H.psi.check_latency_trigger(100, "a psionic plane breach", redactive = TRUE)
				to_chat(H, SPAN_WARNING("You feel like something inside your head try to reach for the anomaly!"))
				update_icon()
			else
				to_chat(H, SPAN_DANGER("A wave of uncontrolled energy emerges from the [src]!"))
				H.eye_blind = max(H.eye_blind,4)
				H.ear_deaf = max(H.ear_deaf,4 * 2)
				H.mod_confused(4 * rand(1,3))
				charged = FALSE
				update_icon()
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

// Психокинетика. Полёт, если провал, то отлетаем в рандомное направление

/obj/psi_plane/psinomaly/psychokinesis
	aura_color = "#cc3333"

/obj/psi_plane/psinomaly/psychokinesis/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				H.levitation = TRUE
				H.pass_flags |= PASS_FLAG_TABLE
				H.pixel_y = 8
				H.AddOverlays(image('mods/psionics/icons/psi.dmi', "levitation"))
				H.make_floating(5)
				to_chat(H, SPAN_WARNING("You feel like flying, but you have no idea how to stop it!"))
				update_icon()
			else
				to_chat(H, SPAN_DANGER("Suddenly, [src] emits a powerful gravitational blast!"))
				H.throw_at_random(FALSE, 4, 3)
				charged = FALSE
				update_icon()
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

// Редакция. Хил, немного от генокрада. При провале - мутируем руку

/obj/psi_plane/psinomaly/redaction
	aura_color = "#33cc33"

/obj/psi_plane/psinomaly/redaction/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				H.adjustBruteLoss(-rand(5,15))
				H.adjustOxyLoss(-rand(5,15))
				H.adjustFireLoss(-rand(5,15))
				H.regenerate_icons()
				to_chat(H, SPAN_GOOD("You feel invigorated with energies of anomaly"))
			else
				var/obj/item/organ/external/E = H.get_organ(H.hand ? BP_L_HAND : BP_R_HAND)
				to_chat(H, SPAN_DANGER("A wave of uncontrolled energy emerges from the [src], and ruches into your arm!"))
				charged = FALSE
				update_icon()
				E.mutate()
				H.Paralyse(5)
				H.make_jittery(100)
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

// Энергии. Триггер латентностей, в случае провала - ЭМИ и разрядка аномалии

/obj/psi_plane/psinomaly/energistics
	aura_color = "#cc8221"

/obj/psi_plane/psinomaly/energistics/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_unlock.ogg', 100, 1)
				charged = FALSE
				update_icon()
				H.psi.max_stamina = 120
				H.psi.stamina = H.psi.max_stamina
				new /obj/temporary(get_turf(user),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
				to_chat(H, SPAN_GOOD("You feel like a second wind opened up!"))
			else
				to_chat(H, SPAN_DANGER("A wave of uncontrolled energy emerges from the [src]!"))
				new /obj/temporary(get_turf(user),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
				empulse(user, 6, 8)
				charged = FALSE
				update_icon()
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

//

/obj/psi_plane/psinomaly/consciousness
	aura_color = "#5233cc"

/obj/psi_plane/psinomaly/consciousness/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				to_chat(H, SPAN_WARNING("You feel like shards of something beyond your reach try to get inside your head!"))
				if(H.species.name in HUMAN_SPECIES)
					H.set_psi_rank(pick(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS, PSI_CONSCIOUSNESS, PSI_MANIFESTATION, PSI_METAKINESIS), 1, defer_update = TRUE)
				if(H.species.name == SPECIES_TAJARA)
					H.set_psi_rank(pick(PSI_COERCION, PSI_SHAYMANISM, PSI_METAKINESIS), 1, defer_update = TRUE)
			else
				to_chat(H, SPAN_DANGER("Suddenly, something meterialize around [src]!"))
				charged = FALSE
				update_icon()
				var/list/places_to_spawn = list()
				for(var/turf/T in orange(1, src))
					if(T.density) continue
					if(locate(/obj/structure/wall_frame) in T) continue
					places_to_spawn.Add(T)
				if(!LAZYLEN(places_to_spawn))
					places_to_spawn.Add(get_turf(src))
				for(var/i = 1 to 3)
					var/turf/spawn_loc = pick(places_to_spawn)
					new /mob/living/simple_animal/hostile/bluespace/doppelganger(spawn_loc)
					if(LAZYLEN(places_to_spawn) > 1)
						places_to_spawn -= spawn_loc
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

// Добавление латентностей. В случае провала - поджигаем

/obj/psi_plane/psinomaly/metakinesis
	aura_color = "#cccc33"

/obj/psi_plane/psinomaly/metakinesis/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				// Честно упёрто у /datum/artifact_effect/cellcharge
				var/last_message
				var/turf/T = get_turf(src)
				for (var/obj/machinery/power/apc/C in range(200, T))
					for (var/obj/item/cell/B in C.contents)
						B.charge += 25
				for (var/obj/machinery/power/smes/S in range(10, T))
					S.charge += 25
				for (var/mob/living/silicon/robot/M in range(50, T))
					for (var/obj/item/cell/D in M.contents)
						D.charge += 25
						if(world.time - last_message > 200)
							to_chat(M, SPAN_WARNING("SYSTEM ALERT: Energy boost detected!"))
							last_message = world.time
				to_chat(H, SPAN_DANGER("You feel like energy spreads from [src] to nearby machinery!"))
			else
				to_chat(H, SPAN_DANGER("An elementary backlash emerges from [src]!"))
				charged = FALSE
				update_icon()
				if(prob(33))
					H.IgniteMob()
				if(prob(33))
					H.electrocute_act(rand(15,35), src, def_zone = H.hand ? BP_L_HAND : BP_R_HAND)
				else
					var/datum/gas_mixture/env = src.loc.return_air()
					if(env)
						env.temperature = max(env.temperature - rand(5,50), 0)
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))

// Манифестация всякой шелухи

/obj/psi_plane/psinomaly/manifestation
	aura_color = "#cc8221"

/obj/psi_plane/psinomaly/manifestation/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	var/mob/living/carbon/human/H = user
	if(H.psi && !H.psi.suppressed)
		if(charged)
			user.visible_message(SPAN_WARNING("\The [user] concentrates and extends his hand forward"), SPAN_WARNING("You begin to carefully collect energy from the anomaly."), "You feel unplesant wave of cold.")
			if(do_after(user, 6 SECONDS, src, DO_PUBLIC_UNIQUE))
				playsound(src, 'sound/effects/psi/power_used.ogg', 100, 1)
				charged = FALSE
				update_icon()
				to_chat(H, SPAN_WARNING("You feel like shards of other's identity materializes in youh hand!"))
				new /obj/item/device/soulstone(H.get_active_hand())
			else
				to_chat(H, SPAN_DANGER("[src] emits sickening cracks and shatters like thousands of metal pieces!"))
				playsound(src, 'sound/effects/psi/power_fabrication.ogg', 100, 1)
				charged = FALSE
				update_icon()
				var/list/places_to_spawn = list()
				for(var/turf/T in orange(3, src))
					if(T.density) continue
					if(locate(/obj/structure/wall_frame) in T) continue
					places_to_spawn.Add(T)
				if(!LAZYLEN(places_to_spawn))
					places_to_spawn.Add(get_turf(src))
				for(var/i = 1 to 16)
					var/turf/spawn_loc = pick(places_to_spawn)
					new /obj/item/material/shard/caltrop(spawn_loc)
					if(LAZYLEN(places_to_spawn) > 1)
						places_to_spawn -= spawn_loc
		else
			if(charged)
				to_chat(user, SPAN_NOTICE("You touch [src], but it faded and does not react to you, leaving only a feeling of loss in your chest and cold in your hand..."))
	else
		to_chat(user, SPAN_NOTICE("You touch [src], but it doesn't react to you in any way, as if you don't exist for it."))
