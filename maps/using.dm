//Easily change which map to build by uncommenting ONE below.
#define DEV_MODE 0
#if DEV_MODE == 1
	#include "../mods/dev_mode/code/dev_map/dev_map.dm"
	#warn Режим разработчика активен, не забудь выключить!
#else
	//#include "example\map.dm"
	//#include "torch\map.dm"
	#include "sierra\map.dm"
#endif
