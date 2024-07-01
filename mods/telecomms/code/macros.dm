/// List Procs

#define list_find(L, needle, LIMITS...) L.Find(needle, LIMITS)

/// Regex

#define regex_replace_char(RE, ARGS...) RE.Replace(ARGS)
#define regex_replace(RE, ARGS...) RE.Replace(ARGS)
#define regex_find_char(RE, ARGS...) RE.Find(ARGS)
#define regex_find(RE, ARGS...) RE.Find(ARGS)
