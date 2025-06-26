/datum/antagonist/rogue_ai/finalize_spawn()
	if(!pending_antagonists)
		return

	for(var/datum/mind/player in pending_antagonists)
		pending_antagonists -= player
		add_antagonist(player,0,0,1)

	reset_antag_selection()

	empty_playable_ai_cores = 0
	log_admin("Сбойный ИИ успешно выбран и добавлен. Остальные ядра ИИ отключены.")

/*
//Rouge AI Abilities
/obj/screen/ability/verb_based/rogue_ai
	icon_state = "const_spell_base"
	background_base_state = "const"
//use this to force add powers
/obj/screen/movable/ability_master/proc/add_rogue_ai_ability(object_given, verb_given, name_given, ability_icon_given, arguments)
	if(!object_given)
		message_admins("ERROR: add_rogue_ai_ability() was not given an object in its arguments.")
	if(!verb_given)
		message_admins("ERROR: add_rogue_ai_ability() was not given a verb/proc in its arguments.")
	if(get_ability_by_PROC_REF(verb_given))
		return // Duplicate
	var/obj/screen/ability/verb_based/rogue_ai/A = new /obj/screen/ability/verb_based/rogue_ai()
	A.ability_master = src
	A.object_used = object_given
	A.verb_to_call = verb_given
	A.ability_icon_state = ability_icon_given
	A.SetName(name_given)
	if(arguments)
		A.arguments_to_use = arguments
	ability_objects.Add(A)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

// Abilities

/datum/malf_research_ability
	/// Is it an active power, or passive?
	var/isVerb = 1
	/// Path to a verb that contains the effects.
	var/verbpath
	/// Is this ability significant enough to dedicate screen space for a HUD button?
	var/make_hud_button = 1
	/// icon_state for icons for the ability HUD.  Must be in screen_spells.dmi.
	var/ability_icon_state = null

/datum/malf_research_ability/research_finished(mob/living/silicon/ai/user)
	if(!user)
		return
	if(ability)
		user.verbs.Add(ability)
	if(ability.make_hud_button && ability.isVerb)
		if(!M.current.ability_master)
			M.current.ability_master = new /obj/screen/movable/ability_master(null, M.current)
		M.current.ability_master.add_ling_ability(
			object_given = M.current,
			verb_given = ability.verbpath,
			name_given = ability.name,
			ability_icon_given = ability.ability_icon_state,
			arguments = list()
			)

/datum/game_mode/malfunction/ai_select_research()
	set category = "Hardware"
	set name = "Select Research"
	set desc = "Allows you to select your next research target."
*/
