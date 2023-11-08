/obj/machinery/atmospherics/binary/circulator
	name = "циркулятор"
	desc = "Турбина-циркулятор газа и теплообменник."

/obj/machinery/atmospherics/binary/oxyregenerator
	name = "кислородный регенератор"
	desc = "Машина для разрушения связей в углекислом газе и выделения чистого кислорода."

/obj/machinery/atmospherics/binary/passive_gate
	name = "регулятор давления"
	desc = "Односторонний воздушный клапан, который может использоваться для регулирования входного или выходного давления, а также расхода воздуха. Не требует питания."

/obj/machinery/atmospherics/binary/pump
	name = "газовый насос"
	desc = "Насос."

/obj/machinery/atmospherics/binary/pump/high_power
	name = "улучшенный газовый насос"
	desc = "Насос. Имеет вдвое большую мощность, чем стандартный."

/obj/machinery/atmospherics/omni/filter
	name = "всенаправленный газовый фильтр"

/obj/machinery/atmospherics/omni/mixer
	name = "всенаправленный газовый смеситель"

/obj/machinery/atmospherics/omni
	name = "всенаправленное устройство"

/obj/machinery/atmospherics/unary/freezer
	name = "система охлаждения газа"
	desc = "Охлаждает газ при подключении к трубопроводной сети."

/obj/machinery/atmospherics/unary/heat_exchanger
	name = "теплообменник"
	desc = "Обменивается теплом между двумя вводимыми газами. Устанавливается для быстрого теплообмена."

/obj/machinery/atmospherics/unary/heater
	name = "система нагрева газа"
	desc = "Нагревает газ при подключении к трубопроводной сети."

/obj/machinery/atmospherics/unary/outlet_injector
	name = "инжектор"
	desc = "Пассивно нагнетает воздух в окружающее пространство. К нему прикреплен клапан, регулирующий расход воздуха."

/obj/machinery/atmospherics/unary/tank
	name = "балон под давлением"
	desc = "Большой балон, содержащий газ под давлением."

/obj/machinery/atmospherics/unary/tank/air
	name = "балон с воздухом"

/obj/machinery/atmospherics/unary/tank/oxygen
	name = "балон с кислородом"

/obj/machinery/atmospherics/unary/tank/nitrogen
	name = "балон с азотом"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "балон с углекислым газом"

/obj/machinery/atmospherics/unary/tank/phoron
	name = "балон с фороном"

/obj/machinery/atmospherics/unary/tank/nitrous_oxide
	name = "балон с закисью азота"

/obj/machinery/atmospherics/unary/tank/hydrogen
	name = "балон с водородом"

/obj/machinery/atmospherics/unary/vent_pump
	name = "вентиляция"
	desc = "К нему присоединены клапан и насос."

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "большая вентиляция"

/obj/machinery/atmospherics/unary/vent_pump/Initialize()
	if (!id_tag)
		id_tag = num2text(sequential_id("obj/machinery"))
	if(controlled)
		var/area/A = get_area(src)
		if(A && !A.air_vent_names[id_tag])
			var/new_name = "[A.name] вентиляция #[length(A.air_vent_names)+1]"
			A.air_vent_names[id_tag] = new_name
			SetName(new_name)
	. = ..()

/obj/machinery/atmospherics/unary/vent_pump/engine
	name = "Вентиляционный насос двигателя"

/obj/machinery/atmospherics/unary/vent_scrubber
	name = "вентиляционный скраббер"
	desc = "К нему прикреплены клапан и насос."

/obj/machinery/atmospherics/unary/vent_scrubber/Initialize()
	if (!id_tag)
		id_tag = num2text(sequential_id("obj/machinery"))
	if(!scrubbing_gas)
		reset_scrubbing()
	var/area/A = get_area(src)
	if(A && !A.air_scrub_names[id_tag])
		var/new_name = "[A.name] вентиляционный скраббер #[length(A.air_scrub_names)+1]"
		A.air_scrub_names[id_tag] = new_name
		SetName(new_name)
	. = ..()

/obj/machinery/atmospherics/pipe/cap/sparker
	name = "воспламенитель для труб"
	desc = "Воспламенитель для труб. Применяется для разжигания огня в трубах."

/obj/machinery/atmospherics/portables_connector
	name = "порт коннектора"
	desc = "Для подключения портативных устройств, связанных с контролем атмосферы."

/obj/machinery/atmospherics/valve/shutoff
	name = "автоматический запорный клапан"
	desc = "Автоматический клапан со схемой управления и датчиком целостности трубопровода, способный автоматически изолировать поврежденные участки трубопроводной сети."

/obj/machinery/atmospherics/valve/shutoff/scrubbers
	name = "запорный клапан скраббера"

/obj/machinery/atmospherics/valve/shutoff/supply
	name = "запорный клапан питания"

/obj/machinery/atmospherics/valve/shutoff/fuel
	name = "топливный запорный клапан"

/obj/machinery/atmospherics/tvalve
	name = "ручной переключающий клапан"
	desc = "Трубный клапан."

/obj/machinery/atmospherics/tvalve/digital
	name = "цифровой переключающий клапан"
	desc = "Клапан с цифровым управлением."

/obj/machinery/atmospherics/tvalve/mirrored/digital
	name = "цифровой переключающий клапан"
	desc = "Клапан с цифровым управлением."

/obj/machinery/atmospherics/valve
	name = "ручной клапан"
	desc = "Клапан трубы."

/obj/machinery/atmospherics/valve/digital
	name = "цифровой клапан"
	desc = "Клапан с цифровым управлением."

/obj/machinery/atmospherics/pipe/simple
	name = "труба"
	desc = "Метровый отрезок обычной трубы."

/obj/machinery/atmospherics/pipe/simple/visible/scrubbers
	name = "труба скраббера"
	desc = "Метровый участок трубы скраббера."

/obj/machinery/atmospherics/pipe/simple/visible/supply
	name = "труба подачи воздуха"
	desc = "Метровый отрезок трубы подачи воздуха."

/obj/machinery/atmospherics/pipe/simple/visible/fuel
	name = "топливная труба"

/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	name = "труба скраббера"
	desc = "Метровый участок трубы скраббера."

/obj/machinery/atmospherics/pipe/simple/hidden/supply
	name = "труба подачи воздуха"
	desc = "Метровый отрезок трубы подачи воздуха."

/obj/machinery/atmospherics/pipe/manifold
	name = "трубный коллектор"
	desc = "Коллектор, состоящий из обычных труб."

/obj/machinery/atmospherics/pipe/manifold/visible/scrubbers
	name = "коллектор, труб скрабберов"
	desc = "Коллектор, состоящий из труб скрабберов."

/obj/machinery/atmospherics/pipe/manifold/visible/supply
	name = "коллектор, труб подачи воздуха"
	desc = "Коллектор, состоящий из подающих воздух труб."

/obj/machinery/atmospherics/pipe/manifold/visible/fuel
	name = "коллектор топливопровода"

/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers
	name = "коллектор труб скрабберов"
	desc = "Коллектор, состоящий из труб скрабберов."

/obj/machinery/atmospherics/pipe/manifold/hidden/supply
	name = "коллектор труб подачи воздуха"
	desc = "Коллектор, состоящий из подающих воздух труб."

/obj/machinery/atmospherics/pipe/manifold4w
	name = "4-х сторонний трубный коллектор"
	desc = "Коллектор, состоящий из обычных труб."

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	name = "4-х сторонний колелектор труб скрабберов"
	desc = "Коллектор, состоящий из труб скрабберов."

/obj/machinery/atmospherics/pipe/manifold4w/visible/supply
	name = "4-х колелектор труб подачи воздуха"
	desc = "Коллектор, состоящий из подающих воздух труб."

/obj/machinery/atmospherics/pipe/manifold4w/visible/fuel
	name = "4-х сторонний коллектор топливопровода"

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	name = "4-х сторонний колелектор труб скрабберов"
	desc = "Коллектор, состоящий из труб скрабберов."

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	name = "4-х сторонний колелектор труб подачи воздуха"
	desc = "Коллектор, состоящий из подающих воздух труб."

/obj/machinery/atmospherics/pipe/manifold4w/hidden/fuel
	name = "4-х сторонний коллектор топливопровода"

/obj/machinery/atmospherics/pipe/cap
	name = "заглушка для труб"
	desc = "Торцевая крышка для труб."

/obj/machinery/atmospherics/pipe/cap/visible/scrubbers
	name = "заглушка для труб скрабберов"
	desc = "Торцевая крышка для труб скрабберов."

/obj/machinery/atmospherics/pipe/cap/visible/supply
	name = "заглушка для труб подачи воздуха"
	desc = "Торцевая крышка для труб подачи воздуха."

/obj/machinery/atmospherics/pipe/cap/visible/fuel
	name = "заглушка для топливопровода"
	desc = "Торцевая крышка для топливных труб."

/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers
	name = "заглушка для труб скрабберов"
	desc = "Торцевая крышка для труб скрабберов."

/obj/machinery/atmospherics/pipe/cap/hidden/supply
	name = "заглушка для труб подачи воздуха"
	desc = "Торцевая крышка для труб подачи воздуха."

/obj/machinery/atmospherics/pipe/cap/hidden/fuel
	name = "заглушка для топливопровода"
	desc = "Торцевая крышка для топливных труб."

/obj/machinery/atmospherics/pipe/vent
	name = "вентиляция"
	desc = "Большая вентиляция."

/obj/machinery/atmospherics/pipe/vent/high_volume
	name = "большая вентиляция"

/obj/machinery/atmospherics/pipe/simple/visible/universal
	name = "универсальный переходник для труб"
	desc = "Переходник для штатных, подающих, скрабберных и топливных труб."

/obj/machinery/atmospherics/pipe/simple/hidden/universal
	name = "универсальный переходник для труб"
	desc = "Переходник для штатных, подающих, скрабберных и топливных труб."
