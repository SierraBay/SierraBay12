## Двуручный хват

ID мода: MODPACK_TWOHANDING

### Описание мода

Двуручное оружие ближнего боя и дальнобойное оружие, которое рассчитано на две руки, занимают вторую руку предметом-хватом. Альт-клик и Z переключают хват. Пробел передёргивает затвор или меняет режим стрельбы. У оружия с прицелом появляется кнопка Use Scope.

Пистолеты и револьверы без спрайта двуручного удержания и со штрафом одной руки меньше 4 остаются одноручными.

### Изменения *кор кода*

- Отсутствуют

### Оверрайды

- `mods/_master_files/code/game/objects/items.dm`: `/obj/item/is_held_twohanded()`, `/obj/item/zoom()`
- `mods/_master_files/code/game/objects/items/weapons/material/twohanded.dm`: `/obj/item/material/twohanded/update_force()`, `/obj/item/material/twohanded/update_twohanding()`
- `mods/_master_files/code/modules/projectiles/gun.dm`: `/obj/item/gun/Initialize()`, `/obj/item/gun/on_update_icon()`, `/obj/item/gun/dropped()`, `/obj/item/gun/switch_firemodes()`, `/obj/item/gun/equipped()`
- `mods/_master_files/code/_onclick/hud/action.dm`: `/datum/action/var/button_overlay_icon`, `/obj/screen/movable/action_button/UpdateIcon()`
- `mods/twohanding/code/keybindings.dm`: `/datum/keybinding/mob/activate_inhand/down()` — Z берёт двуручное оружие в хват, иначе использует предмет как раньше

### Дефайны

- Отсутствуют

### Используемые файлы, не содержащиеся в модпаке

- Отсутствуют
