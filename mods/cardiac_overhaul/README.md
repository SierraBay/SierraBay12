#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/#####

## Кардио-оверхол (Cardiac Overhaul)

ID мода: CARDIAC_OVERHAUL

### Описание мода

Мод добавляет проработанные состояния сердечного ритма (STEMI, V-Fib, PEA, Heart Block), поддержку отображения ритма на медицинских приборах, новый интерфейс монитора жизненных показателей (Vitals Monitor) на NanoUI, и событие спонтанного инфаркта миокарда.

### Изменения *кор кода*

- `code/_helpers/medical_scans.dm`: `medical_scan_results` (добавлена поддержка чисел пульса)
- `code/game/machinery/computer/Operating.dm`: замена `interact()` на NanoUI `ui_interact()`
- `code/game/machinery/vitals_monitor.dm`: замена UI на NanoUI
- `code/game/objects/items/devices/scanners/health.dm`: 
- `code/modules/events/event_container.dm`: 
- `code/modules/events/event_dynamic.dm`: 
- `code/modules/mob/living/carbon/human/life.dm`: 

### Оверрайды

- `mods/_master_files/code/modules/organs/internal/heart.dm` (переменные ритма и инфаркта, проки `handle_infarct`, `update_rhythm`, оверрайды `Life`, `handle_pulse`, `stop`, `is_working`, `listen`)
- `mods/_master_files/code/modules/mob/living/carbon/human/human.dm` (оверрайды `get_pulse_as_number`, `get_pulse`, `resuscitate`)
- `nano/templates/mods/vitals_monitor.tmpl` (новый NanoUI шаблон монитора жизненных показателей)

### Дефайны

- `code/__defines/~mods/~master_defines.dm`: `RHYTHM_NSR`, `RHYTHM_TACHY`, `RHYTHM_BRADY`, `RHYTHM_VFIB`, `RHYTHM_BLOCK`, `RHYTHM_PEA`, `RHYTHM_ASYSTOLE`, `RHYTHM_STEMI`, `RHYTHM_HAS_PULSE(r)`

### Авторы:

ImJustKisik
