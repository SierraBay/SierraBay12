# Как активировать DEV режим?
1. 
Переходим в mods\global_modpacks.dm, снимаем комментирование с второй строки кода 
#include "dev_mode\_dev_mode.dme"

Как у вас:
//#include "dev_mode\_dev_mode.dme"
Как должно стать:
#include "dev_mode\_dev_mode.dme"

2. 
Переходим в файл по пути maps\using.dm
Снимаем комментирование с //#include "../mods/dev_mode/code/dev_map/dev_map.dm"
Комментируем строку #include "sierra\map.dm"

Как у вас:
//Easily change which map to build by uncommenting ONE below.

//#include "example\map.dm"
//#include "torch\map.dm"
#include "sierra\map.dm"
//#include "../mods/dev_mode/code/dev_map/dev_map.dm"
Как должно стать:
//#include "example\map.dm"
//#include "torch\map.dm"
//#include "sierra\map.dm"
#include "../mods/dev_mode/code/dev_map/dev_map.dm"

# Как деактивировать DEV режим?
Всё тоже самое, но в обратном порядке


P.S.: Не забудьте себе выдать админ права через конфиг! И обязательно выключайте ДЕВ-мод при заливании своих изменений! ДЕВ мод создан для очень быстрой компиляции билда и тестирования своего кода, сильно ускоряет девелопмент.
