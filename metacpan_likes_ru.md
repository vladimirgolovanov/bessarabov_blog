# Как узнать кто залайкал Perl дистрибутив на metacpan?

date_time: 2014-05-10 14:45:26 MSK

## Задача

На metacpan можно лайкать дистрбутивы. Вот, например, у моего дистрибутива
[Test::Whitespaces][tw] есть 2 лайка:

 ![Лайки на metacpan][metacpan_likes]

Мне стало интересно узнать кто поставил эти лайки. <del>На сайте metacpan
такой информации нет</del> (update: после написания поста эта информация
появлиась, подробности в конце поста), но есть API через которое наверняка
можно это сделать.

## Первый подход к решению

Сходу задачу решить не удалось. У API есть [документация][docs], есть
[какие-то модули][metacpan_modules], есть чудесный сайт
[explorer.metacpan.org][explorer], но как все это использовать совершенно не
ясно.

В начале [документации][docs] есть ссылка на [доклад Olaf Alders про
API][video], я решил посмотреть этот доклад чтобы разобраться как использовать
API.

Доклад оказался очень интересным (и после него мне удалось решить мою задачу),
я записал тезисы из этого доклада.

## Конспект доклада

Доклад Олафа Алдерса (Olaf Alders) "(Ab)using the MetaCPAN API for Fun and
Profit".

 * [видео][video]
 * [слайды][slides]

 * metacpan api использует elasticsearch
 * elasticsearch стали использовать достаточно случайно, но оказалось что это
   хороший выбор
 * можно использовать metacpan api и без знания elasticsearch
 * elasticsearch — есть сущности indexes & types
 * в терминах привычных баз данных — index = database; type = table
 * скриншотик как связаны разные types:

![Связь типов][types_img]

 * every type has corresponding endpoint (примеры, урлы: /author, /release)
 * базовый url апишечки — https://api.metacpan.org/v0/
 * /v0 в базовом урле чтобы можно было без проблем выкатывать новое api
   с потерей совместимости (пока таких планов нет, но может понадобится в
   будущем)
 * есть 2 типа ручек: elasticsearch endpoint и convinient endpoint
   ("convinient endpoint" — это ручка которая работает не по протоколу
   elasticsearch)
 * т.е. у всех types есть elasticsearch endpoint, но не у каждного endpoint
   есть соответствующий type
 * Примеры convinient endpoints (types таких нет (я это не понял: author и
   pod есть на скриншоте со списком types)):
    * /author/DOY
    * /distribution/Moose
    * /release/Moose
    * /module/Moose
    * /pod/Moose
    * /search/autocomplete?q=Moose
    * /search/reverse_dependencies/Moose
 * Примеры Versioned Convenience Endpoints
    * /release/DOY/Moose-2.0001
    * /module/DOY/Moose-2.0001/lib/Moose.pm
    * /pod/DOY/Moose-2.0001/lib/Moose.pm
    * /search/reverse_dependencies/DOY/Moose-2.0001
 * Convenience endpoints в общем случае могут не соблюдать DSL elasticsearch.
   Пример — /pod/DOY/Moose-2.0001/lib/Moose.pm, эта ручка вообще возвращает
   не json (Раньше ручка отдавала json, но потому поняли что в этом нет
   никакого смысла, это лишь все усложняет, поэтому json убрали)
 * Ручка /pod может возвращать данные в разных форматах:
    * /pod/Moose?content-type=text/html (default)
    * /pod/Moose?content-type=text/plain
    * /pod/Moose?content-type=text/x-pod
    * /pod/Moose?content-type=text/x-markdown
 * Для ручки /pod content-type можно указывать как в урле, так и в хедере
 * В качестве примера потребителя ручки /pod рассказал про сайт
   [perlybook.org](http://perlybook.org) на котором можно скачать POD любого
   дистрибутива в виде файла .mobi, .epub (я попробовал что-то сгрузить, но
   маковские версии iBooks и Kindle не смогли открыть эти файлы)
 * elasticsearch endpoints
    * /author
    * /distribution
    * /favorite
    * /ﬁle
    * /rating
    * /release
 * Ручки /module нет, так как ее функционал реализован в /file
 * One special endpoint /user (need to be logged in) (У меня почему-то
   эта ручка возвращает {}, хотя я залогинен на metacpan.org — в презентации
   Олаф говорил про какой-то токен, но я не понял как его получить)
 * Олаф говорит что с документацией все плохо и одна из целей этого доклада —
   это, как раз, рассказать про базовые принципы
 * Инструменты для исследования API — [explorer.metacpan.org][explorer]
 * Со многих страниц metacpan есть ссылки на explorer
 * Интересная маленькая история. Изначально в профиле пользователя на
   metacpan была только одна textarea, куда можно было вбивать free form text
   (она и сейчас там есть), авторы metacpan смотрели что туда люди вбивают
   и постепенно формализовывали эти данные — добавляли новые поля в которые
   пользователи могут вписывать свои данные.
 * У всех elasticsearch ручек есть возможность посмотреть mapping —
   /author/_mapping (это как show create table в sql). Это фича
   elasticsearch, но даже тем кто не очень разбирается в elasticsearch эта
   ручка будет полезна — можно посмотреть названия полей.
 * Еще одна полезная штука, которая есть у elasticsearch ручек — это
   /favorite/_search — это как "select * ... limit 10" в sql.
 * [Исходники ручек](https://github.com/CPAN-API/cpan-api/blob/master/lib/MetaCPAN/Document/Author.pm)
 * Олаф просит использовать gzip при работе с API — это снижает нагрузку на
   них
 * Рекомендация использовать GET только для простых запросов, использовать
   POST для сложных, так как POST запросы проще формировать и изменять.
 * Сначала у них не было ограничения на API, но их слишком активно
   использовали, поэому сделали ограничение что за раз можно получить не
   более 5000 элементов. Чтобы получить больше используется scrolling API —
   В модуле MetaCPAN::API реализовано это scrolling API таким образом что он
   нем не нужно думать при использовании этого модуля.
 * Для знающих elasticsearch. Рекомендуется для общения с metacpan API
   использовать filter, а не query.
 * [Примеры работы с API](https://github.com/cpan-api/metacpan-examples)
   Начинать лучше с author — там самые простые примеры. В презентации Олаф
   немножко пояснил почти все примеры из папки "scripts/by-topic"
 * У них есть [vagrant виртуалка][vagrant], с помощью которой можно локально у себя
   поднять инстанс metacpan api сервера
 * Единственное правило использования API — be polite
 * Просят представится — записать конатктуню информацию + useragent на
   [вики](https://github.com/CPAN-API/cpan-api/wiki/API-Consumers)

PS В докладе упоминался модуль [MetaCPAN::API](https://metacpan.org/pod/MetaCPAN::API),
но сейчас он уже depreated и рекомендуется использовать вместо него
[MetaCPAN::Client](https://metacpan.org/pod/MetaCPAN::Client).

## Второй подход к решению

После просмотра доклада у меня появилось достаточно данных для того чтобы
решить мою задачу и получить список пользователь кто залайкал мой дистрибутив.

[Скрипт с решением][solution]

Вот вывод скрипта:

    # Who likes 'Test-Whitespaces'?

     * DOHERTY
     * ???

Скрипт сначала запрашивает Metacpan API "а покажи-ка мне id всех пользователей
кто залайкл дистрибутив" с помощью отправки
[запроса](https://gist.github.com/bessarabov/fa4f651837dc2200e076) на ручку
"/v0/favorite". Получаем [ответ](https://gist.github.com/bessarabov/9b2883c5e13f9ff3b3e1).
В отвече куча шума который дает elasticsearch, но есть данные о id
пользователей: "user": "faLMeoWDRjSethSZIGNB_A" и "user": "6wlW4wIgQW6QK_-YU0uxFw".

А дальше скрипт для каждого полученного id пользователя выясняет что это за
пользователь. [Запрос](https://gist.github.com/bessarabov/15e9e27c18a7691e5096)
на ручку "/v0/author" и [ответ](https://gist.github.com/bessarabov/436f2e5a05d24dabe07d).

Почему-то не у для всех id пользователей соответстует находится запись в type
author, если скрипт не находит данных, то выдает "???".

## Update 2014-05-14

Это очень смешно, но через несколько дней после написания этого поста на сайте
[metacpan.org][metacpan] появилась возможность просматривать кто залайкал твой
дистрибутив.

Вот [серия комитов, которые добавили эту фичу][commits].

Вот информация о лайках моего модуля [Test::Whitespaces][tw]:

![Лайки Perl модуля Test::Whitespaces][test-whitespaces_img]

 [tw]: https://metacpan.org/pod/Test::Whitespaces
 [types]: https://upload.bessarabov.ru/bessarabov/MRKhWtdrzM2_FqDq7KlyB-fLNv4.png
 [metacpan_likes]: https://upload.bessarabov.ru/bessarabov/DmwJRAAc4lZbga_CkrGVZNX5x_M.png
 [docs]: https://github.com/CPAN-API/cpan-api/wiki/API-docs
 [metacpan_modules]: https://metacpan.org/search?q=metacpan
 [explorer]: http://explorer.metacpan.org
 [video]: http://perltv.org/v/abusing-the-metacpan-api-for-fun-and-profit
 [slides]: http://www.slideshare.net/oalders/abusing-metacpan2013
 [types_img]: https://upload.bessarabov.ru/bessarabov/MRKhWtdrzM2_FqDq7KlyB-fLNv4.png
 [solution]: https://gist.github.com/bessarabov/f62fbf4e0ccc1912738b
 [vagrant]: https://github.com/cpan-api/metacpan-developer
 [metacpan]: https://metacpan.org
 [test-whitespaces_img]: https://upload.bessarabov.ru/bessarabov/QaMDcsHX72RCuElUe5d3dOF1zBg.png
 [commits]: https://github.com/CPAN-API/metacpan-web/compare/5fb5b3f8350cae197c4312ba6cdc71b568445745...db06727c9a6f3707ec6f5c07c4d22d297103cbb4
