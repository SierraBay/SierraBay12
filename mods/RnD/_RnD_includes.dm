#ifndef MODPACK_RND
#define MODPACK_RND

// Ядро
#include "_RnD.dm"
#include "code/_designs.dm"


// Аугменты
#include "code/augments/active.dm"
#include "code/augments/clicker.dm"
#include "code/augments/sonar.dm"
#include "code/augments/vampire.dm"
#include "code/augments/sandevistan.dm"

// Корпорации и деревья технологий
#include "code/corporations.dm"
#include "code/corporate_tech_trees.dm"

// Исследования
#include "code/research.dm"
#include "code/SSresearch.dm"

// Техноветки
#include "code/tech_branch/tech_engineering.dm"
#include "code/tech_branch/tech_biotech.dm"
#include "code/tech_branch/tech_combat.dm"
#include "code/tech_branch/tech_telecom.dm"
#include "code/tech_branch/tech_cybernetics.dm"
#include "code/tech_branch/tech_illegal.dm"

// Аппаратные модули
#include "code/hardware/scanner_research.dm"

// Машины
#include "code/machinery/autolathe.dm"
#include "code/machinery/destructive_analyzer.dm"
#include "code/machinery/food_replicator.dm"
#include "code/machinery/recipe_analyzer.dm"

#include "code/machinery/rdconsole.dm"
#include "code/machinery/rdmachines.dm"
#include "code/machinery/server.dm"
#include "code/machinery/server_persistence.dm"
#include "code/machinery/away_servers.dm"
#include "code/machinery/robotics_fabricator.dm"
#include "code/machinery/autolathe_disk_cloner.dm"
#include "code/machinery/rd_mission_drone_pad.dm"


// Программы для модульных компьютеров
#include "code/program/asset.dm"
#include "code/program/binary.dm"
#include "code/program/design.dm"
#include "code/program/designownloader.dm"
#include "code/program/mission_tracker.dm"
#include "code/program/camera.dm"
#include "code/program/filetypes.dm"
#include "code/program/codeprocessor.dm"
#include "code/program/itcommand.dm"
#include "code/program/rnd_console.dm"

// Миссии и награды
#include "code/admin.dm"
#include "code/derelict_missions.dm"
#include "code/derelict_mission_items.dm"
#include "code/derelict_mission_configs.dm"
#include "code/derelict_mission_virology.dm"
#include "code/derelict_ghost_invasion.dm"

// Эксперименты и научные приборы
#include "code/experiment.dm"
#include "code/spectral_analysis.dm"
#include "code/artifact_catalogization.dm"
#include "code/research_report.dm"
#include "code/reverse_engineering.dm"
#include "code/defective_component.dm"
#include "code/event.dm"

// Ксенобиология и ксеноботаника
#include "code/xenobiology.dm"
//#include "code/xenobot/botanicdisk.dm"
#include "code/xenobot/botanyscannermodule.dm"
#include "code/xenobot/botanicmachines.dm"
#include "code/xenobot/seedfile.dm"

// Ксеноархеология
#include "code/xenoarch/artifact_analyser.dm"
#include "code/xenoarch/geosample_scanner.dm"
#include "code/xenoarch/tesla.dm"
#include "code/xenoarch/grav.dm"
//#include "code/xenoarch/nature.dm"
#include "code/xenoarch/swap.dm"

// Диски и рынок дизайнов
#include "code/misc.dm"

// Дизайны автолата
#include "code/designs_autolathe/designs_arms_ammo.dm"
#include "code/designs_autolathe/designs_cutlery.dm"
#include "code/designs_autolathe/designs_devices_components.dm"
#include "code/designs_autolathe/designs_engineering.dm"
#include "code/designs_autolathe/designs_medical.dm"
#include "code/designs_autolathe/designs_glasses.dm"
#include "code/designs_autolathe/designs_general.dm"
#include "code/designs_autolathe/designs_tools.dm"
#include "code/designs_autolathe/disks.dm"
#include "code/designs/designs_misc.dm"
#include "code/designs/designs_combat.dm"
#include "code/designs/designs_food.dm"

// Дизайны мехфаба
#include "code\designs\mechfab\arms\mech_l_arm.dm"
#include "code\designs\mechfab\arms\mech_r_arm.dm"
#include "code\designs\mechfab\legs\mech_l_leg.dm"
#include "code\designs\mechfab\legs\mech_r_leg.dm"
#include "code\designs\mechfab\mech_equipment\_equipment.dm"
#include "code\designs\mechfab\mech_equipment\combat.dm"
#include "code\designs\mechfab\mech_equipment\engi.dm"
#include "code\designs\mechfab\mech_equipment\medical.dm"
#include "code\designs\mechfab\mech_equipment\utility.dm"
#include "code\designs\mechfab\armour_mech.dm"
#include "code\designs\mechfab\body.dm"
#include "code\designs\mechfab\doubled_legs.dm"
#include "code\designs\mechfab\main_mech.dm"
#include "code\designs\mechfab\sensors.dm"
#include "code\designs\designs_mechfab.dm"

#endif
