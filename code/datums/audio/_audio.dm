/singleton/audio
	/// Path to file source
	var/source

	/// The real (ie, artist's) audio title
	var/title

	/// The display title to use in game, if different
	var/display

	/// The normal volume to play the audio at, if set
	var/volume

	/// The artist's name
	var/author

	/// The collection (eg album) the audio belongs to
	var/collection

	/// The license under which the audio was made available
	var/singleton/license/license

	/// A link to the audio's source, if available
	var/url


/singleton/audio/Initialize()
	. = ..()
	license = GET_SINGLETON(license)


/singleton/audio/VV_static()
	return ..() + vars


/singleton/audio/proc/get_info(with_meta = TRUE)
	. = SPAN_GOOD("[title][!author?"":" by [author]"][!collection?"":" ([collection])"]")
	if (with_meta)
		. = "[.][!url?"":"\[<a href='[url]'>link</a>\]"]\[<a href='[license.url]'>license</a>\]"


/singleton/audio/proc/get_sound(channel)
	var/sound/sound = sound(source, FALSE, FALSE, channel, volume || 100)
	return sound


/singleton/audio/track/get_sound(channel = GLOB.lobby_sound_channel)
	var/sound/sound = ..()
	sound.repeat = TRUE
	return sound
