// Cooldown countdown on hardsuit module buttons. The label itself is drawn by
// mods/_master_files/code/_onclick/hud/action.dm. The 1 second lockout every module
// gets after each use is too short to be worth a label.

#define RIG_MODULE_SHORTEST_SHOWN_COOLDOWN (1 SECOND)

/obj/item/rig_module
	/// Timer that redraws the buttons every second while a long cooldown runs
	var/cooldown_display_timer

/obj/item/rig_module/engage(atom/target)
	. = ..()
	if(.)
		start_cooldown_display()

/// The shield starts its cooldown after the base deactivate() has run.
/obj/item/rig_module/personal_shield/deactivate()
	. = ..()
	if(.)
		start_cooldown_display()

/obj/item/rig_module/Destroy()
	. = ..()
	// After the parent, whose deactivate() can start a countdown
	if(cooldown_display_timer)
		deltimer(cooldown_display_timer)
		cooldown_display_timer = null

/// Starts the countdown if the cooldown that just began is long enough to show, and redraws the buttons.
/obj/item/rig_module/proc/start_cooldown_display()
	if(!cooldown_display_timer)
		if(next_use - world.time <= RIG_MODULE_SHORTEST_SHOWN_COOLDOWN)
			return
		schedule_cooldown_tick()
	redraw_action_buttons()

/obj/item/rig_module/proc/schedule_cooldown_tick()
	// The last tick lands as the cooldown ends, so the label goes away on time
	cooldown_display_timer = addtimer(new Callback(src, PROC_REF(tick_cooldown_display)), min(1 SECOND, next_use - world.time), TIMER_STOPPABLE)

/obj/item/rig_module/proc/tick_cooldown_display()
	cooldown_display_timer = null
	if(get_countdown_seconds(next_use) > 0)
		schedule_cooldown_tick()
	redraw_action_buttons()

/// Redraws this module's select and toggle buttons.
/obj/item/rig_module/proc/redraw_action_buttons()
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer)
		return
	for(var/datum/action/action as anything in wearer.actions)
		if(action.target == src)
			action.button?.UpdateIcon()

/// Seconds until the module can be used again. Hidden while a toggled module is on, since switching it off ignores the cooldown.
/obj/item/rig_module/get_action_button_label()
	if(!cooldown_display_timer || active)
		return null
	var/seconds_left = get_countdown_seconds(next_use)
	if(seconds_left > 0)
		return create_action_button_label("[seconds_left]", COLOR_WHITE)

#undef RIG_MODULE_SHORTEST_SHOWN_COOLDOWN
