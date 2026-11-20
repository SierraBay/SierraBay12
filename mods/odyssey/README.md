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
4. Классический bluespace jump из эвакуационного меню **недоступен**. Переход в другой сектор: energize Bluespace Drive → **Odyssey Jump** с консоли привода или Command (**~20 мин** отсчёт, abort до `jump_locked`) → commit курса → **~2 мин** на подготовку экипажа → сохранение и reboot. После continue, если предыдущая смена прыгнула, BSD **~1.5 ч** на охлаждении (прыжки недоступны).
5. Воут **Transfer / End the shift** не запускает прыжок: объявляется смена через **5 минут**, корабль остаётся в текущем секторе, сейв (crew shift +1, эшелон тот же) и reboot. Extend по-прежнему продлевает раунд.
6. Обычный ballistic jump привода (overmap) остаётся доступным параллельно, если есть валидный путь.
7. После успешного continue, **до спавна экипажа**, идёт экран загрузки Одиссеи (полоса прогресса + статус каждого `*.json`); затем на карту накатывается сейв. Сектор меняется только если был Odyssey Jump. На **roundend** тот же UI показывает сохранение кампании по шагам. Предупреждение перед снимком — **OOC** (синий/красный чат, не IC-каналы): при Transfer — за 2 мин; после Odyssey Jump — 2 мин grace, затем сейв. DC во время прогресса: job-seat освобождается, окно закрывается на релогине (или снова показывается, если загрузка ещё идёт); join/ready заблокированы до конца UI.
8. Финальный сектор завершает кампанию успешно. Выбор возвращения, emergency abandon ship, уничтожение Сьерры или гибель всего roster завершают её с соответствующим outcome.

Публичный **Sector Map**, **Briefing** и **Chronicle** доступны экипажу в **Newscast** (просмотр; курс прокладывает командование). Command: вкладки Briefing и Chronicle.

В лобби кнопка **Odyssey** (нижнее меню рядом с Changelog): зелёная, если кампания активна в раунде или на диске есть continue-сейв; тусклая, если сейва нет. По клику — блок голосования (старт/continue) и IC-брифинг. У админов с доступом к Odyssey Panel — ссылка на панель (OOC).

**Контракты и цели**

- В `campaign.json`: `contracts` (на всю кампанию) и `objectives` (на смену).
- При старте: контракт «Дойти до конечного сектора».
- На roundstart: 1–2 цели смены от danger сектора (удержать сектор / прыжок / не терять шаттлы / лимит потерь / выжить в hostile и т.п.).
- На roundend цели оцениваются автоматически; успех смены даёт небольшой депозит на счет станции. Контракт закрывается по исходу кампании.
- Всё видно в Briefing и пишется в хронику.

**Антагонисты (только правила Одиссеи)**

- Пока кампания активна, голосование/secret за игровой режим **не выдаёт** ванильных антагов (культ, heist, crossfire, traitor-режим и т.д.). Раунд форсируется в **Extended**; объявление — «режим: Одиссея».
- Шаблоны антагов собираются только из Odyssey-очереди (`additional_antag_types`): changeling / merc / raiders / ninja. Traitor-шаблон не используется — спящих назначает кампания.
- Midround-события движка (wizard event и пр.) этим патчем не режутся.

**Спящие агенты (traitor)**

- Ванильный roll/autotraitor полностью отключён; выдачей управляет кампания.
- Пул: игроки экипажа Сьерры с pref traitor High/Low.
- Каждую смену: сначала reapply живых sleepers с прошлой смены (тот же `ckey|slot`), затем **+1** новый.
- Если живого экипажа на станции **> 20**, через ~12 минут — ещё **+1** midround (один раз за смену).
- Смерть снимает sleeper-статус. Статус пишется в `campaign.json` → `sleepers`.

**Mercenaries (nuke)**

- Odyssey-ролл — максимум **один раз за полёт** (`merc_used` в `campaign.json`).
- Пока флаг не стоит: шанс растёт со сменой — **1-я = 0%**, далее **+20%** за смену (2→20%, 3→40%, 4+→**60%** кап), если есть ≥ **3** кандидата на Mercenary.
- При проке мерки ставятся через `additional_antag_types`, вместе со спящими.
- **Не совмещается** с Odyssey-роллом пиратов/ниндзя: при конфликте merc-ролл или outsider-ролл пропускается.
- Кандидатов мало или бросок не прошёл — флаг не ставится, следующая смена снова роллит.

**Changeling**

- Каждую смену Одиссея сама роллит цель **1 или 2** генокрада (кап 2), без голосования за режим.
- Сначала слоты занимают **перенесённые** с прошлой смены (тот же `ckey|slot`), остаток — roundstart spawn.
- Перенос только если на момент сейва генокрад **жив и на Сьерре** (`station_levels`). Смерть, уход со станции или отсутствие на сейве → статус `lost`, роль не вернётся.
- Запись в `campaign.json` → `changelings`. DNA/силы между сменами не сохраняются — только роль.
- После roundstart/reapply — `odyssey_repair_changeling_state`: добивает отсутствующий `mind.changeling` у уже назначенных и снимает orphan `special_role=Changeling` без datum (типичный leftover lottery finalize на synth/FBP/NO_SCAN после continue).
- Спящие не вешаются поверх уже назначенного антага.

**Революция / лоялисты**

- Новый spawn революции из режима раунда в Одиссее **не** запускается.
- Уже активные Head Revolutionary / Head Loyalist и **конвертированные** члены пишутся в `campaign.json` → `revolutionaries` / `loyalists` (`rank=head|member`) и на следующей смене **reapply** на ту же куклу (`ckey|slot`).
- Смерть → `dead`; деконверсия к сейву → `lost`; отсутствие в раунде при активном статусе — статус сохраняется до следующего захода.
- Живые не светятся в roundend-списке антагов (как sleepers/changelings). Uplink у returning head повторно не выдаётся.

**Пираты / ниндзя (красные сектора)**

- Только при `danger = hostile` у текущего сектора (на стартовом `safe` не роллятся).
- Независимые броски **каждый** визит красного сектора (лимита на кампанию нет).
- Raiders (пираты): **55%**, минимум **3** кандидата.
- Ninja (operative): **50%**, минимум **1** кандидат.
- Через `additional_antag_types` (могут совпасть друг с другом и со спящими).
- **Не совмещаются** с mercenaries (nuke).

**Сохраняется**

- разрушенные / изменённые тайлы на `station_levels` только в зонах из снимка при baselines (зоны, уже лежавшие на Сьерре; `/area/space`, `/area/ship`, `/area/map_template`, `/area/supply` в снимок не входят). Флот Сьерры на ангарах в T=0 попадает сам; midround-гости и supply drone — нет;
- whitelist машин/компьютеров и **все структуры** кроме кабелей, disposal, ladder/stairs и transit tubes как `created / modified / moved / destroyed` (fabricator / chem-fridge / anomaly / SMES / shield / cryo / portable_atmospherics — своё состояние); атмосферные трубы — machinery, в снимок структур не входят (cryo_cell — исключение в machinery whitelist). После apply — `odyssey_refresh_structure_connections` (окна/решётки/рамы/столы/catwalk), иначе изменённые стёкла остаются без визуального стыка с соседями;

- листовые материалы на Сьерре (`materials.json`: тип, количество, клетка; при необходимости обратно в шкаф/ящик). На **continue** сначала снимаются стаки с DMM, затем восстанавливается снимок прошлой смены — купленное и не потраченное остаётся, бесплатный респаун складов нет. Инвентарь на мобах не пишется. Первая смена — карта как обычно;
- документы (`papers.json`: paper / folder / bundle / photo; фото — `papers_photos.sav`) — картотеки **и** бумажки/папки на полу и в шкафах, с текстом, штампами и языком. На continue strip + restore. Лимиты: 500 items / 100 photos / ~2 MB текста. Не в `items_*`;
- предметы на полу / в шкафах (`items.json` lane-marker + `items_<bucket>.json`: weapons / clothing / tools / medical / food / storage / devices / stacks / misc). Пустой корабль всё равно пишет `items.json`, чтобы на continue снять DMM-лут. Общий запрет (и мир, и карманы): nuke disk, pinpointer, blueprints, bag of holding, ID, печати, конверт с кодами, пульты глав, гарнитуры глав, коробки бланков ID/PDA. Мир дополнительно не пишет: trash, shard, гильзы россыпью, organ (это `remains.json`), material stacks, grown/seeds, paperwork, личный сейф. MMI, платы роботов, AI card и uplink пишутся как обычные предметы; живой разум внутри карты или MMI не становится вторым игроком. Служебные `gun/secure` и `stunrevolver/secure` из шкафов глав помечаются при спавне и не пишутся — шкаф выдаёт их снова; арсенал и вендор той же модели пишутся вместе с зарядом. У вещи пишутся имя, цвет и описание, если они отличаются от типа; заряд батареи, магазин и патронник; диск модульного компьютера (программы и чертежи, не текст и не почта) и вставленная флешка. Не с живых мобов. Nested через `storage_id` и `storage_kind` (карман куртки или конкретный аксессуар). Apply сносит весь `startswith` у storage и карманов `suit/storage`. У одежды пишутся `accessories`. У реагентов пишется содержимое, пустой список = банка пустая. Legacy без `items.json`/`items_*` — предметы карты не трогаем;
- mechs / corpses — тот же объём зоны, что items (persistable areas, включая шаттлы off-station Z);
- continue кампании только до старта раунда (лобби); mid-round admin continue запрещён (Force apply — отдельно, с предупреждением);
- оторванные органы (`remains.json`: type, DNA compact, имя, урон, closet/morgue; связь с мёртвым roster по имени). Не в `items_*`. Apply после `corpses`;
- грязь / кровь (`cleanables.json`: `/obj/decal/cleanable`, у крови amount/basecolor/blood_DNA). Отдельно от Bay `SSpersistence` filth;
- мехи;
- счета Сьерры и отделов;
- каналы и сюжеты Newscast, включая фото (savefile рядом с JSON);
- roster участников, погибшие слоты. Смерть сразу пишет `dead`. Дефибриллятор, пересадка разума в живое тело и админский revive снимают метку и возвращают записи спящего, генокрада и фракции. Строка о смерти в хронике остаётся, для командования добавляется «снова среди живых»;
- шаттлы (Guppy, Charon, Petrov, Phaethon, эскейп-поды):
  - вне Сьерры → `abandoned` (пустой док на следующих сменах);
  - на Сьерре, но с повреждениями выше порога → `damaged` + ориентировочная оценка ремонта (информативно, без списания со счетов);
- `shuttle_reports` в `campaign.json` (legacy `abandoned_shuttles` по-прежнему пишется как список имён);
- тело через `character_persist` в **отдельном** файле `…_odyssey.json` (обычный снимок не трогается); личный счёт и `campaign_id` — в одиссейном снимке; хирургические аугменты и импланты на кукле (без uplink/explosive/antag и без psi-dampener — его ставит job essentials); смерть в Одиссее сбрасывает только его;
- **инвентарь живого экипажа** (одиссейный persist): первая смена на кукле — обычный job+loadout; дальше restore worn/carried без нового outfit/loadout. Кукла залочена на `assigned_job` или `Crewman` (roundstart и latejoin; job priority в лобби лок не обходит). ID и гарнитура выдаются работой заново. КПК, планшет и ноутбук переносятся вместе с программами и флешкой; текстовые файлы и почта — нет. Тот же общий запрет уникальных вещей, плюс любая гарнитура. Бумага, фото, папки и бандлы в инвентаре переносятся. Оружие и броня переносятся с зарядом и магазином. Крио живого с включённой персистентностью пишет тело и инвентарь до выхода из капсулы; слот не умирает, человек возвращается обычным спавном. Custody — без inventory;
- employment / security / medical записи, `criminal_status` и `physical_status` (включая правки с консолей в течение смены) — в roster кампании; при спавне в активной Одиссее применяются всегда. Persist-снимок дублирует их, если персистентность включена;
- **custody**: если на конец смены живой участник с `criminal_status` Incarcerated/Arrest находится в бриге/тюрьме/допросе (Sierra security areas) — в roster пишется `custody=brig`; на следующей смене после экипа — оранжевая форма, без ID, спавн на случайный `/obj/landmark/odyssey_custody` (ставить в prison cells; fallback — свободный пол в `/area/security/sierra/prison`); стартовый гир работы снимается;
- трупы экипажа на Сьерре (включая лежащих в морге или шкафу): внешность и раны. Тело в морге в больничной рубашке. Сохраняемые вещи с него лежат в шкафу на соседнем тайле морга, иначе в ближайшем шкафу той же зоны. Уникальные и помеченные стволы глав туда не кладутся.

**Не сохраняется в MVP**

- атмос, провода/трубы, disposal, away sites и любые пристыкованные чужие корабли/шаттлы (даже на Z Сьерры);
- доступ на ID (его заново выдаёт работа); текстовые файлы, логи и почта на дисках компьютеров;
- авто-приживление органов к трупу;
- antag/uplink **импланты в теле** (сам предмет uplink в кармане или на полу — да);

Overmap не сериализуется: он воспроизводимо создаётся из seed текущего сектора. Уровень опасности меняет число облаков hazards (как ванильный `overmap_event_areas`), их типы, задержку случайных событий и шанс Левиафана.

**Whitelist объектов**

- `/obj/machinery/computer` — у модульной консоли внутренний диск (программы и чертежи) и вставленная флешка; немодульная консоль своего списка программ не имеет;
- `/obj/machinery/vending`;
- `/obj/machinery/fabricator` — в том числе `stored_material` (ресурсы в бункере; диски/бикер/очередь печати — нет);
- `/obj/machinery/smartfridge` chemistry / `secure/medbay` / `secure/virology` — всегда в снимке; `fridge_items` (до 300): type, name, reagents, nested `contents` у pill bottles;
- `/obj/machinery/anomaly_container` + `/obj/machinery/artifact` — контейнер с артефактом (`anomaly.artifact`: эффекты, триггеры, icon/HP), свободные артефакты на полу, прикреплённая бумага и `broken`;
- `/obj/machinery/power/smes` — заряд, input/output attempt+level, capacity, name_tag;
- `/obj/machinery/power/shield_generator` — running/energy/radius/modes/input_cap (поле пересобирается при running);
- `/obj/machinery/atmospherics/unary/cryo_cell` — on, stasis mult, бикер с реагентами (без пациента; atmos pipe не спавнится заново);
- `/obj/machinery/portable_atmospherics` (canister / pump / scrubber / hydroponics / cracker / sublimator; без `hydroponics/soil/invisible`) — газ, holding tank, порт, use_power/cell; у канистр valve/release; у hydro — растение по `seed.name` + уровни воды/пита/вредителей;
- листовые `/obj/item/stack/material` на станции (отдельно от бункера фабрикатора);
- `/obj/machinery/sleeper`;
- `/obj/machinery/door/airlock` — HP, поломка панели, сварка, болты, открытая панель, открыт/закрыт; полностью разбитый шлюз остаётся как `/obj/structure/broken_door`;
- **все** `/obj/structure` в персистентных зонах корабля, кроме denylist: кабели, disposal pipe/holder/outlet, ladder / stairs (multiz), transit_tube / pod, **table / bed** (стулья — subtype bed; иначе ложные `destroyed` сносили мебель Харона/карго на continue);
- атмосферные трубы (`/obj/machinery/atmospherics`) в structure-снимок не входят;
- у catwalk дополнительно пишутся plating и открытый люк; мостики в `/area/space` и на обшивке по-прежнему вне снимка (зона не persistable);
- сериализация базовая (`type/dir/name/anchored` + catwalk fields): HP окон и т.п. не восстанавливаются детально — только наличие/позиция/ориентация.

### Файлы сейва

`data/odyssey_<map.path>_<part>.json`

- `campaign.json` — seed, граф, маршрут, статус/outcome и метаданные кампании;
- `turfs.json`, `machinery.json`, `structures.json`, `mechs.json`, `economy.json`, `newscast.json`, `materials.json`, `papers.json` — части снимка;
- `items.json` — маркер lane предметов (`item_count`, список непустых bucket’ов);
- `items_weapons.json` … `items_misc.json` — предметы по категориям (пустые bucket’ы не пишутся);
- `remains.json` — detached organs;
- `cleanables.json` — кровь / filth на тайлах;
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
- **машинерия/компьютеры/мебель**: whitelist diff со стабильными id и tombstones; apply всегда `locate(type)` на клетке при смене id; fabricator / chem-fridge / anomaly / SMES / shield / cryo — своё состояние;
- **материалы**: `materials.json` — стаки на станции; continue = strip DMM + apply снимка;
- **документы**: `papers.json` + `papers_photos.sav` — картотеки + loose paper/folder/bundle/photo на полу/в шкафу; continue = strip + restore; бюджет 500/100/~2MB;
- **предметы**: `items.json` + `items_*.json`; continue = strip всех persistable items если есть manifest/bucket этой generation, затем apply (корни → nested multi-pass; storage autofill wipe);
- **останки**: `remains.json` — detached `/obj/item/organ` с DNA/именем; после corpses;
- **грязь**: `cleanables.json` — `/obj/decal/cleanable` в persistable areas; strip+restore если файл есть;
- **мехи**: тип, компоненты, заряд, оборудование — patch или spawn;
- **экономика**: счёт судна + отделы (баланс и лог транзакций, до 100 записей на счёт); личные счета — в снимке character_persist (`account_money` + `account_transactions`);
- **newscast**: каналы, авторы, цензура, сюжеты, wanted issue и фото в `newscast_photos.sav`;
- **шаттлы**: abandoned (пустой док) и damaged (score + ориентировочный repair_cost без списания; повторная запись в хронику при заметном росте урона);
- **персонаж**: roster по `campaign_id + ckey + slot`; погибший слот блокируется до конца кампании;
- **хроника**: `chronicle.json` + UI в Newscast/Command; continue-vote briefing в чат;
- **контракты/цели**: `contracts` + `objectives` в meta; Briefing UI (Newscast + Command);
- **наука (НИО)**: `research.json` — секторные брифы смены (spectrum / catalog / flora / slime), notes; `tech_tree` (ноды / уровни / репутация / catalog design ids / reverse-engineered payloads) — источник правды между сменами; System HDD `rnd_state` зеркалится только в активной Одиссее; награда — таллеры на счёт Science; в Briefing (консоль RnD контракты удалены);
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
- `code/controllers/subsystems/ticker.dm` — хук `odyssey_pregame_consider_vote()` (no-op; vote из кнопки Odyssey); при активной кампании `choose_gamemode` форсирует `extended`;
- `code/controllers/evacuation/evacuation.dm` — запрет классического BSJ из эвакуационного меню во время Одиссеи;
- `mods/machinery/.../bluespace_drive.dm` + `mods/odyssey/code/bluespace_drive_odyssey.dm` — Odyssey Jump, commit перехода и конец смены;
- `code/modules/client/preferences_persist.dm` — блок загрузки погибшего слота (`load_character` возвращает FALSE);
- `code/modules/mob/new_player/new_player.dm` — блок Ready/Join за погибший слот;
- `code/controllers/subsystems/jobs.dm` — пропуск слота из приоритетного списка, если загрузка отклонена;
- `code/modules/admin/admin_verbs.dm` — верб `Odyssey Panel`.
