/datum/map_template/ruin/exoplanet/statues
	name = "statues site"
	id = "statues"
	description = "Statues, they look like they are alive."
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("statues_base.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_HUMAN
	skip_main_unit_tests = TRUE

/obj/landmark/map_load_mark/statues
	name = "random statues site"
	templates = list(/datum/map_template/statues/pit, /datum/map_template/statues/anomaly, /datum/map_template/statues/fountain, /datum/map_template/statues/monolith)

/datum/map_template/statues
	skip_main_unit_tests = TRUE

/datum/map_template/statues/pit
	name = "random statues site #1 (pit)"
	id = "statues_1"
	mappaths = list("mods/_maps/insidiae_pack/maps/statues1.dmm")

/datum/map_template/statues/anomaly
	name = "random statues site #2 (anomaly)"
	id = "statues_2"
	mappaths = list("mods/_maps/insidiae_pack/maps/statues2.dmm")

/datum/map_template/statues/fountain
	name = "random statues site #3 (fountain)"
	id = "statues_3"
	mappaths = list("mods/_maps/insidiae_pack/maps/statues3.dmm")

/datum/map_template/statues/monolith
	name = "random statues site #4 (monolith)"
	id = "statues_4"
	mappaths = list("mods/_maps/insidiae_pack/maps/statues4.dmm")



/obj/structure/human_statue
	name = "statue"
	desc = "Suspiciously realistic, as if alive, the statue is made of a rough, colorless material resembling concrete. Pieces of decayed clothing cling to the dirt covering its surface. "
	icon = 'mods/_maps/insidiae_pack/icons/statues.dmi'
	icon_state = "statue"
	var/standing_icon = "statue"
	layer = BASE_HUMAN_LAYER
	density = TRUE
	anchored = FALSE
	var/is_standing = TRUE


/obj/structure/human_statue/Move()
	. = ..()

	if(!is_standing)
		return

	is_standing = FALSE
	icon_state = "[standing_icon]_f"
	src.visible_message(SPAN_WARNING("\The [src] loses its balance and falls!"))
	name = "fallen statue"

	var/sound = pick(list(
		'sound/effects/footstep/asteroid1.ogg',
		'sound/effects/footstep/asteroid2.ogg',
		'sound/effects/footstep/asteroid3.ogg',
		'sound/effects/footstep/asteroid4.ogg',
		'sound/effects/footstep/asteroid5.ogg',
		))
	playsound(src, sound, 70)


/obj/structure/human_statue/attack_hand(mob/user)
	if(!istype(user))
		return FALSE

	if(is_standing)
		return FALSE

	if(user.stat || user.restrained() || !Adjacent(user))
		return FALSE

	src.visible_message(SPAN_NOTICE("\The [user] is trying to put \the [src] in an upright position, as it should stand."))
	if(do_after(user, 3 SECONDS, src, DO_DEFAULT | DO_TARGET_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		is_standing = TRUE
		icon_state = standing_icon
		name = "statue"

		var/sound = pick(list(
			'sound/effects/footstep/floor1.ogg',
			'sound/effects/footstep/floor2.ogg',
			'sound/effects/footstep/floor3.ogg',
			'sound/effects/footstep/floor4.ogg',
			'sound/effects/footstep/floor5.ogg',
			))
		playsound(src, sound, 70)

	return ..()



/obj/structure/human_statue/fullsuit
	icon_state = "fullsuit"
	standing_icon = "fullsuit"

/obj/structure/human_statue/fullsuit/Initialize()
	. = ..()
	desc += pick(
		"It stands on tiptoe, helmeted, one gloved hand cupping the head while the other grips a long probe fused seamlessly to the forearm.",
		"It stands with arms crossed tightly over the chest, shoulders raised; the face is tilted upward. A dented helmet is fused as one piece with the head and neck.",
		"It bends at the waist, head bowed low, one hand pressed to the throat and the other clutching the edge of a belt. A cracked helmet brim merges with the skull and neck as if grown from the same substance.",
	)
	desc += " The helmet is made entirely of the same concrete-like material, so the head is not visible."

/obj/structure/human_statue/suit
	icon_state = "suit"
	standing_icon = "suit"

/obj/structure/human_statue/suit/Initialize()
	. = ..()
	desc += pick(
		"It stoops forward, holding a handheld scanner away from the body; the device, its buttons and cracked screen, is sculpted as part of the casting. The face squints with a set jaw, a streak of caked dirt frozen across the cheek.",
		"It kneels with both hands pressed to the temples, head bowed slightly; the face contorted in a grimace, teeth bared. Glove seams and wrist tubing continue seamlessly into the stone-like material.",
		"It sits cross-legged, back straight, one hand held palm-up with a small object resting in it; the face calm but fixed, eyelids half-closed and lips barely parted. The orb or specimen is sculpted as a seamless extension of the hand.",
		"It stands with both arms crossed over the chest as if cradling something precious; the face is locked in rapt focus, eyes soft and unfocused, lips faintly upturned yet still. A wrapped specimen bundle is fused into the arms as a single mass.",
		"It kneels on one knee, elbow braced against the raised leg, chin cupped in one hand; the gaze lifted upward, eyes wide and mouth set in a faint, uncertain smile. A pair of binoculars grows from the brow and hands, indistinguishable from the statue’s substance.",
	)

/obj/structure/human_statue/male
	icon_state = "male"
	standing_icon = "male"

/obj/structure/human_statue/male/Initialize()
	. = ..()
	desc += pick(
		"It kneels with both palms thrust outward, fingers rigid and splayed; the torso leans forward as if straining. The brow is furrowed deep, teeth bared, a cracked visor molded across the forehead.",
		"It crouches low, one hand pressed flat to the ground, the other clutching a tattered notebook fused into the form. The face hangs slack-jawed and hollow-eyed, a smear of dirt frozen from temple to chin.",
		"It bends forward at the waist, shoulders hunched, fingers curled as if gripping something. The mouth hangs open, eyes half-lidded. A small handheld scanner is welded into the palm as part of the casting.",
		"It reclines backward, one leg bent and the other stretched straight, one arm thrown behind the head while the other reaches skyward, fingers splayed. The face is caught mid-breath, lips parted and cheeks hollow; a wrist-mounted scanner melds into the forearm.",
		"It crouches low, head craned forward as if peering closely, one hand hovering just above the other. The eyes squint with harsh focus, lips pursed. A delicate magnifier extends from the fingers, grown seamlessly into the cast.",
	)

/obj/structure/human_statue/female
	icon_state = "female"
	standing_icon = "female"

/obj/structure/human_statue/female/Initialize()
	. = ..()
	desc += pick(
		"Its head is thrown back, mouth stretched wide in a frozen scream; neck tendons and cords sharply defined. Both arms fling outward at shoulder height.",
		"It stands with one arm raised, palm outward as if warding something off; the eyes wide, mouth slightly parted, cheeks taut. A thin wrist-mounted scanner is fused into the forearm.",
		"It hunches with both hands lifted to shield the face, fingers splayed and knuckles sharp; eyes squeezed shut. A cracked tablet clings to the forearm, rendered from the same gray material.",
		"It sits with legs splayed, left arm limp and extended, right hand clamped over the mouth; eyelids pressed tight, lips parted faintly. An oxygen tube loops around the neck as part of the figure.",
		"It stands twisted at the shoulders, torso turned as if to flee, feet braced hard against the ground; the mouth hangs open in a silent scream, eyes pulled wide with strain. A tablet is fused flat against the chest, edges blurred into the casting.",
	)

/obj/structure/human_statue/spaceadapt
	icon_state = "spaceadapt"
	standing_icon = "spaceadapt"

/obj/structure/human_statue/spaceadapt/Initialize()
	. = ..()
	desc += pick(
		"It kneels on one leg, head tilted sharply upward, mouth frozen open. A vial rests clasped in the right hand, stopper and glass fused into the whole, while the left hand presses palm-down to the ground.",
		"It bends at the waist, both hands cupped together with fingertips almost touching. The face is locked in a concentrated frown, lips pressed thin, eyes fixed.",
		"It recoils with hips twisted aside, one arm raised across the chest, fingers stiff and spread. The face contorts in a grimace, nose wrinkled, lips pulled back; strands of hair are plastered to the jawline.",
		"It kneels forward, both hands clasped over the lower abdomen; the jaw clenched, nostrils flared, eyes shut tight in sudden pain. Straps of a harness and a cracked field notebook are embedded seamlessly into the lap.",
	)

/obj/structure/human_statue/skrell
	icon_state = "skrell"
	standing_icon = "skrell"

/obj/structure/human_statue/skrell/Initialize()
	. = ..()
	desc += pick(
		"It stands upright, hands lifted as if framing a view, thumbs and forefingers forming a rectangle. A wrist-mounted instrument grows from the forearm as a single piece of stone.",
		"It kneels low, torso leaning forward, head cocked to the side with a fixed, studying stare; the mouth barely parted. An eyepiece and narrow diagnostic tool extend from the brow into the temple, fused with the skull.",
		"It holds both hands cupped at chest height, fingers curved gently as if cradling something fragile. The face hangs slack, jaw loose, gaze unfocused. A shallow hollow is carved into the palms as part of the statue.",
		"It twists at the torso, head turned over the left shoulder, mouth stretched wide in a silent scream, eyes glazed. The right hand is clenched tight, tendons strained. A scorched implement continues seamlessly from the forearm.",
	)



/obj/random/human_statue
	name = "random statue"
	desc = "This is random statue."
	icon = 'mods/_maps/insidiae_pack/icons/statues.dmi'
	icon_state = "fullsuit"
	spawn_nothing_percentage = 40

/obj/random/human_statue/spawn_choices()
	return list(
		/obj/structure/human_statue/fullsuit = 5,
		/obj/structure/human_statue/suit = 4,
		/obj/structure/human_statue/male = 3,
		/obj/structure/human_statue/female = 3,
		/obj/structure/human_statue/spaceadapt = 2,
		/obj/structure/human_statue/skrell = 1
		)
