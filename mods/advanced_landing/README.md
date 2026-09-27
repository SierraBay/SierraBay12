
#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/2740
<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Продвинутая посадка

ID мода: ADVANCED_LANDING
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Пилот исследовательского шаттла с достаточным навыком пилотирования получает в консоли кнопку
`Advanced Landing`. Она выбирает сектор на текущей клетке овермапа, даёт управление «глазу
посадки» и позволяет поставить шаттл на любую свободную клетку вместо готового навигационного
маркера.

Часть секторов закрыта от такой посадки, чтобы скрытые локации нельзя было найти случайным
облётом. Сектор помечается переменной `advanced_landing_forbidden`, и тогда он вообще не
попадает в список выбора — чужой пилот не только не сядет там, но и не сможет осмотреть
сектор «глазом посадки», который видит турфы сквозь стены.

Исключений нет: запрет действует и на шаттлы самой локации. В закрытых секторах остаётся
только обычная посадка по навигационным маркерам, включая `restricted_waypoints`.

Закрытые локации:

Vox Raider (`vox_start`)
Vox Scavenger Ship (`vox_scav_ship`)
Skrellian Scout Ship (`skrellscoutspace`)
Mercenary Base (`merc_base`)
ERT (`ert_ship`)

База рейдеров в списке не нужна: её темплейт грузится на собственный z-уровень без объекта на
овермапе, поэтому в выбор секторов она не попадает в принципе.

### Изменения *кор кода*

- `code/_helpers/turfs.dm` `/proc/translate_turfs`, `/proc/transport_turf_contents` — перенесённая
  область не затирается базовым турфом карты, а возвращает тот тип, который был под шаттлом.
- `nano/templates/shuttle_control_console_exploration.tmpl` — кнопка `Advanced Landing`
  и ключ `skilled_enough`.
<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

- `mods/_master_files/code/modules/overmap/sectors.dm` `/obj/overmap/visitable/var/advanced_landing_forbidden`
- `mods/_master_files/maps/antag_spawn/ert/ert_ship.dm` `/obj/overmap/visitable/sector/ert_ship`
- `mods/_master_files/maps/antag_spawn/mercenary/mercenary.dm` `/obj/overmap/visitable/sector/merc_base`
- `mods/_master_files/maps/antag_spawn/vox/voxraider.dm` `/obj/overmap/visitable/sector/vox_start`
- `mods/_master_files/maps/away/skrellscoutship/skrellscoutship.dm` `/obj/overmap/visitable/sector/skrellscoutspace`
- `mods/_master_files/maps/away/voxship/voxship.dm` `/obj/overmap/visitable/sector/vox_scav_ship`
- `/obj/machinery/computer/shuttle_control/Initialize()`
- `/mob/living/carbon/human/handle_vision()`
- `/mob/cancel_camera()`
- `/turf/ChangeTurf()`

<!--
  Если ты добавлял новый модульный оверрайд, его нужно указать здесь.
  Здесь указываются оверрайды в твоём моде и папке `_master_files`

  Изменений нет - напиши "Отсутствуют"
-->

### Дефайны

Отсутствуют
<!--
  Если требовалось добавить какие-либо дефайны, укажи файлы,
  в которые ты их добавил, а также перечисли имена.
  И то же самое, если ты используешь дефайны, определённые другим модом.

  Не используешь - напиши "Отсутствуют"
-->

### Используемые файлы, не содержащиеся в модпаке

- `nano/templates/shuttle_control_console_exploration.tmpl`
- `mods/_master_files/code/modules/overmap/sectors.dm`
- `mods/_master_files/maps/antag_spawn/`, `mods/_master_files/maps/away/`
<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:

Lexanx
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
