
#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/2678
<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Восхождение

ID мода: ASCENT
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Этот мод добавляет новую расу воинствующих Кхаармани, сосуществующих в ковенанте с предками ГБС где-то далеко за Скрелльскими границами.
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*

- `code/ascent_chemistry.dm`:
  - `/datum/reagent/toxin/bromide/affect_touch()`
  - `/datum/reagent/toxin/bromide/affect_blood()`
  - `/datum/reagent/toxin/bromide/affect_ingest()`
  - `/datum/reagent/toxin/methyl_bromide/affect_touch()`
  - `/datum/reagent/toxin/methyl_bromide/affect_ingest()`
  - `/datum/reagent/toxin/methyl_bromide/affect_ingest()`
  - `/obj/item/clothing/under/harness`
<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

- Отсутствуют
<!--
  Если ты добавлял новый модульный оверрайд, его нужно указать здесь.
  Здесь указываются оверрайды в твоём моде и папке `_master_files`

  Изменений нет - напиши "Отсутствуют"
-->

### Дефайны

- `SPECIES_MANTID_ALATE`
- `SPECIES_MANTID_GYNE`
- `SPECIES_MONARCH_WORKER`
- `SPECIES_MONARCH_QUEEN`
- `ALL_ASCENT_SPECIES`
- `COLOR_ASCENT_PURPLE`
- `MANTIDIFY`
- `COLOR_ASCENT_PURPLE`
- `CULTURE_ASCENT`
- `HOME_SYSTEM_KHARMAANI`
- `FACTION_ASCENT_GYNE`
- `FACTION_ASCENT_ALATE`
- `FACTION_ASCENT_SERPENTID`
- `RELIGION_KHARMAANI`
- `LANGUAGE_MANTID_NONVOCAL`
- `LANGUAGE_MANTID_VOCAL`
- `LANGUAGE_MANTID_BROADCAST`
<!--
  Если требовалось добавить какие-либо дефайны, укажи файлы,
  в которые ты их добавил, а также перечисли имена.
  И то же самое, если ты используешь дефайны, определённые другим модом.

  Не используешь - напиши "Отсутствуют"
-->

### Используемые файлы, не содержащиеся в модпаке

- `icons/mob/species/nabber/onmob/`
- `icons/mob/species/nabber/msq/onmob/`
- `icons/obj/machines/fabricators/nanofabricator.dmi`
-  Множество, реальное множество других спрайтов для Восхождения, разбросанных по билду с пор их удаления в 2021.
<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:

Оригинальный порт выполнен командой Final Destination (https://github.com/RepoStash/FD-NewBay/tree/dev-sierra)
Код адаптирован и доработан UEDHighCommand
Карты доработаны RocheHendson
Различные фиксы и адаптация карт от Neonvolt
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
