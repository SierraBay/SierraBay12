/datum/click_handler/default/aimodule/OnClick(atom/A, params)
	aiclick(A,params,user,0)

/datum/click_handler/default/aimodule/OnDblClick(atom/A, params)
	aiclick(A,params,user,1)

/datum/click_handler/default/aimodule/proc/aiclick(atom/A, params, mob/user, clicktype)
	var/obj/item/integrated_circuit/manipulation/ai/C = user.loc
	if(get_dist(A, user) <= 9)
		C.set_pin_data(IC_OUTPUT, 2, weakref(A))
		C.push_data()
		if(clicktype != 1)
			var/list/modifiers = params2list(params)
			if(modifiers["middle"])
				C.activate_pin(7)
			else if(modifiers["shift"])
				C.activate_pin(9)
			else if(modifiers["ctrl"])
				C.activate_pin(10)
			else if(modifiers["alt"])
				C.activate_pin(11)
			else
				C.activate_pin(6)
		else
			C.activate_pin(8)

/obj/item/integrated_circuit/manipulation/ai
	var/eol = "&lt;br&gt;"
	var/instruction = null
	inputs = list("Instructions" = IC_PINTYPE_STRING)
	outputs = list("AI's signature" = IC_PINTYPE_STRING, "Clicked Ref" = IC_PINTYPE_REF)
	activators = list("Upwards" = IC_PINTYPE_PULSE_OUT, "Downwards" = IC_PINTYPE_PULSE_OUT, "Left" = IC_PINTYPE_PULSE_OUT, "Right" = IC_PINTYPE_PULSE_OUT, "Push AI Name" = IC_PINTYPE_PULSE_IN,  "On click" = IC_PINTYPE_PULSE_OUT, "On middle click" = IC_PINTYPE_PULSE_OUT, "On double click" = IC_PINTYPE_PULSE_OUT, "On shift click" = IC_PINTYPE_PULSE_OUT, "On ctrl click" = IC_PINTYPE_PULSE_OUT, "On alt click" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/manipulation/ai/load_ai(mob/user, obj/item/card)
	..()
	if(controlling)
		card.forceMove(src)
		controlling.PushClickHandler(/datum/click_handler/default/aimodule)

		var/datum/integrated_io/P = inputs[1]
		if(isweakref(P.data))
			var/datum/d = P.data_as_type(/datum)
			if(d)
				instruction = "[d]"
		else
			instruction = replacetext("[P.data]", eol , "<br>")

		if(instruction)
			to_chat(controlling, instruction)
		set_pin_data(IC_OUTPUT, 1, controlling.name)

/obj/item/integrated_circuit/manipulation/ai/unload_ai()
	if(controlling)
		controlling.RemoveClickHandler(/datum/click_handler/default/aimodule)
	..()

/obj/item/integrated_circuit/manipulation/weapon_firing/proc/eject_gun(mob/user)
	if(installed_gun)
		installed_gun.dropInto(loc)
		to_chat(user, "<span class='notice'>You slide \the [installed_gun] out of the firing mechanism.</span>")
		size = initial(size)
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		installed_gun = null
		set_pin_data(IC_OUTPUT, 1, weakref(null))
		push_data()
	else
		to_chat(user, "<span class='notice'>There's no weapon to remove from the mechanism.</span>")

/obj/item/integrated_circuit/manipulation/magnetizer
	name = "floor magnet"
	desc = "Magnetize your assembly to the floor so no one can pick it up while it is active. Assembly can still be moved."

	outputs = list(
		"enabled" = IC_PINTYPE_BOOLEAN
	)
	activators = list(
		"toggle" = IC_PINTYPE_PULSE_IN,
		"on toggle" = IC_PINTYPE_PULSE_OUT
	)

	complexity = 16
	cooldown_per_use = 5 SECOND
	power_draw_per_use = 50
	power_draw_idle = 0
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MAGNETS = 4)

/obj/item/integrated_circuit/manipulation/magnetizer/do_work(ord)
	if(!isturf(assembly.loc))
		return

	if(ord == 1 && src.loc == assembly)
		assembly.magnetized = !assembly.magnetized
		power_draw_idle = assembly.magnetized ? 50 : 0

		visible_message(
			assembly.magnetized ? \
			"<span class='notice'>\The [get_object()] sticks to the floor!</span>" \
			: \
			"<span class='notice'>\The [get_object()] deactivates its magnets</span>"
		)

		set_pin_data(IC_OUTPUT, 1, assembly.magnetized)
		push_data()
		activate_pin(2)

/obj/item/integrated_circuit/manipulation/magnetizer/power_fail()
	assembly.magnetized = 0
	power_draw_idle = 0
	set_pin_data(IC_OUTPUT, 1, assembly.magnetized)

/obj/item/integrated_circuit/manipulation/magnetizer/disconnect_all()
	assembly.magnetized = 0
	power_draw_idle = 0
	set_pin_data(IC_OUTPUT, 1, assembly.magnetized)