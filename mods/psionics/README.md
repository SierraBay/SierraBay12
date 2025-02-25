
#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/2780
<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Псионика

ID мода: PSIONICS
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Порт псионики с Final Destination, добавляет ВЛьный выбор псионики из лодаута и ограничивает псионику под вайтлист
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*

- `code/controllers/subsystems/processing/psi.dm`: `Закомменчено`
- `baystation12.dme`: `#include "code\modules\client\preference_setup\psionics\01_basic.dm"`, `#include "code\modules\client\preference_setup\psionics\02_abilities.dm"`
- `code/__defines/psi.dm`: `Закомменчено`
- `code/game/jobs/job/job.dm`: `proc/give_psi`, `equip`
- `code/modules/client/preference_setup/preference_setup.dm`: `/datum/category_group/player_setup_category/psionics_preferences`
- `code/modules/psionics/` : `Перенесено в мод, закомменчено`
- `test/check-paths.sh` : `+1 к uses of examine()`
<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

- `Отсутствуют`
<!--
  Если ты добавлял новый модульный оверрайд, его нужно указать здесь.
  Здесь указываются оверрайды в твоём моде и папке `_master_files`

  Изменений нет - напиши "Отсутствуют"
-->

### Дефайны

- `code/__defines/mobs.dm`: `SPECIES_PSI`
- `code/__defines/psi.dm` : `PSI_COERCION`, `PSI_CONSCIOUSNESS`, `PSI_PSYCHOKINESIS`, `PSI_MANIFESTATION`, `PSI_METAKINESIS`, `PSI_ENERGISTICS`, `PSI_REDACTION`, `PSI_RANK_APPRENTICE`, `PSI_RANK_OPERANT`, `PSI_RANK_MASTER`, `PSI_RANK_GRANDMASTER`
<!--
  Если требовалось добавить какие-либо дефайны, укажи файлы,
  в которые ты их добавил, а также перечисли имена.
  И то же самое, если ты используешь дефайны, определённые другим модом.

  Не используешь - напиши "Отсутствуют"
-->

### Авторы:

Roche Hendson
[final-destination.space](https://github.com/RepoStash/FD-NewBay) - источник
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
