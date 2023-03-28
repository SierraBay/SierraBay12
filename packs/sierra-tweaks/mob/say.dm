/// Transforms the speech emphasis mods from [/atom/movable/proc/say_emphasis] into the appropriate HTML tags. Includes escaping.
#define ENCODE_HTML_EMPHASIS(input, char, html, varname) \
	var/static/regex/##varname = regex("(?<!\\\\)[char](.+?)(?<!\\\\)[char]", "g");\
	input = varname.Replace_char(input, "<[html]>$1</[html]>")

/// Scans the input sentence for speech emphasis modifiers, notably `_italics_` and `+bold+`
/mob/proc/say_emphasis(input)
	ENCODE_HTML_EMPHASIS(input, "_", "i", italics)
	ENCODE_HTML_EMPHASIS(input, "\\+", "b", bold)
	var/static/regex/remove_escape_backlashes = regex("\\\\(_|\\+)", "g") // Removes backslashes used to escape text modification.
	input = remove_escape_backlashes.Replace_char(input, "$1")
	return input

#undef ENCODE_HTML_EMPHASIS

/mob/living/format_say_message(message)
	return say_emphasis(..())

/mob/format_emote(emoter, message)
	return say_emphasis(..())


/mob/var/department_radio_keys = list(
	  ":r" = "right ear",	".r" = "right ear",
	  ":l" = "left ear",	".l" = "left ear",
	  ":i" = "intercom",	".i" = "intercom",
	  ":h" = "department",	".h" = "department",
	  ":+" = "special",		".+" = "special", //activate radio-specific special functions
	  ":c" = "Command",		".c" = "Command",
	  ":n" = "Science",		".n" = "Science",
	  ":m" = "Medical",		".m" = "Medical",
	  ":e" = "Engineering", ".e" = "Engineering",
	  ":s" = "Security",	".s" = "Security",
	  ":w" = "whisper",		".w" = "whisper",
	  ":t" = "Mercenary",	".t" = "Mercenary",
	  ":x" = "Raider",		".x" = "Raider",
	  ":u" = "Supply",		".u" = "Supply",
	  ":v" = "Service",		".v" = "Service",
	  ":p" = "AI Private",	".p" = "AI Private",
	  ":z" = "Entertainment",".z" = "Entertainment",
	  ":y" = "Exploration",		".y" = "Exploration",
	  ":o" = "Response Team",".o" = "Response Team", //ERT
	  ":j" = "Hailing", ".j" = "Hailing",

	  ":R" = "right ear",	".R" = "right ear",
	  ":L" = "left ear",	".L" = "left ear",
	  ":I" = "intercom",	".I" = "intercom",
	  ":H" = "department",	".H" = "department",
	  ":C" = "Command",		".C" = "Command",
	  ":N" = "Science",		".N" = "Science",
	  ":M" = "Medical",		".M" = "Medical",
	  ":E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",	".S" = "Security",
	  ":W" = "whisper",		".W" = "whisper",
	  ":T" = "Mercenary",	".T" = "Mercenary",
	  ":X" = "Raider",		".X" = "Raider",
	  ":U" = "Supply",		".U" = "Supply",
	  ":V" = "Service",		".V" = "Service",
	  ":P" = "AI Private",	".P" = "AI Private",
	  ":Z" = "Entertainment",".Z" = "Entertainment",
	  ":Y" = "Exploration",		".Y" = "Exploration",
	  ":O" = "Response Team", ".O" = "Response Team",
	  ":J" = "Hailing", ".J" = "Hailing",
// RUS Localization
	  ":к" = "right ear",	".к" = "right ear",
	  ":д" = "left ear",	".д" = "left ear",
	  ":ш" = "intercom",	".ш" = "intercom",
	  ":р" = "department",	".р" = "department",
	  ":с" = "Command",		".с" = "Command",
	  ":т" = "Science",		".т" = "Science",
	  ":ь" = "Medical",		".ь" = "Medical",
	  ":у" = "Engineering",	".у" = "Engineering",
	  ":ы" = "Security",	".ы" = "Security",
	  ":ц" = "whisper",		".ц" = "whisper",
	  ":е" = "Mercenary",	".е" = "Mercenary",
	  ":г" = "Supply",		".г" = "Supply",
	  ":м" = "Service",		".м" = "Service",
	  ":з" = "AI Private",	".з" = "AI Private",
	  ":я" = "Entertainment",".я" = "Entertainment",
	  ":н" = "Exploration",		".н" = "Exploration",
	  ":а" = "SCG Patrol",	".а" = "SCG Patrol",
	  ":й" = "ICGN Ship",	".й" = "ICGN Ship",
	  ":л" = "Recon",		".л" = "Recon",
	  ":щ" = "Response Team", ".щ" = "Response Team",
	  ":о" = "Hailing", ".о" = "Hailing",

	  ":К" = "right ear",	".К" = "right ear",
	  ":Д" = "left ear",	".Д" = "left ear",
	  ":Ш" = "intercom",	".Ш" = "intercom",
	  ":Р" = "department",	".Р" = "department",
	  ":С" = "Command",		".С" = "Command",
	  ":Т" = "Science",		".Т" = "Science",
	  ":Ь" = "Medical",		".Ь" = "Medical",
	  ":У" = "Engineering",	".У" = "Engineering",
	  ":Ы" = "Security",	".Ы" = "Security",
	  ":Ц" = "whisper",		".Ц" = "whisper",
	  ":Е" = "Mercenary",	".Е" = "Mercenary",
	  ":Г" = "Supply",		".Г" = "Supply",
	  ":М" = "Service",		".М" = "Service",
	  ":З" = "AI Private",	".З" = "AI Private",
	  ":Я" = "Entertainment",".Я" = "Entertainment",
	  ":Н" = "Exploration",		".Н" = "Exploration",
	  ":А" = "SCG Patrol",	".А" = "SCG Patrol",
	  ":Й" = "ICGN Ship",	".Й" = "ICGN Ship",
	  ":Л" = "Recon",		".Л" = "Recon",
	  ":Щ" = "Response Team", ".Щ" = "Response Team",
	  ":О" = "Hailing", ".О" = "Hailing",
)
