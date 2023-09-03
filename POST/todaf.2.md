Книга «Современный подход к программной архитектуре: сложные компромиссы»
=========================================================================

 
В архитектуре программного обеспечения нет простых решений. Напротив, есть масса сложностей — задач и проблем, для решения которых нет готовых ответов и приходится выбирать между различными компромиссами. Эта книга научит вас критически относиться к компромиссам, связанным с распределенными архитектурами.  
  
Опытные архитекторы Нил Форд, Марк Ричардс, Прамод Садаладж и Жамак Дехгани обсуждают стратегии выбора архитектуры, подходящей для тех или иных случаев. История Sysops Squad — вымышленной группы специалистов — позволяет исследовать все аспекты выбора архитектуры: от определения степени гранулярности сервисов, управления рабочими процессами и оркестрации, разделения контрактов и управления распределенными транзакциями до оптимизации таких операционных характеристик, как масштабируемость, адаптируемость и производительность.  
  

Архитектурная модульность
-------------------------

  
_**Вторник, 21 сентября, 09:33**  
  
Это был тот же конференц-зал, в котором они бывали много раз, но сегодня атмосфера была иной. Совершенно иной. Собравшиеся не вели никаких светских бесед. Стояла тишина. Мертвая тишина, которую, казалось, можно было резать ножом. Да, это действительно уместное клише, учитывая тему встречи.  
Владельцы бизнеса и спонсоры потерпевшего неудачу приложения Sysops Squad, предназначенного для обработки заявок, встретились с архитекторами приложения, Эддисоном и Остином, чтобы выразить свою озабоченность и разочарование по поводу неспособности IT-отдела решить накопившиеся проблемы: «Без действующего приложения, — сказали они, — мы не сможем продолжать поддерживать это направление бизнеса».  
Когда напряженная встреча закончилась, спонсоры тихонько удалились один за другим, оставив Эддисона и Остина одних в конференц-зале.  
— Это была тяжелая встреча, — сказал Эддисон. — Я не могу поверить, что они искренне обвиняют нас во всех проблемах, возникших в приложении. Это действительно плохая ситуация.  
— Да, я знаю, — сказал Остин. — Особенно тяжело было слышать о возможном закрытии бизнес-направления поддержки продуктов. Нас переведут на другие проекты или, что еще хуже, могут даже уволить. Конечно, я предпочел бы проводить все свое время на футбольном поле или кататься на лыжах зимой, но я не могу позволить себе потерять эту работу.  
— Я тоже не могу, — сказал Эддисон. — Кроме того, мне очень нравится сложившаяся у нас команда разработчиков, и не хотелось бы, чтобы она распалась.  
— И я, — сказал Остин. — Я думаю, что разделение приложения на части решит большинство возникших проблем.  
— Согласен с тобой, — сказал Эддисон, — но как нам убедить бизнес потратить деньги и время на рефакторинг архитектуры? Ты видел, с какими лицами они говорили о деньгах, которые мы уже потратили на исправление проблем то тут, то там, только чтобы создать дополнительные проблемы.  
— Ты прав, — сказал Остин. — Они никогда не согласятся на дорогостоящий и трудоемкий рефакторинг архитектуры.  
— Но если мы оба согласны с тем, что приложение нужно разделить, чтобы сохранить его, то как нам убедить бизнес и получить финансирование и время, необходимые для этого? — спросил Эддисон.  
— Ума не приложу, — сказал Остин. — Давай поговорим с Логаном, может быть, он согласится обсудить эту проблему с нами.  
Эддисон заглянул в расписание и увидел, что Логан, ведущий архитектор Penultimate Electronics, свободен. Эддисон отправил сообщение, в котором объяснил, что хочет разбить существующее монолитное приложение, но не знает, как убедить бизнес в том, что это необходимо. Эддисон объяснил в сообщении, что они действительно попали в затруднительное положение и хотели бы обсудить этот вопрос. Логан согласился встретиться с ними и пришел в конференц-зал.  
— Почему вы так уверены, что разделение приложения Sysops Squad решит все проблемы? — спросил Логан.  
— Потому что, — сказал Остин, — мы много раз пытались вносить исправления в код, но это мало помогло. У нас все еще слишком много проблем.  
— Вы совершенно упускаете мою мысль, — сказал Логан. — Хорошо, задам вопрос по-другому. Какие у вас гарантии, что разделение системы приведет к чему-то большему, чем простая трата денег и ценного времени?  
— Ну, — сказал Остин, — на самом деле никаких.  
— Тогда откуда вы знаете, что разделение приложения на части — верное решение? — спросил Логан.  
— Мы уже говорили, — сказал Остин, — потому что все, что мы пробовали, не дает положительного результата!  
— Извините, — сказал Логан, — но вы не хуже меня знаете, что это не оправдание для бизнеса. Вы никогда не получите необходимого финансирования по такой нелепой причине.  
— А что может послужить хорошим обоснованием? — спросил Эддисон. — Как нам преподнести эту идею бизнесу и получить одобрение на дополнительное финансирование?  
— Ну, — сказал Логан, — чтобы создать хорошее экономическое обоснование для подобного масштабного проекта, сначала нужно понять преимущества архитектурной модульности, сопоставить их с проблемами, с которыми вы сталкиваетесь в текущей системе, и, наконец, проанализировать и задокументировать компромиссы, связанные с разделением приложения._  
  
Современные предприятия сталкиваются с потоком перемен; рынок, похоже, продолжает стремительно ускоряться. Бизнес-факторы (например, слияния и поглощения), усиление конкуренции на рынке, увеличение потребительского спроса и расширение инноваций (например, автоматизация с помощью методов машинного обучения и искусственного интеллекта) требуют изменения базовых компьютерных систем. Во многих случаях эти инновации требуют изменений в базовых архитектурах, поддерживающих их.  
  
Однако постоянные и быстрые изменения претерпевают не только предприятия, но и техническая среда, в которой действуют компьютерные системы. Контейнеризация, переход к облачной инфраструктуре, внедрение методологии DevOps и даже новые достижения в конвейерах непрерывной доставки — все это влияет на базовую архитектуру компьютерных систем.  
  
В современном мире сложно управлять всеми этими быстрыми изменениями архитектуры ПО. Она является фундаментом системы, поэтому считается, что должна оставаться стабильной и не подвергаться частым изменениям, подобно основным структурным аспектам больших зданий или небоскребов. Однако, в отличие от архитектуры зданий, программная архитектура должна постоянно меняться и адаптироваться, чтобы соответствовать новым требованиям современной деловой и технологической среды.  
  
Обратите внимание на увеличивающееся количество слияний и поглощений, происходящих на современном рынке. Когда одна компания приобретает другую, она получает не только физические ресурсы поглощенной компании (персонал, здания, инвентарь и т. д.), но и клиентов. Могут ли существующие системы в любой из компаний масштабироваться, чтобы соответствовать количеству пользователей, увеличившемуся в результате слияния или поглощения? Масштабируемость — важная часть слияний и поглощений, так же как гибкость и расширяемость, которые являются архитектурными задачами.  
  
Крупные монолитные (развертываемые как единое целое) системы обычно не обеспечивают уровня масштабируемости, гибкости и расширяемости, необходимого для большинства слияний и поглощений. Машинные ресурсы (потоки выполнения, память и ядра процессора) расходуются очень быстро. Чтобы проиллюстрировать это, рассмотрим стакан с водой (рис. 3.1). Стакан представляет сервер (или виртуальную машину), а вода — приложение. По мере увеличения монолитного приложения, чтобы справиться с растущим потребительским спросом и пользовательской нагрузкой (в результате слияния/поглощения или роста компании), оно начинает потреблять все больше и больше ресурсов. По мере добавления воды (представляющей растущее монолитное приложение) стакан начинает наполняться. Добавление еще одного стакана (еще одного сервера или виртуальной машины) ничего не дает, так как новый стакан сможет вместить столько же воды, что и первый.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/p-pvj7cown7wnewp0a431l8oi7m.png)

  
Одним из аспектов архитектурной модульности является разделение больших монолитных приложений на отдельные более мелкие части. Это делается для того, чтобы обеспечить дальнейшую масштабируемость и рост, что способствует возможности быстрого изменения. Все это, в свою очередь, может помочь компании достигать стратегических целей.  
  
Если в нашем примере добавить еще один пустой стакан и разделить воду (приложение) на две части, то мы сможем перелить половину воды в новый пустой стакан и увеличить общую емкость на 50 %, как показано на рис. 3.2. Аналогия с водой в стакане — отличный способ объяснить архитектурную модульность (разделение монолитных приложений) владельцам бизнеса и руководителям высшего звена, которым придется платить за усилия по рефакторингу архитектуры.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/bhbnsxezlf8qopg5xjgsz7_o5rq.png)

  
Повышенная масштабируемость — только одно из преимуществ архитектурной модульности. Еще одно важное преимущество — гибкость, способность быстро реагировать на изменения. В статье Дэвида Бенджамина (David Benjamin) и Дэвида Комлоса (David Komlos) в журнале Forbes, опубликованной в январе 2020 года (https://oreil.ly/2im3v), говорится:  

> «Есть одно важное отличие, которое делит людей на победителей и проигравших: способность быстро и эффективно вносить смелые и решительные корректировки курса».

  
Бизнес должен быть гибким, чтобы выжить в современном мире. Однако если заинтересованные лица на стороне бизнеса могут быстро принимать решения и менять направление, то технический персонал компании может оказаться не в состоянии достаточно быстро реализовать новые директивы. Чтобы технологии развивались так же быстро, как и бизнес (или, скажем так, чтобы технологии не замедляли бизнес), требуется определенный уровень архитектурной гибкости.  
  

Движущие силы модульности
-------------------------

  
Архитекторы не должны делить систему на мелкие части, если не существует четких бизнес-предпосылок. Основные предпосылки для деления приложений — скорость вывода на рынок (иногда ее называют временем вывода на рынок) и достижение определенного уровня конкурентного преимущества на рынке.  
  
Скорость вывода на рынок достигается за счет гибкости архитектуры — способности быстро реагировать на изменения. Гибкость — составная неотъемлемая характеристика архитектуры, состоящая из многих других характеристик, включая сопровождаемость, тестируемость и развертываемость.  
  
Конкурентное преимущество достигается за счет скорости вывода на рынок в сочетании с масштабируемостью, высокой доступностью и отказоустойчивостью приложений. Чем лучше работает компания, тем быстрее она растет и тем выше потребность в большей масштабируемости, позволяющей поддерживать растущую активность пользователей. Отказоустойчивость (способность приложения восстанавливаться после сбоев и продолжать работать) позволяет обеспечивать нормальное функционирование других частей приложения, когда какой-то компонент терпит сбой, и минимизировать влияние сбоев на конечных пользователей. Диаграмма на рис. 3.3 иллюстрирует взаимосвязь между техническими и бизнес-факторами модульности (обведены рамками).  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/ypeohr49nj-qqocb7vkfebflp8e.png)

  
Компании должны быть гибкими, чтобы выжить на современном быстро и постоянно меняющемся рынке, а это означает, что базовые архитектуры тоже должны быть гибкими. Как показано на рис. 3.3, пятью ключевыми архитектурными характеристиками, обеспечивающими гибкость, скорость вывода на рынок и в конечном счете конкурентное преимущество, являются доступность (отказоустойчивость), масштабируемость, а также развертываемость, тестируемость и сопровождаемость.  
  
Обратите внимание, что архитектурная модульность не всегда должна транслироваться в распределенную архитектуру. Улучшенной сопровождаемости, тестируемости и развертываемости (описываются ниже) можно достичь и в монолитных архитектурах, таких как модульный монолит или даже микроядерная архитектура (список ссылок на дополнительную информацию об этих архитектурных стилях вы найдете в приложении Б). Оба этих архитектурных стиля предлагают некий уровень архитектурной модульности, достигаемый за счет особого структурирования компонентов. Например, в модульном монолите компоненты группируются в правильно сформированные предметные области (домены), что создает так называемую доменную архитектуру (domain partitioned architecture; о ней рассказывается в главе 8 книги [Fundamentals of Software Architecture](https://www.piter.com/collection/all/product/fundamentalnyy-podhod-k-programmnoy-arhitekture-patterny-svoystva-proverennye-metody)). В архитектуре микроядра функциональность делится между подключаемыми компонентами, что позволяет значительно сократить объем тестирования и развертывания.  
  

Сопровождаемость
----------------

  
Под сопровождаемостью понимается простота добавления, изменения или удаления особенностей, а также применения внутренних изменений, таких как исправления, обновления фреймворков, сторонние обновления и т. д. Как и большинство характеристик составной архитектуры, степень сопровождаемости трудно определить объективно. Александр фон Зитцевиц (Alexander von Zitzewitz), архитектор программного обеспечения и основатель hello2morrow (http://www.hello2morrow.com/), написал статью (https://oreil.ly/TbFjN) о новой метрике, позволяющей объективно оценивать сопровождаемость приложения. Метрика фон Зитцевица довольно сложна и включает множество факторов, однако в первоначальной форме выглядела так:  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/6o3srax8tfykh0ql-skv-l9viqa.png)

  
где ML — оценка сопровождаемости всей системы (в процентах от 0 до 100 %), k — общее количество логических компонентов в системе, а ci — уровень связанности любого данного компонента, с особым акцентом на уровни входящих связей. Согласно этому уравнению, чем выше уровень входящей связи между компонентами, тем ниже общая оценка сопровождаемости базы кода.  
  
Если оставить в стороне математику, то среди типичных показателей, с помощью которых определяется относительная сопровождаемость приложения на основе компонентов (архитектурных строительных блоков приложения), можно назвать следующие:  

* связанность (coupling) компонентов — степень взаимосвязанности компонентов и способ, с помощью которого они узнают друг о друге;
* связность (cohesion) компонентов — степень и способ взаимосвязанности операций внутри компонента;
* цикломатическую сложность — общий уровень косвенности и вложенности внутри компонента;
* размер компонента — количество агрегированных операторов кода внутри компонента;
* техническое и предметное разбиение — компоненты, сгруппированные по техническому назначению или по предметной области (см. приложение A).

  
В контексте архитектуры компонент определяется как архитектурный строительный блок приложения, выполняющий какую-либо инфраструктурную или бизнес-функцию, обычно проявляющуюся через структуру пакета (Java), пространство имен (C#) или физическую группировку файлов (классы) в виде некой структуры каталогов. Например, компонент Order History (История заказов) может быть реализован в виде набора файлов классов в пространстве имен app.business.order.history.  
  
Крупные монолитные архитектуры обычно имеют низкий уровень сопровождаемости ввиду технического разбиения функциональности на слои, тесной связанности компонентов и слабой связности компонентов с точки зрения предметной области. Например, представьте, что в традиционной монолитной многоуровневой архитектуре потребовалось добавить дату истечения срока действия для элементов, содержащихся в списке желаний клиента (списке товаров, которые теоретически могут быть приобретены позднее). Обратите внимание на рис. 3.4: область изменения нового требования находится на уровне приложения, поскольку изменение распространяется на все уровни приложения.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/wkt0idnebtucumt1wmnncnc-qr4.png)

  
Это изменение касается применения даты истечения срока действия к элементам списка желаний в монолитной многоуровневой архитектуре. Но в зависимости от структуры команды разработчиков внедрение этого простого изменения может потребовать координации как минимум трех команд:  

* команда, отвечающая за пользовательский интерфейс, должна добавить новое поле для ввода срока действия;
* команда, отвечающая за бизнес-логику, должна реализовать бизнес-правила, связанные с датой истечения срока действия, и изменить контракты для обработки нового поля в интерфейсе;
* команда, отвечающая за базу данных, должна изменить схему и добавить новый столбец со сроком действия в таблицу Wishlist (список желаний).

  
Поскольку предметная область Wishlist охватывает всю архитектуру, поддерживать определенную область или подобласть (например, Wishlist) становится сложнее. Модульные архитектуры, с другой стороны, разбивают области и подобласти на более мелкие, отдельно развертываемые единицы программного обеспечения, упрощая изменение области или подобласти. Обратите внимание, что в архитектуре на основе распределенных сервисов (рис. 3.5) область изменения, касающегося нового требования, находится на уровне предметной области в рамках конкретного сервиса. Это упрощает выделение конкретной единицы развертывания, требующей изменения.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/ofowshjpt-jq3fetpetu0bomsro.png)

  
Переход к еще большей архитектурной модульности, например предлагаемой архитектурой микросервисов, как показано на рис. 3.6, ограничивает область изменения нового требования функциональным уровнем, изолируя изменение в конкретном сервисе, отвечающем за функциональность списка пожеланий.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/gsv5bocbuqwgwq_xv_ywh-ii7fy.png)

  
Эти три шага к модульности демонстрируют, как по мере увеличения уровня архитектурной модульности упрощается сопровождение, что, в свою очередь, упрощает добавление, изменение или удаление функциональности.  
  

Тестируемость
-------------

  
Тестируемость определяется не только легкостью тестирования (обычно с помощью автоматизированных тестов), но также его полнотой. Тестируемость — важная составляющая архитектурной гибкости. Большие монолитные архитектуры, такие как многоуровневая архитектура, трудно поддаются тестированию (и, следовательно, имеют невысокую гибкость) ввиду сложности достижения полного и полноценного регрессионного тестирования всех функций в большой единице развертывания. Монолитное приложение может иметь полный набор регрессионных тестов, но представьте себе разочарование, вызванное необходимостью выполнять сотни или даже тысячи модульных тестов даже в случае простого изменения кода. Мало того, что для выполнения всех тестов требуется много времени, разработчик легко может увязнуть в поисках причин неудачи десятков тестов, хотя на самом деле эти неудачи не имеют ничего общего с изменением.  
  
Архитектурная модульность (разбиение приложений на более мелкие единицы развертывания) значительно сокращает общий объем тестирования новых изменений, что позволяет повысить полноту тестирования, а также упростить его. Модульность не только дает возможность создавать меньшие и более целенаправленные наборы тестов, но и упрощает поддержку модульных тестов.  
  
Архитектурная модульность обычно увеличивает тестируемость, но иногда может приводить к тем же проблемам, которые существуют в монолитных приложениях, развертываемых как единое целое. Например, представьте приложение, которое было разделено на три меньшие автономные единицы развертывания (сервисы), как показано на рис. 3.7.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/jubtfvqeegluulvtt7fu1dho4z0.png)

  
Внесение изменений в сервис A ограничивает область тестирования только этим сервисом, поскольку сервисы Б и В не связаны с сервисом A. Однако по мере расширения взаимодействий между этими сервисами, как показано внизу на рис. 3.7, уровень тестируемости быстро снижается, поскольку область тестирования изменения в сервисе A теперь включает сервисы Б и В, что влияет как на простоту, так и на полноту тестирования.  
  

Развертываемость
----------------

  
Развертываемость подразумевает не только легкость самой этой процедуры, но также ее частоту и общий риск появления сопутствующих ошибок. Чтобы обеспечить высокую гибкость и быстро реагировать на изменения, приложения должны поддерживать все три фактора. Развертывание программного обеспечения каждые две недели (или реже) не только увеличивает общий риск появления ошибок при развертывании (ввиду взаимовлияния нескольких изменений, развертываемых вместе), но и в большинстве случаев приводит к неоправданной задержке новых функций или исправлений ошибок, готовых к отправке клиентам. Конечно, частота развертывания должна быть сбалансирована со способностью заказчика (или конечного пользователя) быстро реагировать на изменения.  
  
С развертыванием связано большое количество церемоний (таких как замораживание кода, тестовые развертывания и т. д.). Как следствие, монолитные архитектуры в общем случае имеют низкий уровень развертываемости. При этом повышается риск того, что что-то может сломаться после развертывания новых функций или исправлений ошибок, а также удлиняется промежуток времени между развертываниями (от недель до месяцев). Приложения с определенным уровнем архитектурной модульности и состоящие из единиц программного обеспечения, развертываемых независимо, требуют меньше церемоний, имеют меньший риск появления ошибок при развертывании и могут развертываться чаще.  
  
Уменьшение размеров сервисов и расширение взаимодействий между ними отрицательно влияет не только на тестируемость, но и на развертываемость. Риск появления ошибок при развертывании увеличивается, и развертывать даже простые изменения становится все труднее, поскольку есть страх нарушить работу других сервисов. Вот что сказал архитектор программного обеспечения Мэтт Стайн (Matt Stine; [www.mattstine.com](https://www.mattstine.com/)) в своей статье об оркестрации микросервисов (https://oreil.ly/e9EGN):  

> «Если микросервисы должны развертываться как полный набор в определенном порядке, то соберите их обратно в монолит и избавьте себя от хлопот».

  
Этот сценарий приводит к тому, что обычно называют «большим комом распределенной грязи», где реализовано очень мало (если они вообще есть) преимуществ архитектурной модульности.  
  

Масштабируемость
----------------

  
Масштабируемость определяется как способность системы оставаться отзывчивой при постепенном увеличении пользовательской нагрузки с течением времени. С масштабируемостью неразрывно связана адаптируемость, которая определяется как способность системы оставаться отзывчивой во время значительных мгновенных и беспорядочных скачков пользовательской нагрузки. Различия между масштабируемостью и адаптируемостью показаны на рис. 3.8.  
  
Обе эти характеристики включают скорость отклика как функцию количества одновременно обрабатываемых запросов (или пользователей в системе), но с точки зрения архитектуры реализуются по-разному. Масштабируемость обычно предполагает работу в течение длительного периода времени и рассматривается как функция нормального роста компании, тогда как адаптируемость представляет собой немедленную реакцию на всплеск пользовательской нагрузки.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/gjd-3angwamws7hbsn4km7ty9_y.png)

  
Отличным примером, иллюстрирующим разницу, может служить система продажи билетов на концерты. Между крупными концертными мероприятиями обычно наблюдается довольно небольшая пользовательская нагрузка. Однако когда в продажу поступают горящие билеты на концерт популярных исполнителей, то пользовательская нагрузка значительно возрастает. Система за считаные секунды может перейти от одновременного обслуживания 20 пользователей к 3000. Чтобы поддерживать отзывчивость, система должна иметь возможность справляться с высокими пиками пользовательской нагрузки и мгновенно запускать дополнительные сервисы, позволяющие обрабатывать всплески трафика. Адаптируемость зависит от сервисов, имеющих малое среднее время запуска (Mean Time To Startup, MTTS), и достигается архитектурно за счет создания очень маленьких, детализированных сервисов. При наличии соответствующего архитектурного решения средним временем запуска (и, следовательно, адаптируемостью) можно дополнительно управлять с помощью методов времени разработки, таких как использование небольших легковесных платформ и сред времени выполнения.  
  
Масштабируемость и адаптируемость улучшаются по мере уменьшения размеров сервисов, но адаптируемость в большей степени зависит от детализации (размера единицы развертывания), а масштабируемость — от модульности (разделения приложений на отдельные единицы развертывания). Возьмем для примера традиционную многоуровневую архитектуру, архитектуру на основе сервисов и архитектуру микросервисов и оценим их уровни масштабируемости и адаптируемости, как показано на рис. 3.9. (Описание этих архитектурных стилей и соответствующие оценки их уровней масштабируемости и адаптируемости можно найти в нашей предыдущей книге [Fundamentals of Software Architecture](https://www.piter.com/collection/all/product/fundamentalnyy-podhod-k-programmnoy-arhitekture-patterny-svoystva-proverennye-metody)). Обратите внимание: здесь одна звезда означает, что архитектурный стиль поддерживает возможность недостаточно хорошо, тогда как пять звезд означают, что возможность является основной функцией архитектурного стиля и хорошо поддерживается.  
  

![image](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/j4jmckaffsyugsdylpu8wyk8em0.png)

  
Как можно заметить, монолитная многоуровневая архитектура имеет относительно низкий уровень масштабируемости и адаптируемости. Крупные монолитные многоуровневые архитектуры сложно и дорого масштабировать, поскольку масштабироваться должны все функциональные возможности в одинаковой степени (масштабируемость на уровне приложения и плохое среднее время запуска). Масштабировать такие приложения в облачных средах может стоить особенно дорого. Но обратите внимание, что в архитектуре на основе сервисов улучшение адаптируемости отстает от масштабируемости. Это связано с тем, что предметные сервисы имеют крупномодульную структуру, обычно включают всю предметную область в одну единицу развертывания (например, обработка заказов или управление складом). Кроме того, как правило, из-за большого размера эти сервисы имеют слишком большое среднее время запуска (MTTS), что не позволяет быстро реагировать на всплески (масштабируемость на уровне предметной области и посредственное среднее время запуска). А вот при использовании микросервисов масштабируемость и адаптируемость максимальны ввиду узкой специализации и небольшого размера каждого отдельно развертываемого сервиса (масштабируемость на уровне функций и отличное среднее время запуска).  
  
Так же как в случае с тестируемостью и развертываемостью, чем больше сервисов вовлекается во взаимодействия в целях выполнения одной бизнес-транзакции, тем сильнее отрицательное влияние на масштабируемость и адаптируемость. По этой причине важно свести к минимуму синхронные взаимодействия между сервисами, когда требуется высокий уровень масштабируемости и адаптируемости.  
  

Доступность/отказоустойчивость
------------------------------

  
Как и многие характеристики архитектуры, отказоустойчивость имеет различные определения. В контексте архитектурной модульности отказоустойчивость определяется как способность некоторых частей системы оставаться отзывчивыми и доступными при выходе из строя других частей системы. Например, если произойдет фатальная ошибка (такая как нехватка памяти) в части приложения розничной торговли, обрабатывающей платежи, то пользователи системы должны по-прежнему иметь возможность искать товары и размещать заказы, даже если обработка платежей недоступна.  
  
Все монолитные системы имеют низкий уровень отказоустойчивости. Отказоустойчивость в монолитной системе можно немного улучшить за счет балансировки нагрузки между несколькими экземплярами приложения, но этот метод и дорог, и неэффективен. Если отказ обусловлен программной ошибкой, то она будет существовать во всех экземплярах и, соответственно, может привести к их отказу.  
  
Архитектурная модульность позволяет обеспечивать отказоустойчивость системы на уровне предметной области и функций. При разделении системы на несколько единиц развертывания катастрофический сбой локализуется в одной единице развертывания, что дает остальным частям системы возможность функционировать как обычно. Однако сразу следует оговориться: если другие сервисы синхронно зависят от сервиса, потерпевшего сбой, то их отказоустойчивость невозможна. Это одна из причин, почему для поддержания хорошего уровня отказоустойчивости в распределенной системе необходимы асинхронные взаимодействия между сервисами.  
  

Сага о Sysops Squad: создание бизнес-обоснования
------------------------------------------------

  
_**Четверг, 30 сентября, 12:01**  
Лучше понимая, что подразумевается под архитектурной модульностью и движущими силами разделения системы, Эддисон и Остин встретились, чтобы обсудить проблемы Sysops Squad и попытаться сопоставить их с движущими силами модульности. Они хотели выработать убедительное бизнес-обоснование, которое можно было представить спонсорам.  
— Давай возьмем каждую из проблем, с которыми мы сталкиваемся, и посмотрим, можно ли сопоставить их с некоторыми движущими силами модульности, — сказал Эддисон. — Так мы сможем продемонстрировать бизнесу, что разделение приложения на части действительно решит проблемы.  
— Хорошая идея, — сказал Остин. — Начнем с первого вопроса, о котором они говорили на встрече, — с изменений. Очевидно, что мы не можем эффективно вносить изменения в одну часть существующей монолитной системы, не вызывая проблем в других ее частях. Кроме того, разработка изменений занимает слишком много времени, а их тестирование — сплошная головная боль.  
— И разработчики постоянно жалуются, что база кода слишком велика и им порой трудно найти подходящее место для применения изменений, добавления новых функций или исправления ошибок, — добавил Эддисон.  
— Точно, — сказал Остин, — здесь ключевым вопросом является общая сопровождаемость.  
— Верно, — сказал Эддисон. — Поэтому, разделив приложение на части, мы не только разделим код, но также изолируем и разделим функциональность на отдельно развертываемые сервисы и упростим внесение изменений для разработчиков.  
— Тестируемость — еще одна ключевая характеристика, связанная с этой проблемой, но мы уже охватили ее благодаря имеющимся у нас автоматическим модульным тестам, — сказал Остин.  
— Не совсем так, — ответил Эддисон. — Взгляни сюда.  
Эддисон показал Остину, что более 30 % тестов закомментированы или объявлены устаревшими, а для некоторых критически важных рабочих процессов в системе тесты вообще отсутствуют. Эддисон также отметил, что разработчики постоянно жалуются на необходимость запускать весь набор модульных тестов для любого изменения (большого или маленького), что не только требует много времени, но и вынуждает исправлять проблемы, не связанные с изменениями. Это одна из причин, почему применение даже самых простых изменений занимает так много времени.  
— Тестируемость подразумевает не только простоту, но и полноту тестирования, — сказал Эддисон. — А у нас нет ни того ни другого. Разделив приложение на части, мы сможем значительно сократить объем тестирования изменений, сгруппировать соответствующие автоматические модульные тесты и добиться большей полноты тестирования, а следовательно, уменьшить количество ошибок. То же относится к развертываемости, — продолжил Эддисон. — Вследствие монолитной организации приложения мы должны развертывать систему целиком, даже в случае исправления небольшой ошибки. Поскольку риск появления ошибок при развертывании у нас очень высок, Паркер настаивает на выпуске новых версий ежемесячно. Однако Паркер не понимает, что, поступая так, мы добавляем в каждый выпуск несколько изменений, которые даже не тестировались совместно друг с другом.  
— Согласен, — сказал Остин, — и, кроме того, пробные развертывания в тестовой среде и замораживание кода, которые мы делаем перед каждым выпуском, отнимают драгоценное время, которого у нас нет. Однако то, о чем мы здесь говорим, — это не проблема архитектуры, а исключительно проблема конвейера развертывания.  
— Не согласен, — сказал Эддисон. — Это определенно проблема архитектуры. Давай порассуждаем. Если мы разделим систему на отдельно развертываемые сервисы, то внесение изменений в любой из них будет ограничено только им. Например, предположим, что мы внесли еще одно изменение в процесс назначения заявок для выполнения. Если этот процесс будет осуществляться отдельным сервисом, то мы не только сократим объем тестирования, но и значительно уменьшим риск появления ошибок при развертывании. А это означает, что мы сможем выполнять развертывания чаще и проводя гораздо меньше церемоний, а также значительно сократим количество ошибок.  
— Я понимаю, что ты имеешь в виду, — сказал Остин. — И хотя я согласен с тобой, но все же осмелюсь утверждать, что в какой-то момент нам также придется изменить существующий конвейер развертывания.  
Уверенные в том, что разделение приложения Sysops Squad и переход на распределенную архитектуру решат проблемы изменений, Эддисон и Остин перешли к другим проблемам, озвученным спонсорами.  
— Итак, — сказал Эддисон, — еще один важный момент, который отметили спонсоры на встрече, — общая удовлетворенность клиентов. Иногда система бывает недоступна, и кажется, что она дает сбой в определенное время в течение дня, из-за чего теряется слишком много заявок и возникают проблемы с их маршрутизацией. Неудивительно, что клиенты начинают отказываться от абонентского обслуживания.  
— Подожди, — сказал Остин, — у меня есть результаты последних наблюдений, которые показывают, что к сбою системы приводит не основная функция приема заявок, а функции получения отзывов от клиентов и отчетности.  
— Отличная новость! — сказал Эддисон. — Значит, выделив эти функции в отдельные сервисы, мы сможем изолировать сбои и сохранить работоспособность основных функций приема заявок. Это само по себе хорошее обоснование!  
— Вот именно, — сказал Остин. — Итак, мы согласны с тем, что увеличение отказоустойчивости решит проблему периодов недоступности приложения для клиентов, поскольку они взаимодействуют только с частью системы, связанной с приемом заявок.  
— А как насчет зависания системы? — спросил Эддисон. — Как решить эту проблему с помощью разделения приложения?  
— Так случилось, что я попросил Сидни из команды разработчиков Sysops Squad провести для меня анализ именно этой проблемы, — сказал Остин. — Оказывается, к зависанию приводят два обстоятельства. Во-первых, система зависает всякий раз, когда появляется более 25 клиентов, создающих заявки одновременно. Во-вторых, система также зависает каждый раз, когда запуск формирования оперативных отчетов в течение дня совпадает с вводом заявок клиентами.  
— Итак, — сказал Эддисон, — похоже, что у нас есть проблемы с масштабируемостью и с нагрузкой на базу данных.  
— В точку! — сказал Остин. — Следовательно, разделив приложение и монолитную базу данных, мы сможем выделить создание отчетов в отдельную систему, а также обеспечить дополнительную масштабируемость для ввода заявок, ориентированную на клиентов.  
Эддисон, удовлетворенный тем, что им удалось написать хорошее обоснование для спонсоров, и уверенный в выборе правильного подхода для сохранения этого направления бизнеса, создал запись в реестре архитектурных решений (ADR), в которой зафиксировал решение разделить систему и создать соответствующее обоснование для спонсоров.  
  
**ADR: миграция приложения Sysops Squad на распределенную архитектуру.**  
  
**Контекст**  
В настоящее время Sysops Squad представляет собой монолитное приложение для обработки заявок на устранение проблем, которое поддерживает множество различных бизнес-функций, включая регистрацию клиентов, ввод и обработку заявок, операционную и аналитическую отчетность, выставление счетов и обработку платежей, а также различные функции административного сопровождения. Текущее приложение имеет множество проблем, связанных с масштабируемостью, доступностью и сопровождаемостью.  
  
**Решение**  
Миграция существующего монолитного приложения Sysops Squad на распределенную архитектуру. Переход к распределенной архитектуре приведет к следующему:  
• сделает основные функции регистрации заявок более доступными для внешних клиентов и тем самым обеспечит повышенную отказоустойчивость;  
• обеспечит повышенную масштабируемость при увеличении количества клиентов, создающих заявки, устранив частые зависания;  
• отделит функциональность отчетности и уменьшит нагрузку на базу данных, устранив частые зависания приложения;  
• позволит командам внедрять новые функции и исправлять ошибки намного быстрее, чем это позволяет текущее монолитное приложение, что обеспечит улучшение общей гибкости;  
• уменьшит количество ошибок, вносимых в систему при добавлении изменений, что обеспечит повышение тестируемости;  
• позволит развертывать новые функции и исправлять ошибки гораздо быстрее (еженедельно или даже ежедневно), что обеспечит повышенную развертываемость.  
  
**Последствия**  
В период миграции на новую архитектуру будет задерживаться внедрение новых функций, поскольку она потребует участия большинства разработчиков.  
  
Миграция повлечет дополнительные затраты (оценка затрат будет определена позже).  
Пока существующий конвейер развертывания не будет изменен, инженеры по выпуску должны будут управлять выпуском и мониторингом нескольких единиц развертывания.  
Миграция потребует разделить монолитную базу данных.  
  
Эддисон и Остин встретились со спонсорами системы заявок Sysops Squad и представили им ясное и короткое обоснование. Спонсоры были довольны презентацией и согласились с подходом, дав разрешение Эддисону и Остину начать миграцию._  
  