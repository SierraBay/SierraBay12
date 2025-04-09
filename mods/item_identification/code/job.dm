/datum/job/hos/post_equip_rank(mob/person, alt_title)
	..()
	person.verbs -= /mob/verb/mod_skill_examine_init
	person.verbs += /verb/mod_skill_examine
	person.verbs += /verb/mod_skill_examine_hide

/datum/job/warden/post_equip_rank(mob/person, alt_title)
	..()
	person.verbs -= /mob/verb/mod_skill_examine_init
	person.verbs += /verb/mod_skill_examine
	person.verbs += /verb/mod_skill_examine_hide

/datum/job/detective/post_equip_rank(mob/person, alt_title)
	..()
	person.verbs -= /mob/verb/mod_skill_examine_init
	person.verbs += /verb/mod_skill_examine
	person.verbs += /verb/mod_skill_examine_hide

/datum/job/officer/post_equip_rank(mob/person, alt_title)
	..()
	person.verbs -= /mob/verb/mod_skill_examine_init
	person.verbs += /verb/mod_skill_examine
	person.verbs += /verb/mod_skill_examine_hide

/datum/job/post_equip_rank(mob/person, alt_title)
	..()
	if(person.get_skill_value(SKILL_FORENSICS) > SKILL_UNSKILLED)
		person.verbs -= /mob/verb/mod_skill_examine_init
		person.verbs += /verb/mod_skill_examine
		person.verbs += /verb/mod_skill_examine_hide
