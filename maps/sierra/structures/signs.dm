/obj/structure/sign/dedicationplaque/sierra
	name = "\improper NSV Sierra dedication plaque"

/obj/structure/sign/dedicationplaque/sierra/Initialize()
	. = ..()
	desc = "N.S.V. Sierra - Modified Mako Class - NanoTrasen Registry 3525 - Blume Ship Yards, Earth - Fourth Vessel To Bear The Name - Launched [GLOB.using_map.game_year - 12] - Sol Central Government - 'Travels to the abyss always pays off.'"


/obj/structure/sign/memorial/sierra
	name = "\improper NSV Sierra memorial"
	icon = 'maps/sierra/structures/memorial/sierra_memorial.dmi'
	icon_state = "sierra"

	layer = ABOVE_HUMAN_LAYER

	//description holder
	var/description

	/// The token for the loop sound
	var/levitation_sound

	/// list of sierra port developers
	var/developers = "K.G. List, S.H. Eugene, L.D. Nest, J.X. Kand"

/obj/structure/sign/memorial/sierra/Initialize()
	. = ..()

	levitation_sound = GLOB.sound_player.PlayLoopingSound(src, "\ref[src]", 'maps/sierra/structures/memorial/levitation_sound.ogg', 35, 6)

	set_light(0.8, 2, 5, 2, COLOR_TEAL)

	desc = "You see a golden sign that says: 'Memorial of N.S.V. Sierra - Modified Mako Class'"
	description = {"<div style="max-width: 400px; margin: 12px auto;"><div style="background-color: #d4b241; box-shadow: inset 8px 8px 16px -8px #e6d59d, inset -8px -8px 16px -8px #5f4e16; padding: 20px; color: #7c6827; margin-bottom: 10px;"><div style="font-size: 14px; text-align: center; font-weight: bold;"><div>N.S.V. Sierra - Modified Mako Class</div><div>NanoTrasen Registry 3525 - Blume Ship Yards.</div></div><hr style="border-color: #a38b3d;"><div style="font-style: italic; text-align: center;"><div>Earth - Fourth Vessel To Bear The Name</div><div>Launched [GLOB.using_map.game_year - 12] - Sol Central Government</div><div>"Travels to the abyss always pays off"</div></div><hr style="border-color: #a38b3d;"><div>Special thanks to the engineers of section '#2179-INF'<br><br>Adjustment Engineers: '[developers]' for invaluable contributions to the development of the NSV Sierra</div></div><div class="notice">Next comes an extremely long list of names and job titles, as well as a photograph of the team of engineers responsible for building this ship</div></div>"}

	update_icon()

/obj/structure/sign/memorial/sierra/update_icon()
	. = ..()
	overlays += image(icon, "sierra-overlay")

/obj/structure/sign/memorial/sierra/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "sierra-overlay")

/obj/structure/sign/memorial/sierra/examine(mob/user)
	. = ..()
	to_chat(user, "You see a holographic sign: <A href='?src=\ref[src];show_info=1'>Read Sign</A>")

/obj/structure/sign/memorial/sierra/CanUseTopic()
	return STATUS_INTERACTIVE

/obj/structure/sign/memorial/sierra/OnTopic(href, href_list)
	if(href_list["show_info"])
		to_chat(usr, description)
		return TOPIC_HANDLED
