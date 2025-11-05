# Руководство по системе IFF

## Обзор

Система IFF (Идентификация Свой-Чужой) — это физическое устройство-машинерия, которое хранит и транслирует информацию об идентификации судна во время сканирования сектора на оверкарте. Она заменяет устаревшее поле `scanner_desc` структурированной, редактируемой системой профилей.

## Основные компоненты

### Устройство IFF (`/obj/machinery/overmap_iff`)

Физическая машинерия, расположенная на кораблях, которая хранит данные идентификации и управляет трансляцией.

**Расположение:** `mods/overmap/code/iff.dm`

**Ключевые особенности:**
- Физическое устройство, которое может быть повреждено, отключено или взломано
- Интерфейс NanoUI для просмотра и редактирования данных идентификации
- Автоматическая привязка к судну-носителю при инициализации
- Возможность синхронизации данных с датумом корабля-носителя
- Переключатель трансляции вкл/выкл

### Профиль IFF (`/datum/iff_profile`)

Структура данных, содержащая все поля идентификации, транслируемые при сканировании.

**Расположение:** `mods/overmap/code/iff_profile.dm`

**Поля:**
- `registration` - Официальная регистрация/название судна
- `faction` - Принадлежность к фракции/организации
- `transponder` - Статус и тип транспондера (напр. "Transmitting (SCI), NanoTrasen")
- `contact_class` - Ссылка на класс корабля (напр. `/decl/ship_contact_class/dagon`)
- `vessel_mass` - Масса в кг
- `notice` - Основной текст описания/уведомления
- `scanner_desc` - Редактируемое пользователем поле описания
- `distress` - Текст сигнала бедствия (если есть)
- `header_image` - HTML изображение/логотип, отображаемый первым в выводе сканирования

## Добавление IFF к новым кораблям

### Метод 1: Автоматическая инициализация (рекомендуется)

Устройство IFF автоматически создается и заполняется при инициализации корабля. Переопределите `Initialize()` для настройки:

```dm
/obj/overmap/visitable/ship/myship/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = mylogo.png></center><br>")
		iff.set_registration("MSV My Ship Name")
		iff.set_faction("My Organization")
		iff.set_transponder("Transmitting (CIV), non-hostile")
		iff.set_contact_class(/decl/ship_contact_class/myclass)
		iff.set_vessel_mass(15000)
		iff.set_notice("Судно среднего размера с характерными опознавательными знаками.")
	return .
```

### Метод 2: Внешние переопределения

Для кораблей, определенных во внешних модулях/паках, создайте неинвазивные переопределения:

**Расположение:** `mods/overmap/code/overrides_external.dm`

```dm
/obj/overmap/visitable/ship/external_ship/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("External Ship")
		iff.set_faction("External Faction")
		iff.set_transponder("Transmitting (CIV)")
		iff.set_notice("Описание внешнего корабля")
	return .
```

## Методы-сеттеры IFF

Все данные IFF должны устанавливаться через предоставленные методы-сеттеры:

```dm
iff.set_registration(value)      // Регистрация/название корабля
iff.set_faction(value)            // Фракция-владелец
iff.set_transponder(value)        // Статус транспондера
iff.set_contact_class(path)       // Путь к decl класса корабля
iff.set_vessel_mass(number)       // Масса в кг
iff.set_notice(value)             // Основное описание
iff.set_scanner_desc(value)       // Редактируемое пользователем описание
iff.set_distress(value)           // Текст сигнала бедствия
iff.set_header_image(value)       // HTML заголовок/логотип
```

**Важно:** Всегда используйте методы-сеттеры вместо прямой записи в `iff.profile.field` для обеспечения правильной инициализации и валидации.

## Формат вывода сканирования

Когда корабль сканируется, система IFF генерирует вывод в следующем порядке:

1. **Изображение заголовка** (если установлено) - Логотип или фирменный заголовок
2. **Секция идентификации:**
   - Регистрация
   - Фракция (если установлена)
   - Транспондер
3. **Кинематика:**
   - Класс контакта (название и описание)
   - Масса судна (если установлена)
   - Позиция и скорость
4. **Сигнал бедствия** (если установлен)
5. **Уведомление/Описание:**
   - Поле Notice (приоритетное)
   - ИЛИ scanner_desc (запасной вариант)
6. **Признаки жизни** (если применимо)

### Пример вывода сканирования:

```
<center><img src = bluentlogo.png></center>
Собственность корпорации NanoTrasen:

Регистрация: NSV Sierra
Фракция: NanoTrasen
Транспондер: Transmitting (SCI), NanoTrasen

Научное судно класса Дагон - Столичный научно-исследовательский корабль
Масса судна: 50000 кг
Позиция: [152, 78] Скорость: [2, -1]

Уведомление: Космический объект шириной 121.2 метра, длиной 214.5 метра...

Обнаружены признаки жизни: 45 сигнатур
```

## Интерфейс NanoUI

Игроки могут взаимодействовать с устройствами IFF через NanoUI:

### Режим просмотра (только для чтения):
- **Статус:** Трансляция включена/выключена, привязка к судну-носителю
- **Идентификация судна:** Регистрация, фракция, транспондер
- **Информация сканирования:** Класс контакта, масса судна, уведомление
- **Информация о носителе:** Название привязанного корабля и координаты
- **Превью сканирования:** Предварительный просмотр вывода сканирования в реальном времени

### Режим редактирования (ограниченный):
- **Описание сканера** - Единственное поле, редактируемое пользователями
- Все остальные поля доступны только для чтения для предотвращения подделки идентификации

### Синхронизация с носителем:
Две кнопки позволяют синхронизировать данные с датумом корабля-носителя:
- **Заполнить пропущенное** - Заполняет только пустые поля IFF
- **Перезаписать всё** - Заменяет все данные IFF данными корабля-носителя

## Устаревший запасной вариант

Для обратной совместимости корабли без устройств IFF или с отключенным IFF будут использовать устаревшее поле `scanner_desc` (если присутствует). Это гарантирует, что старый контент продолжит работать.

## Лучшие практики

### 1. Используйте заголовки для брендинга
```dm
iff.set_header_image("<center><img src = faction_logo.png></center><br>")
```

### 2. Четкий статус транспондера
```dm
// Хорошие примеры:
"Transmitting (SCI), NanoTrasen"
"Transmitting (MIL), SCG"
"Transmitting (CIV), non-hostile"
"None Detected"
```

### 3. Описательные уведомления
```dm
// Предпочитайте краткие, информативные уведомления:
iff.set_notice("Патрульный корабль класса Нагашино. Обозначение 5-го флота. Обнаружена массивная тепловая сигнатура.")

// Избегайте расплывчатых описаний:
iff.set_notice("Корабль.") // Слишком расплывчато
```

### 4. Динамическая регистрация
```dm
/obj/overmap/visitable/ship/myship/New()
	name = "Station-[rand(1,99)]"
	..()

/obj/overmap/visitable/ship/myship/Initialize()
	. = ..()
	if(iff)
		iff.set_registration("[name]") // Использует динамически сгенерированное имя
	return .
```

### 5. Классы контактов
Всегда устанавливайте соответствующий класс контакта для правильной классификации:
```dm
iff.set_contact_class(/decl/ship_contact_class/dagon)        // Большой корабль
iff.set_contact_class(/decl/ship_contact_class/shuttle)      // Малый шаттл
iff.set_contact_class(/decl/ship_contact_class/merchant)     // Торговое судно
```

## Миграция с scanner_desc

Если мигрируете старые корабли, использовавшие `scanner_desc`, извлеките структурированные данные:

**Старый способ:**
```dm
/obj/overmap/visitable/ship/oldship
	scanner_desc = @{"
<center><img src = logo.png></center>
Registration: Old Ship
Transponder: Transmitting
Notice: Описание старого корабля"}
```

**Новый способ:**
```dm
/obj/overmap/visitable/ship/oldship

/obj/overmap/visitable/ship/oldship/Initialize()
	. = ..()
	if(iff)
		iff.set_header_image("<center><img src = logo.png></center><br>")
		iff.set_registration("Old Ship")
		iff.set_transponder("Transmitting")
		iff.set_notice("Описание старого корабля")
	return .
```

Затем удалите поле `scanner_desc` из определения типа.

## Распространенные паттерны

### Военные корабли
```dm
if(iff)
	iff.set_header_image("<center><img src = FleetLogo.png></center><br>")
	iff.set_registration("SCGDF Patrol Craft")
	iff.set_faction("SCG")
	iff.set_transponder("Transmitting (MIL), SCG")
	iff.set_contact_class(/decl/ship_contact_class/nagashino)
	iff.set_notice("Многоцелевой патрульный корабль класса Нагашино. Обозначение 5-го флота.")
```

### Корпоративные суда
```dm
if(iff)
	iff.set_header_image("<center><img src = bluentlogo.png></center><br><b>Собственность корпорации NanoTrasen:</b>")
	iff.set_registration("NSV Sierra")
	iff.set_faction("NanoTrasen")
	iff.set_transponder("Transmitting (SCI), NanoTrasen")
	iff.set_notice("Научно-исследовательское судно. Корпоративный актив NanoTrasen.")
```

### Неизвестные/враждебные суда
```dm
if(iff)
	iff.set_registration("UNKNOWN")
	iff.set_faction("Unknown")
	iff.set_transponder("None Detected")
	iff.set_notice("Неопознанное судно. Происхождение неизвестно. Приближаться с осторожностью.")
```

### Независимые/гражданские
```dm
if(iff)
	iff.set_registration("Free Trader Vessel")
	iff.set_faction("Free Trader Union")
	iff.set_transponder("Transmitting (CIV), non-hostile")
	iff.set_notice("Независимое торговое судно, действующее по уставу СВТ.")
```

## Устранение неполадок

### IFF не показывает данные
1. Проверьте существование `iff`: Убедитесь, что переменная `iff` корабля не null
2. Проверьте трансляцию: Убедитесь, что `iff.broadcast_enabled` равно TRUE
3. Проверьте профиль: Убедитесь, что `iff.profile` инициализирован

### Носитель не привязывается
- IFF привязывается к носителю на основе совпадения `map_z` во время инициализации
- Убедитесь, что z-уровень корабля зарегистрирован в системе оверкарты

### Данные не синхронизируются
- Используйте методы-сеттеры, а не прямую запись в поля
- Убедитесь, что методы-сеттеры вызываются после `..()` в Initialize()

### В выводе сканирования отсутствуют поля
- Убедитесь, что поля установлены с непустыми значениями
- Проверьте, что трансляция включена
- Убедитесь, что вызывается `get_scan_lines()`

## Расположение файлов

- **Устройство IFF:** `mods/overmap/code/iff.dm`
- **Профиль IFF:** `mods/overmap/code/iff_profile.dm`
- **Интеграция с кораблём:** `mods/overmap/code/ship.dm`
- **Определения кораблей:** `mods/overmap/code/overmap_objects/ships.dm`
- **Внешние переопределения:** `mods/overmap/code/overrides_external.dm`
- **Шаблон UI:** `nano/templates/overmap_iff.tmpl`
- **Подключения:** `mods/overmap/_overmap_includes.dm`
---

**Версия:** 1.0  
**Последнее обновление:** Ноябрь 2025  
**Разработчик:** imjustkisik
