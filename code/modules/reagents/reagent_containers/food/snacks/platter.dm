//Platters - platters/bowls with multiple snacks to be dispensed. Ported from Aurora.

/obj/item/reagent_containers/food/snacks/platter
	name = "a bowl of item"
	desc = "If you're seeing this, something has gone wrong D:"
	icon_state = "puffpuffbowl_full"
	trash = /obj/item/trash/snack_bowl
	nutriment_amt = 24
	nutriment_desc = list("fried nothing" = 24)
	bitesize = 4
	var/vendingobject = /obj/item/reagent_containers/food/snacks/puffpuff
	var/unitname = "contained_food"

/obj/item/reagent_containers/food/snacks/platter/on_reagent_change()
	..()
	update_icon()

/obj/item/reagent_containers/food/snacks/platter/attack_hand(mob/user as mob)
	var/obj/item/reagent_containers/food/snacks/returningitem = new vendingobject(loc)
	returningitem.reagents.clear_reagents()
	reagents.trans_to(returningitem, bitesize)
	returningitem.bitesize = bitesize/2
	user.put_in_hands(returningitem)
	if (reagents && reagents.total_volume)
		to_chat(user, "You take \a [unitname] from the plate.")
	else
		to_chat(user, "You take the last [unitname] from the plate.")
		var/obj/waste = new trash(loc)
		if (loc == user)
			user.put_in_hands(waste)
		qdel(src)

/obj/item/reagent_containers/food/snacks/platter/MouseDrop(mob/user)
	if(CanMouseDrop(user))
		user.put_in_active_hand(src)
		src.pickup(user)
		return
	. = ..()


/obj/item/reagent_containers/food/snacks/platter/puffpuffs
	name = "puff-puff bowl"
	desc = "A bowl of puffy dough balls. Much like donut balls except pan-fried, chewier, and often served savory, not just sweet. It originates in Nigeria, but it's a popular snack in New Benin and across many parts of Earther space."
	icon_state = "puffpuffbowl_full"
	filling_color = "#bb8a41"
	bitesize = 4
	nutriment_amt = 24
	nutriment_desc = list("fried dough" = 24)
	vendingobject = /obj/item/reagent_containers/food/snacks/puffpuff
	unitname = "puff-puff"

/obj/item/reagent_containers/food/snacks/platter/puffpuffs/on_update_icon()
	switch(reagents.total_volume)
		if(1 to 8)
			icon_state = "puffpuffbowl_few"
		if(9 to INFINITY)
			icon_state = "puffpuffbowl_full"


/obj/item/reagent_containers/food/snacks/puffpuff
	name = "puff-puff"
	desc = "A nice, puffy, puff-puff. Mmmm, fried dough. You can feel your arteries clogging already!"
	icon_state = "puffpuff"
	filling_color = "#bb8a41"
	bitesize = 2


/obj/item/reagent_containers/food/snacks/platter/latkes
	name = "latke platter"
	desc = "A plate of crispy potato pancakes. Get them while they're hot!"
	icon_state = "latkes_full"
	filling_color = "#e88d17"
	bitesize = 4
	nutriment_amt = 12
	nutriment_desc = list("crispy fried potato" = 12)
	vendingobject = /obj/item/reagent_containers/food/snacks/latke
	unitname = "latke"

/obj/item/reagent_containers/food/snacks/platter/latkes/on_update_icon()
	switch(reagents.total_volume)
		if(1 to 3)
			icon_state = "latkes_few"
		if(4 to 6)
			icon_state = "latkes_some"
		if(7 to INFINITY)
			icon_state = "latkes_full"


/obj/item/reagent_containers/food/snacks/latke
	name = "latke"
	desc = "A crispy latke, ready to eat. If only there was applesauce."
	icon_state = "latke"
	filling_color = "#e88d17"
	bitesize = 2
