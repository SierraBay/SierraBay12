/obj/structure/sign/dedicationplaque/sierra
	name = "\improper NSV Sierra dedication plaque"

/obj/structure/sign/dedicationplaque/sierra/Initialize()
	. = ..()
	desc = "N.S.V. Sierra - Modified Mako Class - NanoTrasen Registry 3525 - Blume Ship Yards, Earth - Fourth Vessel To Bear The Name - Launched [GLOB.using_map.game_year - 12] - Sol Central Government - 'Travels to the abyss always pays off.'"


/obj/structure/sign/memorial/sierra
	name = "\improper NSV Sierra memorial"
	icon = 'maps/sierra/structures/memorial/sierra_memorial.dmi'
	icon_state = "sierra"

	//description holder
	var/description

	/// The token for the loop sound
	var/levitation_sound

	/// list of sierra port developers
	var/developers = "Gl1st, Jujuk, Niest ant ozeths" //тут имена надо нормальные написать, кукл мб

/obj/structure/sign/memorial/sierra/Initialize()
	. = ..()

	levitation_sound = GLOB.sound_player.PlayLoopingSound(src, "\ref[src]", 'maps/sierra/structures/memorial/levitation_sound.ogg', 35, 6)


	set_light(0.8, 2, 5, 2, COLOR_TEAL)

	desc = "You see a golden sign that says: 'Memorial of N.S.V. Sierra - Modified Mako Class'"
	description = {"<hr><center>
	N.S.V. Sierra - Modified Mako Class - NanoTrasen Registry 3525 - Blume Ship Yards.
	----
	An extremely long list of names and job titles, as well as a photograph of the team of engineers responsible for building this ship
	Special thanks to the engineers of section '#2179-INF'
	Adjustment Engineers: '[developers]' for invaluable contributions to the development of the NSV Sierra
	----
	Earth - Fourth Vessel To Bear The Name - Launched [GLOB.using_map.game_year - 12] - Sol Central Government - Travels to the abyss always pays off.
	</center><hr>"}

/obj/structure/sign/memorial/sierra/examine(mob/user)
	. = ..()
	to_chat(user, "You see a holographic sign: <A href='?src=\ref[src];show_info=1'>Read Sign</A>")

/obj/structure/sign/memorial/sierra/CanUseTopic()
	return STATUS_INTERACTIVE

/obj/structure/sign/memorial/sierra/OnTopic(href, href_list)
	if(href_list["show_info"])
		to_chat(usr, description)
		return TOPIC_HANDLED
