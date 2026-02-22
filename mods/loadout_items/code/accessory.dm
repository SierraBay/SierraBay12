/obj/item/clothing/accessory/solgov
	name = "master solgov accessory"
	icon = 'maps/torch/icons/obj/obj_accessories_solgov.dmi'
	accessory_icons = list(slot_w_uniform_str = 'maps/torch/icons/mob/onmob_accessories_solgov.dmi', slot_wear_suit_str = 'maps/torch/icons/mob/onmob_accessories_solgov.dmi')
	w_class = ITEM_SIZE_TINY
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_accessories_solgov_unathi.dmi'
	)

/*********
ranks - ec
*********/

/obj/item/clothing/accessory/solgov/rank
	name = "ranks"
	desc = "Insignia denoting rank of some kind. These appear blank."
	icon_state = "fleetrank"
	on_rolled_down = ACCESSORY_ROLLED_NONE
	slot = ACCESSORY_SLOT_RANK
	gender = PLURAL
	accessory_flags = ACCESSORY_REMOVABLE | ACCESSORY_HIGH_VISIBILITY

/obj/item/clothing/accessory/solgov/rank/ec
	name = "explorer ranks"
	desc = "Insignia denoting rank of some kind. These appear blank."
	icon_state = "ecrank_e1"

/obj/item/clothing/accessory/solgov/rank/ec/enlisted
	name = "ranks (E-1 apprentice explorer)"
	desc = "Insignia denoting the rank of Apprentice Explorer."
	icon_state = "ecrank_e1"

/obj/item/clothing/accessory/solgov/rank/ec/enlisted/e3
	name = "ranks (E-3 explorer)"
	desc = "Insignia denoting the rank of Explorer."
	icon_state = "ecrank_e3"

/obj/item/clothing/accessory/solgov/rank/ec/enlisted/e5
	name = "ranks (E-5 senior explorer)"
	desc = "Insignia denoting the rank of Senior Explorer."
	icon_state = "ecrank_e5"

/obj/item/clothing/accessory/solgov/rank/ec/enlisted/e7
	name = "ranks (E-7 chief explorer)"
	desc = "Insignia denoting the rank of Chief Explorer."
	icon_state = "ecrank_e7"

/obj/item/clothing/accessory/solgov/rank/ec/officer
	name = "ranks (O-1 ensign)"
	desc = "Insignia denoting the rank of Ensign."
	icon_state = "ecrank_o1"

/obj/item/clothing/accessory/solgov/rank/ec/officer/o3
	name = "ranks (O-3 lieutenant)"
	desc = "Insignia denoting the rank of Lieutenant."
	icon_state = "ecrank_o3"

/obj/item/clothing/accessory/scarf/fancy
	name = "red striped scarf"
	icon_state = "stripedredscarf"
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	item_icons = list(slot_wear_mask_str = 'mods/loadout_items/icons/onmob_accessory.dmi')

/obj/item/clothing/accessory/scarf/fancy/green
	name = "green striped scarf"
	icon_state = "stripedgreenscarf"

/obj/item/clothing/accessory/scarf/fancy/blue
	name = "blue striped scarf"
	icon_state = "stripedbluescarf"

/obj/item/clothing/accessory/scarf/fancy/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"

/obj/item/clothing/accessory/scarf/fancy/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"

// Press

/obj/item/clothing/accessory/badge/press/independent
	name = "press pass"
	desc = "A freelance journalist's pass, certified by Oculum Broadcast."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "pressbadge-i"
	badge_string = "Freelance Journalist"

/obj/item/clothing/accessory/badge/holo/investigator
	name = "\improper Internal Investigations holobadge"
	desc = "This badge marks the holder as an internal affairs investigator."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "invbadge"
	badge_string = "Internal Investigations"
	slot_flags = SLOT_TIE | SLOT_BELT

/obj/item/clothing/accessory/badge/iso
	name = "\improper Internal Security badge"
	desc = "This badge, depicting the infamous crimson shield logo of the NanoTrasen Internal Security, marks the holder as an internal security operative."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "isobadge"
	badge_string = "Internal Security"
	slot_flags = SLOT_TIE | SLOT_BELT

/*
--- Kinky stuff
*/

/obj/item/clothing/accessory/corset
	name = "Corset"
	desc = "Tight fitting undergarment, worn to shape the figure"
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "corset"

/obj/item/clothing/accessory/corset/vinyl
	name = "Vinyl Corset"
	desc = "I don't even want to ask..."
	icon_state = "vynilcorset"

/obj/item/clothing/accessory/choker
	name = "choker"
	desc = "to keep your neck warm"
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "choker_color"

/obj/item/clothing/accessory/necklace/collar
	name = "silver tag collar"
	desc = "A collar for your little pets... or the big ones."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon_state = "collar_bksilv"

	accessory_icons = list(
		slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi',
		slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi'
	)
	item_icons = list(
		slot_wear_mask_str = 'mods/loadout_items/icons/onmob_accessory.dmi'
	)

	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/unathi/onmob_accessory_unathi.dmi',
		SPECIES_RESOMI = 'mods/loadout_items/icons/resomi/onmob_accessory_resomi.dmi'
	)

	var/renameable = FALSE

/obj/item/clothing/accessory/necklace/collar/gold
	name = "golden tag collar"
	desc = "A collar for your little pets... or the big ones."
	icon_state = "collar_bkgold"
	renameable = TRUE

/obj/item/clothing/accessory/necklace/collar/bell
	name = "bell collar"
	desc = "A collar with a tiny bell hanging from it, purrfect furr kitties."
	icon_state = "collar_bkbell"
	renameable = TRUE

/obj/item/clothing/accessory/necklace/collar/spike
	name = "spiked collar"
	desc = "A collar with spikes that look as sharp as your teeth."
	icon_state = "collar_bkspike"
	renameable = TRUE

/obj/item/clothing/accessory/necklace/collar/pink
	name = "pink collar"
	desc = "This collar will make your pets look FA-BU-LOUS."
	icon_state = "collar_pisilv"
	renameable = TRUE

/obj/item/clothing/accessory/necklace/collar/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(renameable && tool.sharp)
		var/inscription = sanitize(input("Enter an inscription to engrave.", "Inscription") as null|text)

		if(!user.stat && !user.incapacitated() && user.Adjacent(src) && user.use_sanity_check(src, tool))
			if(!inscription)
				return TRUE
			USE_FEEDBACK_FAILURE("You carve \"[inscription]\" into \the [src].")
			name = initial(name) + " ([inscription])"
			desc = initial(desc) + " The tag says \"[inscription]\"."
			return TRUE
	return ..()

/obj/item/clothing/accessory/necklace/collar/holo
	name = "holo-collar"
	desc = "An expensive holo-collar for the modern day pet."
	icon_state = "collar_bkholo"

/obj/item/clothing/accessory/necklace/collar/holo/attack_self(mob/user as mob)
	to_chat(user, SPAN_NOTICE("[name]'s interface is projected onto your hand."))

	var/str = copytext(reject_bad_text(input(user,"Tag text?","Set tag","")),1,MAX_NAME_LEN)

	if(!str || !length(str))
		to_chat(user, SPAN_NOTICE("[name]'s tag set to be blank."))
		name = initial(name)
		desc = initial(desc)
	else
		to_chat(user, SPAN_NOTICE("You set the [name]'s tag to '[str]'."))
		name = initial(name) + " ([str])"
		desc = initial(desc) + " The tag says \"[str]\"."

/obj/item/clothing/accessory/necklace/collar/shock
	name = "shock collar"
	desc = "A collar used to ease hungry predators."
	icon_state = "collar_bkshk0"
	item_state = "collar_bkshk"
	var/on = FALSE // 0 for off, 1 for on, starts off to encourage people to set non-default frequencies and codes.
	var/frequency = 1449
	var/code = 2
	var/datum/radio_frequency/radio_connection

/obj/item/clothing/accessory/necklace/collar/shock/New()
	..()
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT) // Makes it so you don't need to change the frequency off of default for it to work.

/obj/item/clothing/accessory/necklace/collar/shock/Destroy() //Clean up your toys when you're done.
	radio_controller.remove_object(src, frequency)
	radio_connection = null //Don't delete this, this is a shared object.
	return ..()

/obj/item/clothing/accessory/necklace/collar/shock/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

/obj/item/clothing/accessory/necklace/collar/shock/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return
	if(((istype(usr, /mob/living/carbon/human) && ((!( SSticker ) || (SSticker && SSticker.mode != "monkey")) && LAZYACCESS(usr.contents, src))) || (LAZYACCESS(usr.contents, master) || (in_range(src, usr) && istype(loc, /turf)))))
		usr.set_machine(src)
		if(href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			set_frequency(new_frequency)
		else
			if(href_list["code"])
				code += text2num(href_list["code"])
				code = round(code)
				code = min(100, code)
				code = max(1, code)
			else
				if(href_list["power"])
					on = !( on )
					icon_state = "collar_bkshk[on]" // And apparently this works, too?!
		if(!( master ))
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in viewers(1, src))
					if(M.client)
						attack_self(M)
		else
			if(istype(master.loc, /mob))
				attack_self(master.loc)
			else
				for(var/mob/M in viewers(1, master))
					if(M.client)
						attack_self(M)
	else
		close_browser(usr, "window=radio")
		return
	return

/obj/item/clothing/accessory/necklace/collar/shock/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption != code)
		return

	if(on)
		var/mob/M = null
		if(ismob(loc))
			M = loc
		if(ismob(loc.loc))
			M = loc.loc // This is about as terse as I can make my solution to the whole 'collar won't work when attached as accessory' thing.
		to_chat(M, SPAN_DANGER("You feel a sharp shock!"))
		var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
		s.set_up(3, 1, M)
		s.start()
		M.Weaken(5)
	return

/obj/item/clothing/accessory/necklace/collar/shock/attack_self(mob/user as mob, flag1)
	if(!istype(user, /mob/living/carbon/human))
		return
	user.set_machine(src)
	var/dat = {"<TT>
			<a href='byond://?src=\ref[src];power=1'>Turn [on ? "Off" : "On"]</A><BR>
			<B>Frequency/Code</B> for collar:<BR>
			Frequency:
			<a href='byond://?src=\ref[src];freq=-10'>-</A>
			<a href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(frequency)]
			<a href='byond://?src=\ref[src];freq=2'>+</A>
			<a href='byond://?src=\ref[src];freq=10'>+</A><BR>

			Code:
			<a href='byond://?src=\ref[src];code=-5'>-</A>
			<a href='byond://?src=\ref[src];code=-1'>-</A> [code]
			<a href='byond://?src=\ref[src];code=1'>+</A>
			<a href='byond://?src=\ref[src];code=5'>+</A><BR>
			</TT>"}
	show_browser(user, dat, "window=radio")
	onclose(user, "radio")
	return

// Overrides

/obj/item/clothing/accessory/badge/holo
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(
		slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi',
		slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi'
	)
	item_icons = list(
		slot_wear_mask_str = 'mods/loadout_items/icons/onmob_accessory.dmi'
	)

/obj/item/clothing/glasses/prescription/hitech
	name = "high-tech blue visor"
	desc = "Blue glistening visor for vision corrective."
	item_icons = list(slot_glasses_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon_state = "hitech_blue"
	item_state = "hitech_blue"
	body_parts_covered = EYES
	prescription = 7

/obj/item/clothing/glasses/prescription/hitech
	name = "high-tech blue visor"
	desc = "Blue glistening visor for vision corrective."
	item_icons = list(slot_glasses_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon_state = "hitech_blue"
	item_state = "hitech_blue"
	body_parts_covered = EYES
	prescription = 7

/obj/item/clothing/glasses/prescription/hitech/red
	name = "high-tech red visor"
	desc = "Red glistening visor for vision corrective."
	icon_state = "hitech_red"
	item_state = "hitech_red"

/obj/item/clothing/glasses/prescription/hitech/green
	name = "high-tech green glasses"
	desc = "Green glistening glasses for vision corrective."
	icon_state = "hitech_green"
	item_state = "hitech_green"

/obj/item/clothing/glasses/prescription/hitech/purple
	name = "high-tech purple visor"
	desc = "Purple glistening visor for vision corrective."
	icon_state = "hitech_purple"
	item_state = "hitech_purple"

/obj/item/clothing/glasses/prescription/hitech/retro
	name = "high-tech retro glasses"
	desc = "Dark green glistening glasses for vision corrective."
	icon_state = "hitech_retro"
	item_state = "hitech_retro"

// KMS EMT kneepads
/obj/item/clothing/accessory/kms_kneepads
	name = "KMS kneepads"
	desc = "Pair of sturdy polymer kneepads generously provided by Komatsu Medical Services to their employees. Offer no additional protection, though."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "kms_kneepads"

// Visas override
/obj/item/paper/workvisa
	name = "Sol Work Visa"
	info = "<center><b><large>Рабочая виза Правительства Солнечной Системы</large></b></center><br><center><img src = sollogo.png><br><br><i><small>Выдано от имени Генерального секретаря.</small></i></center><hr><BR>Настоящим документом разрешается предъявителю беспрепятственно передвигаться по территориям, колониям и космическому пространству Солнечной системы с целью работы и трудовой деятельности."
	desc = "A flimsy piece of laminated cardboard issued by the Sol Central Government."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	on_turf_icon = 'mods/loadout_items/icons/on_turf_icons/obj_accessory.dmi'

/obj/item/paper/travelvisa
	name = "Sol Travel Visa"
	info = "<center><b><large>Туристическая виза Правительства Солнечной Системы</large></b></center><br><center><img src = sollogo.png><br><br><i><small>Выдано от имени Генерального секретаря.</small></i></center><hr><BR>Настоящим документом разрешается предъявителю беспрепятственно передвигаться по территориям, колониям и космическому пространству Солнечной системы с целью отдыха и туризма."
	desc = "A flimsy piece of laminated cardboard issued by the Sol Central Government."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	on_turf_icon = 'mods/loadout_items/icons/on_turf_icons/obj_accessory.dmi'

/obj/item/paper/workvisa/New()
	..()
	icon_state = "workvisa" //Has to be here or it'll assume default paper sprites.

/obj/item/paper/travelvisa/New()
	..()
	icon_state = "travelvisa" //Has to be here or it'll assume default paper sprites.

/obj/item/paper/iccgvisa
	name = "ICCG Work Visa"
	info = "<center><b><large>Рабочая виза Гильгамешской Колониальной Конфедерации</large></b></center><br><center><img src = terralogo.png><br><br><i><small>Выдано от имени Премьер-министра.</small></i></center><hr><BR>Настоящим документом разрешается предъявителю беспрепятственно передвигаться по территориям, колониям и космическому пространству ГКК с целью работы и трудовой деятельности."
	desc = "A flimsy piece of laminated cardboard issued by the ICCG."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	on_turf_icon = 'mods/loadout_items/icons/on_turf_icons/obj_accessory.dmi'
	readable = FALSE
	language = LANGUAGE_HUMAN_RUSSIAN
	var/open = FALSE

/obj/item/paper/iccgvisa/New()
	..()
	icon_state = "iccgvisa0" //Has to be here or it'll assume default paper sprites.

/obj/item/paper/iccgvisa/attack_self(mob/living/user)
	open = !open
	icon_state = "iccgvisa[open]"
	readable = open
	update_icon()

/obj/item/paper/iccgvisa/on_update_icon()
	icon_state = "iccgvisa[open]"

/obj/item/clothing/accessory/sweater/simple
	name = "sweater"
	desc = "A warm, knit sweater."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "sweater"

/obj/item/clothing/accessory/sweater/tubeneck
	name = "tubeneck sweater"
	desc = "A warm, knit tubeneck sweater."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "sweater_tubeneck"

/obj/item/clothing/accessory/sweater/crewneck
	name = "crewneck sweater"
	desc = "A sewn crewneck sweater featuring a collarless neckline."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "sweater_crewneck"

/obj/item/clothing/accessory/sweater/v_neck
	name = "v-neck sweater"
	desc = "A sewn v-neck sweater featuring a collarless neckline."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "sweater_v_neck"

/obj/item/clothing/accessory/sweater/v_neck_deep
	name = "deep v-neck sweater"
	desc = "A sewn v-neck sweater with deep drawn neckline."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "sweater_deep_v_neck"

/obj/item/clothing/accessory/sweater/argyle
	name = "argyle sweater"
	desc = "A warm, knit sweater with an argyle pattern."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "argyle_sweater"

/obj/item/clothing/accessory/sweater/argyle_tubeneck
	name = "argyle tubeneck sweater"
	desc = "A warm, knit argyle tubeneck sweater."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "argyle_sweater_tubeneck"

/obj/item/clothing/accessory/sweater/argyle_turtleneck
	name = "argyle turtleneck sweater"
	desc = "A warm, knit argyle turtleneck sweater."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "argyle_sweater_turtleneck"

/obj/item/clothing/accessory/sweater/argyle_crewneck
	name = "argyle crewneck sweater"
	desc = "A sewn crewneck sweater featuring a collarless neckline and an argyle pattern."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "argyle_sweater_crewneck"

/obj/item/clothing/accessory/sweater/argyle_v_neck
	name = "argyle v-neck sweater"
	desc = "A sewn v-neck sweater featuring a collarless neckline and an argyle pattern."
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	icon_state = "argyle_sweater_v_neck"
