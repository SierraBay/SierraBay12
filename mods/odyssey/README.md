#### Список PRов:

<!--
  Ссылки на PRы, связанные с модом:
  - Создание каркаса
-->

## Одиссея

ID мода: ODYSSEY

### Описание

Секторная кампания из 3–5 смен с сохранением состояния Сьерры и судьбы персонажей.

**Цикл**

1. В лобби голосование о старте/продолжении запускается из кнопки **Odyssey** (не автоматически). Нужно минимум **10 голосов «За»**, и их должно быть больше, чем «Против». Если на continue «Против» набирает 10+ и больше «За» — кампания архивируется. Если никто не набрал 10 — сейв остаётся.
2. При старте по seed создаётся ветвящийся граф с перекрёстными коридорами и финальными маршрутами длиной 3, 4 и 5 прыжков (эшелон сектора). Смена экипажа в том же секторе эшелон не тратит.
3. На консолях командования в программе **Command and Communications** вкладка **Sector Map** открывает карту секторов. Клик по сектору открывает досье; авторизованный командный состав может проложить курс. Действует последний выбор.
4. Классический bluespace jump из эвакуационного меню **недоступен**. Переход в другой сектор: energize Bluespace Drive → **Odyssey Jump** с консоли привода или Command (**~10 мин** отсчёт, abort до `jump_locked`) → commit курса, сохранение и reboot. После continue, если предыдущая смена прыгнула, BSD **~1.5 ч** на охлаждении (прыжки недоступны).
5. Воут **Transfer / End the shift** не запускает прыжок: объявляется смена через **5 минут**, корабль остаётся в текущем секторе, сейв (crew shift +1, эшелон тот же) и reboot. Extend по-прежнему продлевает раунд.
6. Обычный ballistic jump привода (overmap) остаётся доступным параллельно, если есть валидный путь.
7. После успешного continue загружается сохранённое состояние Сьерры; сектор меняется только если был Odyssey Jump.
8. Финальный сектор завершает кампанию успешно. Выбор возвращения, emergency abandon ship, уничтожение Сьерры или гибель всего roster завершают её с соответствующим outcome.

Публичный **Sector Map**, **Briefing** и **Chronicle** доступны экипажу в **Newscast** (просмотр; курс прокладывает командование). Command: вкладки Briefing и Chronicle.

В лобби кнопка **Odyssey** (нижнее меню рядом с Changelog): зелёная, если кампания активна в раунде или на диске есть continue-сейв; тусклая, если сейва нет. По клику — блок голосования (старт/continue) и IC-брифинг. У админов с доступом к Odyssey Panel — ссылка на панель (OOC).

**Контракты и цели**

- В `campaign.json`: `contracts` (на всю кампанию) и `objectives` (на смену).
- При старте: контракт «Дойти до конечного сектора».
- На roundstart: 1–2 цели смены от danger сектора (удержать сектор / прыжок / не терять шаттлы / лимит потерь / выжить в hostile и т.п.).
- На roundend цели оцениваются автоматически; успех смены даёт небольшой депозит на счет станции. Контракт закрывается по исходу кампании.
- Всё видно в Briefing и пишется в хронику.

**Спящие агенты (traitor)**

- В Одиссее ванильный roll/autotraitor отключён (в том числе у проголосованного Traitor); выдачей управляет кампания.
- Пул: игроки экипажа Сьерры с pref traitor High/Low.
- Каждую смену: сначала reapply живых sleepers с прошлой смены (тот же `ckey|slot`), затем **+1** новый.
- Если живого экипажа на станции **> 20**, через ~12 минут — ещё **+1** midround (один раз за смену).
- Смерть снимает sleeper-статус. Статус пишется в `campaign.json` → `sleepers`.

**Mercenaries (nuke)**

- Дополнительный Odyssey-ролл — максимум **один раз за полёт** (`merc_used` в `campaign.json`).
- Пока флаг не стоит: **каждую смену** плоский шанс **40%**, если есть ≥ **3** кандидата на Mercenary.
- При проке мерки добавляются поверх текущего режима (`additional_antag_types`), вместе со спящими.
- Если режим уже Mercenary / add-antag выдал мерков — это тоже засчитывается в `merc_used`.
- Проголосованный **Mercenary** не вырезается: даже после `merc_used` nuke-режим спавнит отряд.
- Кандидатов мало или бросок не прошёл — флаг не ставится, следующая смена снова роллит.

**Changeling / Heist**

- Вне Одиссеи генокрад спавнится штатно (скалирование режима).
- В Одиссее: цель **1 или 2** генокрада на смену (бросок на лобби, кап 2). Сначала слоты занимают **перенесённые** с прошлой смены (тот же `ckey|slot`), остаток докидывает ванильный spawn.
- Перенос только если на момент сейва генокрад **жив и на Сьерре** (`station_levels`). Смерть, уход со станции или отсутствие на сейве → статус `lost`, роль не вернётся.
- Запись в `campaign.json` → `changelings`. DNA/силы между сменами не сохраняются — только роль.
- Спящие не вешаются поверх уже назначенного антага.
- Heist (raiders) как выбранный режим спавнится в любом секторе. Дополнительный Odyssey-ролл пиратов — только в `hostile`.

**Революция / лоялисты**

- Режим Revolution (и mixed с revs/loyalists) работает как обычно; Одиссея **не** вырезает эти теги.
- Head Revolutionary / Head Loyalist и **конвертированные** члены пишутся в `campaign.json` → `revolutionaries` / `loyalists` (`rank=head|member`).
- На следующей смене роль **reapply** на ту же куклу (`ckey|slot`), даже если режим раунда уже не Revolution.
- При режиме Revolution ванильный spawn голов уменьшается на число уже перенесённых head.
- Смерть → `dead`; деконверсия к сейву → `lost`; отсутствие в раунде при активном статусе — статус сохраняется до следующего захода.
- Живые не светятся в roundend-списке антагов (как sleepers/changelings). Uplink у returning head повторно не выдаётся.

**Пираты / ниндзя (красные сектора)**

- Только при `danger = hostile` у текущего сектора.
- Независимые броски **каждый** визит красного сектора (лимита на кампанию нет).
- Raiders (пираты): **55%**, минимум **3** кандидата.
- Ninja (operative): **50%**, минимум **1** кандидат.
- Добавляются поверх режима через `additional_antag_types` (могут совпасть друг с другом, со спящими и с nuke).

**Сохраняется**

- разрушенные / изменённые тайлы на `station_levels` только в зонах из снимка при baselines (зоны, уже лежавшие на Сьерре; `/area/space`, `/area/ship`, `/area/map_template`, `/area/supply` в снимок не входят). Флот Сьерры на ангарах в T=0 попадает сам; midround-гости и supply drone — нет;
- whitelist машин/компьютеров и **все структуры** кроме кабелей, disposal, ladder/stairs и transit tubes как `created / modified / moved / destroyed` (у fabricator — ещё ресурсы в бункере); атмосферные трубы — machinery, в снимок структур не входят;
- листовые материалы на Сьерре (`materials.json`: тип, количество, клетка; при необходимости обратно в шкаф/ящик). На **continue** сначала снимаются стаки с DMM, затем восстанавливается снимок прошлой смены — купленное и не потраченное остаётся, бесплатный респаун складов нет. Инвентарь на мобах не пишется. Первая смена — карта как обычно;
- документы в **картотеках** (`papers.json`: paper / folder / bundle / photo; фото — `papers_photos.sav`). На continue содержимое картотек на persistable-зонах strip + restore. Лимиты: 500 items / 100 photos / ~2 MB текста. Шкафы и бумага на полу не пишутся;
- мехи;
- счета Сьерры и отделов;
- каналы и сюжеты Newscast, включая фото (savefile рядом с JSON);
- roster участников, погибшие слоты;
- шаттлы (Guppy, Charon, Petrov, Phaethon, эскейп-поды):
  - вне Сьерры → `abandoned` (пустой док на следующих сменах);
  - на Сьерре, но с повреждениями выше порога → `damaged` + ориентировочная оценка ремонта (информативно, без списания со счетов);
- `shuttle_reports` в `campaign.json` (legacy `abandoned_shuttles` по-прежнему пишется как список имён);
- тело через `character_persist` в **отдельном** файле `…_odyssey.json` (обычный снимок не трогается); личный счёт и `campaign_id` — в одиссейном снимке; смерть в Одиссее сбрасывает только его;
- employment / security / medical записи, `criminal_status` и `physical_status` (включая правки с консолей в течение смены) — в roster кампании; при спавне в активной Одиссее применяются всегда. Persist-снимок дублирует их, если персистентность включена;
- **custody**: если на конец смены живой участник с `criminal_status` Incarcerated/Arrest находится в бриге/тюрьме/допросе (Sierra security areas) — в roster пишется `custody=brig`; на следующей смене после экипа — оранжевая форма, без ID, спавн на случайный `/obj/landmark/odyssey_custody` (ставить в prison cells; fallback — свободный пол в `/area/security/sierra/prison`); стартовый гир работы снимается;
- трупы экипажа на Сьерре (включая лежащих в морге или шкафу): внешность, раны, только униформа. На следующей смене тела появляются в моргах, не на месте смерти.

**Не сохраняется в MVP**

- атмос, провода/трубы, away sites и любые пристыкованные чужие корабли/шаттлы (даже на Z Сьерры);
- предметы на полу и содержимое шкафов (кроме листовых `/obj/item/stack/material`); документы вне картотек;
- инвентарь персонажа кроме униформы на трупе; импланты/аугменты (живое тело — в `character_persist`);

Overmap не сериализуется: он воспроизводимо создаётся из seed текущего сектора. Уровень опасности меняет число облаков hazards (как ванильный `overmap_event_areas`), их типы, задержку случайных событий и шанс Левиафана.

**Whitelist объектов**

- `/obj/machinery/computer`;
- `/obj/machinery/vending`;
- `/obj/machinery/fabricator` — в том числе `stored_material` (ресурсы в бункере; диски/бикер/очередь печати — нет);
- листовые `/obj/item/stack/material` на станции (отдельно от бункера фабрикатора);
- `/obj/machinery/sleeper`;
- `/obj/machinery/door/airlock` — HP, поломка панели, сварка, болты, открытая панель, открыт/закрыт; полностью разбитый шлюз остаётся как `/obj/structure/broken_door`;
- **все** `/obj/structure` в персистентных зонах корабля, кроме denylist: кабели, disposal pipe/holder/outlet, ladder / stairs (multiz), transit_tube / pod;
- атмосферные трубы (`/obj/machinery/atmospherics`) в structure-снимок не входят;
- у catwalk дополнительно пишутся plating и открытый люк; мостики в `/area/space` и на обшивке по-прежнему вне снимка (зона не persistable);
- сериализация базовая (`type/dir/name/anchored` + catwalk fields): HP окон и т.п. не восстанавливаются детально — только наличие/позиция/ориентация.

### Файлы сейва

`data/odyssey_<map.path>_<part>.json`

- `campaign.json` — seed, граф, маршрут, статус/outcome и метаданные кампании;
- `turfs.json`, `machinery.json`, `structures.json`, `mechs.json`, `economy.json`, `newscast.json`, `materials.json`, `papers.json` — части снимка;
- `newscast_photos.sav` — иконки фотографий Newscast;
- `papers_photos.sav` — иконки фото из картотек;
- `roster.json` — участники и погибшие слоты;
- `corpses.json` — трупы для моргов (тело + униформа);
- `chronicle.json` — журнал кампании (прыжки, потери, шаттлы, контакты, исходы; visibility public/command/admin).

### Статус

Реализовано:

- версия формата 2 (`campaign.json` и части снимка; сейвы иной версии не загружаются);
- процедурный секторный граф, навигационный компьютер и переход через Bluespace Drive (Odyssey Jump);
- детерминированные профили угроз;
- хуки: baseline турфов/объектов → apply → roundend save/finalize;
- **турфы**: diff относительно roundstart baseline (смена типа, урон стен, broken/burnt полов);
- **машинерия/компьютеры/мебель**: whitelist diff со стабильными id и tombstones; у `/obj/machinery/fabricator` — `stored_material`;
- **материалы**: `materials.json` — стаки на станции; continue = strip DMM + apply снимка;
- **документы**: `papers.json` + `papers_photos.sav` — содержимое `/obj/structure/filingcabinet` (paper/folder/bundle/photo); continue = strip + restore; бюджет 500/100/~2MB;
- **мехи**: тип, компоненты, заряд, оборудование — patch или spawn;
- **экономика**: счёт судна + отделы (баланс и лог транзакций, до 100 записей на счёт); личные счета — в снимке character_persist (`account_money` + `account_transactions`);
- **newscast**: каналы, авторы, цензура, сюжеты, wanted issue и фото в `newscast_photos.sav`;
- **шаттлы**: abandoned (пустой док) и damaged (score + ориентировочный repair_cost без списания; повторная запись в хронику при заметном росте урона);
- **персонаж**: roster по `campaign_id + ckey + slot`; погибший слот блокируется до конца кампании;
- **хроника**: `chronicle.json` + UI в Newscast/Command; continue-vote briefing в чат;
- **контракты/цели**: `contracts` + `objectives` в meta; Briefing UI (Newscast + Command);
- **наука (НИО)**: `research.json` — секторные брифы смены (spectrum / catalog / flora / slime), notes; награда — таллеры на счёт Science; в Briefing (консоль RnD контракты удалены);
- **брифы отделов**: в том же `research.json` (`dept_briefs`) — карго (экспорт на N таллеров, без денежной награды) и мед (body scan N человек из отдела X; награда на Medical);
- **итоги кампании**: при завершении Одиссеи — сводка (маршрут, задачи, потери) в хронике, анонсе и лобби;

- **записи экипажа**: sec/gen/med текст, `criminal_status` и `physical_status` из roster применяются при активной Одиссее всегда (не только при включённой персистентности);
- **трупы**: мёртвые human на корабле → `corpses.json`; apply раскладывает их по `/obj/structure/morgue`;
- **снимок persist** (opt-in): отдельный файл на кампанию (`…_odyssey.json`), тег `odyssey_campaign_id`, абсолютный баланс счёта; обычный persist-файл не читается и не пишется, пока Одиссея активна; снимок другой кампании не применяется.

### Админка

Вкладка **Admin → Odyssey Panel**: статус раунда/диска, граф и roster, validation и превью снапшотов; лобби-vote (start/continue по сейву), force begin new/continue, reactivate архива, finish/archive, сброс курса, queue shift end, regenerate графа, force save/apply/baseline; у погибших в roster — **вернуть слот** (снимает tombstone, пишет `roster.json`, при активной кампании восстанавливает sleeper/changeling если они были сняты смертью); у detained — **снять custody**.

### Изменения кора

- `code/modules/modular_computers/file_system/programs/generic/news.dm` — опциональный режим Sector Map и хуки для модов;
- `nano/templates/crew_manifest.tmpl` — архив экипажа прошлых смен Одиссеи;
- `mods/global_modpacks.dm` — подключение модпака;
- `code/controllers/subsystems/ticker.dm` — хук `odyssey_pregame_consider_vote()` (no-op; vote из кнопки Odyssey);
- `code/controllers/evacuation/evacuation.dm` — запрет классического BSJ из эвакуационного меню во время Одиссеи;
- `mods/machinery/.../bluespace_drive.dm` + `mods/odyssey/code/bluespace_drive_odyssey.dm` — Odyssey Jump, commit перехода и конец смены;
- `code/modules/client/preferences_persist.dm` — блок загрузки погибшего слота (`load_character` возвращает FALSE);
- `code/modules/mob/new_player/new_player.dm` — блок Ready/Join за погибший слот;
- `code/controllers/subsystems/jobs.dm` — пропуск слота из приоритетного списка, если загрузка отклонена;
- `code/modules/admin/admin_verbs.dm` — верб `Odyssey Panel`.
