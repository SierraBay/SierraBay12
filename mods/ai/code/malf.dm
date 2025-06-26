// Parameters: None
// Description: Allows AI to select it's next research priority.

/mob/living/silicon/ai/proc/ai_select_research()

	set category = "Hardware"
	set name = "Select Research"
	set desc = "Allows you to select your next research target."
	var/mob/living/silicon/ai/user = usr

	if(!ability_prechecks(user, 0, 1))
		return

	var/datum/malf_research/res = user.research
	var/datum/malf_research_ability/tar = input("Select your next research target") in res.available_abilities
	if(!tar)
		return
	res.focus = tar
	to_chat(user, "Research set: [tar.name]")
	log_ability_use(src, "Selected research: [tar.name]", null, 0)

/mob/living/silicon/ai/proc/ai_select_hardware()

	set category = "Hardware"
	set name = "Select Hardware"
	set desc = "Allows you to select a hardware piece to install."
	var/mob/living/silicon/ai/user = usr

	if(!ability_prechecks(user, 0, 1))
		return

	if(user.hardware)
		to_chat(user, "You have already selected your hardware.")
		return

	var/hardware_list = list()
	for(var/H in typesof(/datum/malf_hardware))
		var/datum/malf_hardware/HW = new H
		hardware_list += HW

	var/possible_choices = list()
	for(var/datum/malf_hardware/H in hardware_list)
		possible_choices += H.name

	possible_choices += "CANCEL"
	var/choice = input("Select desired hardware. You may only choose one hardware piece!: ") in possible_choices
	if(choice == "CANCEL")
		return
	var/note = null

	var/datum/malf_hardware/C

	for (var/datum/malf_hardware/H in hardware_list)
		if(H.name == choice)
			C = H
			break

	if(C)
		note = C.desc
	else
		to_chat(user, "This hardware does not exist! Probably a bug in game. Please report this.")
		return


	if(!note)
		error("Hardware without description: [C]")
		return

	var/confirmation = alert("[note] - Is this what you want?", "Hardware selection", "Yes", "No")
	if(confirmation != "Yes")
		to_chat(user, "Selection cancelled. Use command again to select")
		return

	if(C)
		log_ability_use(src, "Picked hardware [C.name]")
		C.owner = user
		C.install()
	update_hud()
