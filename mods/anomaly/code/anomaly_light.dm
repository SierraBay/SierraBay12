//Отвечает за вспышки и свет от аномалии
/obj/anomaly
	///Сделать вспышку после активации?
	var/light_after_activation = FALSE
	///Время, которое будет держаться свет от активации
	var/time_of_light = 1 SECOND
	///Цвет вспышки
	var/color_of_light = COLOR_WHITE
	var/range_of_light = 3
	var/power_of_light = 2

///Запускаем свет/вспышку
/obj/anomaly/proc/start_light()
	set_light(3, 2, color_of_light)
	addtimer(new Callback(src, PROC_REF(stop_light)), time_of_light)

/obj/anomaly/proc/stop_light()
	set_light(0)
