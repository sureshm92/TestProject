1)	В идеале использовать IDE IntelliJ Idea + Illuminated cloud (Web Storm + Illuminated Cloud)
2)	Настроить редактор чтобы он автоматом добавлял автора
3)	Настроить редактор чтобы знаки табуляции заменялись на пробелы, иногда знаки табуляции некорректно отображаются
4)	 В хелпер выносим только то, что многократно используем, иначе логику оставляем в action контроллера
5)	В разметке компонента группируем элементы, разделяя небольшими комментариями
атрибуты, хендлеры, методы и тп
примерно так:


```html
<!--
 - Created by Leonid Bartenev
 -->

<aura:component description="TasksTab" controller="TasksRemote">

    <!-- attributes: -->
    <aura:attribute name="taskMode" type="String" default="{!$Label.c.Task_Tab_Open_Tasks}"/>
    <aura:attribute name="openTasks" type="Object[]"/>
    <aura:attribute name="completedTasks" type="Task[]"/>
    <aura:attribute name="emptyTaskLabel" type="String"/>
    <aura:attribute name="initialized" type="Boolean" default="false"/>

    <!-- handlers: -->
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>

    <!-- component body: -->
    <c:RRSpinner aura:id="spinner" size="medium" fixed="true" showSpinner="true"/>
    <aura:if isTrue="{!v.initialized}">
    ....
```


6)	Серверный контроллер называем с окончанием Remote, если назвать с окончанием Controller то может возникнуть кофликт имен если совпадут имена у методов в JS  и серверном контроллере компонента.
7)	UI компоненты, которые можно многократно использовать типа диалоги, бары, кнопки, панели, табы и тп назваем с префикса RR (так сложилось), например RRIcon, RRPanel, RRLink и тд

8)	вызов логики сервера осуществляем через communityService.executeAction, сам удаленный метод должен ловить ошибки и при их возникновении выбрасывать AuraHandledException, пример обработки ошибок в удаленном контроллере:

 ```js
 try {
    //your logic here..
}catch (Exception e){
    AuraHelper.throwException(e);
}
```

Обработка ошибок должна происходить именно в таком виде, тогда в связке с communityService.executeAction будет прочитан ответ с ошибкой, записан стектрейс ошибки в консоль браузера и выведен алерт с сообщением.
пример вызова метода сервера(передается ссылка на компонент, имя метода в серверном контроллере, параметры которые надо передать в метод, колбэк с результатом, опционально колбэк обработки ошибки, опционально колбэк финальных действий):

 ```js
 communityService.executeAction(component, 'completeTask', {
    taskId: taskId
}, function (participantTasks) {
    helper.updateTasks(component, participantTasks);
}, null, function () {
    component.find('spinner').hide();
});
```

9)	Часто используемые компоненты:
- RRSpinner - если задан параметр fixed="true" тогда рисует спиннер в пределах всего окна, если не задан то в пределах ближайшего элемента с position:relative, спиннеру лучше давать aura:id="spinner" и в логике показывать и скрывать через методы show/hide, примерно так:
component.find('spinner').hide();
- RRLink - ссылка, можно указать как URL так и просто имя страницы (параметр page)
- RRTopBar - заголовок страницы вида: (edited) 
- Popup - диалоговое окно, название кривое и по идее должен иметь префикс RR но так сложилось, уже менять поздно, много где используется
- Другие компоненты с префиксом RR
10)	По наличию реализованных компонентов предлагаю смотреть на существующий UI, если что-то подобное там есть то возможно это уже реализовано, по этому было бы хорошо пробежаться по функционалу Referral Hub и посмотреть на элементы UI чтобы не изобретать велосипед и сохранять целостность интерфейса во всем портале. Всегда можно написать мне я подскажу есть уже что-то подобное или нет

11)	При разработке новых компонентов предлагаю сначала оценить UI новых элементов на мокапах и выделить общие блоки в отдельные компоненты, вместо дублирования разметки в каждом специализированном компоненте 

12)	Писать компоненты нужно сразу с адаптивной разметкой, для это можно использовать SLDS Grid, Lightning layout или чистый CSS Flexbox (знание СSS Flexbox must have! Вот ссылка: https://html5book.ru/css3-flexbox Изучить  обязательно!)



