#define PENCODE_IMAGE_HOSTS_FILE "config/image_hosts.txt"

/datum/configuration
	/// Hosts that [img] links may point to, from config/image_hosts.txt, as host = TRUE.
	/// Empty when the file is missing: then no host is allowed and [img] stays plain text.
	var/list/pencode_image_hosts = list()

/datum/configuration/New()
	. = ..()
	load_pencode_image_hosts(PENCODE_IMAGE_HOSTS_FILE)

/// Reads one host per line; lines starting with # are comments. See config/example/image_hosts.txt.
/// A line that isn't a bare host name is skipped with a warning, so "https://i.imgur.com" doesn't silently allow nothing.
/datum/configuration/proc/load_pencode_image_hosts(filename)
	// Not static: config/New() runs before static vars get their values.
	var/regex/host_name = regex(@"^[a-z0-9-]+(\.[a-z0-9-]+)+$")
	pencode_image_hosts = list()
	if(!fexists(filename))
		log_misc("[filename] is missing: no image hosts are allowed, so \[img\] stays plain text.")
		return
	for(var/line in read_commentable(filename))
		var/host = lowertext(line)
		if(!host_name.Find(host))
			log_misc("Skipped '[line]' in [filename]: write a bare host name, like i.imgur.com.")
			continue
		pencode_image_hosts[host] = TRUE

#undef PENCODE_IMAGE_HOSTS_FILE
