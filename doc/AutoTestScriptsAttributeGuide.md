# AutoTest Scripts Attribute Guide
Для того чтобы ускорить/упростить написание и поддержку автотестов командой SVT было принято решение для новых компонент и компонент которые перерабатываються/обновляються добавлять аттрибуты к ключевым элементам.

1) Если в Jira Story указаны значения аттрибутов для элементов UI к примеру my_participants-add_new_participant_button  
2) Нужно добавить в соответствующий элемент аттрибут data-gtm с указанным значением
`<button class="apollo-btn primary" onclick="{!c.doAddNewParticipant}" data-gtm="my_participants-add_new_participant_button">{!$Label.c.BTN_Add_NewParticipant}</button>` 

Naming convetion:

- BTN_XXX - button, обозначение кнопок 
- DDL_XXX - drop down list, обозначение пиклистов
- FLD_XXX - field, поле ввода
- NAV_XXX - navigation, навигация
- PNL_XXX - panel, панель
- LNK_XXX - link, ссылка
- CBX_XXX - checkbox, чекбокс
- RDO_XXX - radio button
- LKP_XXX - lookup (RRSearchAbstract, webLookup)
- TGL_XXX - toggle


Если нужного обозначения нет в списке то нужно его придумать и добавить в этот документ