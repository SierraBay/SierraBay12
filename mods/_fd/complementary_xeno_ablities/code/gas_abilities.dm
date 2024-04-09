/obj/item/organ/internal/brain/insectoid/nabber/proc/change_skin_color()
	set name = "Change Skin Color"
	set desc = "Changes your skin color."
	set category = "Abilities"
	set src in usr
	if (!owner || owner.incapacitated())
		return
	var/new_eyes = input("Please select skin color.", "Skin Color", owner.eye_color) as color|null
	if(new_eyes)
		var/list/ergb = rgb2num(new_eyes)
		if(do_after(owner, 2 SECOND, do_flags = DO_DEFAULT | DO_USER_UNIQUE_ACT) && owner.change_skin_color(ergb[1], ergb[2], ergb[3]))
			owner.regenerate_icons()
			owner.visible_message(SPAN_NOTICE("Кожа \The [owner] начинает переливатся всеми цветами радуги, останавливаясь на новом оттенке!"),SPAN_NOTICE("Вы сменили свой цвет кожи."),)

/obj/item/organ/internal/brain/insectoid/nabber/New()
	..()
	verbs |= /obj/item/organ/internal/brain/insectoid/nabber/proc/change_skin_color

/datum/grab/nab/masticate(obj/item/grab/G, attack_damage)
	var/assailant = G.assailant
	if(!assailant)
		return

	..()

	var/obj/item/organ/internal/stomach/stomach = G.assailant.internal_organs_by_name[BP_STOMACH]
	if(!stomach)
		return

	var/obj/item/organ/external/limb = G.affecting.organs_by_name[G.target_zone]
	if(BP_IS_ROBOTIC(limb) || BP_IS_ASSISTED(limb) || BP_IS_CRYSTAL(limb))
		return

	stomach.ingested.add_reagent(/datum/reagent/nutriment/protein, 3)
