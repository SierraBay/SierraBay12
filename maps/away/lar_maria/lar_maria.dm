#include "lar_maria_areas.dm"

/obj/overmap/visitable/sector/lar_maria
	name = "Lar Maria space station"
	desc = "Sensors detect an orbital station with low energy profile and sporadic life signs."
	icon_state = "object"


/datum/map_template/ruin/away_site/lar_maria
	name = "Lar Maria"
	id = "awaysite_lar_maria"
	description = "An orbital virus research station."
	suffixes = list("lar_maria/lar_maria-1.dmm", "lar_maria/lar_maria-2.dmm")
	spawn_cost = 2
	area_usage_test_exempted_root_areas = list(/area/lar_maria)

/datum/map_template/ruin/away_site/lar_maria/after_load(z)
	..()
	spawn_derelict_mission_object(/obj/item/derelict_mission_artifact/virus_container, z)

///////////////////////////////////crew and prisoners
/obj/landmark/corpse/lar_maria
	eye_colors_per_species = list(SPECIES_HUMAN = list(COLOR_RED))//red eyes
	skin_tones_per_species = list(SPECIES_HUMAN = list(-15))
	facial_styles_per_species = list(SPECIES_HUMAN = list("Shaved"))
	genders_per_species = list(SPECIES_HUMAN = list(MALE))

// ============================================================
// Lar Maria NPC Spawner (carbon/human with AI)
// ============================================================

/obj/landmark/lar_maria_npc
	var/npc_name = "hostile"
	var/outfit_type                          // singleton outfit for equipping
	var/ai_type = /datum/ai_holder/human/lar_maria
	var/faction_name = "lar_maria"
	var/list/weapons = list()                // item types to put in hands
	var/npc_gender = MALE

/obj/landmark/lar_maria_npc/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/landmark/lar_maria_npc/LateInitialize()
	var/mob/living/carbon/human/H = new(loc)
	H.real_name = npc_name
	H.SetName(npc_name)
	H.faction = faction_name
	H.a_intent = I_HURT
	H.change_gender(npc_gender)
	// Infected appearance: red eyes, pale skin
	H.change_eye_color(255, 0, 0)
	H.change_skin_tone(-15)
	H.change_facial_hair("Shaved")
	apply_appearance(H)
	// Equip outfit
	if(outfit_type)
		var/singleton/hierarchy/outfit/O = outfit_by_type(outfit_type)
		O.equip(H, equip_adjustments = OUTFIT_ADJUSTMENT_SKIP_ID_PDA|OUTFIT_ADJUSTMENT_SKIP_BACKPACK|OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR|OUTFIT_ADJUSTMENT_SKIP_POST_EQUIP)
	// Weapons in hands
	for(var/W in weapons)
		var/obj/item/I = new W(H)
		H.put_in_hands(I)
	// AI setup
	H.ai_holder = new ai_type(H)
	H.say_list = new /datum/say_list/lar_maria()
	H.say_list_type = /datum/say_list/lar_maria
	// Infect with Lar Maria virus (defined in virusology mod)
	lar_maria_npc_infect_human(H)
	H.update_icon()
	qdel(src)

// Override for subtype-specific appearance tweaks
/obj/landmark/lar_maria_npc/proc/apply_appearance(mob/living/carbon/human/H)
	return

// --- Test Subject ---
/obj/landmark/lar_maria_npc/test_subject
	npc_name = "test subject"
	outfit_type = /singleton/hierarchy/outfit/corpse/test_subject

/obj/landmark/corpse/lar_maria/test_subject
	name = "Dead test subject"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/test_subject)
	spawn_flags = CORPSE_SPAWNER_NO_RANDOMIZATION//no name, no hairs etc.

/singleton/hierarchy/outfit/corpse/test_subject
	name = "Dead ZHP test subject"
	uniform = /obj/item/clothing/under/color/orange
	shoes = /obj/item/clothing/shoes/orange

/obj/landmark/corpse/lar_maria/zhp_guard
	name = "dead guard"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/zhp_guard)
	skin_tones_per_species = list(SPECIES_HUMAN = list(-15))

/obj/landmark/corpse/lar_maria/zhp_guard/dark
	skin_tones_per_species = list(SPECIES_HUMAN = list(-115))

/singleton/hierarchy/outfit/corpse/zhp_guard
	name = "Dead ZHP guard"
	uniform = /obj/item/clothing/under/rank/virologist
	suit = /obj/item/clothing/suit/armor/pcarrier
	head = /obj/item/clothing/head/soft/lar_maria/zhp_cap
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset

// --- Guard (melee, baton) ---
/obj/landmark/lar_maria_npc/guard
	npc_name = "security"
	outfit_type = /singleton/hierarchy/outfit/corpse/zhp_guard
	weapons = list(/obj/item/melee/baton)

/obj/landmark/lar_maria_npc/guard/apply_appearance(mob/living/carbon/human/H)
	if(prob(50))
		H.change_skin_tone(-115) // dark skin variant

// --- Guard (ranged, shotgun with beanbags) ---
/obj/landmark/lar_maria_npc/guard/ranged
	weapons = list(/obj/item/gun/projectile/shotgun/pump)

/obj/item/clothing/head/soft/lar_maria/zhp_cap
	name = "Zeng-Hu Pharmaceuticals cap"
	icon = 'maps/away/lar_maria/lar_maria_sprites.dmi'
	desc = "A green cap with Zeng-Hu Pharmaceuticals symbol on it."
	icon_state = "zhp_cap"
	item_icons = list(slot_head_str = 'maps/away/lar_maria/lar_maria_clothing_sprites.dmi')

// --- Virologist (male) ---
/obj/landmark/lar_maria_npc/virologist
	npc_name = "virologist"
	outfit_type = /singleton/hierarchy/outfit/corpse/zhp_virologist

/obj/landmark/corpse/lar_maria/virologist
	name = "dead virologist"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/zhp_virologist)

/singleton/hierarchy/outfit/corpse/zhp_virologist
	name = "Dead male ZHP virologist"
	uniform = /obj/item/clothing/under/rank/virologist
	suit = /obj/item/clothing/suit/storage/toggle/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex/nitrile
	head = /obj/item/clothing/head/surgery
	mask = /obj/item/clothing/mask/surgical
	glasses = /obj/item/clothing/glasses/eyepatch/hud/medical

// --- Virologist (female, with scalpel) ---
/obj/landmark/lar_maria_npc/virologist/female
	npc_name = "virologist"
	outfit_type = /singleton/hierarchy/outfit/corpse/zhp_virologist_female
	weapons = list(/obj/item/scalpel/basic)
	npc_gender = FEMALE

/obj/landmark/lar_maria_npc/virologist/female/apply_appearance(mob/living/carbon/human/H)
	H.change_hair("Flaired Hair")
	H.change_hair_color(174, 123, 72) // #ae7b48

/obj/landmark/corpse/lar_maria/virologist_female
	name = "dead virologist"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/zhp_virologist_female)
	hair_styles_per_species = list(SPECIES_HUMAN = list("Flaired Hair"))
	hair_colors_per_species = list(SPECIES_HUMAN = list("#ae7b48"))
	genders_per_species = list(SPECIES_HUMAN = list(FEMALE))

/singleton/hierarchy/outfit/corpse/zhp_virologist_female
	name = "Dead female ZHP virologist"
	uniform = /obj/item/clothing/under/rank/virologist
	suit = /obj/item/clothing/suit/storage/toggle/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex/nitrile
	mask = /obj/item/clothing/mask/surgical

////////////////////////////Notes and papers
/obj/item/paper/lar_maria/note_1
	name = "paper note"
	info = {"
			<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><b><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></b></center>
			<i>We received the latest batch of subjects this evening. Evening? Is it even evening? The schedule out here is so fucked in terms of sleep-cycles I forget to even check what time it is sometimes. I'm pretty sure it's evening anyway. Anyway, point is, we got the new guys, and thus far they seem like they fit the criteria pretty well. No family histories of diseases or the like, no current illnesses, prime physical condition, perfect subjects for our work. Tomorrow we start testing out the type 008 Serum. Hell if I know where this stuff's coming from, but it's fascinating. Injected into live subjects, it seems like it has a tendancy to not only cure them of ailments, but actually improve their bodily functions...</i>
			"}

/obj/item/paper/lar_maria/note_2
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			<i>I can't believe it, the type 8 Serum seems to actually have a regenerative effect on the subjects. We actually cut one's arm open during the test and ten minutes later, it had clotted. Fifteen and it was healing, and within two hours it was nothing but a fading scar. This is insanity, and the worst part is, we can't even determine HOW it does it yet. All these samples of the goo and not a damn clue how it works, it's infuriating! I'm going to try some additional tests with this stuff. I've heard it's got all kinds of uses, fuel enhancer, condiment, so on and so forth, even with this minty taste, but we'll see. There's got to be some rhyme or reason to this damned stuff.</i>
			"}

/obj/item/paper/lar_maria/note_3
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			<i>The samples of Type 8 we've got are almost out, but it seems like we're actually onto something major here. We'll need to get more sent over asap. This stuff may well be the key to immortality. We cut off one of the test subject's arms and they just put it back on and it healed in an hour or so to the point it was working fine. It's nothing short of miraculous.</i>
			"}

/obj/item/paper/lar_maria/note_4
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			<i>Tedd, don't get into the cells with the Type 8 subjects anymore, something's off about them the last couple days. They haven't been moving right, and they seem distracted nearly constantly, and not in a normal way. They also look like they're turning kinda... green? One of the other guys says it's probably just a virus or something reacting with it, but I don't know, something seems off.</i>
			"}

/obj/item/paper/lar_maria/note_5
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			This is a reminder to all facility staff, while we may be doing important work for the good of humanity here, our methods are not necessarily one hundred percent legal under SCG law, and as such you are NOT permitted, as outlined in your contract, to discuss the nature of your work, nor any other related information, with anyone not directly involved with the project without express permission of your facility director. This includes family, friends, local or galactic news outlets and bluenet chat forums.
			"}

/obj/item/paper/lar_maria/note_6
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			Due to the recent incident in the labs involving Type 8 test subject #12 and #33, all research personnel are to refrain from interacting directly with the research subjects involved in serum type 8 testing without the presence of armed guards and full Biohazard protective measures in place.
			"}

/obj/item/paper/lar_maria/note_7
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			<i>Can we get some more diversity in test subjects? I know we're mostly working off SCG undesirables, but martians and frontier colonists aren't exactly the most varied bunch. We could majorly benefit from having some Skrell test subjects, for example. Oooh, or one of those GAS things Xynergy's got a monopoly on.</i>
			"}

/obj/item/paper/lar_maria/note_8
	name = "paper note"
	info = {"<center><b><span style='color: green'>Zeng-Hu Pharmaceuticals</span></b></center>
			<center><span style='color: red'><small>CONFIDENTIAL USE ONLY</small></span></center>
			<i>On a related note, can we get some more female subjects? There's been some discussion about gender related differences in reactions to some of the chemicals we're working on. Testosterone and shit affecting chemical balances or something, I'm not sure, point is, variety.</i>
			"}

/obj/item/paper/lar_maria/note_9
	name = "paper note"
	info = "<i><span style='color: blue'>can we get some fresh carp sometime? Or freshish? Or frozen? I just really want carp, ok? I'm willing to pay for it if so.</span></i>"

/datum/ai_holder/human/lar_maria
	hostile = TRUE
	speak_chance = 50
	wander = TRUE
	cooperative = TRUE

/datum/say_list/lar_maria
	speak = list("Die!", "Fresh meat!", "Hurr!", "You said help will come!", "I did nothing!", "Eat my fist!", "One for the road!")
	emote_see = list("cries", "grins insanely", "itches fiercly", "scratches their face", "shakes their fists above their head")
	emote_hear = list("roars", "giggles", "breathes loudly", "mumbles", "yells something unintelligible")
