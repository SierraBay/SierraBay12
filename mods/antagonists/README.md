
#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/1474
- https://github.com/SierraBay/SierraBay12/pull/1683
- https://github.com/SierraBay/SierraBay12/pull/1798
<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Antag tweaks

ID мода: ANTAGONISTS
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Общие изменения антагонистов, специфичные для SierraBay.
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*

- `code/datums/mind/memory.dm`:
  - `/datum/mind/ShowMemory`
- `code/game/gamemodes/objective.dm`:
  - `/datum/objective/get_display_text`
<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

- `mods/_master_files/code/game/gamemodes/ert.dm`:
  - `/datum/map_template/ruin/antag_spawn/ert`:
    - `var/prefix`
    - `var/suffixes`
    - `var/shuttles_to_initialise`
    - `var/apc_test_exempt_areas`
  - `/datum/shuttle/autodock/multi/antag/ert/var/destination_tags`
  - `/area/map_template/rescue_base/start/var/base_turf`

- `code/game/antagonist/antagonist_objectives.dm`:
  - `/datum/antagonist/proc/create_objectives()`

- `code/game/antagonist/antagonist_add.dm`:
  - `/datum/antagonist/proc/add_antagonist_mind()`
  - `/datum/antagonist/proc/remove_antagonist()`

- `code/game/antagonist/station/traitor.dm`:
  - `/datum/antagonist/traitor/create_objectives()`

- `code/game/gamemodes/game_mode.dm`:
  - `/datum/game_mode/create_antagonists()`
<!--
  Если ты добавлял новый модульный оверрайд, его нужно указать здесь.
  Здесь указываются оверрайды в твоём моде и папке `_master_files`

  Изменений нет - напиши "Отсутствуют"
-->

### Дефайны

- Отсутствуют
<!--
  Если требовалось добавить какие-либо дефайны, укажи файлы,
  в которые ты их добавил, а также перечисли имена.
  И то же самое, если ты используешь дефайны, определённые другим модом.

  Не используешь - напиши "Отсутствуют"
-->

### Используемые файлы, не содержащиеся в модпаке

- `icons/obj/augment.dmi`
- `mods/ntnet/code/NTNet-items.dm`
- `mods/rocket_launchers/code/rockets.dm`
- `mods/rocket_launchers/code/launcher.dm`

<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:

LordNest
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
