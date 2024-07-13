
#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/2437
- https://github.com/SierraBay/SierraBay12/pull/2448
- https://github.com/SierraBay/SierraBay12/pull/2463
- https://github.com/SierraBay/SierraBay12/pull/2473
<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Мод-пример

ID мода: MODPACK_NEWUI
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Этот мод добавляет/изменяет UI для различных машин, компьютеров и т.д.
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*

- Отсутствуют
<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

- `mods/_master_files/code/game/machinery/telecomms/machinery_interactions`:
  `/obj/machinery/telecomms/interact()`,
  `/obj/machinery/telecomms/interface_interact()`,
  `/obj/machinery/telecomms/ui_interact()`,
  `/obj/machinery/telecomms/Topic()`,
  `/obj/machinery/telecomms/use_tool()`,
  
- `mods/_master_files/code/modules/paperwork/photocopier.dm`:
  `/obj/machinery/photocopier/interact()`,
  `/obj/machinery/photocopier/interface_interact()`,
  `/obj/machinery/photocopier/ui_interact()`,
  `/obj/machinery/photocopier/Topic()`,

  - `mods/_master_files/code/modules/paperwork/faxmachine.dm`:
  `/obj/machinery/photocopier/faxmachine/interact()`,
  `/obj/machinery/photocopier/faxmachine/Topic()`,

- `mods/_master_files/code/modules/mob/observer/ghost.dm`:
  `/mob/observer/ghost/view_manfiest()`

- `mods/_master_files/code/modules/mob/new_player/new_player.dm`:
  `/mob/new_player/ViewManifest()`
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

- `mods/_master_files/code/game/machinery/telecomms/machine_interactions.dm`
- `mods/_master_files/code/modules/paperwork/photocopier.dm`
- `mods/_master_files/code/modules/paperwork/faxmachine.dm`
- `mods/_master_files/code/modules/mob/observer/ghost.dm`
- `mods/_master_files/code/modules/mob/new_player/new_player.dm`
<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:
FeudeyTF
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
