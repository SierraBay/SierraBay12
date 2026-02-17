/obj/structure/sign/dedicationplaque/sierra
	name = "\improper NSV Sierra dedication plaque"

/obj/structure/sign/dedicationplaque/sierra/Initialize()
	. = ..()
	desc = "N.S.V. Sierra - Modified Mako Class - NanoTrasen Registry 3525 - Blume Ship Yards, Earth - Fourth Vessel To Bear The Name - Launched [GLOB.using_map.game_year - 12] - Sol Central Government - 'Travels to the abyss always pays off.'"


/obj/structure/sign/memorial/sierra
	name = "\improper NSV Sierra model"
	icon = 'maps/sierra/structures/memorial/sierra_memorial.dmi'
	icon_state = "sierra"

	layer = ABOVE_HUMAN_LAYER

	//description holder
	var/description

	/// The token for the loop sound
	var/levitation_sound

	/// list of sierra port developers
	var/developers = "K.G. List, S.H. Eugene, L.D. Nest, J.X. Kand and A.T. Cuddle"

/obj/structure/sign/memorial/sierra/Initialize()
	. = ..()

	levitation_sound = GLOB.sound_player.PlayLoopingSound(src, "\ref[src]", 'maps/sierra/structures/memorial/levitation_sound.ogg', 25, 3)

	set_light(2, 0.8, COLOR_TEAL)

	desc = "You see a holographic sign that says: 'Model of N.S.V. Sierra - Modified Mako Class'"
	description = {"<div style="max-width: 480px; margin: 12px auto;"><div style="border: 1px solid #4e9bcf; padding: 20px; color: #4e9bcf; margin-bottom: 10px; font-family: monospace;"><div style="font-size: 14px; text-align: center; font-weight: bold;"><div>N.S.V. Sierra - Modified Mako Class</div><div>NanoTrasen Registry 3525 - Blume Ship Yards.</div></div><hr style="border-color: #4e9bcf;"><div style="font-style: italic; text-align: center;"><div>Earth - Fourth Vessel To Bear The Name</div><div>Launched [GLOB.using_map.game_year - 12] - Sol Central Government</div><div>"Travels to the abyss always pays off"</div></div><hr style="border-color: #4e9bcf;"><div>Special thanks to the engineers of section '#2179-INF'.<br><br>Adjustment Engineers: [developers] for invaluable contributions to the development of the NSV Sierra.</div></div><div class="notice">Next comes an extremely long list of names and job titles, as well as a photograph of the team of engineers responsible for building this ship.</div></div>"}

	update_icon()

/obj/structure/sign/memorial/sierra/on_update_icon()
	. = ..()
	AddOverlays(image(icon, "sierra-overlay"))

/obj/structure/sign/memorial/sierra/update_emissive_blocker()
	. = ..()
	. += emissive_appearance(icon, "sierra-overlay")

/obj/structure/sign/memorial/sierra/examine(mob/user)
	. = ..()
	to_chat(user, "You see a holographic sign: <a href='byond://?src=\ref[src];show_info=1'>Read Sign</A>")

/obj/structure/sign/memorial/sierra/CanUseTopic()
	return STATUS_INTERACTIVE

/obj/structure/sign/memorial/sierra/OnTopic(href, href_list)
	if(href_list["show_info"])
		to_chat(usr, description)
		return TOPIC_HANDLED
	. = ..()


/obj/structure/sign/poster/annoyed_gas
	icon_state = "annoyed_gas"
	poster_type = /singleton/poster/annoyed_gas

/obj/structure/sign/poster/healthy_hugs
	icon_state = "healthy_hugs"
	poster_type = /singleton/poster/healthy_hugs

/obj/structure/sign/poster/no_alcohol
	icon_state = "no_alcohol"
	poster_type = /singleton/poster/no_alcohol

/obj/structure/sign/poster/pizza_for_captain
	icon_state = "pizza_for_captain"
	poster_type = /singleton/poster/pizza_for_captain

/obj/structure/sign/poster/would_you_plant
	icon_state = "would_you_plant"
	poster_type = /singleton/poster/would_you_plant

/obj/structure/sign/poster/cabbage_tray
	icon_state = "cabbage_tray"
	poster_type = /singleton/poster/cabbage_tray

/obj/structure/sign/poster/unusual_gas
	icon_state = "unusual_gas"
	poster_type = /singleton/poster/contraband_only/unusual_gas


/// TORCH ZONE

/obj/structure/sign/dedicationplaque
	name = "\improper SEV Torch dedication plaque"
	icon_state = "lightplaque"

/obj/structure/sign/dedicationplaque/Initialize()
	. = ..()
	desc = "S.E.V. Torch - Mako Class - Sol Expeditionary Corps Registry 95519 - Shiva Fleet Yards, Mars - First Vessel To Bear The Name - Launched [GLOB.using_map.game_year - 5] - Sol Central Government - 'Never was anything great achieved without danger.'"


/obj/floor_decal/scglogo
	alpha = 230
	icon = 'maps/torch/icons/obj/solgov_floor.dmi'
	icon_state = "center"

/obj/structure/sign/solgov
	name = "\improper SolGov Seal"
	desc = "A sign which signifies who this vessel belongs to."
	icon = 'maps/torch/icons/obj/solgov-decals.dmi'
	icon_state = "solgovseal"

/obj/structure/sign/double/solgovflag
	name = "\improper Sol Central Government Flag"
	desc = "The flag of the Sol Central Government, a symbol of many things to many people."
	icon = 'maps/torch/icons/obj/solgov-decals.dmi'

/obj/structure/sign/double/solgovflag/left
	icon_state = "solgovflag-left"

/obj/structure/sign/double/solgovflag/right
	icon_state = "solgovflag-right"

/obj/structure/sign/memorial
	name = "memorial rock"
	desc = "A large stone slab, engraved with the names of uniformed personnel who gave their lives for scientific progress. Not a list you'd want to make. Add the dog tags of the fallen to the monument to memorialize them."
	icon = 'maps/torch/icons/obj/solgov-64x.dmi'
	icon_state = "memorial"
	density = TRUE
	anchored = TRUE
	pixel_x = -16
	pixel_y = -16
	unacidable = TRUE
	var/list/fallen = list()
	var/list/accepted_branches = list(
		"Expeditionary Corps",
		"Fleet"
	)

/obj/structure/sign/memorial/Initialize()
	. = ..()
	#ifndef DEV_MODE
	var/datum/map/sierra/sierra_map = GLOB.using_map
	fallen += sierra_map?.memorial_entries
	#endif

/obj/structure/sign/memorial/use_tool(obj/item/tool, mob/user, list/click_params)
	// Dog Tags - Add dog tag
	if (istype(tool, /obj/item/clothing/accessory/badge/solgov/tags))
		var/obj/item/clothing/accessory/badge/solgov/tags/dog_tags = tool
		if (!(dog_tags.owner_branch in accepted_branches))
			USE_FEEDBACK_FAILURE("\The [src] only accepts dog tags from the [english_list(accepted_branches, and_text = " or ")] branches.")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		fallen += "[dog_tags.owner_rank] [dog_tags.owner_name] | [dog_tags.owner_branch]"
		user.visible_message(
			SPAN_NOTICE("\The [user] adds \a [tool] to \the [src]."),
			SPAN_NOTICE("You add \the [dog_tags.owner_name]'s [tool.name] to \the [src].")
		)
		qdel(dog_tags)
		return TRUE

	return ..()


/obj/structure/sign/memorial/examine(mob/user, distance)
	. = ..()
	if (distance <= 2)
		if (length(fallen))
			to_chat(user, "<b>Among the many names, you read:</b><br> [jointext(fallen, "<br>")]")
		else
			to_chat(user, "<b>There are many names engraved on \the [src].</b>")

// Disallow trader to sell unique memorial
/datum/trader/trading_beacon/manufacturing/New()
	possible_trading_items[/obj/structure/sign/memorial] = TRADER_BLACKLIST_ALL
