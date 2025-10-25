GLOBAL_LIST_EMPTY(available_ai_shells)


/mob/living/silicon/robot
	var/shell = FALSE
	var/mob/living/silicon/ai/shell_link = null

/obj/item/aicard/grab_ai(mob/living/silicon/ai/ai, mob/living/user)
	if(ai.Controlling && istype(ai.Controlling, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = ai.Controlling
		R.dropAiBack()
	..()

/obj/structure/AIcore/deactivated/use_tool(obj/item/tool, mob/user, list/click_params)
	// AI Card - Load AI
	if (istype(tool, /obj/item/aicard))
		var/mob/living/silicon/ai/ai = locate() in tool
		if(ai.Controlling && istype(ai.Controlling, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = ai.Controlling
			R.dropAiBack()
	..()

/obj/item/robot_parts/robot_suit/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/device/mmi/digital/robot/ai/boris))
		var/obj/item/device/mmi/digital/robot/ai/boris/ai_mmi = W

		if(!istype(loc,/turf))
			to_chat(user, SPAN_WARNING("You can't put \the [W] in without the frame being on the ground."))
			return TRUE

		if(!check_completion())
			to_chat(user, SPAN_WARNING("The frame is not ready for the central processor to be installed."))
			return TRUE

		var/mob/living/carbon/brain/B
		if(istype(W, /obj/item/device/mmi))
			var/obj/item/device/mmi/M = W
			B = M.brainmob
		else
			var/obj/item/organ/internal/posibrain/P = W
			B = P.brainmob

		if(B.is_dead())
			to_chat(user, SPAN_WARNING("Sticking a dead [W.name] into the frame would sort of defeat the purpose."))
			return TRUE

		if(!user.unEquip(W))
			FEEDBACK_UNEQUIP_FAILURE(user, W)
			return TRUE
		var/mob/living/silicon/robot/O = new product(get_turf(loc))
		if(!O)
			return TRUE

		O.mmi = W
		O.set_invisibility(0)
		O.custom_name = created_name
		O.updatename("Default")
		O.faction = user.faction
		if(O.mind)
			O.mind.faction = user.faction

			if(O.mind.assigned_role)
				O.job = O.mind.assigned_role
			else
				O.job = "Robot"

		var/obj/item/robot_parts/chest/chest = parts[BP_CHEST]
		if (chest && chest.cell)
			chest.cell.forceMove(O)
		W.forceMove(O) //Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.

		// Since we "magically" installed a cell, we also have to update the correct component.
		if(O.cell)
			var/datum/robot_component/cell_component = O.components["power cell"]
			cell_component.wrapped = O.cell
			cell_component.installed = 1
		callHook("borgify", list(O))
		O.Namepick()

		O.shell = TRUE
		O.registerShell()
		O.shell_link = ai_mmi.connected_ai

		if(O.shell_link)
			O.connect_to_ai(O.shell_link)

		qdel(src)
		return TRUE

	..()

/mob/living/silicon/robot/proc/dropAiBack()
	if(shell && AiHolder && AiHolder.MyAI)
		to_chat(src, SPAN_BAD("Connection lost."))
		mind?.transfer_to(AiHolder.MyAI)
		AiHolder.MyAI = null
		src?.onReturnAi2Core()

/mob/living/silicon/robot/Destroy()
	if(shell)
		dropAiBack()
		unregisterShell()
	..()

/mob/living/silicon/robot/death()
	if(shell)
		dropAiBack()
	..()

/mob/living/silicon/ai/death()
	if(Controlling && istype(Controlling, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = Controlling
		if(R.ckey)
			ckey = R.ckey
		R.dropAiBack()
	..()

/mob/proc/ExitMobHolder()
	set name = "Return to core"
	//set category = "Silicon Commands"
	set category = "Software"

	mind?.transfer_to(AiHolder.MyAI)
	AiHolder.MyAI = null
	src?.onReturnAi2Core()

/mob/proc/registerShell()
	GLOB.available_ai_shells |= src

/mob/proc/unregisterShell()
	GLOB.available_ai_shells -= src

/mob/living/silicon/robot/AiControl(mob/living/silicon/ai/ai)
	if(!istype(ai)) return
	if(!AiHolder) return
	if(!AiHolder.MyAI) switch(alert(ai, "Are you sure that you want to deploy yourself into this body?", name, "Yes", "No"))
		if("Yes")
			assume_AI_control(ai)
	else
		to_chat(ai, "[src] already occupied by another AI.")

/mob/living/silicon/robot/assume_AI_control(mob/living/silicon/ai/ai)
	if(!AiHolder)
		AIHOLDERINIT
	connect_to_ai(ai)
	to_chat(ai, SPAN_GOOD("Connection estabilished. Return to core command is now available."))
	ai.mind?.transfer_to(AiHolder.holder)
	AiHolder.MyAI = ai
	ai.Controlling = src
	verbs |= /mob/proc/ExitMobHolder

/obj/item/device/mmi/digital/robot/ai/boris
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon = 'mods/ai/icons/boris.dmi'
	icon_state = "boris"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 3, TECH_DATA = 5, TECH_BLUESPACE = 4)

	var/mob/living/silicon/ai/connected_ai = null

/obj/item/device/mmi/digital/robot/ai/boris/attack_self()
	var/mob/M = usr

	var/additional_text = ""

	if(connected_ai)
		additional_text = " This board is currently linked to [connected_ai.name]."

	var/list/ais = active_ais(z)
	var/mob/living/silicon/current

	ais += "No restrictions"
	if(length(ais))
		if(M?.client)

			var/choice = input(M,"Allow this board only for the specific AI.[additional_text]", "AI selection") as null|anything in ais

			current = choice

			if(current || choice == "No restrictions")
				if (!M.IsHolding(src))
					to_chat(usr, SPAN_WARNING("You need to keep the item in your hands."))
					return

				if(choice == "No restrictions")
					to_chat(M, "Restriction dropped.")
					connected_ai = null
				else
					to_chat(M, "[current.name] is linked to this board.")
					connected_ai = current
	else
		to_chat(M, "No active AIs detected.")

/mob/living/silicon/robot/attack_ai(mob/living/silicon/ai/ai)
	if(shell)
		if(!istype(ai))
			return
		if(ai.control_disabled)
			to_chat(ai, SPAN_WARNING("Wireless networking module is offline."))
			return
		if(stat == DEAD)
			to_chat(ai, SPAN_BAD("No response recieved."))
			return
		if(shell_link && shell_link != ai)
			to_chat(ai, SPAN_BAD("Access denied."))
			return

		if(!AiHolder)
			AIHOLDERINIT
		if(!AiHolder?.MyAI) AiControl(ai)
		. = ..()

/mob/living/silicon/ai/verb/deploy_to_shell()
	set category = "Software"
	set name = "Deploy to Shell"

	var/mob/living/silicon/robot/target

	if(usr.incapacitated())
		return
	if(control_disabled)
		to_chat(src, SPAN_WARNING("Wireless networking module is offline."))
		return

	var/list/possible = list()

	for(var/borg in GLOB.available_ai_shells)
		var/mob/living/silicon/robot/R = borg
		if(R.shell && (R.stat != DEAD) && (!R.shell_link || (R.shell_link == src)))
			possible += R

	if(!LAZYLEN(possible))
		to_chat(src, "No usable AI shell beacons detected.")
		return

	if(!target || !(target in possible)) //If the AI is looking for a new shell, or its pre-selected shell is no longer valid
		target = input(src, "Which body to control?", "Direct Control") as null|anything in possible

	if(isnull(target))
		return
	if (target.stat == DEAD || !(!target.shell_link || (target.shell_link == src)))
		return

	if(mind)
		target.attack_ai(src)

/datum/design/item/synthstorage/boris
	name = "B.O.R.I.S. module"
	id = "boris"
	req_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 3, TECH_DATA = 5, TECH_BLUESPACE = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 1000, MATERIAL_GOLD = 500, MATERIAL_PHORON = 1000, MATERIAL_DIAMOND = 500)
	build_path = /obj/item/device/mmi/digital/robot/ai/boris
	category = "Misc"
	sort_string = "VACAC"

/datum/technology/robo/ai/New()
	..()
	unlocks_designs |= "boris"