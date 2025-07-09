// добавляет флажки  "уооо прячу в носки" этим предметам во имя логики

// ОБЩЕЕ //

/obj/item/card // вообще все карточки (в основном айди, но также и емаг, и партийные карточки)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/hand //игральные карты (их можно хоть пачкой там прятать)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/paper //бумажки (также включают в себя травел и рабочие визы, талисманы культистов)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/spacecash //бабосы (включая электронный чип)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/clothing/mask/smokable/cigarette //сигареты со вкусом носков
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/reagent_containers/food/snacks/monkeycube //манкикубы со вкусом носков
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/storage/fancy/smokable //пачки сигарет (а также сигаретные держалки монеток)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/flame //зажигалки, спички, свечи
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/device/flashlight/flare //флаеры, светопалочки
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/device/oxycandle //кислородные свечи
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/storage/fancy/matches //спичечные коробки
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/passport //паспорта
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/folder/envelope //конверты
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/photo //фотографии
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/seeds //семечки
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES




// ТЕХНОЛОГИЧЕСКАЯ ФИГНЯ //

/obj/item/disk //дискеты (секретные проекты, отчёты сканеров, ДНК-диски ботаники, диск от нюки...)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/stock_parts/computer/hard_drive/portable //флешки и дискеты к консолям
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/stock_parts/computer/network_card //сетевые платы
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/stock_parts/circuitboard //все платы для машинок/консолей
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/disk/integrated_circuit/upgrade //все диски для интегрального принтера (зачем? ну ладно, если тебе надо, то так надо)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/circuitboard //особняком платы к мехам (thanks shegar)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/aiModule //платы законов ИИ
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/device/encryptionkey //ключи шифрования
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES



// МЕДИЦИНСКАЯ ФИГНЯ С РЕАГЕНТАМИ И НЕ ТОЛЬКО //

/obj/item/reagent_containers/syringe //шприцы
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/syringe_cartridge //дротики из шприцов
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/pen //ручки (включая слипи-пен)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/hypospray/autoinjector //автоинъекторы
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/implanter //имплантеры
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/implantcase //сами мелкие кейсики с имплантами
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/implant //сами мелкие имплантики
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/reagent_containers/glass/beaker/vial //хрупкие стеклянные пробирки прямо в сапоге
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/storage/pill_bottle //таблетницы
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/reagent_containers/pill //таблетки со вкусом носков
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/storage/pill_bottle/dice
	item_flags = null

/obj/item/storage/pill_bottle/dice_nerd
	item_flags = null

/obj/item/device/spy_bug //жучки для прослушки
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES




// ОБОЙМЫ И ПУЛИ //

/obj/item/ammo_casing //одна пуля любого калибра
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/foam_dart //ЛЮБОГО. КАЛИБРА.
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_casing/rpg_rocket //кроме ракет лол
	item_flags = null

/obj/item/ammo_casing/rocket
	item_flags = null

/obj/item/ammo_magazine/pistol //пистолетные
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/pistol/double //кроме расширенных
	item_flags = null

/obj/item/ammo_magazine/magnum //пистолетные 15мм
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/smg/machine_pistol //УЗИ на 16 пулек
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/shotholder //держалки для пуль дробовиков
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/speedloader/clip //вот эти вот стрипперы прикольные
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/speedloader/hpclip
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/speedloader/pclip
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/iclipr
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/ammo_magazine/chemdart //мини-обойма к дротикомёту
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES





// ОРУЖИЕ //

/obj/item/material/star //сюрикены
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/gun/launcher/syringe/disguised //маскированный шприцемёт трейтора (сигара)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/gun/projectile/pistol/holdout //P3 Whisper без глушителя
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/silencer //сам глушитель к нему
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/gun/projectile/revolver/holdout //al-Maliki & Mosley Partner
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/gun/energy/gun/small //LAEP90-C
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/melee/energy/sword//выключенные энергомечи (как же хорошо что в коде ботинок своя проверка на размер предмета)
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/melee/energy/machete //выключенные энергомачеты тоже
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES
