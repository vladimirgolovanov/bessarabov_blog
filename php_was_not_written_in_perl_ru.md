# Первые версии PHP не были написаны на Perl

date_time: 2015-05-28 13:37:45 MSK

Существует мнение что первые версии языка программирования PHP были написаны
на языке Perl.

Этот факт иногда приводят умные люди и иногда об этом пишут в [статьях](https://medium.com/@qfox/%D0%BF%D1%80%D0%B0%D0%B2%D0%B8%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F-%D1%88%D0%B0%D0%B1%D0%BB%D0%BE%D0%BD%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F-34d55e3b8dfd#0e13)

Я несколько раз слышал это менение и был уверен что это правда —
действительно, звучит вполне разумно. Плюс мне приятно было думать что
мой любимый язык программировая Perl был использованл таким образом.

16 мая 2015 года Иван Сережкин на Perl конференции YAPC::Russia выступал
с докладом «[Долгая история перла](http://event.yapcrussia.org/yr2015/talk/323)».
В этом докладе он упомянул что PHP никогда не был написан на Perl, а с самого
начала был написан на си.

Я полез проверять.

[Википедия говорит](https://en.wikipedia.org/wiki/PHP#History) что PHP
изначально был написан в 1994 году на си. Версии 1.0 появилась в 1995 году и
язык тогда назывался "Personal Home Page/Forms Interpreter" или PHP/FI.

Исходики [PHP хостятся на GitHub](https://github.com/php/php-src), но они содержат
историю только с 1999 года. На [странице со списокм релизов PHP](https://php.net/releases/)
все начинается с версии 3.0.x.

С трудом, но мне все-таки мне удалось найти исходный код PHP версии 1.0:
[http://museum.php.net/php1/php-108.tar.gz](http://museum.php.net/php1/php-108.tar.gz).
Для удобства я положил эти файлы [на гитхаб](https://github.com/bessarabov/php1).

Вот однострочник посчитать количество разных файлов в исходном коде PHP
первой версии:

    $ ls -1 | perl -nalE '/(\..*?)$/; say $1' | sort | uniq -c | sort -r
    9 .c
    6 .h
    3

Действительно, никакого Perl кода в PHP версии 1 нет. Первая версия PHP была
написана сразу на си. А история о том что первая версия PHP была написана
на Perl — это всего лишь городская легенда.
