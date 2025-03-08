/mob/living/silicon
	var/speech_sounds

/mob/living/silicon/robot/default_emotes = list(
	/singleton/emote/audible/clap,
	/singleton/emote/visible/bow,
	/singleton/emote/visible/salute,
	/singleton/emote/visible/rsalute,
	/singleton/emote/visible/flap,
	/singleton/emote/visible/aflap,
	/singleton/emote/visible/twitch,
	/singleton/emote/visible/twitch_v,
	/singleton/emote/visible/nod,
	/singleton/emote/visible/shake,
	/singleton/emote/visible/glare,
	/singleton/emote/visible/look,
	/singleton/emote/visible/stare,
	/singleton/emote/visible/deathgasp_robot,
	/singleton/emote/audible/synth,
	/singleton/emote/audible/synth/ping,
	/singleton/emote/audible/synth/buzz,
	/singleton/emote/audible/synth/confirm,
	/singleton/emote/audible/synth/deny,
	/singleton/emote/audible/synth/security,
	/singleton/emote/audible/synth/security/halt,
	/singleton/emote/audible/synth/scream
)

/mob/living/silicon/handle_speech_sound()
	if(prob(20))
		var/list/returns[2]
		returns[1] = sound(pick(speech_sounds))
		returns[2] = 20
		return returns
	return ..()

/mob/living/silicon/ai
	speech_sounds = list(
		'mods/emote_panel/sound/robot_talk_heavy_1.ogg',
		'mods/emote_panel/sound/robot_talk_heavy_2.ogg',
		'mods/emote_panel/sound/robot_talk_heavy_3.ogg',
		'mods/emote_panel/sound/robot_talk_heavy_4.ogg'
	)

/mob/living/silicon/robot
	speech_sounds = list(
		'mods/emote_panel/sound/robot_talk_heavy_1.ogg',
		'mods/emote_panel/sound/robot_talk_heavy_2.ogg',
		'mods/emote_panel/sound/robot_talk_heavy_3.ogg',
		'mods/emote_panel/sound/robot_talk_heavy_4.ogg'
	)

/mob/living/silicon/robot/drone
	speech_sounds = list(
		'mods/emote_panel/sound/robot_talk_light_1.ogg',
		'mods/emote_panel/sound/robot_talk_light_2.ogg',
		'mods/emote_panel/sound/robot_talk_light_3.ogg',
		'mods/emote_panel/sound/robot_talk_light_4.ogg',
		'mods/emote_panel/sound/robot_talk_light_5.ogg'
	)

/mob/living/silicon/robot/flying
	speech_sounds = list(
		'mods/emote_panel/sound/robot_talk_light_1.ogg',
		'mods/emote_panel/sound/robot_talk_light_2.ogg',
		'mods/emote_panel/sound/robot_talk_light_3.ogg',
		'mods/emote_panel/sound/robot_talk_light_4.ogg',
		'mods/emote_panel/sound/robot_talk_light_5.ogg'
	)

/singleton/emote/audible/synth/do_extra(atom/user)
	if(emote_sound)
		playsound(user.loc, emote_sound, 50, 0)

/singleton/emote/audible/synth/scream
	key = "scream"
	emote_message_3p = "USER screams."
	emote_sound = 'mods/emote_panel/sound/scream_robot.ogg'
