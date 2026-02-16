//Easily change which map to build by uncommenting ONE below.
// #define DEV_MODE
#if NEW_AWAYS_TESTING == 1
	#include "../mods/new_aways_testing/code/_new_aways_testing.dm"
	#warn Включено тестирование новых авеек, не забудь выключить!
#else
	#ifdef DEV_MODE
		#include "../mods/dev_mode/code/dev_map/dev_map.dm"
		#warn Режим разработчика активен, не забудь выключить!
	#else
		//#include "example\map.dm"
		//#include "torch\map.dm"
		#include "sierra\map.dm"
	#endif
#endif
