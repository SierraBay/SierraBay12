# Как активировать DEV режим?
1. 
Переходим в файл по пути maps\using.dm
Меняем значение #define DEV_MODE с 0 на 1
Как у вас: 
//Easily change which map to build by uncommenting ONE below.
#define DEV_MODE 0
#if DEV_MODE == 1
	#include "../mods/dev_mode/code/dev_map/dev_map.dm"
	#warn Активирован режим разработчика, не забудь отключить!
#else
	//#include "example\map.dm"
	//#include "torch\map.dm"
	#include "sierra\map.dm"
#endif

Как должно стать:
//Easily change which map to build by uncommenting ONE below.
#define DEV_MODE 1 
#if DEV_MODE == 1
	#include "../mods/dev_mode/code/dev_map/dev_map.dm"
	#warn Активирован режим разработчика, не забудь отключить!
#else
	//#include "example\map.dm"
	//#include "torch\map.dm"
	#include "sierra\map.dm"
#endif

# Как деактивировать DEV режим?
Всё тоже самое, но в обратном порядке


P.S.: Не забудьте себе выдать админ права через конфиг! И обязательно выключайте ДЕВ-мод при заливании своих изменений! ДЕВ мод создан для очень быстрой компиляции билда и тестирования своего кода, сильно ускоряет девелопмент.
