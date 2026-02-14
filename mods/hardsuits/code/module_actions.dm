// buttons that appear at the top of the screen

/obj/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = 0
		return 1
	if(usr.next_move >= world.time) // Is this needed ?
		return
	if(modifiers["ctrl"])
		owner.engage()
		return 1
	owner.Trigger()
	return TRUE

/obj/screen/movable/action_button/CtrlClick(mob/living/user)
	if(istype(src, /datum/action/module_select))
		var/datum/action/module_select/A = src
		A.module.engage()
	else if(istype(src, /datum/action/module_toggle))
		var/datum/action/module_toggle/A = src
		A.module.engage()

/datum/action/proc/engage()
	return

/datum/action/module_select
	name = "Select module"
	var/obj/item/rig_module/module

/datum/action/module_select/New(Target)
	..()
	if(istype(Target, /obj/item/rig_module))
		module = Target
		name = "Select [module.interface_name]"

/datum/action/module_select/Trigger()
	if(!Checks())
		return

	if(istype(target, /obj/item/rig_module))
		module = target
		if(module.holder)
			if(module.holder.selected_module == module)
				module.holder.selected_module = null
				to_chat(owner, "<span class='bold notice'>Primary system is now: deselected.</span>")
			else
				module.holder.selected_module = module
				to_chat(owner, "<span class='bold notice'>Primary system is now: [module.interface_name].</span>")
			module.holder.update_selected_action()

/datum/action/module_select/engage()
	if(!Checks())
		return
	if(istype(target, /obj/item/rig_module))
		module = target
		if(module.holder)
			module.engage()

/datum/action/module_toggle
	name = "Toggle module"
	var/obj/item/rig_module/module

/datum/action/module_toggle/New(Target)
	..()
	if(istype(Target, /obj/item/rig_module))
		module = Target
		name = "[module.activate_string]"

/datum/action/module_toggle/Trigger()
	if(!Checks())
		return

	if(istype(target, /obj/item/rig_module))
		module = target
		if(module.holder)
			if(module.active) // activate and deactivate will update action icons
				module.deactivate()
			else if(!module.holder.offline)
				module.activate()

/datum/action/module_toggle/engage()
	if(!Checks())
		return
	if(istype(target, /obj/item/rig_module))
		module = target
		if(module.holder)
			module.engage()
