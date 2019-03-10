/**
 * Created by Leonid Bartenev
 */

trigger TaskProcess on Task (before insert, before update) {
    TaskTriggerHandler.checkTaskFieldsBeforeInsert();
}