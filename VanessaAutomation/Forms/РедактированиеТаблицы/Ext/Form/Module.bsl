﻿#Область КомандыФормы

&НаКлиенте
Процедура ПометитьВсе(Команда)
	Ном = 0;
	Для Каждого Элем Из СписокКолонок Цикл
		Ном          = Ном + 1;
		Элем.Пометка = Истина;
		Элементы["ТаблицаНаФорме_Колонка" + Формат(Ном, "ЧГ=; ЧН=0")].Видимость = Элем.Пометка;
	КонецЦикла;	
	
	Элементы.ТаблицаНаФорме_СлужебнаяПустаяКолонка_.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	Ном = 0;
	Для Каждого Элем Из СписокКолонок Цикл
		Ном          = Ном + 1;
		Элем.Пометка = Ложь;
		Элементы["ТаблицаНаФорме_Колонка" + Формат(Ном, "ЧГ=; ЧН=0")].Видимость = Элем.Пометка;
	КонецЦикла;
	
	Элементы.ТаблицаНаФорме_СлужебнаяПустаяКолонка_.Видимость = Истина;
КонецПроцедуры

&НаКлиенте
Процедура СдвинутьКолонкуВВерх(Команда)
	ТекИмяКолонки = Элементы.СписокКолонок.ТекущиеДанные.Значение;
	НомерКолонки = Число(СтрЗаменить(ТекИмяКолонки, "Колонка", "")) - 1;
	Если НомерКолонки = 0 Тогда
		Возврат;
	КонецЕсли;	
	
	НовыйНомерКолонки = НомерКолонки - 1;
	
	ПоменятьКолонкиМестами(НомерКолонки, НовыйНомерКолонки);
	
КонецПроцедуры

&НаКлиенте
Процедура СдвинутьКолонкуВниз(Команда)
	ТекИмяКолонки = Элементы.СписокКолонок.ТекущиеДанные.Значение;
	НомерКолонки = Число(СтрЗаменить(ТекИмяКолонки, "Колонка", "")) - 1;
	Если НомерКолонки = СписокКолонок.Количество() - 1 Тогда
		Возврат;
	КонецЕсли;	
	
	НовыйНомерКолонки = НомерКолонки + 1;
	
	ПоменятьКолонкиМестами(НомерКолонки, НовыйНомерКолонки);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция РазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено) Экспорт
	
	Результат = Новый Массив;
	
	// для обеспечения обратной совместимости
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
		
	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Результат.Добавить(Подстрока);
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Результат.Добавить(Строка);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции 

&НаСервере
Процедура ЗагрузитьМассивСтрокВТаблицу(Таблица,МассивСтрок)
	Таблица.Очистить();
	Таблица.Колонки.Очистить();
	
	Для Каждого Стр Из МассивСтрок Цикл
		СтрокаТаблицы = Таблица.Добавить();
		
		Стр = СтрЗаменить(Стр,"\|","~ЭкранированиеВертикальнойЧерты~");
		
		Стр = СокрЛП(Стр);
		Если Лев(Стр,1) = "|" Тогда
			Стр = Сред(Стр,2);
		КонецЕсли;	 
		
		Если Прав(Стр,1) = "|" Тогда
			Стр = Лев(Стр,СтрДлина(Стр)-1);
		КонецЕсли;	 
		
		МассивЗначений = РазложитьСтрокуВМассивПодстрок(Стр,"|");
		
		Для Ккк = 0 По МассивЗначений.Количество()-1 Цикл
			ИмяКолонки = "Колонка" + (Ккк+1);
			Если Таблица.Колонки.Количество() < Ккк+1 Тогда
				Таблица.Колонки.Добавить(ИмяКолонки,Новый ОписаниеТипов("Строка"));
			КонецЕсли;	
			
			МассивЗначений[Ккк] = СокрЛП(СтрЗаменить(МассивЗначений[Ккк],"~ЭкранированиеВертикальнойЧерты~","\|"));
			СтрокаТаблицы[ИмяКолонки] = МассивЗначений[Ккк];
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	Таблица.Колонки.Добавить("СлужебнаяПустаяКолонка_");
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗагрузитьТаблицуСервер()
КонецПроцедуры


&НаСервере
Функция ЗаголовкКолонкиСервер(Стр,Имя)
	Если Найти(Имя,"СлужебнаяПустаяКолонка_") > 0 Тогда
		Возврат " ";
	КонецЕсли;	 
	
	Возврат Стр; 
КонецФункции	 

&НаСервере
Процедура ЗагрузитьТаблицуСервер(МассивСтрокДляРедактирования = Неопределено)
	УжеЕстьРеквизиты = Ложь;
	Если МассивСтрокДляРедактирования = Неопределено Тогда
		МассивСтрокДляРедактирования = Параметры.МассивСтрокДляРедактирования;
	Иначе	
		УжеЕстьРеквизиты = Истина;
	КонецЕсли;	 
	
	ПромТаблица = Новый ТаблицаЗначений;
	ЗагрузитьМассивСтрокВТаблицу(ПромТаблица,МассивСтрокДляРедактирования);
	
	Если УжеЕстьРеквизиты Тогда
		УдаляемыеРеквизиты = Новый Массив;
		Для Каждого Колонка Из ПромТаблица.Колонки Цикл 
			УдаляемыеРеквизиты.Добавить("ТаблицаНаФорме." + Колонка.Имя);
		КонецЦикла;	 
		ИзменитьРеквизиты(,УдаляемыеРеквизиты);
	КонецЕсли;	 
	
	ДобавляемыеРеквизиты  = Новый Массив;
	Для Каждого Колонка Из ПромТаблица.Колонки Цикл 
		НоваяКолонка = Новый РеквизитФормы(Колонка.Имя, Новый ОписаниеТипов("Строка"), "ТаблицаНаФорме",
		    ЗаголовкКолонкиСервер(СокрЛП(ПромТаблица[0][Колонка.Имя]),Колонка.Имя)); 
		ДобавляемыеРеквизиты.Добавить(НоваяКолонка);
		
		Если Найти(Колонка.Имя,"СлужебнаяПустаяКолонка_") > 0 Тогда
			Продолжить;
		КонецЕсли;	 
		
		Если НЕ УжеЕстьРеквизиты Тогда
			ЭлементСпискаКолонок               = СписокКолонок.Добавить();
			ЭлементСпискаКолонок.Значение      = Колонка.Имя;
			ЭлементСпискаКолонок.Пометка       = Истина;
			ЭлементСпискаКолонок.Представление = СокрЛП(ПромТаблица[0][Колонка.Имя]);
			Если Лев(ЭлементСпискаКолонок.Представление,1) = "'" И Прав(ЭлементСпискаКолонок.Представление,1) = "'" Тогда
				ЭлементСпискаКолонок.Представление = Сред(ЭлементСпискаКолонок.Представление,2,СтрДлина(ЭлементСпискаКолонок.Представление)-2);
			КонецЕсли;	 
		КонецЕсли;	 
	КонецЦикла; 
	
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	Если НЕ УжеЕстьРеквизиты Тогда
		Для Каждого Колонка Из ПромТаблица.Колонки Цикл 
			НовыйЭлемент = Элементы.Добавить("ТаблицаНаФорме_" + Колонка.Имя, Тип("ПолеФормы"), Элементы.ТаблицаНаФорме);       
			НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
			НовыйЭлемент.ПутьКДанным = "ТаблицаНаФорме." + Колонка.Имя;
			НовыйЭлемент.Ширина = 10;		
		КонецЦикла; 
	КонецЕсли;	 
	
	ЗначениеВРеквизитФормы(ПромТаблица,"ТаблицаНаФорме");
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
КонецПроцедуры

&НаКлиенте
Процедура СписокКолонокПометкаПриИзменении(Элемент)
	Значение      = Элементы.СписокКолонок.ТекущиеДанные.Значение;
	ЭлементСписка = СписокКолонок.НайтиПоЗначению(Значение);
	
	ИД = СписокКолонок.Индекс(ЭлементСписка);
	
	Элементы["ТаблицаНаФорме_Колонка" + Формат(ИД+1, "ЧГ=; ЧН=0")].Видимость = Элементы.СписокКолонок.ТекущиеДанные.Пометка;
	
	КолПометок = 0;
	Для Каждого Элем Из СписокКолонок Цикл
		Если Элем.Пометка Тогда
			КолПометок = КолПометок + 1;
		КонецЕсли;	 
	КонецЦикла;	 
	
	Если КолПометок = 0 Тогда
		Элементы.ТаблицаНаФорме_СлужебнаяПустаяКолонка_.Видимость = Истина;
	Иначе	
		Элементы.ТаблицаНаФорме_СлужебнаяПустаяКолонка_.Видимость = Ложь;
	КонецЕсли;	 
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивСтрокПослеРедактирования()
	Таблица = РеквизитФормыВЗначение("ТаблицаНаФорме");
	
	Массив = Новый Массив;
	
	Для НомерСтроки = 0 По Таблица.Количество()-1 Цикл
		Стр = "| ";
		Для Ккк = 0 По СписокКолонок.Количество()-1 Цикл
			Если НЕ СписокКолонок[Ккк].Пометка Тогда
				Продолжить;
			КонецЕсли;	 
			
			Стр = Стр + Таблица[НомерСтроки][Ккк] + "|";
		КонецЦикла;
		
		Массив.Добавить(Стр);
	КонецЦикла;	
	
	Возврат Массив;
КонецФункции	

&НаКлиенте
Процедура ОК(Команда)
	МассивСтрок = ПолучитьМассивСтрокПослеРедактирования();
	Оповестить("РедактированиеТаблицыGherkin",МассивСтрок);
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура СписокКолонокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	СнятьВсе(Неопределено);
	СписокКолонок[ВыбраннаяСтрока].Пометка = Истина;
	СписокКолонокПометкаПриИзменении(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура ПоменятьКолонкиМестами(НомерКолонки, НовыйНомерКолонки)
	ПредставлениеНомерКолонки = СписокКолонок[НомерКолонки].Представление;
	ПредставлениеНовыйНомерКолонки = СписокКолонок[НовыйНомерКолонки].Представление;
	НовоеЗначениеКолонки = СписокКолонок[НовыйНомерКолонки].Значение;
	
	СписокКолонок[НомерКолонки].Представление = ПредставлениеНовыйНомерКолонки; 
	СписокКолонок[НовыйНомерКолонки].Представление = ПредставлениеНомерКолонки; 
	
	Если НовыйНомерКолонки > НомерКолонки Тогда
		Элементы.СписокКолонок.ТекущаяСтрока = Элементы.СписокКолонок.ТекущаяСтрока + 1;
	Иначе	
		Элементы.СписокКолонок.ТекущаяСтрока = Элементы.СписокКолонок.ТекущаяСтрока - 1;
	КонецЕсли;	 
	
	ПоменятьКолонкиМестамиСервер(НомерКолонки, НовыйНомерКолонки);
	
КонецПроцедуры 

&НаСервере
Процедура ПоменятьКолонкиМестамиСервер(НомерКолонки, НовыйНомерКолонки)
	
	ТаблицаНаФормеСервер = РеквизитФормыВЗначение("ТаблицаНаФорме");
	
	Для Каждого СтрокаТаблицаНаФормеСервер Из ТаблицаНаФормеСервер Цикл
		ПервоеЗначение = СтрокаТаблицаНаФормеСервер[НомерКолонки];
		ВтороеЗначение = СтрокаТаблицаНаФормеСервер[НовыйНомерКолонки];
		
		СтрокаТаблицаНаФормеСервер[НомерКолонки] = ВтороеЗначение;
		СтрокаТаблицаНаФормеСервер[НовыйНомерКолонки] = ПервоеЗначение;
	КонецЦикла;	
	
	ЗначениеВРеквизитФормы(ТаблицаНаФормеСервер,"ТаблицаНаФорме"); 
	МассивСтрок = ПолучитьМассивСтрокПослеРедактирования();
	ЗагрузитьТаблицуСервер(МассивСтрок);
	
КонецПроцедуры 

#КонецОбласти

