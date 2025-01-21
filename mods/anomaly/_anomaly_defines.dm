#ifndef MODPACK_ANOMALY
#define MODPACK_ANOMALY

#include "_anomaly.dm"
// Далее просто включай свой код
// #include "code/something.dm"
#include "code\anomaly_admin.dm" //Админские кнопочки
#include "code\anomaly_controller.dm" //Контроллер аномалий
#include "code\anomaly_defines.dm"


//Аномалии
//Типы аномалий
#include "code\anomalies\__anomalies_includes.dm"
#include "code\artefacts\__small_artefacts_includes.dm" //Код артефактов и всё с ними связанное
#include "code\big_artefacts\_big_artefacts_includes.dm" //Код больших артефактов
#include "code\detectors_and_etc\_equipment_includes.dm" //Детекторы и прочее оборудование
#include "code\spawn_anomalies_protocol\__spawn_protocols_includes.dm" //Размещение аномалий в игре
#include "maps\anomaly_ruins_includes.dm" // Руины и разные карты

//ETC
#include "code\functions\locating.dm"

#endif
