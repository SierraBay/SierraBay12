/datum/computer_file/report/recipient/sci/generate_fields()
	..()
	set_access(access_research)

/datum/computer_file/report/recipient/sci/anomaly
	form_name = "NT-SCI-05"
	title = "Изучение Аномалий"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/sci/anomaly/generate_fields()
	..()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Научный департамент")
	add_field(/datum/report_field/simple_text, "Кодовое название AO", required = 1)
	add_field(/datum/report_field/people/from_manifest, "Отчет заполнял", required = 1)
	add_field(/datum/report_field/pencode_text, "Процедуры сдерживания", required = 1)
	add_field(/datum/report_field/pencode_text, "Общее описание", required = 1)
	add_field(/datum/report_field/simple_text, "Примерный возраст AO", required = 1)
	add_field(/datum/report_field/simple_text, "Уровень угрозы AO", required = 1)

/datum/computer_file/report/recipient/sci/volunteer
	form_name = "HR-NTCO-02b"
	title = "Форма добровольца для исследований"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/sci/volunteer/generate_fields()
	..()
	var/list/rd_fields = list()
	var/list/sci_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Научный департамент")
	add_field(/datum/report_field/date, "Дата")
	add_field(/datum/report_field/time, "Время")
	add_field(/datum/report_field/people/from_manifest, "Имя и должность добровольца", required = 1)
	add_field(/datum/report_field/text_label/instruction, "Фото обязательно")
	add_field(/datum/report_field/simple_text, "Область исследования", required = 1)
	sci_fields += add_field(/datum/report_field/people/from_manifest, "Полное имя и должность ответственного за проведения исследования", required = 1)
	rd_fields += add_field(/datum/report_field/signature, "Подпись Директора Исследований")
	sci_fields += add_field(/datum/report_field/signature, "Подпись ответственного", required = 1)
	add_field(/datum/report_field/signature, "Подпись добровольца", required = 1)
	for(var/datum/report_field/field in rd_fields)
		field.set_access(access_edit = access_rd)
	for(var/datum/report_field/field in sci_fields)
		field.set_access(access_edit = access_research)

/datum/computer_file/report/recipient/sci/volunteer_denied
	form_name = "HR-NTCO-02b-D"
	title = "Прекращение добровольного исследования"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/sci/volunteer_denied/generate_fields()
	..()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Научный департамент")
	add_field(/datum/report_field/date, "Дата")
	add_field(/datum/report_field/time, "Время")
	add_field(/datum/report_field/people/from_manifest, "Имя и должность добровольца", required = 1)
	add_field(/datum/report_field/simple_text, "Причина прекращения", required = 1)
	add_field(/datum/report_field/signature, "Подпись", required = 1)

/datum/computer_file/report/recipient/sci/prototype
	form_name = "NT-SCI-07"
	title = "Передача прототипов оборудования"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/sci/prototype/generate_fields()
	..()
	var/list/rd_fields = list()
	var/list/sci_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Научный департамент")
	add_field(/datum/report_field/simple_text, "Отдел, в который передаются прототипы", required = 1)
	sci_fields += add_field(/datum/report_field/people/from_manifest, "Имя научного сотрудника, передающего прототипы", required = 1)
	sci_fields += add_field(/datum/report_field/signature, "Подпись научного сотрудника", required = 1)
	add_field(/datum/report_field/people/from_manifest, "Имя сотрудника, принимающего прототипы", required = 1)
	add_field(/datum/report_field/signature, "Подпись принимающего сотрудника", required = 1)
	add_field(/datum/report_field/date, "Дата передачи")
	add_field(/datum/report_field/time, "Время передачи")
	add_field(/datum/report_field/pencode_text, "Список передаваемых прототипов", required = 1)
	add_field(/datum/report_field/text_label/instruction, "При необходимости - вписать дополнительные пункты в списке. Пустые графы заполнить, как N/A")
	rd_fields += add_field(/datum/report_field/signature, "Подпись Директора Исследований")
	for(var/datum/report_field/field in sci_fields)
		field.set_access(access_edit = access_research)
	for(var/datum/report_field/field in rd_fields)
		field.set_access(access_edit = access_rd)
