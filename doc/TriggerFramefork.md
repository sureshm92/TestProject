# Triggers approach

###### 1) Create a handler with name `<objectName>`Handler
e.g.
```sh
public without sharing class PrepareAdditionalFieldsHandler  extends TriggerHandler {

}
```

###### 2) Override event that you need to handle 
e.g.
```sh
public class PrepareAdditionalFieldsHandler extends TriggerHandler {
        
    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
     
    }
}
```
###### 3) Create static method that handle your business logic: 
e.g.
```sh
public class PrepareAdditionalFieldsHandler extends TriggerHandler {

    public override beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        prepareAdditionalFields(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
    }
}
```
-   trigger example :
```sh
trigger ParticipantEnrollmentTrigger on Participant_Enrollment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(PETriggerHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
    TriggerHandlerExecutor.execute(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
}
```

#### Considerations
- one trigger per Object
- name should be `<objctName>`Trigger
- declaration of the trigger should contains `all events before insert, before update, before delete, after insert, after update, after delete`
```sh
sfdx force:source:push
```
#### examples of usage
e.g.1
```java
Account acc = new Account(Name = 'test');
//prevent running 'after ins' operation again of this triggerhandler  if execution context contains account insert operation
TriggerHandlerExecutor.bypassHandler(AccountTriggerHandler.class, TriggerOperation.AFTER_INSERT);
insert acc;
TriggerHandlerExecutor.clearbypass(AccountTriggerHandler.class)
```
e.g.2
```java
Account acc = new Account(Name = 'test');
//bypass all events
TriggerHandlerExecutor.bypassHandler(AccountTriggerHandler.class);
insert acc;
TriggerHandlerExecutor.clearbypass(AccountTriggerHandler.class);
```
e.g.3 `debug mode `:
```java
 TriggerHandlerExecutor.setDebugMode(true);
Account acc = new Account(Name = 'test');
insert acc;
```
res 
```java
Stats for AccountTriggerHandler:BEFORE_INSERT
13:41:22.2 (408183792)|USER_DEBUG|[198]|DEBUG|Queries used 2
13:41:22.2 (408254162)|USER_DEBUG|[198]|DEBUG|Query rows used 2
13:41:22.2 (408320837)|USER_DEBUG|[198]|DEBUG|Dml statements used 0
13:41:22.2 (408382123)|USER_DEBUG|[198]|DEBUG|Dml rows used 1
```
