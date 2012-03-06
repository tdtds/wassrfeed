# wassrfeed - RSS feedの内容をWassrのヒトコトへ流す

パラメタに与えたURLからfeedを取得して、その内容をWassrに流します。現在サポートしているfeedはほぼTwitterのみです(ようするにTwitterのつぶやきをWassrに転送するのが目的)。

## How to Install
gemでインストールできます:

    % gem install wassrfeed

## How to Use
TwitterのRSS feedをパラメタに与えて実行します:

    % wassrfeed https://twitter.com/statuses/user_timeline/EXAMPLE.rss

"EXAMPLE"にTwitterのユーザ名を指定することで、そのユーザのtweetを取得できます。

参考→[TwitterのRSSフィードを取得したい場合](http://memorandum.char-aznable.com/web_service/twitter-rss.html)

cron等で、2分間隔くらいで回すと良いでしょう。前回の状態を記録しておくので、次の実行では追加分のみを流します。

----

Copyright (C) 2009 TADA Tadashi <t@tdtds.jp> / You can redistribute it and/or modify it under GPL.
