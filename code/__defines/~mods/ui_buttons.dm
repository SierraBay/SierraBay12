/// Симпл баттон, но с состоянием выбранности
#define CFBTN(key, value, selected) \
"<a class='[selected ? "linkOn" : ""]' href='?src=\ref[src];[key]=[value]'>[value]</a>"

/// Симпл баттон, но с состоянием выбранности и с возможностью выбрать "отца"
#define FCFBTN(father, key, value, selected) \
"<a class='[selected ? "linkOn" : ""]' href='?src=\ref[father];[key]=[value]'>[value]</a>"

#define EXTRA_BTN(action, ref_obj, extra_param, label) \
"<a href='?src=\ref[src];[action]=[ref_obj]|[extra_param]'>[label]</a>"

/*
Зачем вообще эта кнопка?
Данная кнопка используется в Повелителе зоны (Админ кнопке для управления модом аномалий)
Вместо обычной кнопки где передаётся 2 значения (1 это src, второе это что вы выберете)
Мы выдаём 3 значения (src, которое захотим (Обычно это ссылка на обьект) и текстовая переменная),
Последнее используется чтоб обьяснить в какое меню перекинуть пользователя после выполнения действия
*/

#define MULTI_BTN(action, ref_obj, extra_key, label) \
"<a href='?src=\ref[src];[action]=[ref_obj];[extra_key]=[1]'>[label]</a>"
