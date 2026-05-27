#ifndef MODPACK_AI
#define MODPACK_AI

#include "_ai.dm"

#include "code/ai.dm"
#include "code/ai_hud.dm"
#include "code/ai_screen_objects.dm"

//[INFINITY]
#include "code/AI-holder/AI-holder.dm" //ИИ холдер
#include "code/AI-holder/atom_helpers.dm" //Вспомогательный мусор для ИИ холдера
#include "code/AI-holder/turret_control.dm" //Управление туррелью будучи ИИ
//[INFINITY]
#include "code/vars.dm" //Переменные
#include "code/borgs_equipments.dm" //Перепись снаряжения для боргов
#include "code/alarm_silicon.dm" //Тревоги для боргов и ИИ
#include "code/ntos_ai.dm" //НТОС для ИИ
#include "code/ai_hack.dm" //Взлом шлюза и APC у ИИ
#include "code/ai-stuff.dm" //Дополнительные действия и фичи у ИИ
#include "code/ai_machine_interaction.dm" //Взаимодействие ИИ с машинами
#include "code/boris.dm" //Модуль B.O.R.I.S. и его логика
#include "code/modules.dm" //Модуль роботов
#include "code/equipment_items.dm" //Айтемы модулей роботов
#include "code/law_modules.dm" //Физические модули законов ИИ
#include "code/law_rack_machine.dm" //Физическая стойка законов ИИ (машина, UI, доступ, синхронизация)
#include "code/law_rack_presets.dm" //Пресеты стойки законов и связывание ИИ
#include "code/law_rack_designs.dm" //Плата и исследования стойки законов
#include "code/law_rack_upload_api.dm" //Полиморфный API для программирования модулей
#include "code/preprogrammed_laws.dm" //Предустановленные платы законов и автоматическая замена дисков
#include "code/cognitive_load.dm" //Когнитивная нагрузка ИИ

#endif
