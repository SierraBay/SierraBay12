
#### Список PRов:

https://github.com/SierraBay/SierraBay12/pull/2277
https://github.com/SierraBay/SierraBay12/pull/2317
https://github.com/SierraBay/SierraBay12/pull/2380
https://github.com/SierraBay/SierraBay12/pull/2386
https://github.com/SierraBay/SierraBay12/pull/2456
https://github.com/SierraBay/SierraBay12/pull/2562

<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## Мехи Шегара

ID мода: MECHS_BY_SHEGAR
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Данный мод сильно углубляет механ мехов и имеет следующие изменения:
-Сильно пересмотрены мехи в плане баланса, теперь каждый модуль имеет смысл
-Мехи получили огнестрельное оружие
-Возвращены спрайты инфинити
-Добавлены многие фичи, по типу пассажирки, тарана, пересмотра ХУДа и прочего.
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*
Указывать триллион изменений - глупо и бесполезно. Ниже указаны файлы, в которых есть изменения. Вы всегда можете найти в коде изменения с помощью Mechs-by-Shegar
code\game\machinery\robotics_fabricator.dm
code\modules\mechs\_mech_setup.dm
code\modules\mechs\mech_damage.dm
code\modules\mechs\mech_icon.dm
code\modules\mechs\mech_interaction.dm
code\modules\mechs\mech_life.dm
code\modules\mechs\mech_movement.dm
code\modules\mechs\mech.dm
code\modules\mechs\equipment\combat.dm
code\modules\mechs\equipment\engineering.dm
code\modules\mechs\equipment\medical.dm
code\modules\mechs\equipment\utility.dm
code\modules\mechs\interface\_interface.dm
code\modules\mechs\interface\screen_objects.dm
code\modules\mechs\premade\powerloader.dm
code\modules\mob\living\living.dm
code\modules\projectiles\projectile.dm
code\modules\research\designs\designs_mechfab.dm

<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.

  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

-`mods/_master_files/code/modules/mechs/mech_icon.dm`:

<!--
  Если ты добавлял новый модульный оверрайд, его нужно указать здесь.
  Здесь указываются оверрайды в твоём моде и папке `_master_files`

  Изменений нет - напиши "Отсутствуют"
-->

### Дефайны

MECH_DROP_ALL_PASSENGER 
MECH_DROP_ANY_PASSENGER
BOLTS_NOMITAL
BOLTS_DESTROYED
BASIC_BUMP 
MEDIUM_BUMP
HARD_BUMP
MECH_BACK_LAYER
<!--
  Если требовалось добавить какие-либо дефайны, укажи файлы,
  в которые ты их добавил, а также перечисли имена.
  И то же самое, если ты используешь дефайны, определённые другим модом.

  Не используешь - напиши "Отсутствуют"
-->

### Используемые файлы, не содержащиеся в модпаке

Отсутствуют
<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:

Shegar - Всё
AK200 - задники для ослепления и эми удара
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
