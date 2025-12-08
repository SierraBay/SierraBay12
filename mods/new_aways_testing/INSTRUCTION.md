# Инструкция по использованию теста новых авеек.
1. 
Переходим в файл по пути code\__defines\~mods\~master_defines.dm
Меняем значение #define NEW_AWAYS_TESTING с 0 на 1
По итогу строки должны быть такими: 
//New aways testing mod, change to 1 in order to turn it on. Always turn it off afterwards.
#define NEW_AWAYS_TESTING 1

#if NEW_AWAYS_TESTING == 1
	#define UNIT_TEST 1
#endif
//New aways testing mod


2. 
Переходим в файл \mods\new_aways_testing\code\test_these_maps.dm и в него добавляем свою авей карту с переменной 'skip_main_unit_tests = FALSE', например:

/datum/map_template/ruin/exoplanet/my_new_map
	skip_main_unit_tests = FALSE

(Для удобства, там уже сейчас находятся четыре авей карты Шегара)

3. 
Запустите скомпилированный сервер в Dream Daemon.

Тесты будут производиться автоматически, и по их окончанию - сервер автоматически выключится.

В качестве результата, в окне Dream Daemon будет отображен текст тестов авеек также, как сейчас у теста на Гитхабе. Его можно полностью скопировать и для удобства перенести в любой текстовый редактор для чтения.

Если карта попала в тесты, то ее можно будет найти в итоговом тексте.

4. 
По окончанию тестирования авеек, необходимо вернуть NEW_AWAYS_TESTING в значение 0, при этом изменения \mods\new_aways_testing\code\test_these_maps.dm можно не откатывать.
