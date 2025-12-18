#include "../builder.dm"
#include "../roundend.dm"
#include "anomalies_menu.dm"
#include "artefacts_menu.dm"
#include "main_buttons.dm"
#include "storytellers_menu.dm"
#include "weather_menu.dm"


// ANOMALY CONTROL MODULE
/datum/admins/proc/anomaly_control()
	set category = "Fun"
	set desc = "Control anomalies in world"
	set name = "Anomaly control"

	if(!check_rights(R_SPAWN) && !check_rights(R_DEBUG) && !check_rights(R_ADMIN))
		return
	SSanom.Topic(href_list = list("show_anom_control_main" = "Начальное меню управления аномалиями"))

/datum/controller/subsystem/processing/anom/proc/ShowAnomcontrolUI(list/input_html, mob/living/user)
	draw_main_buttons(input_html) //Рисуем главные верхние кноки
