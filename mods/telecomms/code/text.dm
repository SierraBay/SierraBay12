// It's not perfect, but will work in most cases
// Don't use it if you don't know what you're doing
/proc/sanitize_html(t)
	var/static/regex/RegexReplaceHTML = new(@"<(/?)([^> ]*)([^>]*)>", "ig")
	t =  regex_replace_char(RegexReplaceHTML, t, /proc/html_replace)

	for (var/w in html_attr_blacklist)
		t = replacetext_char(t, w, "a")

	return t

/proc/html_replace(match, slash, tag, attrs)
	if (!(tag in html_allowed_tags))
		tag = "span"

	var/static/regex/RegexAttrs = new("(\\l+)( *= *\[\"\\'])", "ig")
	attrs = regex_replace_char(RegexAttrs, attrs, /proc/attrs_replace)

	return "<[slash][tag][attrs]>"

/proc/attrs_replace(match, attr, rest)
	if (!(attr in html_allowed_attrs))
		return "a[rest]"
	return "[attr][rest]"

// IE won't receive updates
// so...
var/global/list/html_attr_blacklist = list(
	"oncancel", "oncanplay", "oncanplaythrough", "onchange", "onclick", "onclose",
	"oncuechange", "ondblclick", "ondrag", "ondragend", "ondragenter", "ondragleave",
	"ondragover", "ondragstart", "ondrop", "ondurationchange", "onemptied", "onended",
	"onerror", "onfocus", "oninput", "oninvalid", "onkeydown", "onkeypress", "onkeyup",
	"onload", "onloadeddata", "onloadedmetadata", "onloadstart", "onmousedown",
	"onmouseenter", "onmouseleave", "onmousemove", "onmouseout", "onmouseover",
	"onmouseup", "onmousewheel", "onpause", "onplay", "onplaying", "onprogress",
	"onratechange", "onreset", "onresize", "onscroll", "onseeked", "onseeking",
	"onselect", "onshow", "onstalled", "onsubmit", "onsuspend", "ontimeupdate",
	"ontoggle", "onvolumechange", "onwaiting", "oncopy", "oncut", "onpaste", "onabort",
	"onerror", "onresize", "onscroll", "onunload", "onbegin", "onend", "onrepeat"
)
var/global/list/html_allowed_tags = list(
	"h1", "h2", "h3", "h4", "h5", "h6",
	"font", "span", "hr", "br",
	"p", "b", "i", "u", "s"
)
var/global/list/html_allowed_attrs = list(
	"style", "class",       // Everything
	"color", "size", "face" // <font></font>
)
