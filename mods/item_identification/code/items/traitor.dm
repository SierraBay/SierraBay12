/obj/item/device/augment_implanter/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Благодаря обширным знаниям комплексных устройств, вы идентифицируете эту коробочку как имплантер аугментаций."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_EXPERIENCED,
			)
		)
	)

/obj/item/grenade/supermatter/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в области оружия или сложных устройств достаточно, чтобы определить, что в этой гранате находится небольшой кусочек суперматерии"),
			"failure" = SPAN_BAD("Выглядит как светошумовая граната с очень яркой раскраской."),
			"skillcheck" = list(
				SKILL_WEAPONS = SKILL_MASTER,
				SKILL_DEVICES = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/grenade/anti_photon/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в области оружия или сложных устройств достаточно, чтобы определить, что эта граната способна рассеивать фотоны, и тем самым гасить видимый свет в области своего использования."),
			"failure" = SPAN_BAD("Выглядит как ЭМИ граната."),
			"skillcheck" = list(
				SKILL_WEAPONS = SKILL_EXPERIENCED,
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/rig_module/electrowarfare_suite/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств или оружия достаточно, чтобы понять, что модификации предоставляемые этим модулем усложняют слежку со стороны ИИ."),
			"failure" = SPAN_BAD("Вы не можете определить назначение модуля."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_BASIC,
				SKILL_WEAPONS = SKILL_BASIC
			)
		)
	)

/obj/item/rig_module/voice/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств или оружия достаточно, чтобы понять, что этот модуль предоставляет возможность синтеза голоса по заданным параметрам."),
			"failure" = SPAN_BAD("Вы не можете определить назначение модуля."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_BASIC,
				SKILL_WEAPONS = SKILL_BASIC
			)
		)
	)

/obj/item/rig_module/power_sink/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств или оружия достаточно, чтобы понять, что этот модуль может быть задействован для подпитки энергетических резервов костюма напрямую через выкачивание энергии из внешних источников."),
			"failure" = SPAN_BAD("Вы не можете определить назначение модуля."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_BASIC,
				SKILL_WEAPONS = SKILL_BASIC
			)
		)
	)

/obj/item/rig_module/fabricator/energy_net/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств или оружия достаточно, чтобы понять, что это комплексный энергетический проектор, способный создавать энергетическую сеть для захвата цели."),
			"failure" = SPAN_BAD("Вы не можете определить назначение модуля."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED,
				SKILL_WEAPONS = SKILL_TRAINED
			)
		)
	)

/obj/item/material/harpoon/bomb/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств или оружия достаточно, чтобы понять, что на конце гарпуна установлена взрывчатка, которая предположительно должна сработать при броске в цель."),
			"failure" = SPAN_BAD("Очевидно, выглядит как гарпун, но вы не можете понять что за устройство находится на его конце."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED,
				SKILL_WEAPONS = SKILL_TRAINED
			)
		)
	)

/obj/item/melee/energy/sword/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств или ближнего боя достаточно, чтобы понять, что это рукоять энергетического клинка. При активации рукояти из нее проецируется поток энергии, который может быть мощной разрезающей силой."),
			"skillcheck" = list(
				SKILL_COMBAT = SKILL_BASIC,
				SKILL_DEVICES = SKILL_BASIC
			)
		)
	)

/obj/item/clothing/head/helmet/space/psi_amp/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших обширных знаний в медицине и сложных устройствах достаточно, для того чтобы определить, что это устройство используется для значительного сильного усиления латентных пси способностей путем прямого вмешательства в работу мозга. Подключение к мозгу возможно после выбора мозговой карты на устройстве. При активации короны, будет просверлено несколько отверстий к мозгу с применением анестезии."),
			"failure" = SPAN_BAD("Выглядит как несуразная диадема. Даже если принять это за головной убор, то вам абсолютно ничего неизвестно про установку его в мозг, лишь исходя из этого осмотра."),
			"skillcheck" = list(
				SKILL_MEDICAL = SKILL_MASTER,
				SKILL_DEVICES = SKILL_MASTER
			),
			"LOGIC" = "AND"
		)
	)


/obj/item/device/encryptionkey/syndicate/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний информационных технологий достаточно, чтобы понять, что данный ключ использует незнакомый вам шифрключ и ссылается на незнакомую частоту."),
			"skillcheck" = list(
				SKILL_COMPUTER = SKILL_TRAINED
			)
		)
	)

/obj/item/plastique/update_mod_identification()
	mod_skill_identification = list(
		"device_usage" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в различном оружии было бы достаточно для использования этой взрывчатки."),
			"failure" = SPAN_BAD("Вы понимаете, что не смогли бы использовать эту взрывчатку при необходимости."),
			"skillcheck" = list(
				SKILL_WEAPONS = SKILL_TRAINED
			)
		),
		"device_info" = list(
			"success" = SPAN_GOOD("Вы определяете, что это C-4."),
			"failure" = SPAN_BAD("Вы понимаете что это взрывчатка, но не можете определить ее тип."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_TRAINED
			)
		)
	)

/*
/obj/item/reagent_containers/glass/bottle/dye/polychromic/strong/update_mod_identification()
	var/reagent_is_there = "содержит"
	if(!reagents.has_reagent(/datum/reagent/dye/strong))
		reagent_is_there = "содержала"

	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в области химии или готовки достаточно, чтобы понять, что данная емкость [reagent_is_there] краситель."),
			"skillcheck" = list(
				SKILL_CHEMISTRY = SKILL_TRAINED,
				SKILL_COOKING = SKILL_EXPERIENCED
			)
		)
	)
*/

/obj/item/device/encryptionkey/syndie_full/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний информационных технологий достаточно, чтобы понять, что данный ключ использует множество шифрключей и частот для возможности прослушки всего радио эфира. Должно быть наподобие того, как устроен ключ шифрования у Капитана. Но дополнительно еще есть доступ к незнакомой частоте."),
			"skillcheck" = list(
				SKILL_COMPUTER = SKILL_TRAINED
			)
		)
	)

/obj/item/door_charge/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших оружейных знаний хватает, чтобы понять, что это растяжка для шлюзов."),
			"failure" = SPAN_BAD("Выглядит действительно подозрительно, но вы не можете понять что это за устройство."),
			"skillcheck" = list(
				SKILL_WEAPONS = SKILL_TRAINED
			)
		)
	)

/obj/item/shield_diffuser/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний криминалистики или сложных устройств достаточно, чтобы понять, что это миниатюрный рассеиватель энергощитов"),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED,
				SKILL_FORENSICS = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/stamp/chameleon/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших обширных знаний криминалистики достаточно, чтобы понять, что это изменяемая печать для подделки документов."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/pen/chameleon/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших обширных знаний криминалистики достаточно, чтобы понять, что это специальная ручка для подмены стиля написания."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/scanner/health/syndie/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Базовых знаний сложных устройств вам достаточно для того чтобы найти посторонний микролазер на корпусе анализатора. Он способен облучать сканируемую цель."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_BASIC
			)
		)
	)

/obj/item/device/encryptionkey/binary/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний информационных технологий достаточно, чтобы понять, что данный ключ перенастраивает наушник для возможности работы с протоколом связи синтетических единиц. Посредством данного ключа информация из канала синтетических единиц может преобразовываться в звуковой формат и обратно в формат данных."),
			"skillcheck" = list(
				SKILL_COMPUTER = SKILL_TRAINED
			)
		)
	)

/obj/item/device/suit_sensor_jammer/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний криминалистики или сложных устройств достаточно, чтобы понять, что данное устройство способно глушить или подменять сигнал датчиков костюма в определенном радиусе."),
			"failure" = SPAN_BAD("Выглядит как странная круглая штучка. Не можете определить для чего она нужна."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_MASTER,
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/device/blackout/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний электротехники и информационных технологий достаточно, чтобы понять, что данное устройство способно создать перегрузку сети питания при подключении к терминалу. Например через терминал под любым АПЦ."),
			"failure" = SPAN_BAD("Выглядит как одно из множества устройств из НИО."),
			"skillcheck" = list(
				SKILL_ELECTRICAL = SKILL_EXPERIENCED,
				SKILL_COMPUTER = SKILL_TRAINED
			),
			"LOGIC" = "AND"
		)
	)

/obj/item/clothing/glasses/thermal/syndi/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("При помощи оружейных знаний и при детальном осмотре, вы находите переключатель термального режима у этих очков."),
			"skillcheck" = list(
				SKILL_WEAPONS = SKILL_BASIC
			)
		)
	)

	if(active)
		mod_skill_identification["device_info"]["failure"] = "Вам не пришлось даже особо детально осматривать эти очки, чтобы понять что у них сейчас активен термальный режим. Но вы все еще не знаете, переключается ли этот режим каким-либо образом."

/obj/item/device/multitool/hacktool/update_mod_identification()
	var/additional_good_descr = ""

	if(in_hack_mode)
		additional_good_descr = " Он уже сейчас переведен в этот скрытый режим."

	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("На вид и по функционалу как обычный мультитул, но вашей экспертизы в электротехнике и сложных устройствах достаточно, чтобы понять, что у этого мультитула есть скрытый режим для взаимодействия с дверьми, который активируется при модификации отверткой.[additional_good_descr]"),
			"skillcheck" = list(
				SKILL_ELECTRICITY = SKILL_EXPERIENCED,
				SKILL_DEVICES = SKILL_TRAINED
			),
			"LOGIC" = "AND"
		)
	)

/obj/item/card/emag/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в электротехнике и криминалистике достаточно, для того чтобы определить, что это устройство используется для взлома широкого спектра вещей, где могут применяться ID карты."),
			"failure" = SPAN_BAD("Выглядит как пустая идентификационная карта с кучей проводов, которых там точно не должно быть."),
			"skillcheck" = list(
				SKILL_ELECTRICAL = SKILL_EXPERIENCED,
				SKILL_FORENSICS = SKILL_EXPERIENCED
			),
			"LOGIC" = "AND",
		)
	)

/obj/item/device/radio_jammer/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в криминалистике достаточно, для того чтобы определить, что это устройство используется для подавления радио сигналов в определенном радиусе действия."),
			"failure" = SPAN_BAD("С виду выглядит как обычное радио с каким-то странным меню выбора частот."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/flashlight/flashdark/update_mod_identification()
	var/additional_bad_descr = ""

	if(on)
		additional_bad_descr = " Но так как он уже включен, вы видите что от его работы становится только темнее."

	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в криминалистике или сложных устройствах достаточно, для того чтобы определить, что это устройство способно поглощать свет в активном состоянии."),
			"failure" = SPAN_BAD("Выглядит, как необычный, но непримечательный фонарик.[additional_bad_descr]"),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_TRAINED,
				SKILL_DEVICES = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/powersink/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в электротехнике достаточно, для того чтобы определить, что это устройство способно вызывать перепады питания за счет очень быстрого поглащения энергии из подключенной сети."),
			"failure" = SPAN_BAD("Вы не знаете что это такое. Если вы видели это устройство где-то в близи проводки, то понимаете, что это явно что-то лишнее."),
			"skillcheck" = list(
				SKILL_ELECTRICITY = SKILL_TRAINED
			)
		)
	)

/obj/item/device/syndietele/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в сложных устройствах достаточно, для того чтобы определить, что это замаскированный маяк телепортации."),
			"failure" = SPAN_BAD("Выглядит достаточно подозрительно. Вы не знаете что это."),
			"skillcheck" = list(
				SKILL_DEVICE = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/syndietele/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в сложных устройствах достаточно, для того чтобы определить, что это замаскированный маяк телепортации."),
			"failure" = SPAN_BAD("Выглядит достаточно подозрительно. Вы не знаете что это."),
			"skillcheck" = list(
				SKILL_DEVICE = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/syndiejaunter/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в сложных устройствах достаточно, для того чтобы определить, что это ручное устройство телепортации. Устройство должно по идее работать в связке со специальным маяком."),
			"failure" = SPAN_BAD("Выглядит достаточно подозрительно. Вы не знаете что это."),
			"skillcheck" = list(
				SKILL_DEVICE = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/supply_beacon/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вы без проблем определяете, что это маяк снабжения."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_UNSKILLED
			)
		)
	)

/obj/item/aiModule/syndicate/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в информационных технологиях достаточно, для того чтобы определить, что это взломанная версия платы смены законов для ИИ. Модификации платы позволяют проставить законы в максимальном приоритете и с усложнением отслеживания со стороны ИИ."),
			"failure" = SPAN_BAD("Обыкновенная плата, используемая во многих машинах."),
			"skillcheck" = list(
				SKILL_COMPUTER = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/clothing/mask/ai/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в криминалистике и в сложных устройствах достаточно, для того чтобы определить, что через эту маску можно напрямую подключаться к сети камер."),
			"failure" = SPAN_BAD("Странная маска в виде черепа, через которую всё хорошо видно в выключенном состоянии."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_MASTER,
				SKILL_DEVICES = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/personal_shield/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших обширных знаний в криминалистике или в оружии хватает для того чтобы определить, что это переносной персональный энергощит."),
			"failure" = SPAN_BAD("Выглядит как дымарь."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_MASTER,
				SKILL_WEAPONS = SKILL_MASTER
			)
		)
	)

/obj/item/gun/launcher/syringe/disguised/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("(!Невозможно опознать, если нет свидетелей стрельбы из этой сигареты!) Ваших знаний в криминалистике хватает для того чтобы определить, что это скрытый дротикомет."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_TRAINED
			)
		)
	)

/obj/item/clothing/head/bowlerhat/razor/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("При детальном осмотре вы сразу понимаете, что котелок сильно заострен."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_UNSKILLED
			)
		)
	)

/obj/item/stack/telecrystal/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Благодаря обширным научным знаниям вы понимаете, что это телекристал."),
			"skillcheck" = list(
				SKILL_SCIENCE = SKILL_MASTER
			)
		)
	)

/obj/item/device/spy_bug/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в криминалистике или в сложных устройствах достаточно, для того чтобы определить, что это жучок передающий изображение и звук на неизвестный монитор."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_TRAINED,
				SKILL_DEVICES = SKILL_BASIC
			)
		)
	)

/obj/item/device/spy_monitor/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в криминалистике или в сложных устройствах достаточно, для того чтобы определить, что это скрытый под ПДА монитор, который может получать изображение и звук из неизвестных источников."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_TRAINED,
				SKILL_DEVICES = SKILL_BASIC
			)
		)
	)

/obj/item/card/id/syndicate/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в криминалистике и в сложных устройствах достаточно, для того чтобы определить, что это карта со сменяемыми полями и со встроенными средстами предотвращения слежки. Также вы обнаружили, что эта карта может копировать доступ других карт."),
			"skillcheck" = list(
				SKILL_FORENSICS = SKILL_MASTER,
				SKILL_DEVICES = SKILL_EXPERIENCED
			),
			"LOGIC" = "AND"
		)
	)

/obj/item/clothing/mask/chameleon/voice/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Благодаря знаниям сложных устройств, вы обнаруживаете встроенный модулятор голоса в обследуемой маске."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/device/chameleon/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Благодаря знаниям сложных устройств, вы понимаете, что это устройство может сканировать небольшие объекты и при активации маскировать владельца устройства под просканированный предмет."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/implanter/imprinting/update_mod_identification()
	if(!imp || !istype(imp, /obj/item/implant/imprinting))
		mod_skill_identification = list()
	else
		mod_skill_identification = list(
			"device_info" = list(
				"success" = SPAN_GOOD("Вашей обширной экспертизы медицины и знаний сложных устройств достаточно, для того чтобы определить, что данный имплант способен внушить определенную инструкцию при дополнительном воздействии сильных наркотиков, влияющих на разум."),
				"skillcheck" = list(
					SKILL_DEVICES = SKILL_BASIC,
					SKILL_MEDICAL = SKILL_EXPERIENCED
				),
				"LOGIC" = "AND"
			)
		)

/obj/item/implant/imprinting/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы медицины и знаний сложных устройств достаточно, для того чтобы определить, что данный имплант способен внушить определенную инструкцию при дополнительном воздействии сильных наркотиков, влияющих на разум."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_BASIC,
				SKILL_MEDICAL = SKILL_EXPERIENCED
			),
			"LOGIC" = "AND"
		)
	)

/obj/item/implanter/freedom/update_mod_identification()
	if(!imp || !istype(imp, /obj/item/implant/freedom))
		mod_skill_identification = list()
	else
		mod_skill_identification = list(
			"device_info" = list(
				"success" = SPAN_GOOD("Вашей экспертизы в области сложных устройств достаточно, для того чтобы определить, что данный имплант позволяет владельцу вырываться из оков через применение заданного эмоционального триггера."),
				"skillcheck" = list(
					SKILL_DEVICES = SKILL_TRAINED
				)
			)
		)

/obj/item/implant/freedom/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в области сложных устройств достаточно, для того чтобы определить, что данный имплант позволяет владельцу вырываться из оков через применение заданного эмоционального триггера."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/implanter/compressed/update_mod_identification()
	if(!imp || !istype(imp, /obj/item/implant/compressed))
		mod_skill_identification = list()
	else
		mod_skill_identification = list(
			"device_info" = list(
				"success" = SPAN_GOOD("Вашей обширной экспертизы в области сложных устройств достаточно, для того чтобы определить, что данный имплант в своей основе использует технологию сжатии материи, для возможности имплантации предметов в тело. Предмет может быть вновь развернут на заданный эмоциональный триггер."),
				"skillcheck" = list(
					SKILL_DEVICES = SKILL_EXPERIENCED
				)
			)
		)

/obj/item/implant/compressed/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в области сложных устройств достаточно, для того чтобы определить, что данный имплант в своей основе использует технологию сжатии материи, для возможности имплантации предметов в тело. Предмет может быть вновь развернут на заданный эмоциональный триггер."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/implanter/adrenalin/update_mod_identification()
	if(!imp || !istype(imp, /obj/item/implant/adrenalin))
		mod_skill_identification = list()
	else
		mod_skill_identification = list(
			"device_info" = list(
				"success" = SPAN_GOOD("Вашей экспертизы в области сложных устройств достаточно, для того чтобы определить, что данный имплант содержит в себе наноботов, способных стимулировать тело на массовое производство адреналина. Активируется на заданный эмоциональный триггер."),
				"skillcheck" = list(
					SKILL_DEVICES = SKILL_TRAINED
				)
			)
		)

/obj/item/implant/adrenalin/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в области сложных устройств достаточно, для того чтобы определить, что данный имплант содержит в себе наноботов, способных стимулировать тело на массовое производство адреналина. Активируется на заданный эмоциональный триггер."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/implanter/explosive/update_mod_identification()
	if(!imp || !istype(imp, /obj/item/implant/explosive))
		mod_skill_identification = list()
	else
		mod_skill_identification = list(
			"device_info" = list(
				"success" = SPAN_GOOD("Вашей обширной экспертизы в области сложных устройств достаточно, для того чтобы определить, что это имплантируемая микровзрывчатка, которая может быть активирована по сигналу или по заданной фразе.."),
				"skillcheck" = list(
					SKILL_DEVICES = SKILL_EXPERIENCED
				)
			)
		)

/obj/item/implant/explosive/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей обширной экспертизы в области сложных устройств достаточно, для того чтобы определить, что это имплантируемая микровзрывчатка, которая может быть активирована по сигналу или по заданной фразе."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/reagent_containers/food/snacks/corpse_cube/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний в медицине достаточно, чтобы понять, что этот куб способен клонировать тело того, чьё ДНК в него будет введено."),
			"failure" = SPAN_BAD("Выглядит как обычный куб для быстрого выращивания животного."),
			"skillcheck" = list(
				SKILL_MEDICAL = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/dna_sampler/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний в медицине достаточно, чтобы понять, что этот предмет способен взять образец чужого ДНК."),
			"failure" = SPAN_BAD("Выглядит как необычный шприц."),
			"skillcheck" = list(
				SKILL_MEDICAL = SKILL_EXPERIENCED
			)
		)
	)

/obj/item/device/cosmetic_surgery_kit/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний сложных устройств достаточно, чтобы опознать данный предмет как набор для проведения автоматической косметической хирургии."),
			"failure" = SPAN_BAD("Выглядит как таймер с кучей проводов."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_TRAINED
			)
		)
	)

/obj/item/pen/reagent/sleepy/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Используя свои знания сложных устройств, вы смогли обнаружить небольшую ёмкость для реагентов внутри ручки."),
			"skillcheck" = list(
				SKILL_DEVICES = SKILL_BASIC,
				SKILL_MEDICAL = SKILL_BASIC
			),
			"LOGIC" = "AND"
		)
	)

/obj/item/card/emag_broken/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Вашей экспертизы в электротехнике и криминалистике достаточно, для того чтобы сказать, что магнитная лента данной карты могла использоваться для нестандартного подключения к устройствам. Невозможно определить функционал. Плата, подключенная к этой ленте, уже полностью выгорела."),
			"failure" = SPAN_BAD("Выглядит как пустая идентификационная карта с кучей проводов, которых там точно не должно быть. Также выглядит немного сгоревшей при внешнем осмотре."),
			"skillcheck" = list(
				SKILL_ELECTRICAL = SKILL_EXPERIENCED,
				SKILL_FORENSICS = SKILL_EXPERIENCED
			),
			"LOGIC" = "AND"
		)
	)