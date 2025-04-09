/datum/wire_description
	var/index
	var/description
	var/skill_level = SKILL_MASTER
	/// String. Short label displayed on the wire panel UI for high-skill electricians.
	var/label = "???"

/datum/wire_description/New(index, description, label, skill_level)
	src.index = index
	if(description)
		src.description = description
	if (label)
		src.label = label
	if(skill_level)
		src.skill_level = skill_level
	..()
