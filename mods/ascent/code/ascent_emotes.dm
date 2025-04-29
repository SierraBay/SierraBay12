/singleton/emote/audible/ascent_purr
	key = "purr"
	emote_message_3p = "USER purrs."
	emote_sound = 'mods/ascent/sound/ascent1.ogg'

/singleton/emote/audible/ascent_hiss
	key ="hiss"
	emote_message_3p = "USER hisses."
	emote_sound = 'sound/effects/razorweb.ogg'

/singleton/emote/audible/ascent_snarl
	key = "snarl"
	emote_message_3p = "USER snarls."
	emote_sound = 'sound/effects/razorweb_hiss.ogg'

/singleton/emote/visible/ascent_flicker
	key = "flicker"
	emote_message_3p = "USER flickers prismatically."

/singleton/emote/visible/ascent_glint
	key = "glint"
	emote_message_3p = "USER glints."

/singleton/emote/visible/ascent_glimmer
	key = "glimmer"
	emote_message_3p = "USER glimmers."

/singleton/emote/visible/ascent_pulse
	key = "pulse"
	emote_message_3p = "USER pulses with light."

/singleton/emote/visible/ascent_shine
	key = "shine"
	emote_message_3p = "USER shines brightly!"

/singleton/emote/visible/ascent_dazzle
	key = "dazzle"
	emote_message_3p = "USER dazzles!"

/mob/living/silicon/robot/flying/ascent
	default_emotes = list(
		/singleton/emote/audible/ascent_purr,
		/singleton/emote/audible/ascent_hiss,
		/singleton/emote/audible/ascent_snarl
	)

/datum/species/mantid
	default_emotes = list(
		/singleton/emote/audible/ascent_purr,
		/singleton/emote/audible/ascent_hiss,
		/singleton/emote/audible/ascent_snarl,
		/singleton/emote/visible/ascent_flicker,
		/singleton/emote/visible/ascent_glint,
		/singleton/emote/visible/ascent_glimmer,
		/singleton/emote/visible/ascent_pulse,
		/singleton/emote/visible/ascent_shine,
		/singleton/emote/visible/ascent_dazzle
	)

/datum/species/nabber/monarch_queen
	default_emotes = list(
		/singleton/emote/audible/bug_hiss,
		/singleton/emote/audible/bug_buzz,
		/singleton/emote/audible/bug_chitter,
		/singleton/emote/audible/ascent_purr,
	)
