
#### Список PRов:

<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Мод-пример

ID мода: IMPULSE_CANNON
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Добавляет импульсную пушку для военных кораблей
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*

- `code/modules/overmap/disperser/disperser_charge.dm`: 
	`/obj/structure/ship_munition/disperser_charge/proc/fire`, 

- `code/modules/overmap/disperser/disperser_console.dm` :
	`/obj/machinery/computer/ship/disperser/`

- `code/modules/overmap/disperser/disperser_fire.dm` : 
	`/obj/machinery/computer/ship/disperser/proc/fire_at_sector`

<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

- `mods/impulse_cannon/code/modules/overmap/disperser/disperser_charge.dm`: 
	`/obj/structure/ship_munition/disperser_charge/fire/military`,
	`/obj/structure/ship_munition/disperser_charge/fire/military/fire`,
	`/obj/structure/ship_munition/disperser_charge/emp/military`,
	`/obj/structure/ship_munition/disperser_charge/emp/military/fire`,
	`/obj/structure/ship_munition/disperser_charge/explosive/military`,
	`/obj/structure/ship_munition/disperser_charge/explosive/military/fire`,
  `/obj/structure/ship_munition/disperser_charge/fire/fire`,
	`/obj/structure/ship_munition/disperser_charge/emp/fire`,
	`/obj/structure/ship_munition/disperser_charge/mining/fire`,
	`/obj/structure/ship_munition/disperser_charge/explosive/fire`,

- `mods/impulse_cannon/code/modules/overmap/disperser/disperser_circuit.dm` : 
	`/obj/item/stock_parts/circuitboard/disperser/military`

- `mods/impulse_cannon/code/modules/overmap/disperser/disperser_console.dm` :
	`/obj/machinery/computer/ship/disperser/military`

- `mods/impulse_cannon/code/reagents.dm` : 
	`/datum/reagent/napalm/touch_turf`
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

- Отсутствуют
<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:

thekekman666
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
