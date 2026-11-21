/*
/singleton/psionic_power/patia/coercion/mind_control
	use_intent =     I_DISARM
	name =          "Mind Control"
	cost =          28
	cooldown =      10 SECONDS
	use_ranged =    TRUE
	use_melee =     TRUE
	min_rank =      PSI_RANK_OPERANT
	use_description = "Переключитесь на синий интент, затем выберите голову и нажмите по цели чтобы ВРЕМЕННО обратить её в своего верного подчинённого."

	var/invoking = FALSE

/singleton/psionic_power/patia/coercion/mind_control/invoke(mob/living/user, mob/living/target)
	if(!istype(target))
		return FALSE

	if(user.zone_sel.selecting != BP_HEAD)
		return FALSE

	if(!can_use(user, target))
		return FALSE

	if(user == target)
		return FALSE

	if(!..())
		return FALSE

	user.visible_message("<span class='notice'><i>[user] прижимает палец к веску, старательно концентрируясь над чем-то...</i></span>")
	to_chat(user, "<span class='warning'>Вы проникаете в хрупкое сознание [target]...</span>")
	to_chat(target, "<span class='danger'>Вы ощущаете присутствие [user] в своей голове! Его настойчивые мысли и желания постепенно заражают ваш разум!</span>")

	invoking = TRUE

	var/rank = user.psi.get_rank(faculty)
	var/delay = 30 SECONDS / (rank - 2) // 30, 20, 10
	if(!do_after(user, delay, target, DO_SHOW_PROGRESS|DO_USER_SAME_HAND|DO_BOTH_CAN_TURN|DO_TARGET_CAN_MOVE))
		user.psi.backblast(rand(2,10))
		invoking = FALSE
		return TRUE

	invoking = FALSE

	if(get_dist(user, target) > world.view)
		to_chat(user, "<span class='warning'>[target] находится слишком далеко!</span>")
		return TRUE

	if(!can_use(user, target))
		return TRUE

	var/flags = rank > PSI_RANK_OPERANT ? null : MIND_CONTROL_ALLOW_SAY
	var/duration = 1 MINUTE + 2 MINUTE * (rank - 3) // 1, 3, 5

	user.set_control_mind(target, duration, flags)
	handle_mind_link(user, duration, target)

	to_chat(user, "<span class='danger'>Вы вторгаетесь в сознание [target], ощущая частичный контроль над его телом!</span>")
	to_chat(target, "<span class='danger'>Ваши стены наконец пали, и вы потеряли контроль над своим телом!</span>")

	return TRUE

/singleton/psionic_power/patia/coercion/mind_control/proc/can_use(mob/living/user, mob/living/target)
	if(invoking)
		return FALSE

	if(target.stat == UNCONSCIOUS)
		to_chat(user, "<span class='warning'>[target] находится в бессознательном состоянии!</span>")
		return FALSE

	if(target.stat == DEAD || (target.status_flags & FAKEDEATH))
		to_chat(user, "<span class='warning'>[target] мёртв!</span>")
		return FALSE

	var/datum/mind_control/mind_controller = user.mind_controller
	if(mind_controller && (target in mind_controller.affected))
		to_chat(user, "<span class='warning'>[target] уже находится под чьим-то контролем!</span>")
		return FALSE

	return TRUE

/singleton/psionic_power/patia/coercion/mind_control/proc/handle_mind_link(mob/user, duration, target)
	set waitfor = FALSE

	if(user.client)
		user.client.verbs += /client/proc/order_move

	do_after(user, duration, null, DO_SHOW_PROGRESS|DO_BOTH_CAN_TURN|DO_BOTH_CAN_MOVE)
	to_chat(user, "<span class='danger'>Разум [target] более не находится в вашем подчинении!</span>")

	var/datum/mind_control/mind_controller = user.mind_controller
	if(!mind_controller)
		mind_controller.affected -= target
		return

	if(user.client)
		user.client.verbs -= /client/proc/order_move

/client/proc/order_move(atom/A as mob|obj|turf in view())
	set name = "Mind Control: Move"
	set category = "IC"

	var/datum/mind_control/mind_controller = mob.mind_controller
	if(!mind_controller)
		verbs -= /client/proc/order_move
		return

	mind_controller.target = A
*/
