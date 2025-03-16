/obj/screen/exosuit/full_integrity
	icon = 'mods/mechs_by_shegar/icons/mech_full_integrity.dmi'
	icon_state = "hp-24"

/obj/screen/exosuit/full_integrity/Click()
	to_chat(usr, "Current full hp: [owner.health], max full hp: [owner.maxHealth]")

/obj/screen/exosuit/full_integrity/proc/update_hp()
	var/value = (owner.health/owner.maxHealth) * 24
	var/output = floor(value)
	output = clamp(output, 0, 24)
	icon_state = "hp-[output]"
