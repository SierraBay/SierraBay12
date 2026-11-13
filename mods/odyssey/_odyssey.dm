/singleton/modpack/odyssey
	name = "Одиссея"
	desc = "Цепочка смен с сохранением повреждений карты, машин, меха и счетов. Старт и продолжение через голосование в лобби."
	author = "Lexanx"


/singleton/modpack/odyssey/Topic(href, href_list)
	if (!href_list["show_odyssey_stats"])
		return
	var/mob/user = usr
	if (!user)
		return
	if (!islist(odyssey_last_campaign_stats))
		to_chat(user, SPAN_WARNING("Нет сохранённой статистики Одиссеи."))
		return
	var/datum/browser/popup = new(user, "odyssey_campaign_stats", "Odyssey Statistic", 780, 720)
	popup.set_content(odyssey_campaign_stats_html(odyssey_last_campaign_stats))
	popup.open()
