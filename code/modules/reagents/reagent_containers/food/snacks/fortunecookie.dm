GLOBAL_LIST_AS(fortune_cookie_default_fortunes, list(
	"Today it's up to you to create the peacefulness you long for.",
	"If you refuse to accept anything but the best, you very often get it.",
	"A smile is your passport into the hearts of others.",
	"Hard work pays off in the future, laziness pays off now.",
	"Change can hurt, but it leads a path to something better.",
	"Hidden in a valley beside an open stream- This will be the type of place where you will find your dream.",
	"Never give up. You're not a failure if you don't give up.",
	"Love can last a lifetime, if you want it to.",
	"The love of your life is stepping into your planet this summer.",
	"Your ability for accomplishment will follow with success.",
	"Please help me, I'm trapped in a fortune cookie factory!"
))


/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#e8e79e"
	center_of_mass = "x=15;y=14"
	nutriment_desc = list("fortune cookie" = 2)
	nutriment_amt = 3
	bitesize = 2

	/// The paper fortune contained inside the cookie. Set during `Initialize()`.
	var/obj/item/paper/fortune

	/// Boolean. Whether or not the cookie has already been broken open,
	var/opened = FALSE


/obj/item/reagent_containers/food/snacks/fortunecookie/Initialize(mapload, obj/item/paper/fortune)
	. = ..()
	if (. == INITIALIZE_HINT_QDEL)
		return
	if (!fortune)
		fortune = new (src)
		fortune.set_content(pick(GLOB.fortune_cookie_default_fortunes), "fortune", FALSE)
	set_fortune(fortune)


/obj/item/reagent_containers/food/snacks/fortunecookie/Destroy()
	QDEL_NULL(fortune)
	return ..()


/obj/item/reagent_containers/food/snacks/fortunecookie/examine(mob/user, distance)
	. = ..()
	if (opened)
		to_chat(user, SPAN_WARNING("It's been broken open and no longer holds a fortune."))


/obj/item/reagent_containers/food/snacks/fortunecookie/attack_self(mob/user)
	if (opened)
		USE_FEEDBACK_FAILURE("\The [src] has already been broken open.")
		return TRUE
	var/message = "but it was empty"
	if (fortune)
		message = "revealing \a [fortune]"
		fortune.forceMove(user.loc)
		user.put_in_hands(fortune)
		fortune = null
	user.visible_message(
		SPAN_NOTICE("\The [user] cracks open \a [src], [message]."),
		SPAN_NOTICE("You crack open \the [src], [message].")
	)
	SetName("open [name]")
	opened = TRUE


/obj/item/reagent_containers/food/snacks/fortunecookie/proc/set_fortune(obj/item/paper/new_fortune)
	if (new_fortune == fortune)
		return
	if (fortune)
		fortune.dropInto(loc)
	if (new_fortune)
		new_fortune.forceMove(src)
	fortune = new_fortune
