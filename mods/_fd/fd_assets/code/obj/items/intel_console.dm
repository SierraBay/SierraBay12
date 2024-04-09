/obj/structure/fd/intel_console
	name = "Old terminal"
	desc = "Strange, pretty old looking data terminal. Possibly holds some good info to sold or use!"
	icon = 'mods/_fd/fd_assets/icons/structures/miscobjs.dmi'
	icon_state = "retrosmall"
	density = TRUE
	anchored = TRUE
	var/state = 1 // 1 - fully functional(still need cell to work), 2 - slightly broken(use welder to fix it), 3 - destroyed(use glass to fix the screen and then welder to put everything together)
	var/powerless = TRUE //do we have cell installed? No cell by default
	var/data = 5 //Do we have any data that we can extract?
	var/list/disk = list(/obj/item/fd/data,
						/obj/item/fd/data/engineering,
						/obj/item/fd/data/engineering/lvl2,
						/obj/item/fd/data/engineering/lvl3,
						/obj/item/fd/data/engineering/lvl4,
						/obj/item/fd/data/science,
						/obj/item/fd/data/science/lvl2,
						/obj/item/fd/data/science/lvl3,
						/obj/item/fd/data/science/lvl4,
						/obj/item/fd/data/weapons,
						/obj/item/fd/data/weapons/lvl2/kinetic,
						/obj/item/fd/data/weapons/lvl2/energy,
						/obj/item/fd/data/weapons/lvl2/magnetic,
						/obj/item/fd/data/weapons/lvl2/special,
						/obj/item/fd/data/weapons/lvl3/kinetic,
						/obj/item/fd/data/weapons/lvl3/energy,
						/obj/item/fd/data/weapons/lvl3/magnetic,
						/obj/item/fd/data/weapons/lvl3/special,
						/obj/item/fd/data/weapons/lvl3/secret,
						/obj/item/fd/data/weapons/lvl4/kinetic,
						/obj/item/fd/data/weapons/lvl4/energy,
						/obj/item/fd/data/weapons/lvl4/magnetic,
						/obj/item/fd/data/weapons/lvl4/special,
						/obj/item/fd/data/weapons/lvl4/secret) //possible pool of data-disks that can be inside
	var/icon_state_functional = "retrosmall"
	var/icon_state_unpowered = "retrosmallp"
	var/icon_state_broken = "retrosmall0"
	var/icon_state_brolen_fully = "retrosmallb"

/obj/structure/fd/intel_console/New()
	. = ..()
	state = pick(1,2,3)
	data = rand(1,5)
	update_icon()

/obj/structure/fd/intel_console/LateInitialize()
	. = ..()
	update_icon()

/obj/structure/fd/intel_console/on_update_icon()
	if(state == 1 && powerless == TRUE)
		icon_state = icon_state_unpowered
	if(state == 1 && powerless == FALSE)
		icon_state = icon_state_functional
	if(state == 2)
		icon_state = icon_state_broken
	if(state == 3)
		icon_state = icon_state_brolen_fully
	return

/obj/structure/fd/intel_console/attackby(obj/item/I, mob/living/user)

	if(state == 3 && istype(I, /obj/item/stack/material/glass/))
		var/obj/item/stack/material/glass/guass = I
		if(guass.amount <= 5)
			to_chat(user, "<span class='warning'>У вас недостаточно материалов! Для починки экрана понадобится минимум 5 единиц стекла!</span>")
			return
		to_chat(user, "<span class='notice'>Вы начинаете заменять разбитый экран...</span>")
		if(do_after(user, 30) && guass.amount >= 5)
			guass.amount -= 5
			state = 2
			update_icon()
			if(guass.amount <= 0)
				qdel(I)
	if(state == 2 && isWelder(I))
		var/obj/item/weldingtool/welder = I
		if(do_after(user, 50))
			if(istype(I, /obj/item/weldingtool) && !welder.remove_fuel(0, user))
				return
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			to_chat(user, "<span class='notice'>Вы начинаете сваривать детали и приводить кейпад в божеский вид...</span>")
			state = 1
			update_icon()
	if(state == 1)
		if(powerless == TRUE && istype(I, /obj/item/cell/))
			if(do_after(user, 30))
				powerless = FALSE
				to_chat(user, "<span class='notice'>Вы аккуратно вставляете внутрь батарею...</span>")
				qdel(I)
				update_icon()
/*		if(powerless == TRUE && istype(I, /obj/item/psychic_power/psielectro)) ПСИОНИКА
			if(istype(user) && user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) < PSI_RANK_OPERANT)
				to_chat(user, "<span class='notice'>Вы ещё не успели освоиться с током настолько хорошо, чтобы провернуть нечто подобное...</span>")
				return
			if(do_after(user, 60))
				powerless = FALSE
				to_chat(user, "<span class='notice'>Вы оживляете платы старого терминала, наполняя его своим внутренним электричеством...</span>")
				update_icon() */
	if(state == 1 && powerless == FALSE)
		if(data == 1)
			to_chat(user, "<span class='notice'>Похоже, что полезных чертежей в терминале не осталось...впрочем, вы всё ещё можете найти что-либо в округе с его помощью.</span>")
		if(data == 0)
			to_chat(user, "<span class='warning'>В терминале не осталось полезной информации...</span>")
		if(data > 1)
			if(do_after(user, 80) && isMultitool(I))
				to_chat(user, "<span class='notice'>Вы начали извлечение информации из терминала!</span>")
				var/obj/item/datamine = pickweight(disk)
				datamine = new datamine(loc)
				data -= 2
				to_chat(user, "<span class='notice'>Вы нашли [datamine]!</span>")

	else
		to_chat(user, "<span class='warning'>На вряд ли [I] может здесь чем-то помочь...</span>")
		return

/obj/structure/fd/intel_console/attack_hand(mob/user)
	if(state == 1 && powerless == FALSE)
		if(data > 0)
			if(do_after(user, 80))
				var/option =  alert(user, "Что вы хотите отследить?", "Реестр терминала", "Хранилища", "Крио-капсулы")
				switch(option)
					if("Крио-капсулы")
						var/obj/structure/abandoned_cryo/C = locate() in orange(30)
						if(C)
							to_chat(user, "<span class='notice'>Ближайшая капсула гибернации находится на координатах: [C.x], [C.y]</span>")
							data -= 1
						else
							to_chat(user, "<span class='notice'>Похоже, что в памяти данного терминала подобной информации нет!</span>")
					if("Хранилища")
						var/obj/structure/closet/crate/CR = locate() in orange(30)
						if(CR)
							to_chat(user, "<span class='notice'>Ближайшее хранилище снаряжения находится на координатах: [CR.x], [CR.y]</span>")
							data -= 1
						else
							to_chat(user, "<span class='notice'>Похоже, что в памяти данного терминала подобной информации нет!</span>")
		else
			to_chat(user, "<span class='notice'>В терминале не осталось полезной информации...</span>")
