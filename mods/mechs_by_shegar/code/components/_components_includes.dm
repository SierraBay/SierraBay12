#include "_components.dm"
#include "armour.dm"

//Взаимодействие с частями меха
#include "components_interactions\material.dm"
#include "components_interactions\screwdriver.dm"
#include "components_interactions\welder.dm"

//Сенсоры
#include "head\_head_core.dm"
#include "head\combat.dm"
#include "head\heavy.dm"
#include "head\light.dm"
#include "head\powerloader.dm"
//Пузо
#include "body\_body_core.dm"
#include "body\combat.dm"
#include "body\heavy.dm"
#include "body\light.dm"
#include "body\pod.dm"
#include "body\powerloader.dm"
//Руки
#include "arms\_arms_core.dm"
#include "arms\combat.dm"
#include "arms\heavy.dm"
#include "arms\light.dm"
#include "arms\powerloader.dm"
//Ноги
#include "legs\_legs_core.dm"
#include "legs\combat.dm"
#include "legs\doubled_legs.dm"
#include "legs\heavy.dm"
#include "legs\light.dm"
#include "legs\powerloader.dm"
#include "legs\spider.dm"
#include "legs\tracks.dm"
//Пассажирка
#include "passenger_compartment\_passenger_core.dm"
#include "passenger_compartment\add_passenger.dm"
#include "passenger_compartment\remove_passenger.dm"

//Каркас
#include "frame\_vars.dm"
#include "frame\frame.dm"
#include "frame\render.dm"
#include "frame\use_tool.dm"
#include "frame\use_tool\arms_install.dm"
#include "frame\use_tool\body_install.dm"
#include "frame\use_tool\cable_coil.dm"
#include "frame\use_tool\crowbar.dm"
#include "frame\use_tool\doubled_leg_instalation.dm"
#include "frame\use_tool\legs_install.dm"
#include "frame\use_tool\material_install.dm"
#include "frame\use_tool\screwdriver_interaction.dm"
#include "frame\use_tool\sensors_install.dm"
#include "frame\use_tool\welder_interaction.dm"
#include "frame\use_tool\wirecutter_interactio.dm"
#include "frame\use_tool\wrench_interaction.dm"
//Прочее
#include "software.dm"

#include "id_control.dm" //ID control
