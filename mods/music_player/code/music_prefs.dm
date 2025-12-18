/datum/client_preference/play_jukeboxes
	description ="Play jukeboxes and boomboxes"
	key = "SOUND_JUKEBOXES"

/datum/client_preference/play_pmps
	description ="Play music players"
	key = "SOUND_PMPS"

/datum/sound_token
	var/datum/client_preference/preference

/datum/sound_token/proc/check_preference(atom/listener)
	if(preference)
		var/mob/M = listener
		if(istype(M))
			if((M.get_preference_value(preference) != GLOB.PREF_YES))
				return FALSE
	return TRUE

/singleton/sound_player/PlaySoundDatum(atom/source, sound_id, sound/sound, range, prefer_mute, datum/client_preference/preference)
	var/token_type = isnum(sound.environment) ? /datum/sound_token : /datum/sound_token/static_environment
	return new token_type(source, sound_id, sound, range, prefer_mute, preference)

/singleton/sound_player/PlayLoopingSound(atom/source, sound_id, sound, volume, range, falloff = 1, echo, frequency, prefer_mute, datum/client_preference/preference)
	var/sound/S = istype(sound, /sound) ? sound : new(sound)
	S.environment = 0 // Ensures a 3D effect even if x/y offset happens to be 0 the first time it's played
	S.volume  = volume
	S.falloff = falloff
	S.echo = echo
	S.frequency = frequency
	S.repeat = TRUE

	return PlaySoundDatum(source, sound_id, S, range, prefer_mute, preference)

/datum/sound_token/New(atom/source, sound_id, sound/sound, range = 4, prefer_mute = FALSE, datum/client_preference/preference)
	src.preference	= preference
	..()

/datum/sound_token/PrivAddListener(atom/listener)
	if(!check_preference(listener))
		return
	..()

/datum/sound_token/PrivUpdateListener(listener, update_sound = TRUE)
	if(!check_preference(listener))
		PrivRemoveListener(listener)
		return
	..()


/datum/jukebox/Play()
	if (playing)
		return
	var/datum/jukebox_track/track = tracks[index]
	if (!track.source)
		return
	playing = TRUE
	token = GLOB.sound_player.PlayLoopingSound(owner, sound_id, track.source,
		volume, range, falloff, frequency = frequency, prefer_mute = TRUE, preference = /datum/client_preference/play_jukeboxes)
	owner.queue_icon_update()