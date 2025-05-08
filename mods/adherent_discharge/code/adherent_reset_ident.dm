/obj/item/organ/internal/brain/adherent/attack_self(mob/user)
	var/newname = sanitizeSafe(input(user, "Enter a new ident.", "Reset Ident") as text, MAX_NAME_LEN)
	if(!newname)
		return
	var/confirm = input(user, "Are you sure you wish your name to become [newname]?","Reset Ident") as anything in list("No", "Yes")
	if(confirm == "Yes" && owner && user == owner && !owner.incapacitated())
		owner.real_name = "[newname]"
		if(owner.mind)
			owner.mind.name = owner.real_name
		owner.SetName(owner.real_name)
		to_chat(user, SPAN_NOTICE("You are now designated <b>[owner.real_name]</b>."))
