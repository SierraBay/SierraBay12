/datum/computer_file/report/recipient/eng/generate_fields()
	..()
	set_access(access_engine)

/datum/computer_file/report/recipient/construction_work
	form_name = "NT-ENG-11"
	title = "Запрос на проведение строительных работ"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/construction_work/generate_fields()
	..()
	var/list/work_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Инженерный департамент")
	add_field(/datum/report_field/number, "Номер запроса")
	add_field(/datum/report_field/date, "Дата проведения работ")
	work_fields += add_field(/datum/report_field/people/from_manifest, "Ответственный за процесс", required = 1)
	work_fields += add_field(/datum/report_field/people/list_from_manifest, "Список привлеченных работников", required = 1)
	add_field(/datum/report_field/time,"Время начала")
	add_field(/datum/report_field/simple_text, "Вид работ", required = 1)
	add_field(/datum/report_field/simple_text, "Предоставленный доступ", required = 1)
	add_field(/datum/report_field/text_label/instruction, "Доступ обеспечивается сотрудником или его вышестоящим, рассмотревшим и принявшим данный запрос совместно с инженерным составом. Доступ может быть предоставлен на карту сотрудника(ов), выдан виде\
	гостевой карты или обеспечен иным способом, без дополнительных документов при условии, что он будет изъят по окончанию проведения соответствующих работ.")
	add_field(/datum/report_field/pencode_text, "Необходимые ресурсы", required = 1)
	work_fields += add_field(/datum/report_field/signature, "Подпись ответственного", required = 1)
	add_field(/datum/report_field/signature, "Подпись запросившего работы", required = 1)
	for(var/datum/report_field/field in work_fields)
		field.set_access(access_edit = access_engine)

/datum/computer_file/report/recipient/eng/report_work
	form_name = "NT-ENG-11a"
	title = "Отчёт о проведении ремонтных/строительных работ"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/eng/report_work/generate_fields()
	..()
	var/list/work_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Инженерный департамент")
	add_field(/datum/report_field/number, "Номер запроса для проведения данных работ")
	add_field(/datum/report_field/date, "Дата проведения работ")
	add_field(/datum/report_field/people/from_manifest, "Ответственный за процесс", required = 1)
	add_field(/datum/report_field/people/list_from_manifest, "Список привлеченных работников", required = 1)
	add_field(/datum/report_field/time,"Время начала")
	add_field(/datum/report_field/time,"Время окончания")
	add_field(/datum/report_field/simple_text, "Вид проведённой работы", required = 1)
	add_field(/datum/report_field/simple_text, "Доступ, предоставленный на время проведения работ", required = 1)
	work_fields += add_field(/datum/report_field/pencode_text, "Затраченные ресурсы", required = 1)
	work_fields += add_field(/datum/report_field/signature, "Подпись ответственного", required = 1)
	add_field(/datum/report_field/signature, "Подпись изъявшего временный доступ", required = 1)
	for(var/datum/report_field/field in work_fields)
		field.set_access(access_edit = access_engine)

/datum/computer_file/report/recipient/request_eng
	form_name = "NT-ENG-12"
	title = "Запрос к инженерии"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/request_eng/generate_fields()
	..()
	var/list/work_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Инженерный департамент")
	add_field(/datum/report_field/date, "Дата запроса")
	add_field(/datum/report_field/time, "Время запроса")
	add_field(/datum/report_field/people/from_manifest, "Запрашивающий", required = 1)
	add_field(/datum/report_field/pencode_text, "Содержание запроса", required = 1)
	add_field(/datum/report_field/simple_text,"Причина запроса", required = 1)
	work_fields += add_field(/datum/report_field/people/from_manifest,"Ответственный за запрос", required = 1)
	work_fields += add_field(/datum/report_field/options/yes_no, "Статус запроса (принят/отклонён)", required = 1)
	add_field(/datum/report_field/simple_text, "Предоставляемый доступ", required = 1)
	add_field(/datum/report_field/text_label/instruction, "Доступ обеспечивается сотрудником или его вышестоящим, рассмотревшим и принявшим данный запрос совместно с инженерным составом. Доступ может быть предоставлен на карту сотрудника/ов, выдан виде\
	гостевой карты или обеспечен иным способом, без дополнительных документов при условии, что он будет изъят по окончанию проведения соответствующих работ.")
	add_field(/datum/report_field/signature, "Подпись запросившего", required = 1)
	work_fields += add_field(/datum/report_field/signature, "Подпись ответственного", required = 1)
	for(var/datum/report_field/field in work_fields)
		field.set_access(access_edit = access_engine)

/datum/computer_file/report/recipient/eng/startup_systems
	form_name = "NT-ENG-13"
	title = "Отчёт о подготовке судовых систем"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/eng/startup_systems/generate_fields()
	..()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Инженерный департамент")
	add_field(/datum/report_field/date, "Дата")
	add_field(/datum/report_field/time, "Время")
	add_field(/datum/report_field/people/from_manifest, "Ответственный за процесс", required = 1)
	add_field(/datum/report_field/people/list_from_manifest, "Список привлечённых работников", required = 1)
	add_field(/datum/report_field/pencode_text,"Список систем судна и проведённое технического обслуживание", required = 1)
	add_field(/datum/report_field/signature,"Подпись ответственного", required = 1)

/datum/computer_file/report/recipient/eng/exosuit
	form_name = "NT-ENG-14"
	title = "Передача экзокостюма"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/eng/exosuit/generate_fields()
	..()
	var/list/ce_fields = list()
	var/list/robo_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Инженерный департамент")
	add_field(/datum/report_field/simple_text, "Отдел, в который передатеся экзокостюм", required = 1)
	robo_fields += add_field(/datum/report_field/people/from_manifest, "Имя сотрудника, передающего экзокостюм", required = 1)
	robo_fields += add_field(/datum/report_field/signature, "Подпись сотрудника инженерного отдела", required = 1)
	add_field(/datum/report_field/people/from_manifest, "Имя сотрудника, принимающего экзокостюм", required = 1)
	add_field(/datum/report_field/signature, "Подпись принимающего сотрудника", required = 1)
	add_field(/datum/report_field/date, "Дата передачи")
	add_field(/datum/report_field/time, "Время передачи")
	add_field(/datum/report_field/simple_text, "Назначение экзокостюма", required = 1)
	add_field(/datum/report_field/pencode_text, "Список установленного оборудования", required = 1)
	add_field(/datum/report_field/text_label/instruction, "Каждый элемент оборудования описать в виде: место установки, если не установлено, то указать. \
	При необходимости - вписать дополнительные пункты в списке. Пустые графы заполнить, как N/A")
	ce_fields += add_field(/datum/report_field/signature, "Подпись Главного Инженера")
	for(var/datum/report_field/field in robo_fields)
		field.set_access(access_edit = access_robotics)
	for(var/datum/report_field/field in ce_fields)
		field.set_access(access_edit = access_ce)

/datum/computer_file/report/recipient/eng/augmentations
	form_name = "AG17-N1S"
	title = "Аугментация сотрудника (Синтетика)"
	available_on_ntnet = 1

/datum/computer_file/report/recipient/eng/augmentations/generate_fields()
	..()
	var/list/ce_fields = list()
	var/list/robo_fields = list()
	add_field(/datum/report_field/text_label/header, "ИКН Сьерра - Инженерный департамент")
	add_field(/datum/report_field/simple_text, "Отдел, в котором работает аугментируемый", required = 1)
	add_field(/datum/report_field/people/from_manifest, "Имя сотрудника, в которого имплантируются аугментации", required = 1)
	add_field(/datum/report_field/simple_text, "Поколение (для ИПС)")
	robo_fields += add_field(/datum/report_field/people/from_manifest, "Имя сотрудника, проводящего операцию", required = 1)
	robo_fields += add_field(/datum/report_field/signature, "Подпись сотрудника, проводящего операцию", required = 1)
	add_field(/datum/report_field/date, "Дата аугментации")
	add_field(/datum/report_field/time, "Время аугментации")
	add_field(/datum/report_field/simple_text, "Причина аугментации", required = 1)
	add_field(/datum/report_field/options/yes_no, "Добавить инфомацию об аугментациях в базу данных?")
	add_field(/datum/report_field/pencode_text, "Список аугментаций", required = 1)
	add_field(/datum/report_field/text_label/instruction, "Каждую аугментацию оформить в виде: часть тела, если протез - описать марку протеза, функционал, название. \
	При необходимости - вписать дополнительные пункты в списке. Пустые графы заполнить, как N/A.")
	ce_fields += add_field(/datum/report_field/signature, "Подпись Главного Инженера")
	add_field(/datum/report_field/signature, "Подпись главы отдела аугментированного")
	set_access(access_robotics)
	for(var/datum/report_field/field in ce_fields)
		field.set_access(access_edit = access_ce)
	for(var/datum/report_field/field in robo_fields)
		field.set_access(access_edit = access_robotics)
