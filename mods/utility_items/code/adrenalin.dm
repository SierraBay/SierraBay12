// Рывок импланта: сколько длится, во сколько раз короче шаг и до скольких единиц доливаются
// уже переваренные опиаты в начале и в конце рывка.
#define ADRENALIN_BURST_DURATION (10 SECONDS)
#define ADRENALIN_BURST_MOVE_DELAY_MULT 0.5
#define ADRENALIN_OPIATE_DOSE 30
// Флаги `status_flags`, которые рывок снимает: пока их нет, Stun/Weaken/Paralyse ничего не делают.
#define ADRENALIN_BURST_STATUS_FLAGS (CANSTUN | CANWEAKEN | CANPARALYSE)

/obj/item/implant/adrenalin
	action_button_name = "Adrenaline Surge"
	default_action_type = /datum/action/item_action/adrenalin_implant
	var/activation_emote
	var/imp_reagents = list(/datum/reagent/adrenaline = 5)

/obj/item/implant/adrenalin/New()
	uses = rand(1, 5)
	..()
	return

/obj/item/implant/adrenalin/implanted(mob/living/carbon/source)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_v", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "slowclap", "smile", "pale", "sniff", "whimper", "wink")
	source.StoreMemory("Adrenaline implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate, or with its action button, even while unconscious.", /singleton/memory_options/system)
	to_chat(source, "The implanted adrenaline implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate, or with its action button, even while unconscious.")
	return TRUE

/obj/item/implant/adrenalin/trigger(emote, mob/source)
	if (emote == src.activation_emote)
		activate()

/obj/item/implant/adrenalin/ui_action_click(mob/living/user)
	activate()

/obj/item/implant/adrenalin/activate()
	var/mob/living/carbon/human/host = imp_in
	if (uses < 1 || malfunction || !istype(host))
		return FALSE
	uses--
	to_chat(host, SPAN_NOTICE("You feel a sudden surge of energy!"))
	for(var/reagent in src.imp_reagents)
		var/amount = imp_reagents[reagent]
		host.reagents.add_reagent(reagent, amount)
	host.start_adrenalin_burst()
	host.update_action_buttons()
	return TRUE


/*
	Кнопка импланта. Её выдаёт и забирает `handle_actions()` каждый тик Life: имплант лежит в
	содержимом моба, а `CheckRemoval()` у `item_action` убирает кнопку, когда имплант вынут.
	Проверок нет: смысл кнопки — нажать её без сознания, в стане или лёжа.
*/
/datum/action/item_action/adrenalin_implant
	check_flags = 0

/datum/action/item_action/adrenalin_implant/IsAvailable()
	var/obj/item/implant/adrenalin/implant = target
	return ..() && implant.uses > 0 && !implant.malfunction

// Число зарядов в правом нижнем углу кнопки. `update_action_buttons()` зовёт это при каждой
// перерисовке, и кнопка к этому времени уже есть — другой точки, где она всегда есть, нет.
/datum/action/item_action/adrenalin_implant/UpdateName()
	var/obj/item/implant/adrenalin/implant = target
	if(button)
		button.maptext_width = 28
		button.maptext_height = 10
		button.maptext_y = 2
		button.maptext = SPAN_STYLE("text-align: right", STYLE_SMALLFONTS_OUTLINE("[implant.uses]", 7, "#ffffff", "#000000"))
	return ..()


/mob/living/carbon/human
	/// `world.time`, до которого идёт рывок импланта адреналина; 0 — рывка нет.
	var/adrenalin_burst_until = 0
	/// Биты `ADRENALIN_BURST_STATUS_FLAGS`, которые рывок снял и вернёт, когда кончится.
	var/adrenalin_burst_cleared_flags = 0

/*
	Рывок: приводит в себя и на `ADRENALIN_BURST_DURATION` не даёт снова свалить — снимает флаги
	стана, отключки и сбивания с ног, — не даёт замешательству уводить шаги, а шаг идёт так, будто
	тело цело, и вдвое короче (`movement_delay()` ниже). Боль глушат опиаты, долитые сразу в
	переваренные, и после рывка их снова `ADRENALIN_OPIATE_DOSE`. Повторный рывок продлевает
	текущий. Таймер висит на мобе, а не на импланте: вынутый посреди рывка имплант не оставит
	неуязвимость к стану навсегда. Сон флагами не закрыт — снотворное и SSD продолжают работать.
*/
/mob/living/carbon/human/proc/start_adrenalin_burst()
	// Set-процедуры смотрят на те же флаги, поэтому сбрасываем до того, как флаги снять.
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	SetSleeping(0)
	shock_stage = 0
	adjust_stamina(100)
	// Сознание Life вернёт только на следующем тике, а при боли не ниже `total_health` у лежащего
	// без сознания — ещё на тик позже: боль снимут опиаты, но их подсчитают после проверки.
	if(stat == UNCONSCIOUS)
		set_stat(CONSCIOUS)
		UpdateLyingBuckledAndVerbStatus()
	adrenalin_burst_cleared_flags |= status_flags & ADRENALIN_BURST_STATUS_FLAGS
	status_flags &= ~ADRENALIN_BURST_STATUS_FLAGS
	adrenalin_burst_until = world.time + ADRENALIN_BURST_DURATION
	top_up_adrenalin_opiates()
	addtimer(new Callback(src, PROC_REF(end_adrenalin_burst)), ADRENALIN_BURST_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/carbon/human/proc/end_adrenalin_burst()
	status_flags |= adrenalin_burst_cleared_flags
	adrenalin_burst_cleared_flags = 0
	adrenalin_burst_until = 0
	top_up_adrenalin_opiates()
	to_chat(src, SPAN_WARNING("The adrenaline rush fades."))

/// Доливает переваренные опиаты до `ADRENALIN_OPIATE_DOSE`; больше уже есть — не трогает.
/mob/living/carbon/human/proc/top_up_adrenalin_opiates()
	var/missing = ADRENALIN_OPIATE_DOSE - metabolized.get_reagent_amount(/datum/reagent/opiate)
	if(missing > 0)
		metabolized.add_reagent(/datum/reagent/opiate, missing)

/mob/living/carbon/human/proc/is_in_adrenalin_burst()
	return world.time < adrenalin_burst_until

// Замешательство не уводит шаги, не роняет о стену и не мешает в захвате, пока идёт рывок. Само
// `confused` тикает дальше и после рывка снова действует, если не сошло.
/mob/living/carbon/human/is_confused(threshhold = 1)
	if(is_in_adrenalin_burst())
		return FALSE
	return ..()

/*
	Ноги подводят только после рывка. Без этого при `stance_damage` от 4 (сломанные или разбитые
	ноги) `handle_stance()` каждый тик Life кричит, пишет «collapses!» и зовёт `Weaken()`: рывок
	его гасит, носитель остаётся стоять, и всё повторяется. `stance_damage` в рывке не
	пересчитывается — шаг его всё равно вычитает (`get_body_state_movement_delay()`).
*/
/mob/living/carbon/human/handle_stance()
	if(is_in_adrenalin_burst())
		return
	return ..()

// Кор `human/Weaken()` играет звук падения раньше, чем `mob/Weaken()` смотрит на `CANWEAKEN`:
// в рывке дубинка, тазер и прочее иначе стучали бы телом об пол у стоящего.
/mob/living/carbon/human/Weaken(amount)
	if(is_in_adrenalin_burst())
		return
	return ..()

/*
	Шаг в рывке: из задержки вычитается то, что даёт состояние тела, и остаток делится надвое.
	Снаряжение, груз, местность, намерение шага, прицеливание и нехватка ног остаются. Пол —
	половина задержки намерения шага: Sandevistan (мод RnD) собирается раньше и множит задержку
	до этого оверрайда, и вычитание полной слагаемой из уменьшенной задержки иначе дало бы ноль.
*/
/mob/living/carbon/human/movement_delay(singleton/move_intent/using_intent = move_intent)
	. = ..()
	if(!is_in_adrenalin_burst() || (mRun in mutations))
		return
	if(ispath(using_intent))
		using_intent = GET_SINGLETON(using_intent)
	. = max(. - get_body_state_movement_delay(), using_intent.move_delay * 0.5) * ADRENALIN_BURST_MOVE_DELAY_MULT

/**
 * Часть `movement_delay()` от состояния тела: сонливость, ползком в замешательстве, химия, раны,
 * боль, повреждённые и сломанные ноги, шаткая стойка, усталость, шок и остановка сердца.
 * Повторяет слагаемые кор `/mob/movement_delay()` и `/mob/living/carbon/human/movement_delay()` —
 * поменялись там, поменять и здесь. Отсутствующая нога или культя
 * не вычитается — ни в шаге, ни в стойке: рывок её не вернёт.
 */
/mob/living/carbon/human/proc/get_body_state_movement_delay()
	. = 0
	if(drowsyness > 0)
		. += 6
	if(lying)
		. += confused * 2
	if(CE_SLOWDOWN in chem_effects)
		. += chem_effects[CE_SLOWDOWN]
	var/health_deficiency = maxHealth - health
	if(health_deficiency >= 40)
		. += health_deficiency / 25
	if(can_feel_pain() && get_shock() >= 10)
		. += get_shock() / 10
	// `handle_stance()` даёт по 2 за каждую отсутствующую ногу или стопу — эту часть стойки оставляем.
	var/missing_legs = 0
	for(var/organ_name in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
		var/obj/item/organ/external/leg = get_organ(organ_name)
		if(!leg || leg.is_stump())
			missing_legs++
		else if(!istype(buckled, /obj/structure/bed/chair/wheelchair))
			. += leg.movement_delay(4)
	if(shock_stage >= 10 || get_stamina() <= 0)
		. += 3
	if(is_asystole())
		. += 10
	. += 2 * max(stance_damage - 2 * missing_legs, 0)


/datum/uplink_item/item/implants/imp_adrenalin
	name = "Adrenaline Implant"
	desc = "An implant with an emotive trigger and an action button that works even while unconscious. For ten seconds it shrugs off stuns, confusion and wounds, doubles your speed and leaves you full of painkillers."
	item_cost = 36
	path = /obj/item/storage/box/syndie_kit/imp_adrenalin

/obj/item/storage/box/syndie_kit/imp_adrenalin
	startswith = list(/obj/item/implanter/adrenalin)

#undef ADRENALIN_BURST_DURATION
#undef ADRENALIN_BURST_MOVE_DELAY_MULT
#undef ADRENALIN_OPIATE_DOSE
#undef ADRENALIN_BURST_STATUS_FLAGS
